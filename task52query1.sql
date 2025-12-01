-- QUERY 1: PLANNED HOURS PER COURSE INSTANCE
-- generates a report showing the total planned work hours required for every course instance in the current year. 
-- sums up scheduled activities (lectures etc) and uses the math formulas to estimate the time needed for grading 
-- exams and administration.

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
JOIN course_layout cl ON ci.course_id = cl.course_id -- "this course instance, what course_layout is it?"
JOIN course_study cs ON ci.instance_id = cs.instance_id -- "this course instance, what study_period is it?"
JOIN study_period sp ON cs.study_period_id = sp.study_period_id -- "this study_period instance, what study_period is it?"
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id -- "this course instance, what planned_activity is it?" (LEFT JOIN because some course instances may not have planned_activity yet, but we still include those course instances)
LEFT JOIN teaching_activity ta ON pa.teaching_activity_id = ta.teaching_activity_id -- "this planned_activity, what teaching_activity is it?" (LEFT JOIN because some planned_activities may not have teaching_activity yet, but we still include those planned_activities)
CROSS JOIN CurrentConstants const
WHERE ci.study_year = '2025' -- filtering for 
GROUP BY cl.course_code, ci.instance_id, cl.hp, sp.study_period_name, ci.num_students, 
         const.adm_hour_mul_hp, const.adm_hour_add, const.adm_hour_mul_student, const.exam_hour_add, const.exam_hour_mul
ORDER BY cl.course_code;