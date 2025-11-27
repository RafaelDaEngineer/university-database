-- 1. Measure Raw Query Cost (Take a screenshot!)
EXPLAIN ANALYZE
-- (Paste the content of task52query1.sql here without the "WITH" clause if possible, or just run the file content)
SELECT cl.course_code, ci.instance_id, SUM(pa.planned_hours) -- ... (abbreviated for instructions)
FROM course_instance ci ... -- (Use your full query 1 code);

-- 2. Create Materialized View
CREATE MATERIALIZED VIEW planned_hours_report AS
-- (PASTE THE FULL CONTENT OF task52query1.sql HERE)
WITH CurrentConstants AS ( SELECT * FROM constants ORDER BY constants_id DESC LIMIT 1 )
SELECT 
    cl.course_code AS "Course Code",
    -- ... (The rest of your Query 1 code) ...
FROM course_instance ci
-- ... (The rest of your joins) ...
ORDER BY cl.course_code;

-- 3. Measure View Access Cost (Take a screenshot!)
EXPLAIN ANALYZE
SELECT * FROM planned_hours_report;