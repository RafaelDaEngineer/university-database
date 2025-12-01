-- QUERY 5: Variance > 15% between Planned and Allocated Hours
WITH PlannedStats AS (
    -- Calculate Total Planned Hours (with factors) per instance
    SELECT 
        pa.instance_id, 
        SUM(pa.planned_hours * ta.factor) AS total_planned
    FROM planned_activity pa
    JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
    GROUP BY pa.instance_id
),
AllocatedStats AS (
    -- Calculate Total Allocated Hours (with factors) per instance
    SELECT 
        pa.instance_id, 
        SUM(ep.allocated_hours * ta.factor) AS total_allocated
    FROM planned_activity pa
    JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
    JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id
    GROUP BY pa.instance_id
)
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Instance ID",
    COALESCE(ps.total_planned, 0) AS "Planned Total",
    COALESCE(als.total_allocated, 0) AS "Allocated Total",
    
    -- Difference
    COALESCE(ps.total_planned, 0) - COALESCE(als.total_allocated, 0) AS "Difference",

    -- Variance Ratio
    CASE 
        WHEN COALESCE(ps.total_planned, 0) > 0 THEN
            ROUND(
                ABS(COALESCE(ps.total_planned, 0) - COALESCE(als.total_allocated, 0))::numeric 
                / COALESCE(ps.total_planned, 0)::numeric, 2
            )
        ELSE 0
    END AS "Variance Ratio"

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.course_id
-- Join the pre-calculated CTEs
LEFT JOIN PlannedStats ps ON ci.instance_id = ps.instance_id
LEFT JOIN AllocatedStats als ON ci.instance_id = als.instance_id
WHERE ci.study_year = '2025'
GROUP BY cl.course_code, ci.instance_id, ps.total_planned, als.total_allocated
HAVING 
    CASE 
        WHEN COALESCE(ps.total_planned, 0) > 0 THEN
            ABS(COALESCE(ps.total_planned, 0) - COALESCE(als.total_allocated, 0))::numeric 
            / COALESCE(ps.total_planned, 0)::numeric
        ELSE 0
    END > 0.15;