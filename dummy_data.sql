-- ---------------------------------------------------------------------------------
-- 1. INSERT CONSTANTS & INDEPENDENT LOOKUP TABLES
-- ---------------------------------------------------------------------------------

-- Insert Constants (Global Config)
INSERT INTO constants (employee_max_courses, exam_hour_add, exam_hour_mul, adm_hour_add, adm_hour_mul_student, adm_hour_mul_hp, starting_from) 
VALUES (4, 32, 0.725, 28, 0.2, 2, '2024-01-01 00:00:00');

-- Insert Job Titles
INSERT INTO job_title (job_name) VALUES
('Department Head'), ('Professor'), ('Lecturer'), ('PhD Student'), ('Teaching Assistant');

-- Insert Skills
INSERT INTO skill_set (skill_name) VALUES
('SQL'), ('Java'), ('Python'), ('Calculus'), ('Algorithms'), ('Systems Design'), ('Technical Writing');

-- Insert Teaching Activities
INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.6), 
('Lab Supervision', 2.4), 
('Seminar', 1.8), 
('Grading', 1.0), 
('Course Admin', 1.0);

-- Insert Study Periods (Matches the ENUM types)
INSERT INTO study_period (study_period_name) VALUES
('P1'), ('P2'), ('P3'), ('P4');

-- Insert Salary Bands
INSERT INTO salary_info (start_date, salary) VALUES
('2020-01-01', 95000), -- Senior/Head
('2021-01-01', 75000), -- Prof
('2022-01-01', 55000), -- Lecturer
('2023-01-01', 35000), -- PhD/TA
('2024-01-01', 30000); -- New Hire

-- ---------------------------------------------------------------------------------
-- 2. INSERT PEOPLE & PHONES (12 Individuals)
-- ---------------------------------------------------------------------------------

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
('191206230000', 'Alan', 'Turing', 'Enigma Way 1'),
('181512100000', 'Ada', 'Lovelace', 'Analytical Engine Blvd'),
('190612090000', 'Grace', 'Hopper', 'Cobol Street 5'),
('193801100000', 'Donald', 'Knuth', 'Algorithm Ave 101'),
('192308230000', 'Edgar', 'Codd', 'Relational Rd 3NF'),
('196912280000', 'Linus', 'Torvalds', 'Penguin Park 1'),
('194901150000', 'Anita', 'Borg', 'System Sisterhood Ln'),
('191604300000', 'Claude', 'Shannon', 'Entropy End 01'),
('193608170000', 'Margaret', 'Hamilton', 'Apollo Drive 11'),
('195506080000', 'Tim', 'Berners-Lee', 'Web World Wide 80'),
('199001010001', 'Junior', 'Dev', 'Intern Alley 404'),
('199001010002', 'Newbie', 'Tester', 'Buggy Lane 500');

-- Insert Phone Numbers
INSERT INTO phone_number ("number", person_id) VALUES
('555-0101', (SELECT person_id FROM person WHERE last_name = 'Turing')),
('555-0102', (SELECT person_id FROM person WHERE last_name = 'Lovelace')),
('555-0103', (SELECT person_id FROM person WHERE last_name = 'Hopper')),
('555-0104', (SELECT person_id FROM person WHERE last_name = 'Torvalds')),
('555-0105', (SELECT person_id FROM person WHERE last_name = 'Hamilton'));

-- ---------------------------------------------------------------------------------
-- 3. INSERT DEPARTMENTS & EMPLOYEES (Circular Logic Handling)
-- ---------------------------------------------------------------------------------

-- A. Insert Departments (Manager is NULL initially)
INSERT INTO department (department_name, department_manager_id) VALUES
('Computer Science', NULL),
('Mathematics', NULL);

-- B. Insert Employees (The Hierarchy)

-- 1. The Boss (Alan Turing) - CS Dept
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
(NULL, -- No manager yet
 (SELECT job_id FROM job_title WHERE job_name = 'Department Head'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE last_name = 'Turing'),
 (SELECT salary_id FROM salary_info WHERE salary = 95000));

-- 2. Senior Professors (Managed by Turing)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Turing')), -- Manager is Turing
 (SELECT job_id FROM job_title WHERE job_name = 'Professor'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE last_name = 'Lovelace'),
 (SELECT salary_id FROM salary_info WHERE salary = 75000)),

((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Turing')),
 (SELECT job_id FROM job_title WHERE job_name = 'Professor'),
 (SELECT department_id FROM department WHERE department_name = 'Mathematics'),
 (SELECT person_id FROM person WHERE last_name = 'Shannon'),
 (SELECT salary_id FROM salary_info WHERE salary = 75000));

-- 3. Lecturers & TAs (Managed by Lovelace or Shannon)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
-- Grace Hopper (Lecturer, CS, Boss: Lovelace)
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Lovelace')),
 (SELECT job_id FROM job_title WHERE job_name = 'Lecturer'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE last_name = 'Hopper'),
 (SELECT salary_id FROM salary_info WHERE salary = 55000)),

-- Edgar Codd (Lecturer, CS, Boss: Lovelace)
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Lovelace')),
 (SELECT job_id FROM job_title WHERE job_name = 'Lecturer'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE last_name = 'Codd'),
 (SELECT salary_id FROM salary_info WHERE salary = 55000)),

