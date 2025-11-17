-- 1. Insert base data (no FKs)
INSERT INTO job_title (job_name) VALUES
('Professor'),
('Lecturer'),
('TA');

INSERT INTO skill_set (skill_name) VALUES
('Databases'),
('Programming'),
('Math');

INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.6),
('Lab', 2.4),
('Seminar', 1.8),
('Examination', 1.0),
('Administration', 1.0);

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
('198001011234', 'Alan', 'Turing', '123 Bletchley St'),
('199002025678', 'Ada', 'Lovelace', '456 Analytical Ave');

INSERT INTO salary_info (start_date, salary) VALUES
('2020-01-01', 80000),
('2021-05-10', 65000);

INSERT INTO course_identity (course_code, course_name) VALUES
('IV1351', 'Data Storage Paradigms'),
('IX1500', 'Discrete Mathematics');

-- Populate the study_period table from your ENUM
INSERT INTO study_period (study_period_name) VALUES
('P1'), ('P2'), ('P3'), ('P4');

-- 2. Insert dependent data (using subqueries)

-- Insert a department, setting manager to NULL for now
INSERT INTO department (department_name, department_manager_id) VALUES
('Computer Science', NULL);

-- Insert a phone number for 'Alan Turing'
INSERT INTO phone_number (number, person_id) VALUES
('555-1111', (SELECT person_id FROM person WHERE personal_number = '198001011234'));

-- Insert an employee for 'Alan Turing'
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id, max_courses) VALUES
(
  NULL, -- No manager yet
  (SELECT job_id FROM job_title WHERE job_name = 'Professor'),
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
  (SELECT person_id FROM person WHERE personal_number = '198001011234'),
  (SELECT salary_id FROM salary_info WHERE salary = 80000),
  4
);

-- Now, set Alan Turing as the manager of the department
UPDATE department
SET department_manager_id = (SELECT e.employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.personal_number = '198001011234')
WHERE department_name = 'Computer Science';

-- Insert course layouts
INSERT INTO course_layout (course_id, min_students, max_students, hp, version_start) VALUES
(
  (SELECT course_id FROM course_identity WHERE course_code = 'IV1351'),
  50, 250, 7, '2024-01-01 00:00:00'
);

-- Insert course instances
INSERT INTO course_instance (num_students, study_year, course_layout_id) VALUES
(
  200, '2025',
  (SELECT cl.course_layout_id FROM course_layout cl JOIN course_identity ci ON cl.course_id = ci.course_id WHERE ci.course_code = 'IV1351')
);

-- 3. Insert linking table data (all FKs)

-- Link the 'IV1351' instance to period 'P2'
INSERT INTO course_study (study_period_id, instance_id) VALUES
(
  (SELECT study_period_id FROM study_period WHERE study_period_name = 'P2'),
  (SELECT ci.instance_id FROM course_instance ci
     JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
     JOIN course_identity c ON cl.course_id = c.course_id
     WHERE c.course_code = 'IV1351' AND ci.study_year = '2025')
);

-- Assign Alan Turing to the 'IV1351' instance
-- (This is the INSERT that your trigger will check!)
INSERT INTO employee_course (employment_id, instance_id) VALUES
(
  (SELECT e.employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.personal_number = '198001011234'),
  (SELECT ci.instance_id FROM course_instance ci
     JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
     JOIN course_identity c ON cl.course_id = c.course_id
     WHERE c.course_code = 'IV1351' AND ci.study_year = '2025')
);