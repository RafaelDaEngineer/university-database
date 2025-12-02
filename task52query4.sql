-- identifies teachers who are assigned to more than a specific number of courses (currently set to 1) 
-- during a single study period. 
-- this helps the university quickly spot potential scheduling conflicts or teachers who might be overworked.

-- QUERY 4: TEACHERS WITH MORE THAN N COURSES IN A PERIOD
SELECT 
    e.employment_id AS "Employment ID",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    sp.study_period_name AS "Period",
    COUNT(DISTINCT ec.instance_id) AS "No of courses"
FROM employee e
JOIN person p ON e.person_id = p.person_id
JOIN employee_course ec ON e.employment_id = ec.employment_id
JOIN course_instance ci ON ec.instance_id = ci.instance_id
JOIN course_study cs ON ci.instance_id = cs.instance_id
JOIN study_period sp ON cs.study_period_id = sp.study_period_id
WHERE ci.study_year = '2025' AND cs.study_period_id = 2
GROUP BY e.employment_id, p.first_name, p.last_name, sp.study_period_name -- collapse to one row per teacher

HAVING COUNT(DISTINCT ec.instance_id) > 1
ORDER BY "No of courses" DESC;