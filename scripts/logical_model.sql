-- =============================================
-- 1. CONSTANTS TABLE
-- =============================================
CREATE TABLE constants (
 constants_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 employee_max_courses INT NOT NULL,
 exam_hour_add INT NOT NULL,
 exam_hour_mul NUMERIC(4,3) NOT NULL,
 adm_hour_add INT NOT NULL,
 adm_hour_mul_student NUMERIC(2,1) NOT NULL,
 adm_hour_mul_hp INT NOT NULL,
 starting_from TIMESTAMP NOT NULL,
 PRIMARY KEY (constants_id)
);

-- =============================================
-- 2. INDEPENDENT TABLES
-- =============================================

CREATE TABLE job_title (
 job_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 job_name VARCHAR(100) NOT NULL UNIQUE, 
 PRIMARY KEY (job_id)
);

CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 personal_number VARCHAR(12) NOT NULL UNIQUE,
 first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 address VARCHAR(100) NOT NULL,
 PRIMARY KEY (person_id)
);

CREATE TABLE salary_info (
 salary_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 start_date TIMESTAMP NOT NULL,
 salary INT NOT NULL, 
 employment_id INT NOT NULL, -- New Column
 PRIMARY KEY (salary_id),
 FOREIGN KEY (employment_id) REFERENCES employee(employment_id) -- New FK
);

CREATE TABLE skill_set (
 skill_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 skill_name VARCHAR(50) NOT NULL UNIQUE, 
 PRIMARY KEY (skill_id)
);

CREATE TYPE study_period_enum AS ENUM ('P1', 'P2', 'P3', 'P4');

CREATE TABLE study_period (
 study_period_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 study_period_name study_period_enum NOT NULL UNIQUE, 
 PRIMARY KEY (study_period_id)
);

CREATE TABLE teaching_activity (
 teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 activity_name VARCHAR(150) NOT NULL UNIQUE,
 factor NUMERIC(2, 1) NOT NULL,
 PRIMARY KEY (teaching_activity_id)
);

-- =============================================
-- 3. TABLES WITH DEPENDENCIES
-- =============================================

CREATE TABLE course_layout (
 course_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 course_code VARCHAR(20) NOT NULL, -- REMOVED 'UNIQUE' to allow versioning
 course_name VARCHAR(100) NOT NULL, -- also removed UNIQUE
 min_students INT NOT NULL,
 max_students INT NOT NULL,
 hp NUMERIC(2, 1) NOT NULL,
 version_start TIMESTAMP NOT NULL, 
 PRIMARY KEY (course_id)
);

CREATE TABLE department (
 department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 department_name VARCHAR(100) NOT NULL UNIQUE,
 department_manager_id INT,
 PRIMARY KEY (department_id)
);

CREATE TABLE phone_number (
 number_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 "number" VARCHAR(20) NOT NULL UNIQUE,
 person_id INT NOT NULL,
 PRIMARY KEY (number_id),
 FOREIGN KEY (person_id) REFERENCES person(person_id)
);

CREATE TABLE course_instance (
 instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 num_students INT NOT NULL,
 study_year VARCHAR(4) NOT NULL,
 course_id INT NOT NULL, 
 PRIMARY KEY (instance_id),
 FOREIGN KEY (course_id) REFERENCES course_layout(course_id)
);

CREATE TABLE employee (
 employment_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 manager_id INT,
 job_id INT NOT NULL,
 department_id INT NOT NULL,
 person_id INT NOT NULL,
 -- salary_id removed
 PRIMARY KEY (employment_id),
 FOREIGN KEY (job_id) REFERENCES job_title(job_id),
 FOREIGN KEY (person_id) REFERENCES person(person_id)
 -- fk_employee_department and fk_employee_manager_id are added later via ALTER
);

-- =============================================
-- 4. LINKING TABLES
-- =============================================

CREATE TABLE course_study (
  study_period_id INT NOT NULL,
  instance_id INT NOT NULL,
  PRIMARY KEY (study_period_id, instance_id),
  FOREIGN KEY (study_period_id) REFERENCES study_period(study_period_id),
  FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id)
);

