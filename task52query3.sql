-- QUERY 3: TOTAL ALLOCATED HOURS PER TEACHER (CURRENT YEAR)
-- Matches PDF Table 6
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    sp.study_period_name AS "Period",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",

    -- Activity Columns
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab Supervision' THEN pa.planned_hours * ta.factor END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor END), 0) AS "Seminar Hours",
    
    -- Other/Admin/Exam Breakdowns
    COALESCE(SUM(CASE 
        WHEN ta.activity_name NOT IN ('Lecture', 'Tutorial', 'Lab Supervision', 'Seminar', 'Course Admin', 'Grading') 
        THEN pa.planned_hours * ta.factor 
        ELSE 0 
    END), 0) AS "Overhead Hours",

    COALESCE(SUM(CASE WHEN ta.activity_name = 'Course Admin' THEN pa.planned_hours * ta.factor END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Grading' THEN pa.planned_hours * ta.factor END), 0) AS "Exam Total",

    -- Grand Total
    COALESCE(SUM(pa.planned_hours * ta.factor), 0) AS "Total Hours"

FROM employee e
JOIN person p ON e.person_id = p.person_id
JOIN employee_planned ep ON e.employment_id = ep.employment_id
JOIN planned_activity pa ON ep.planned_activity_id = pa.planned_activity_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN course_instance ci ON pa.instance_id = ci.instance_id
JOIN course_layout cl ON ci.course_id = cl.course_id
JOIN course_study cs ON ci.instance_id = cs.instance_id
JOIN study_period sp ON cs.study_period_id = sp.study_period_id
WHERE ci.study_year = '2025'
GROUP BY cl.course_code, ci.instance_id, cl.hp, sp.study_period_name, p.first_name, p.last_name
ORDER BY p.last_name, sp.study_period_name;