-- QUERY 2: ACTUAL ALLOCATED HOURS PER TEACHER PER COURSE
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    j.job_name AS "Designation",

    -- Breakdowns using ALLOCATED hours 
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN ep.allocated_hours * ta.factor END), 0) AS "Lecture Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN ep.allocated_hours * ta.factor END), 0) AS "Tutorial Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab Supervision' THEN ep.allocated_hours * ta.factor END), 0) AS "Lab Hours",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN ep.allocated_hours * ta.factor END), 0) AS "Seminar Hours",

    -- "Other" (Any generic activity)
    COALESCE(SUM(CASE 
        WHEN ta.activity_name NOT IN ('Lecture', 'Tutorial', 'Lab Supervision', 'Seminar', 'Course Admin', 'Grading') 
        THEN ep.allocated_hours * ta.factor 
        ELSE 0 
    END), 0) AS "Other Overhead",

    -- Specific Admin/Exam activities assigned to this person
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Course Admin' THEN ep.allocated_hours * ta.factor END), 0) AS "Admin",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Grading' THEN ep.allocated_hours * ta.factor END), 0) AS "Exam",

    -- Total Allocated for this person
    COALESCE(SUM(ep.allocated_hours * ta.factor), 0) AS "Total"

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.course_id
JOIN planned_activity pa ON ci.instance_id = pa.instance_id
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id
JOIN employee e ON ep.employment_id = e.employment_id
JOIN person p ON e.person_id = p.person_id
JOIN job_title j ON e.job_id = j.job_id
WHERE ci.study_year = '2025' 
AND cl.course_code = 'IV1351'
GROUP BY cl.course_code, ci.instance_id, cl.hp, p.first_name, p.last_name, j.job_name
ORDER BY cl.course_code, p.last_name;