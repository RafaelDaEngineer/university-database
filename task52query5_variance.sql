-- QUERY: Variance > 15% between Planned and Allocated Hours
SELECT 
    cl.course_code,
    ci.instance_id,
    SUM(pa.planned_hours) AS "Planned Total",
    COUNT(ep.employment_id) * (SUM(pa.planned_hours)/COUNT(pa.planned_activity_id)) AS "Allocated Estimate", -- Simplified for estimation
    -- Note: A precise calculation requires summing specific employee assignments.
    -- Ideally, we compare Total Planned vs Total Assigned.
    
    ABS(SUM(pa.planned_hours) - (
        SELECT COALESCE(SUM(sub_pa.planned_hours), 0)
        FROM employee_planned sub_ep
        JOIN planned_activity sub_pa ON sub_ep.planned_activity_id = sub_pa.planned_activity_id
        WHERE sub_pa.instance_id = ci.instance_id
    )) AS "Difference",

    CASE 
        WHEN SUM(pa.planned_hours) > 0 THEN
        ROUND(
            ABS(SUM(pa.planned_hours) - (
                SELECT COALESCE(SUM(sub_pa.planned_hours), 0)
                FROM employee_planned sub_ep
                JOIN planned_activity sub_pa ON sub_ep.planned_activity_id = sub_pa.planned_activity_id
                WHERE sub_pa.instance_id = ci.instance_id
            ))::numeric / SUM(pa.planned_hours)::numeric, 2
        )
        ELSE 0
    END AS "Variance Ratio"

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.course_id
JOIN planned_activity pa ON ci.instance_id = pa.instance_id
GROUP BY cl.course_code, ci.instance_id
HAVING 
    CASE 
        WHEN SUM(pa.planned_hours) > 0 THEN
        ABS(SUM(pa.planned_hours) - (
            SELECT COALESCE(SUM(sub_pa.planned_hours), 0)
            FROM employee_planned sub_ep
            JOIN planned_activity sub_pa ON sub_ep.planned_activity_id = sub_pa.planned_activity_id
            WHERE sub_pa.instance_id = ci.instance_id
        ))::numeric / SUM(pa.planned_hours)::numeric
        ELSE 0
    END > 0.15;