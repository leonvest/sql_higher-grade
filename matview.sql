CREATE MATERIALIZED VIEW mv_teacher_load_per_period AS
SELECT 
    ta.employee_id,
    ci.period_code,
    COUNT(DISTINCT ta.course_instance_id) AS num_courses
FROM teaching_allocation ta
JOIN course_instance ci 
    ON ta.course_instance_id = ci.course_instance_id
GROUP BY ta.employee_id, ci.period_code;
