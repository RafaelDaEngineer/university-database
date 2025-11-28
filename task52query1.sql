-- QUERY 1: PLANNED HOURS PER COURSE INSTANCE
-- takes the first (most recent) constants row
WITH CurrentConstants AS (
    SELECT * FROM constants ORDER BY constants_id DESC LIMIT 1
)
SELECT 
    -- create columns "as"
    cl.course_code AS "Course Code",
    ci.instance_id AS "Instance ID",
    cl.hp AS "HP",
    sp.study_period_name AS "Period",
    ci.num_students AS "# Students",

    -- Activity Columns (Only sum specific activities from the table, the .factor are different for each activity)
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lecture' THEN pa.planned_hours * ta.factor END), 0) AS "Lecture",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Tutorial' THEN pa.planned_hours * ta.factor END), 0) AS "Tutorial",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Lab Supervision' THEN pa.planned_hours * ta.factor END), 0) AS "Lab",
    COALESCE(SUM(CASE WHEN ta.activity_name = 'Seminar' THEN pa.planned_hours * ta.factor END), 0) AS "Seminar",
    
    -- Other Overhead: Exclude Admin/Grading because we use formulas for those below
    COALESCE(SUM(CASE 
        WHEN ta.activity_name NOT IN ('Lecture', 'Tutorial', 'Lab Supervision', 'Seminar', 'Course Admin', 'Grading') 
        THEN pa.planned_hours * ta.factor 
        ELSE 0 
    END), 0) AS "Other Overhead",
    
    -- Admin & Exam 
    ROUND((const.adm_hour_mul_hp * cl.hp) + const.adm_hour_add + (const.adm_hour_mul_student * ci.num_students), 2) AS "Admin",
    ROUND(const.exam_hour_add + (const.exam_hour_mul * ci.num_students), 2) AS "Exam",

    -- Total Sum: Sum of Table Activities (excluding Admin/Grading) + The Two Formulas
    ROUND(
        COALESCE(SUM(CASE 
            WHEN ta.activity_name NOT IN ('Course Admin', 'Grading') 
            THEN pa.planned_hours * ta.factor 
            ELSE 0 
        END), 0) + 
        ((const.adm_hour_mul_hp * cl.hp) + const.adm_hour_add + (const.adm_hour_mul_student * ci.num_students)) +
        (const.exam_hour_add + (const.exam_hour_mul * ci.num_students)), 2
    ) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl ON ci.course_id = cl.course_id
JOIN course_study cs ON ci.instance_id = cs.instance_id
JOIN study_period sp ON cs.study_period_id = sp.study_period_id
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
LEFT JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id
CROSS JOIN CurrentConstants const
WHERE ci.study_year = '2025'
GROUP BY cl.course_code, ci.instance_id, cl.hp, sp.study_period_name, ci.num_students, 
         const.adm_hour_mul_hp, const.adm_hour_add, const.adm_hour_mul_student, const.exam_hour_add, const.exam_hour_mul
ORDER BY cl.course_code;