


-- Drop tables is in reverse dependency order
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



-- department

CREATE TABLE department (
    department_id   INTEGER        PRIMARY KEY,
    department_name VARCHAR(1000)  NOT NULL,
    manager_id      INTEGER        NULL        -- FK added after employee exists
);




-- job_title

CREATE TABLE job_title (
    job_title_id INTEGER        PRIMARY KEY,
    title        VARCHAR(1000)  NOT NULL
);




-- employee

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


-- (NEW) Ensure department.manager_id references employee(employee_id)
ALTER TABLE department
  ADD CONSTRAINT fk_department_manager
  FOREIGN KEY (manager_id)
  REFERENCES employee(employee_id)
  ON DELETE SET NULL;





-- salary_history  (versioned salaries)

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




-- course

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




-- period

CREATE TABLE period (
    period_code  VARCHAR(10)    PRIMARY KEY,
    description  VARCHAR(1000)  NOT NULL
);




-- course_layout  (versioned layouts)

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




-- teaching_activity_type

CREATE TABLE teaching_activity_type (
    activity_type_id INTEGER        PRIMARY KEY,
    activity_name    VARCHAR(1000)  NOT NULL,
    factor           DECIMAL(10,2)  NOT NULL
);




-- course_instance

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




-- planned_activity  (identifying: CI + activity_type)

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




-- teaching_allocation

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




-- system_setting  (business constants, e.g. "4 courses")

CREATE TABLE system_setting (
    name   VARCHAR(100)  PRIMARY KEY,
    value  NUMERIC(10,2) NOT NULL
);

-- added based on ammendment bullet points 
CREATE OR REPLACE FUNCTION enforce_max_courses_per_period()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_year        INTEGER;
  v_period      TEXT;
  v_limit       INTEGER;
  v_count       INTEGER;
BEGIN
  -- get the year + period for the course instance being allocated
  SELECT ci.year, ci.period_code
    INTO v_year, v_period
  FROM course_instance ci
  WHERE ci.course_instance_id = NEW.course_instance_id;

  IF v_year IS NULL OR v_period IS NULL THEN
    RAISE EXCEPTION 'Invalid course_instance_id: %', NEW.course_instance_id;
  END IF;

  -- read limit from system_setting (fallback to 4 if missing)
  SELECT COALESCE(MAX(value)::INT, 4)
    INTO v_limit
  FROM system_setting
  WHERE name = 'MAX_COURSES_PER_PERIOD';

  -- Count distinct course instances this employee teaches in same year+period
  SELECT COUNT(DISTINCT ta.course_instance_id)
    INTO v_count
  FROM teaching_allocation ta
  JOIN course_instance ci2
    ON ci2.course_instance_id = ta.course_instance_id
  WHERE ta.employee_id = NEW.employee_id
    AND ci2.year = v_year
    AND ci2.period_code = v_period;

  IF v_count > v_limit THEN
    RAISE EXCEPTION
      'Business rule violation: employee % teaches % course(s) in % %, max allowed is %',
      NEW.employee_id, v_count, v_period, v_year, v_limit;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_max_courses_per_period ON teaching_allocation;

CREATE CONSTRAINT TRIGGER trg_max_courses_per_period
AFTER INSERT OR UPDATE OF employee_id, course_instance_id
ON teaching_allocation
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_max_courses_per_period();






-- End of uppg1.sql