-- Linus Torvalds (PhD Student, CS, Boss: Turing)
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Turing')),
 (SELECT job_id FROM job_title WHERE job_name = 'PhD Student'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE last_name = 'Torvalds'),
 (SELECT salary_id FROM salary_info WHERE salary = 35000));

-- C. Update Department Manager (Closing the loop)
UPDATE department
SET department_manager_id = (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Turing'))
WHERE department_name = 'Computer Science';

UPDATE department
SET department_manager_id = (SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE last_name = 'Shannon'))
WHERE department_name = 'Mathematics';


-- ---------------------------------------------------------------------------------
-- 4. COURSES & INSTANCES
-- ---------------------------------------------------------------------------------

INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version_start) VALUES
('IV1351', 'Data Storage Paradigms', 20, 200, 7.5, '2023-01-01'),
('DD1337', 'Advanced Algorithms', 10, 100, 7.5, '2023-01-01'),
('IS1500', 'Operating Systems', 50, 300, 9.0, '2023-01-01'),
('IX1000', 'Discrete Math', 20, 150, 6.0, '2023-01-01');

-- Create Instances for 2025
INSERT INTO course_instance (num_students, study_year, course_id) VALUES
(150, '2025', (SELECT course_id FROM course_layout WHERE course_code = 'IV1351')), -- DB
(80,  '2025', (SELECT course_id FROM course_layout WHERE course_code = 'DD1337')), -- Algos
(200, '2025', (SELECT course_id FROM course_layout WHERE course_code = 'IS1500')); -- OS

-- ---------------------------------------------------------------------------------
-- 5. LINKING TABLES
-- ---------------------------------------------------------------------------------

-- A. Course Study Periods
INSERT INTO course_study (study_period_id, instance_id) VALUES
-- DB in P1
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P1'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
-- Algos in P2
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P2'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'DD1337')),
-- OS in P3
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P3'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IS1500'));

-- B. Employee Skills
INSERT INTO employee_skill (skill_id, employment_id) VALUES
-- Codd knows SQL
((SELECT skill_id FROM skill_set WHERE skill_name = 'SQL'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Codd')),
-- Torvalds knows Systems
((SELECT skill_id FROM skill_set WHERE skill_name = 'Systems Design'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Torvalds'));

-- C. Employee Courses (Staffing)
INSERT INTO employee_course (employment_id, instance_id) VALUES
-- Codd teaches DB (IV1351)
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Codd'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
-- Torvalds teaches OS (IS1500)
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Torvalds'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IS1500'));

-- ---------------------------------------------------------------------------------
-- 6. PLANNED ACTIVITIES (Logic Test)
-- ---------------------------------------------------------------------------------

-- 1. Create a Planned Activity (e.g., 40 hours of Lectures for DB)
INSERT INTO planned_activity (planned_hours, teaching_activity_id, instance_id, constants_id) VALUES
(40,
 (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'),
 (SELECT constants_id FROM constants LIMIT 1));

-- 2. Assign Employee to that Activity (Codd does the lectures)
INSERT INTO employee_planned (planned_activity_id, employment_id) VALUES
((SELECT planned_activity_id FROM planned_activity ORDER BY planned_activity_id DESC LIMIT 1),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Codd'));


-- =================================================================================
-- 7. TRIGGER TEST: MAX 4 COURSES LIMIT
-- =================================================================================
-- 'Grace Hopper' will be assigned 4 dummy courses in Period P4. (5th assignment should fail)

-- 1. Create 5 Test Courses
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version_start) VALUES
('TEST01', 'Trigger Test 1', 10, 100, 7.5, '2025-01-01'),
('TEST02', 'Trigger Test 2', 10, 100, 7.5, '2025-01-01'),
('TEST03', 'Trigger Test 3', 10, 100, 7.5, '2025-01-01'),
('TEST04', 'Trigger Test 4', 10, 100, 7.5, '2025-01-01'),
('TEST05', 'Trigger Test 5', 10, 100, 7.5, '2025-01-01');

-- 2. Create Instances for these courses
INSERT INTO course_instance (num_students, study_year, course_id)
SELECT 0, '2025', course_id 
FROM course_layout WHERE course_code LIKE 'TEST%';

-- 3. Link ALL these instances to Study Period P4
INSERT INTO course_study (study_period_id, instance_id)
SELECT (SELECT study_period_id FROM study_period WHERE study_period_name = 'P4'), instance_id
FROM course_instance WHERE course_id IN (SELECT course_id FROM course_layout WHERE course_code LIKE 'TEST%');

-- 4. Assign Grace Hopper to the first 4 courses (Should Succeed)
INSERT INTO employee_course (employment_id, instance_id)
SELECT 
  (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Hopper'),
  instance_id
FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id 
WHERE cl.course_code IN ('TEST01', 'TEST02', 'TEST03', 'TEST04');

-- 5. Attempt to assign Grace Hopper to the 5th course (Should FAIL)
DO $$
BEGIN
    BEGIN
        INSERT INTO employee_course (employment_id, instance_id) VALUES (
          (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.last_name = 'Hopper'),
          (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'TEST05')
        );
    EXCEPTION WHEN raise_exception THEN
        RAISE NOTICE 'SUCCESS: Trigger correctly blocked the 5th course assignment for Grace Hopper.';
    END;
END $$;