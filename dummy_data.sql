-- =================================================================================
-- 1. CLEANUP (Optional - use if you are reloading data)
-- =================================================================================
TRUNCATE TABLE employee_planned, planned_activity, employee_course, employee_skill, 
course_study, course_instance, course_layout, employee, department, phone_number, 
person, salary_info, study_period, teaching_activity, skill_set, job_title, constants RESTART IDENTITY CASCADE;

-- =================================================================================
-- 2. INDEPENDENT LOOKUP TABLES
-- =================================================================================

-- 1. Constants (For Formula Calculations)
INSERT INTO constants (employee_max_courses, exam_hour_add, exam_hour_mul, adm_hour_add, adm_hour_mul_student, adm_hour_mul_hp, starting_from) 
VALUES (4, 32, 0.725, 28, 0.2, 2, '2024-01-01 00:00:00');

-- 2. Job Titles
INSERT INTO job_title (job_name) VALUES
('Department Head'), ('Professor'), ('Ass. Professor'), ('Lecturer'), ('PhD Student'), ('Teaching Assistant');

-- 3. Skills
INSERT INTO skill_set (skill_name) VALUES
('SQL'), ('Java'), ('Python'), ('Project Management');

-- 4. Teaching Activities & Multipliers
-- Matches PDF Table 2 + "Other" for overhead
INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.6), 
('Lab Supervision', 2.4), 
('Tutorial', 2.4),
('Seminar', 1.8), 
('Grading', 1.0), 
('Course Admin', 1.0);

-- 5. Study Periods
INSERT INTO study_period (study_period_name) VALUES
('P1'), ('P2'), ('P3'), ('P4');

-- 6. Salary Bands
INSERT INTO salary_info (start_date, salary) VALUES
('2020-01-01', 85000), -- Prof
('2022-01-01', 55000), -- Lecturer/Ass Prof
('2023-01-01', 32000); -- TA/PhD

-- =================================================================================
-- 3. PEOPLE (Matches PDF Table 5 & 6 Examples)
-- =================================================================================

INSERT INTO person (personal_number, first_name, last_name, address) VALUES
('198001010001', 'Alan', 'Turing', 'Head Office 1'), -- Dept Head
('198505050002', 'Paris', 'Carbone', 'Cloud Lane 10'), -- Ass. Prof
('197903030003', 'Leif', 'Lindbäck', 'Logic Way 42'), -- Lecturer
('199009090004', 'Niharika', 'Gauraha', 'Data Drive 5'), -- Lecturer (Busy teacher)
('199501010005', 'Brian', 'Student', 'Lab Hall 1'), -- PhD
('199801010006', 'Adam', 'Assistant', 'Dorm Room 22'); -- TA

-- =================================================================================
-- 4. DEPARTMENTS & EMPLOYEES
-- =================================================================================

-- 1. Departments
INSERT INTO department (department_name, department_manager_id) VALUES
('Computer Science', NULL),
('Information Systems', NULL);

-- 2. Employees

-- Alan Turing (Head of CS)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
(NULL, 
 (SELECT job_id FROM job_title WHERE job_name = 'Department Head'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE first_name = 'Alan'),
 (SELECT salary_id FROM salary_info WHERE salary = 85000));

-- Update Dept to link back to Turing
UPDATE department SET department_manager_id = 
(SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Alan'))
WHERE department_name = 'Computer Science';

-- Paris Carbone (Ass. Professor, CS)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Alan')),
 (SELECT job_id FROM job_title WHERE job_name = 'Ass. Professor'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE first_name = 'Paris'),
 (SELECT salary_id FROM salary_info WHERE salary = 55000));

-- Leif Lindback (Lecturer, CS)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Alan')),
 (SELECT job_id FROM job_title WHERE job_name = 'Lecturer'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE first_name = 'Leif'),
 (SELECT salary_id FROM salary_info WHERE salary = 55000));

-- Niharika Gauraha (Lecturer, Info Systems - The busy teacher)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Alan')),
 (SELECT job_id FROM job_title WHERE job_name = 'Lecturer'),
 (SELECT department_id FROM department WHERE department_name = 'Information Systems'),
 (SELECT person_id FROM person WHERE first_name = 'Niharika'),
 (SELECT salary_id FROM salary_info WHERE salary = 55000));

-- Brian (PhD)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Paris')),
 (SELECT job_id FROM job_title WHERE job_name = 'PhD Student'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE first_name = 'Brian'),
 (SELECT salary_id FROM salary_info WHERE salary = 32000));

-- Adam (TA)
INSERT INTO employee (manager_id, job_id, department_id, person_id, salary_id) VALUES
((SELECT employment_id FROM employee WHERE person_id = (SELECT person_id FROM person WHERE first_name = 'Paris')),
 (SELECT job_id FROM job_title WHERE job_name = 'Teaching Assistant'),
 (SELECT department_id FROM department WHERE department_name = 'Computer Science'),
 (SELECT person_id FROM person WHERE first_name = 'Adam'),
 (SELECT salary_id FROM salary_info WHERE salary = 32000));

-- =================================================================================
-- 5. COURSES & INSTANCES (Matches PDF Table 4)
-- =================================================================================

-- 1. Course Layouts
INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version_start) VALUES
('IV1351', 'Data Storage Paradigms', 20, 250, 7.5, '2023-01-01'),
('IX1500', 'Discrete Mathematics', 20, 150, 7.5, '2023-01-01'), 
('ID2214', 'Artificial Intelligence', 10, 100, 7.5, '2023-01-01'),
('IV1350', 'Object Oriented Prog', 50, 300, 7.5, '2023-01-01');

