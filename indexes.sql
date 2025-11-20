-- =========================================================
-- INDEXES FOR HIGHER GRADE
-- =========================================================

-- Foreign key indexes (PostgreSQL does NOT auto-create these)
CREATE INDEX idx_course_instance_course
    ON course_instance(course_code);

CREATE INDEX idx_course_instance_period
    ON course_instance(period_code);

CREATE INDEX idx_planned_activity_ci
    ON planned_activity(course_instance_id);

CREATE INDEX idx_planned_activity_activity
    ON planned_activity(activity_type_id);

CREATE INDEX idx_teaching_allocation_employee
    ON teaching_allocation(employee_id);

CREATE INDEX idx_teaching_allocation_ci
    ON teaching_allocation(course_instance_id);

CREATE INDEX idx_teaching_allocation_activity
    ON teaching_allocation(activity_type_id);

-- Versioning: helps Query 4 (variance calculation)
CREATE INDEX idx_course_layout_versioning
    ON course_layout(course_code, valid_from, valid_to);

-- High-frequency query optimization
CREATE INDEX idx_employee_period
    ON course_instance(period_code);

CREATE INDEX idx_allocation_employee_period
    ON teaching_allocation(employee_id, course_instance_id);
