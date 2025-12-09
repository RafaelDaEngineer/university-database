-- demonstrates how to make the "Overloaded Teachers" search run faster by adding specific search shortcuts (indices) to the database. 
-- runs a performance test before and after adding the shortcuts to prove the speed improvement.

-- 1. Measure BEFORE 
EXPLAIN ANALYZE
SELECT 
    e.employment_id,
    COUNT(DISTINCT ec.instance_id)
FROM employee e
JOIN employee_course ec ON e.employment_id = ec.employment_id
JOIN course_instance ci ON ec.instance_id = ci.instance_id
WHERE ci.study_year = '2025'
GROUP BY e.employment_id
HAVING COUNT(DISTINCT ec.instance_id) > 1;

-- 2. Create an Index (Optimization)
-- We index the columns used in JOINs and WHERE clauses
CREATE INDEX idx_course_instance_year ON course_instance(study_year);
CREATE INDEX idx_employee_course_ref ON employee_course(instance_id, employment_id);

-- 3. Measure AFTER 
EXPLAIN ANALYZE
SELECT 
    e.employment_id,
    COUNT(DISTINCT ec.instance_id)
FROM employee e
JOIN employee_course ec ON e.employment_id = ec.employment_id
JOIN course_instance ci ON ec.instance_id = ci.instance_id
WHERE ci.study_year = '2025'
GROUP BY e.employment_id
HAVING COUNT(DISTINCT ec.instance_id) > 1;