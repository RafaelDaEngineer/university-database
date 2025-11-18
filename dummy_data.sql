-- ==========================================
-- 1. INSERT BASE DATA
-- ==========================================

-- Insert CONSTANTS first (UPDATED with starting_from timestamp)
INSERT INTO constants (employee_max_courses, exam_hour_add, exam_hour_mul, adm_hour_add, adm_hour_mul_student, adm_hour_mul_hp, starting_from) 
VALUES (4, 32, 0.725, 28, 0.2, 2, '2025-01-01 00:00:00');

INSERT INTO job_title (job_name) VALUES
('Professor'), ('Lecturer'), ('TA');

INSERT INTO skill_set (skill_name) VALUES
('Databases'), ('Programming'), ('Math');

INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.6), ('Lab', 2.4), ('Seminar', 1.8), ('Examination', 1.0), ('Administration', 1.0);

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
('198001011234', 'Alan', 'Turing', '123 Bletchley St'),
('199002025678', 'Ada', 'Lovelace', '456 Analytical Ave');

INSERT INTO salary_info (start_date, salary) VALUES
('2020-01-01', 80000), ('2021-05-10', 65000);

-- Populate the study_period table
INSERT INTO study_period (study_period_name) VALUES
('P1'), ('P2'), ('P3'), ('P4');

-- ==========================================
-- 2. INSERT DEPENDENT DATA
-- ==========================================

-- Insert department (manager NULL initially)
INSERT INTO department (department_name, department_manager_id) VALUES
('Computer Science', NULL);

-- Insert phone number
INSERT INTO phone_number ("number", person_id) VALUES
('555-1111', (SELECT person_id FROM person WHERE personal_number = '198001011234'));

-- Insert employee (No max_courses column)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
(
  NULL, 
  (SELECT job_id FROM job_title WHERE job_name = 'Professor'),
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
  (SELECT person_id FROM person WHERE personal_number = '198001011234'),
  (SELECT salary_id FROM salary_info WHERE salary = 80000)
);

-- Update department manager
UPDATE department
SET department_manager_id = (SELECT e.employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.personal_number = '198001011234')
WHERE department_name = 'Computer Science';

-- Insert course layouts
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version_start) VALUES
('IV1351', 'Data Storage Paradigms', 50, 250, 7, '2024-01-01 00:00:00'),
('IX1500', 'Discrete Mathematics', 50, 150, 7, '2024-01-01 00:00:00');

-- Insert course instances
INSERT INTO course_instance (num_students, study_year, course_id) VALUES
(
  200, '2025',
  (SELECT course_id FROM course_layout WHERE course_code = 'IV1351')
);

-- ==========================================
-- 3. INSERT LINKING DATA
-- ==========================================

-- Link instance to study period
INSERT INTO course_study (study_period_id, instance_id) VALUES
(
  (SELECT study_period_id FROM study_period WHERE study_period_name = 'P2'),
  (SELECT ci.instance_id FROM course_instance ci
     JOIN course_layout cl ON ci.course_id = cl.course_id
     WHERE cl.course_code = 'IV1351' AND ci.study_year = '2025')
);

-- Assign Alan Turing to course
INSERT INTO employee_course (employment_id, instance_id) VALUES
(
  (SELECT e.employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.personal_number = '198001011234'),
  (SELECT ci.instance_id FROM course_instance ci
     JOIN course_layout cl ON ci.course_id = cl.course_id
     WHERE cl.course_code = 'IV1351' AND ci.study_year = '2025')
);

-- Assign Skill
INSERT INTO employee_skill (skill_id, employment_id) VALUES
(
  (SELECT skill_id FROM skill_set WHERE skill_name = 'Databases'),
  (SELECT e.employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.personal_number = '198001011234')
);


-- ==========================================
-- 4. TEST: MAX 4 COURSES TRIGGER
-- ==========================================

-- Create a Victim (Grace Hopper)
INSERT INTO person (personal_number, first_name, last_name, address) 
VALUES ('190612090000', 'Grace', 'Hopper', 'Navy St 1');

INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
(
  NULL, 
  (SELECT job_id FROM job_title WHERE job_name = 'Professor'), 
  (SELECT department_id FROM department WHERE department_name = 'Computer Science'), 
  (SELECT person_id FROM person WHERE personal_number = '190612090000'), 
  (SELECT salary_id FROM salary_info WHERE salary = 80000)
);

-- Create 5 Test Courses
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version_start) VALUES
('TEST01', 'Trigger Test 1', 10, 100, 7, '2025-01-01'),
('TEST02', 'Trigger Test 2', 10, 100, 7, '2025-01-01'),
('TEST03', 'Trigger Test 3', 10, 100, 7, '2025-01-01'),
('TEST04', 'Trigger Test 4', 10, 100, 7, '2025-01-01'),
('TEST05', 'Trigger Test 5', 10, 100, 7, '2025-01-01');

-- Create Instances
INSERT INTO course_instance (num_students, study_year, course_id)
SELECT 0, '2025', course_id 
FROM course_layout WHERE course_code LIKE 'TEST%';

-- Link to Study Period P1
INSERT INTO course_study (study_period_id, instance_id)
SELECT (SELECT study_period_id FROM study_period WHERE study_period_name = 'P1'), instance_id
FROM course_instance WHERE course_id IN (SELECT course_id FROM course_layout WHERE course_code LIKE 'TEST%');

-- Attempt Assignments (5 times)
-- The first 4 will work. The 5th will FAIL because the trigger reads '4' from the Constants table.

INSERT INTO employee_course (employment_id, instance_id) VALUES (
  (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '190612090000')),
  (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST01')
);

INSERT INTO employee_course (employment_id, instance_id) VALUES (
  (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '190612090000')),
  (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST02')
);

INSERT INTO employee_course (employment_id, instance_id) VALUES (
  (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '190612090000')),
  (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST03')
);

INSERT INTO employee_course (employment_id, instance_id) VALUES (
  (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '190612090000')),
  (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST04')
);

-- THIS SHOULD FAIL
INSERT INTO employee_course (employment_id, instance_id) VALUES (
  (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE personal_number = '190612090000')),
  (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST05')
);