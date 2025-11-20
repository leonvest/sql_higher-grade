-- =========================================================
-- uppgift1.sql
-- Schema for Course Layout & Teaching Load (higher grade)
-- =========================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS teaching_allocation CASCADE;
DROP TABLE IF EXISTS planned_activity CASCADE;
DROP TABLE IF EXISTS teaching_activity_type CASCADE;
DROP TABLE IF EXISTS course_instance CASCADE;
DROP TABLE IF EXISTS course_layout CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS salary_history CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS period CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS system_setting CASCADE;

-- =========================================================
-- department
-- =========================================================
CREATE TABLE department (
    department_id   INTEGER        PRIMARY KEY,
    department_name VARCHAR(1000)  NOT NULL,
    manager_id      INTEGER        NULL        -- FK added after employee exists
);

-- =========================================================
-- job_title
-- =========================================================
CREATE TABLE job_title (
    job_title_id INTEGER        PRIMARY KEY,
    title        VARCHAR(1000)  NOT NULL
);

-- =========================================================
-- employee
-- =========================================================
CREATE TABLE employee (
    employee_id    INTEGER        PRIMARY KEY,
    employment_id  INTEGER        NOT NULL UNIQUE,
    first_name     VARCHAR(1000)  NOT NULL,
    last_name      VARCHAR(1000)  NOT NULL,
    email          VARCHAR(1000)  NOT NULL,
    phone_number   VARCHAR(30),
    salary         DECIMAL(20,2)  NOT NULL,
    manager_id     INTEGER        NULL,
    department_id  INTEGER        NOT NULL,
    job_title_id   INTEGER        NOT NULL,

    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id),

    CONSTRAINT fk_employee_job_title
        FOREIGN KEY (job_title_id)
        REFERENCES job_title(job_title_id),

    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id)
        REFERENCES employee(employee_id)
);

-- connect department.manager_id → employee.employee_id
ALTER TABLE department
    ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager_id)
    REFERENCES employee(employee_id);

-- =========================================================
-- salary_history  (versioned salaries)
-- =========================================================
CREATE TABLE salary_history (
    salary_history_id INTEGER       PRIMARY KEY,
    valid_from        DATE          NOT NULL,
    valid_to          DATE,
    hourly_rate       NUMERIC(20,2) NOT NULL,
    employee_id       INTEGER       NOT NULL,

    CONSTRAINT fk_salary_history_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
);

-- =========================================================
-- course
-- =========================================================
CREATE TABLE course (
    course_code    VARCHAR(20)    PRIMARY KEY,
    course_name    VARCHAR(1000)  NOT NULL,
    hp             DECIMAL(6,2)   NOT NULL,
    min_students   INTEGER        NOT NULL,
    max_students   INTEGER        NOT NULL,
    department_id  INTEGER        NOT NULL,

    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id)
        REFERENCES department(department_id)
);

-- =========================================================
-- period
-- =========================================================
CREATE TABLE period (
    period_code  VARCHAR(10)    PRIMARY KEY,
    description  VARCHAR(1000)  NOT NULL
);

-- =========================================================
-- course_layout  (versioned layouts)
-- =========================================================
CREATE TABLE course_layout (
    layout_id     INTEGER       PRIMARY KEY,
    course_code   VARCHAR(20)   NOT NULL,
    hp            DECIMAL(6,2)  NOT NULL,
    min_students  INTEGER       NOT NULL,
    max_students  INTEGER       NOT NULL,
    valid_from    DATE          NOT NULL,
    valid_to      DATE,
    version_label VARCHAR(64),

    CONSTRAINT fk_course_layout_course
        FOREIGN KEY (course_code)
        REFERENCES course(course_code)
);

-- =========================================================
-- teaching_activity_type
-- =========================================================
CREATE TABLE teaching_activity_type (
    activity_type_id INTEGER        PRIMARY KEY,
    activity_name    VARCHAR(1000)  NOT NULL,
    factor           DECIMAL(10,2)  NOT NULL
);

-- =========================================================
-- course_instance
-- =========================================================
CREATE TABLE course_instance (
    course_instance_id VARCHAR(20)  PRIMARY KEY,
    year               INTEGER      NOT NULL,
    num_students       INTEGER      NOT NULL,
    course_code        VARCHAR(20)  NOT NULL,
    period_code        VARCHAR(10)  NOT NULL,
    layout_id          INTEGER      NOT NULL,

    CONSTRAINT fk_ci_course
        FOREIGN KEY (course_code)
        REFERENCES course(course_code),

    CONSTRAINT fk_ci_period
        FOREIGN KEY (period_code)
        REFERENCES period(period_code),

    CONSTRAINT fk_ci_layout
        FOREIGN KEY (layout_id)
        REFERENCES course_layout(layout_id)
);

-- =========================================================
-- planned_activity  (identifying: CI + activity_type)
-- =========================================================
CREATE TABLE planned_activity (
    course_instance_id VARCHAR(20)  NOT NULL,
    activity_type_id   INTEGER      NOT NULL,
    planned_hours      INTEGER      NOT NULL,

    CONSTRAINT pk_planned_activity
        PRIMARY KEY (course_instance_id, activity_type_id),

    CONSTRAINT fk_pa_course_instance
        FOREIGN KEY (course_instance_id)
        REFERENCES course_instance(course_instance_id),

    CONSTRAINT fk_pa_activity_type
        FOREIGN KEY (activity_type_id)
        REFERENCES teaching_activity_type(activity_type_id)
);

-- =========================================================
-- teaching_allocation
-- =========================================================
CREATE TABLE teaching_allocation (
    allocation_id      INTEGER       PRIMARY KEY,
    allocated_hours    INTEGER       NOT NULL,
    employee_id        INTEGER       NOT NULL,
    course_instance_id VARCHAR(20)   NOT NULL,
    activity_type_id   INTEGER       NOT NULL,

    CONSTRAINT fk_ta_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id),

    CONSTRAINT fk_ta_course_instance
        FOREIGN KEY (course_instance_id)
        REFERENCES course_instance(course_instance_id),

    CONSTRAINT fk_ta_activity_type
        FOREIGN KEY (activity_type_id)
        REFERENCES teaching_activity_type(activity_type_id)
);

-- =========================================================
-- system_setting  (business constants, e.g. "4 courses")
-- =========================================================
CREATE TABLE system_setting (
    name   VARCHAR(100)  PRIMARY KEY,
    value  NUMERIC(10,2) NOT NULL
);

-- =========================================================
-- End of uppgift1.sql
-- =========================================================
