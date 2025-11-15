CREATE TABLE course_identity (
 course_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 course_code VARCHAR(50) NOT NULL UNIQUE,
 course_name VARCHAR(50) NOT NULL UNIQUE, 
 PRIMARY KEY (course_id)
);


CREATE TABLE course_layout (
 course_layout_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 course_id INT NOT NULL,
 min_students INT NOT NULL,
 max_students INT NOT NULL,
 hp INT NOT NULL,
 version_start TIMESTAMP NOT NULL, 
 PRIMARY KEY (course_layout_id),
 FOREIGN KEY (course_id) REFERENCES course_identity(course_id)
);


CREATE TABLE department (
 department_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 department_name VARCHAR(100) NOT NULL UNIQUE,
 department_manager INT, 
 PRIMARY KEY (department_id)
 -- no fk cause employee table is not yet created
);


CREATE TABLE job_title (
 job_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 job_title VARCHAR(100) NOT NULL UNIQUE, 
 PRIMARY KEY (job_id)
);



CREATE TABLE person (
 person_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 personal_number VARCHAR(12) NOT NULL UNIQUE,
 first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 address VARCHAR(100) NOT NULL,
 phone_number VARCHAR(20) NOT NULL UNIQUE, 
 PRIMARY KEY (person_id)
);



CREATE TABLE salary_info (
 salary_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 start_date TIMESTAMP NOT NULL,
 salary INT NOT NULL, 
 PRIMARY KEY (salary_id)
);



CREATE TABLE skill_set (
 skill_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 skill_name VARCHAR(50) NOT NULL UNIQUE, 
 PRIMARY KEY (skill_id)
);



CREATE TABLE study_period (
 study_period_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 study_period_name VARCHAR(10) NOT NULL UNIQUE, 
 PRIMARY KEY (study_period_id)
);



CREATE TABLE teaching_activity (
 teaching_activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 activity_name VARCHAR(150) NOT NULL UNIQUE,
 factor FLOAT(10) NOT NULL, 
 PRIMARY KEY (teaching_activity_id)
);



CREATE TABLE course_instance (
 instance_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 num_students INT NOT NULL,
 study_year VARCHAR(4) NOT NULL,
 course_layout_id INT NOT NULL, 
 PRIMARY KEY (instance_id),
 FOREIGN KEY (course_layout_id) REFERENCES course_layout(course_layout_id)
);


CREATE TABLE course_study (
  study_period_id INT NOT NULL,
  instance_id INT NOT NULL,
  PRIMARY KEY (study_period_id, instance_id),
  FOREIGN KEY (study_period_id) REFERENCES study_period(study_period_id),
  FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id)
);


CREATE TABLE employee (
 employment_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 manager INT,
 job_id INT NOT NULL,
 department_id INT NOT NULL,
 person_id INT NOT NULL,
 salary_id INT NOT NULL,
 max_courses INT NOT NULL,
 PRIMARY KEY (employment_id),
 FOREIGN KEY (job_id) REFERENCES job_title(job_id),
 FOREIGN KEY (person_id) REFERENCES person(person_id),
 FOREIGN KEY (salary_id) REFERENCES salary_info(salary_id)
);


CREATE TABLE employee_course (
  employment_id INT NOT NULL,
  instance_id INT NOT NULL,
  PRIMARY KEY (employment_id, instance_id),
  FOREIGN KEY (employment_id) REFERENCES employee(employment_id),
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
  PRIMARY KEY (planned_activity_id),
  FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(teaching_activity_id),
  FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id)
);


CREATE TABLE person_planned (
  planned_activity_id INT NOT NULL,
  employment_id INT NOT NULL,
  PRIMARY KEY (planned_activity_id, employment_id),
  FOREIGN KEY (planned_activity_id) REFERENCES planned_activity(planned_activity_id),
  FOREIGN KEY (employment_id) REFERENCES employee(employment_id)
);


-- ADD FKs after all tables exist:
ALTER TABLE department
  ADD CONSTRAINT fk_department_manager
  FOREIGN KEY (department_manager) REFERENCES employee (employment_id);

ALTER TABLE employee
  ADD CONSTRAINT fk_employee_department
  FOREIGN KEY (department_id) REFERENCES department (department_id);

ALTER TABLE employee
  ADD CONSTRAINT fk_employee_manager
  FOREIGN KEY (manager) REFERENCES employee (employment_id);