CREATE TABLE employee_skill (
  skill_id INT NOT NULL,
  employment_id INT NOT NULL,
  PRIMARY KEY (skill_id, employment_id),
  FOREIGN KEY (skill_id) REFERENCES skill_set(skill_id),
  FOREIGN KEY (employment_id) REFERENCES employee(employment_id)
);

CREATE TABLE planned_activity (
  planned_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
  planned_hours INT NOT NULL,
  teaching_activity_id INT NOT NULL,
  instance_id INT NOT NULL,
  constants_id INT NOT NULL,
  PRIMARY KEY (planned_activity_id),
  FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(teaching_activity_id),
  FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id),
  FOREIGN KEY (constants_id) REFERENCES constants(constants_id)
);

CREATE TABLE employee_planned (
  planned_activity_id INT NOT NULL,
  employment_id INT NOT NULL,
  allocated_hours INT NOT NULL,
  PRIMARY KEY (planned_activity_id, employment_id),
  FOREIGN KEY (planned_activity_id) REFERENCES planned_activity(planned_activity_id),
  FOREIGN KEY (employment_id) REFERENCES employee(employment_id)
);

-- =============================================
-- 5. CIRCULAR FOREIGN KEYS
-- =============================================

ALTER TABLE department
  ADD CONSTRAINT fk_department_manager_id
  FOREIGN KEY (department_manager_id) REFERENCES employee (employment_id);

ALTER TABLE employee
  ADD CONSTRAINT fk_employee_department
  FOREIGN KEY (department_id) REFERENCES department (department_id);

ALTER TABLE employee
  ADD CONSTRAINT fk_employee_manager_id
  FOREIGN KEY (manager_id) REFERENCES employee (employment_id);

-- =============================================
-- 6. TRIGGER FOR MAX COURSE LIMIT (UPDATED)
-- =============================================

CREATE OR REPLACE FUNCTION check_employee_course_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_course_count INT;
    global_max_limit INT;
    target_instance_id INT;
    target_period_id INT;
BEGIN
    -- 1. Get limit
    SELECT employee_max_courses INTO global_max_limit
    FROM constants
    ORDER BY constants_id DESC LIMIT 1;

    -- 2. Find the instance_id for the planned activity being inserted
    SELECT instance_id INTO target_instance_id
    FROM planned_activity
    WHERE planned_activity_id = NEW.planned_activity_id;

    -- 3. Find the study period for that instance
    SELECT study_period_id INTO target_period_id
    FROM course_study
    WHERE instance_id = target_instance_id;

    -- 4. Count DISTINCT courses this employee is already active in for this period
    -- join employee_planned -> planned_activity -> course_study
    SELECT COUNT(DISTINCT pa.instance_id)
    INTO current_course_count
    FROM employee_planned ep
    JOIN planned_activity pa ON ep.planned_activity_id = pa.planned_activity_id
    JOIN course_study cs ON pa.instance_id = cs.instance_id
    WHERE ep.employment_id = NEW.employment_id
      AND cs.study_period_id = target_period_id;

    -- 5. Check limit (If count is already at max AND this is a NEW course for them)
    -- ensure we don't block adding a second activity to a course they are ALREADY in.
    IF current_course_count >= global_max_limit THEN
        -- Check if the course being added is one they're already in.
        -- If NOT, then we are trying to exceed the limit.
        IF target_instance_id NOT IN (
            SELECT pa.instance_id
            FROM employee_planned ep
            JOIN planned_activity pa ON ep.planned_activity_id = pa.planned_activity_id
            JOIN course_study cs ON pa.instance_id = cs.instance_id
            WHERE ep.employment_id = NEW.employment_id
            AND cs.study_period_id = target_period_id
        ) THEN
            RAISE EXCEPTION 'Employee % has reached the max limit of % courses.', NEW.employment_id, global_max_limit;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger now fires on employee_planned not employee_course
CREATE TRIGGER enforce_course_limit
BEFORE INSERT ON employee_planned
FOR EACH ROW
EXECUTE FUNCTION check_employee_course_limit();