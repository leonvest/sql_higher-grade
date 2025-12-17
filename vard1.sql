
-- vard1.sql
-- Sample data for Course Layout & Teaching Load 


BEGIN;

-- Enforcement of max courses per period based on bullet points. SYSTEM SETTING  (constant "4 courses per period")
INSERT INTO system_setting(name, value) VALUES
  ('MAX_COURSES_PER_PERIOD', 4.00);


-- 1. DEPARTMENTS
INSERT INTO department (department_id, department_name, manager_id) VALUES
  (1, 'Computer Science', NULL),
  (2, 'Mathematics',      NULL),
  (3, 'Electrical Engineering', NULL);



-- 2. JOB TITLES
INSERT INTO job_title (job_title_id, title) VALUES
  (1, 'Lecturer'),
  (2, 'Assistant Professor'),
  (3, 'Professor'),
  (4, 'PhD Student'),
  (5, 'Teaching Assistant');



-- 3. EMPLOYEES
INSERT INTO employee (
  employee_id, employment_id, first_name, last_name, email, phone_number,
  salary, manager_id, department_id, job_title_id
) VALUES
  (1, 500000, 'Dept', 'Manager', 'manager@kth.se',  '+46-70-0000000', 900000.00, NULL, 1, 3),
  (2, 500001, 'Paris', 'Carbone', 'paris.carbone@kth.se', '+46-70-1111111', 750000.00, 1, 1, 2),
  (3, 500004, 'Leif', 'Lindbäck', 'leif.lindback@kth.se', '+46-70-2222222', 650000.00, 1, 1, 1),
  (4, 500009, 'Niharika', 'Gauraha', 'niharika.gauraha@kth.se', '+46-70-3333333', 700000.00, 1, 1, 1),
  (5, 500010, 'Brian', 'Nguyen', 'brian.nguyen@kth.se', '+46-70-4444444', 500000.00, 1, 1, 4),
  (6, 500011, 'Adam', 'Svensson', 'adam.svensson@kth.se', '+46-70-5555555', 400000.00, 1, 1, 5),
  (7, 500012, 'Matte', 'Professor', 'matte.prof@kth.se', '+46-70-6666666', 700000.00, 1, 2, 3);



-- 4. UPDATE DEPARTMENT MANAGERS
UPDATE department SET manager_id = 1 WHERE department_id IN (1,2,3);



-- 5. SALARY HISTORY (versioned salaries)
INSERT INTO salary_history (salary_history_id, valid_from, valid_to, hourly_rate, employee_id) VALUES
  (1, DATE '2023-01-01', NULL,               600.00, 2),  -- Paris
  (2, DATE '2023-01-01', NULL,               520.00, 3),  -- Leif
  (3, DATE '2023-01-01', DATE '2024-12-31',  500.00, 4),  -- Niharika old
  (4, DATE '2025-01-01', NULL,               550.00, 4),  -- Niharika new
  (5, DATE '2023-01-01', NULL,               350.00, 5),  -- Brian
  (6, DATE '2023-01-01', NULL,               300.00, 6),  -- Adam
  (7, DATE '2023-01-01', NULL,               520.00, 7);  -- Matte



-- 6. COURSES
INSERT INTO course (course_code, course_name, hp, min_students, max_students, department_id) VALUES
  ('IV1351', 'Data Storage Paradigms',        7.50, 50, 250, 1),
  ('IX1500', 'Discrete Mathematics',          7.50, 50, 150, 2),
  ('ID2214', 'Advanced Distributed Systems',  7.50, 30, 120, 1),
  ('IV1350', 'Introduction to Databases',     7.50, 50, 200, 1);



-- 7. PERIODS
INSERT INTO period (period_code, description) VALUES
  ('P1', 'Academic Period 1'),
  ('P2', 'Academic Period 2'),
  ('P3', 'Academic Period 3'),
  ('P4', 'Academic Period 4');



-- 8. COURSE LAYOUT VERSIONS (HP & layout versions)
INSERT INTO course_layout (
  layout_id, course_code, hp, min_students, max_students,
  valid_from, valid_to, version_label
) VALUES
  (1, 'IV1351',  7.50, 50, 250, DATE '2024-01-01', DATE '2024-12-31', 'IV1351-2024'),
  (2, 'IV1351', 15.00, 50, 250, DATE '2025-01-01', NULL,               'IV1351-2025'),
  (3, 'IX1500',  7.50, 50, 150, DATE '2025-01-01', NULL,               'IX1500-2025'),
  (4, 'ID2214',  7.50, 30, 120, DATE '2025-01-01', NULL,               'ID2214-2025'),
  (5, 'IV1350',  7.50, 50, 200, DATE '2025-01-01', NULL,               'IV1350-2025');



