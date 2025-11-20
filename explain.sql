EXPLAIN ANALYZE
SELECT 
    ta.employee_id,
    ci.period_code,
    COUNT(DISTINCT ta.course_instance_id)
FROM teaching_allocation ta
JOIN course_instance ci
    ON ta.course_instance_id = ci.course_instance_id
WHERE ci.period_code = 'P2'
GROUP BY ta.employee_id, ci.period_code;
