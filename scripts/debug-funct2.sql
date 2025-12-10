-- for debugging functionality 2
SELECT 
    ta.activity_name, 
    pa.planned_hours AS "Hours Needed (Budget)",
    SUM(ep.allocated_hours) AS "Hours Assigned (Actual)"
FROM planned_activity pa
JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
JOIN course_instance ci ON pa.instance_id = ci.instance_id
JOIN course_layout cl ON ci.course_id = cl.course_id
LEFT JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id
WHERE cl.course_code = 'IV1351' 
  AND ta.activity_name = 'Grading'
GROUP BY ta.activity_name, pa.planned_hours;