-- 9. COURSE INSTANCES  (NOTE: all layout_id values are NON-NULL)
INSERT INTO course_instance (
  course_instance_id, year, num_students, course_code, period_code, layout_id
) VALUES
  ('2024-40001', 2024, 180, 'IV1351', 'P1', 1), -- old layout 7.5 HP
  ('2025-50273', 2025, 200, 'IV1351', 'P2', 2), -- new layout 15 HP
  ('2025-50413', 2025, 150, 'IX1500', 'P1', 3),
  ('2025-50341', 2025, 120, 'ID2214', 'P2', 4),
  ('2025-60104', 2025,  90, 'IV1350', 'P3', 5);



-- 10. TEACHING ACTIVITY TYPES
INSERT INTO teaching_activity_type (activity_type_id, activity_name, factor) VALUES
  (1, 'Lecture',   3.60),
  (2, 'Lab',       2.40),
  (3, 'Tutorial',  2.40),
  (4, 'Seminar',   1.80),
  (5, 'Exam',      1.00),
  (6, 'Admin',     1.00),
  (7, 'Other',     1.00);



-- 11. PLANNED ACTIVITIES

-- IV1351, 2025-50273 (P2)
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours) VALUES
  ('2025-50273', 1, 20),
  ('2025-50273', 3, 80),
  ('2025-50273', 2, 40),
  ('2025-50273', 4, 80),
  ('2025-50273', 7, 650),
  ('2025-50273', 6, 177),
  ('2025-50273', 5, 83);



-- IX1500, 2025-50413
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours) VALUES
  ('2025-50413', 1, 44),
  ('2025-50413', 3,  0),
  ('2025-50413', 2,  0),
  ('2025-50413', 4, 64),
  ('2025-50413', 7, 200),
  ('2025-50413', 6, 141),
  ('2025-50413', 5, 73);



-- ID2214, 2025-50341
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours) VALUES
  ('2025-50341', 1, 44),
  ('2025-50341', 3, 36),
  ('2025-50341', 2,  0),
  ('2025-50341', 4,  0),
  ('2025-50341', 7, 40),
  ('2025-50341', 6,  0),
  ('2025-50341', 5, 20);



-- IV1350, 2025-60104
INSERT INTO planned_activity (course_instance_id, activity_type_id, planned_hours) VALUES
  ('2025-60104', 1,  0),
  ('2025-60104', 3, 25),
  ('2025-60104', 2,  0),
  ('2025-60104', 4,  0),
  ('2025-60104', 7,100),
  ('2025-60104', 6,  0),
  ('2025-60104', 5, 74);



-- 12. TEACHING ALLOCATIONS

-- IV1351 (2025-50273)
INSERT INTO teaching_allocation (allocation_id, allocated_hours, employee_id, course_instance_id, activity_type_id) VALUES
  (1, 20, 2, '2025-50273', 1),
  (2,100, 2, '2025-50273', 7),
  (3, 43, 2, '2025-50273', 6),
  (4, 61, 2, '2025-50273', 5),

  (5, 64, 3, '2025-50273', 4),
  (6,100, 3, '2025-50273', 7),
  (7, 62, 3, '2025-50273', 5),

  (8, 64, 4, '2025-50273', 4),
  (9,100, 4, '2025-50273', 7),
  (10,43, 4, '2025-50273', 6),
  (11,61, 4, '2025-50273', 5),

  (12,50, 5, '2025-50273', 2),
  (13,50, 5, '2025-50273', 7),

  (14,50, 6, '2025-50273', 2),
  (15,50, 6, '2025-50273', 4);



-- IX1500 (2025-50413) - Niharika load
INSERT INTO teaching_allocation (allocation_id, allocated_hours, employee_id, course_instance_id, activity_type_id) VALUES
  (16,44, 4, '2025-50413', 1),
  (17,64, 4, '2025-50413', 4),
  (18,100,4, '2025-50413', 7),
  (19,141,4, '2025-50413', 6),
  (20,73, 4, '2025-50413', 5);



-- ID2214 (2025-50341)
INSERT INTO teaching_allocation (allocation_id, allocated_hours, employee_id, course_instance_id, activity_type_id) VALUES
  (21,44, 4, '2025-50341', 1),
  (22,36, 4, '2025-50341', 3),
  (23,40, 4, '2025-50341', 7),
  (24,20, 4, '2025-50341', 5);



-- IV1350 (2025-60104)
INSERT INTO teaching_allocation (allocation_id, allocated_hours, employee_id, course_instance_id, activity_type_id) VALUES
  (25,25, 4, '2025-60104', 3),
  (26,100,4, '2025-60104', 7),
  (27,74, 4, '2025-60104', 5);





COMMIT;