-- 2. Course Instances (Current Year 2025)
INSERT INTO course_instance (num_students, study_year, course_id) VALUES
-- IV1351 (P2)
(200, '2025', (SELECT course_id FROM course_layout WHERE course_code = 'IV1351')),
-- IX1500 (P1)
(150, '2025', (SELECT course_id FROM course_layout WHERE course_code = 'IX1500')),
-- ID2214 (P2)
(80,  '2025', (SELECT course_id FROM course_layout WHERE course_code = 'ID2214')),
-- IV1350 (P3)
(120, '2025', (SELECT course_id FROM course_layout WHERE course_code = 'IV1350'));

-- 3. Link Instances to Study Periods
INSERT INTO course_study (study_period_id, instance_id) VALUES
-- IV1351 in P2
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P2'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
-- IX1500 in P1
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P1'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IX1500')),
-- ID2214 in P2 (Overlaps with IV1351)
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P2'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'ID2214')),
-- IV1350 in P3
((SELECT study_period_id FROM study_period WHERE study_period_name = 'P3'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1350'));

-- =================================================================================
-- 6. EMPLOYEE COURSE ASSIGNMENTS (Who is "Allocated" to the course?)
-- =================================================================================

INSERT INTO employee_course (employment_id, instance_id) VALUES
-- Paris, Leif, Niharika, Brian, Adam ALL on IV1351 (Matches PDF Table 5)
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Paris'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Leif'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Niharika'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Brian'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Adam'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351')),

-- Niharika ALSO on IX1500 and ID2214 (To show High Load / Multi-course reports)
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Niharika'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IX1500')),
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Niharika'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'ID2214')),
 
-- Niharika on IV1350 in P3
((SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Niharika'),
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1350'));

-- =================================================================================
-- 7. PLANNED ACTIVITIES (Budgeting Hours)
-- =================================================================================
-- Note: "Planned Hours" * "Factor" = Total Hours seen in the PDF Reports.

-- --- COURSE: IV1351 ---
INSERT INTO planned_activity (planned_hours, teaching_activity_id, instance_id, constants_id) VALUES
-- Lectures: 20h * 3.6 = 72h
(20, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1)),

-- Tutorials: 80h (Planned) * 2.4 = 192h
(80, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Tutorial'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1)),

-- Labs: 40h (Planned) * 2.4 = 96h
(40, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lab Supervision'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1)),

-- Seminars: 80h (Planned) * 1.8 = 144h
(80, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Seminar'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1)),

-- Course Admin (Overhead): 100h * 1.0 = 100h
(100, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Course Admin'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1));

-- --- COURSE: IX1500 (Discrete Math) ---
INSERT INTO planned_activity (planned_hours, teaching_activity_id, instance_id, constants_id) VALUES
-- Lecture: 44h * 3.6 = 158.4h
(44, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Lecture'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IX1500'), 
 (SELECT constants_id FROM constants LIMIT 1));

-- =================================================================================
-- 8. LINKING EMPLOYEES TO PLANNED ACTIVITIES (Allocating the hours)
-- =================================================================================

-- 1. Paris Carbone does the Lectures for IV1351 (All 20h)
INSERT INTO employee_planned (planned_activity_id, employment_id, allocated_hours) VALUES
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Lecture' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Paris'),
 20);

-- 2. Leif and Niharika split Seminars for IV1351 (80h Total -> 40h each)
INSERT INTO employee_planned (planned_activity_id, employment_id, allocated_hours) VALUES
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Seminar' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Leif'),
 40),
 
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Seminar' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Niharika'),
 40);

-- 3. Brian and Adam (TAs) split Labs for IV1351 (40h Total -> 20h each)
INSERT INTO employee_planned (planned_activity_id, employment_id, allocated_hours) VALUES
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Lab Supervision' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Brian'),
 20),

((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Lab Supervision' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Adam'),
 20);

 -- =================================================================================
-- 9. ADDITIONAL DATA FOR "PROPER" REPORTS
-- =================================================================================

-- 1. Add "Grading" as a planned activity for IV1351
INSERT INTO planned_activity (planned_hours, teaching_activity_id, instance_id, constants_id) VALUES
(40, (SELECT teaching_activity_id FROM teaching_activity WHERE activity_name = 'Grading'), 
 (SELECT instance_id FROM course_instance ci JOIN course_layout cl ON ci.course_id = cl.course_id WHERE cl.course_code = 'IV1351'), 
 (SELECT constants_id FROM constants LIMIT 1));

-- 2. Assign "Course Admin" to Paris Carbone (Course Responsible) (100h)
INSERT INTO employee_planned (planned_activity_id, employment_id, allocated_hours) VALUES
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Course Admin' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Paris'),
 100);

-- 3. Assign "Grading" (Exam) to Paris Carbone and Adam (TA) (40h Total -> 20h each)
INSERT INTO employee_planned (planned_activity_id, employment_id, allocated_hours) VALUES
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Grading' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Paris'),
 20),
 
((SELECT planned_activity_id FROM planned_activity pa 
  JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
  JOIN course_instance ci ON pa.instance_id = ci.instance_id
  JOIN course_layout cl ON ci.course_id = cl.course_id
  WHERE ta.activity_name = 'Grading' AND cl.course_code = 'IV1351'),
 (SELECT employment_id FROM employee e JOIN person p ON e.person_id = p.person_id WHERE p.first_name = 'Adam'),
 20);