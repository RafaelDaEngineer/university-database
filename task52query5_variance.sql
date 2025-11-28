-- QUERY: Variance > 15% between Planned and Allocated Hours
SELECT 
    cl.course_code,
    ci.instance_id,
    
    -- Planned is the Budget (Distinct sum because joining to employees duplicates rows)
    SUM(DISTINCT pa.planned_hours) AS "Planned Total",
    
    -- Allocated is the Sum of actual assignments
    COALESCE(SUM(ep.allocated_hours), 0) AS "Allocated Total",
    
    -- Difference
    SUM(DISTINCT pa.planned_hours) - COALESCE(SUM(ep.allocated_hours), 0) AS "Difference",

    -- Variance Ratio
    CASE 
        WHEN SUM(DISTINCT pa.planned_hours) > 0 THEN
        ROUND(
            ABS(SUM(DISTINCT pa.planned_hours) - COALESCE(SUM(ep.allocated_hours), 0))::numeric 
            / SUM(DISTINCT pa.planned_hours)::numeric, 2
        )
        ELSE 0
    END AS "Variance Ratio"

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.course_id
JOIN planned_activity pa ON ci.instance_id = pa.instance_id
LEFT JOIN employee_planned ep ON pa.planned_activity_id = ep.planned_activity_id
GROUP BY cl.course_code, ci.instance_id
HAVING 
    CASE 
        WHEN SUM(DISTINCT pa.planned_hours) > 0 THEN
        ABS(SUM(DISTINCT pa.planned_hours) - COALESCE(SUM(ep.allocated_hours), 0))::numeric 
        / SUM(DISTINCT pa.planned_hours)::numeric
        ELSE 0
    END > 0.15;