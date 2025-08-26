-- Bảng cơ quan (Bộ, Sở, UBND, ...)
CREATE TABLE agencies (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,        -- mã viết tắt (VD: BKHCN, BTTTT)
  name TEXT NOT NULL,
  contact_person TEXT,
  contact_email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Bảng nhiệm vụ / chỉ tiêu
CREATE TABLE tasks (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE,                 -- mã nội bộ nhiệm vụ (tùy chọn)
  title TEXT NOT NULL,
  description TEXT,
  unit TEXT,                        -- đơn vị đo lường (vd: %/năm, số đơn)
  target_value TEXT,                -- mục tiêu (lưu text để linh hoạt)
  baseline_value TEXT,              -- giá trị ban đầu
  start_date DATE,
  due_date DATE,
  status TEXT DEFAULT 'not_started', -- not_started, in_progress, completed, delayed
  priority SMALLINT DEFAULT 3,       -- 1 cao ... 5 thấp
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Bảng phân công nhiệm vụ: cơ quan chủ trì & phối hợp
CREATE TABLE task_assignments (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES tasks(id) ON DELETE CASCADE,
  agency_id BIGINT REFERENCES agencies(id) ON DELETE CASCADE,
  role TEXT NOT NULL, -- 'chu_tri' or 'phoi_hop'
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE (task_id, agency_id, role)
);

-- Bảng tiến độ báo cáo (lưu theo mốc thời gian)
CREATE TABLE progress_reports (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES tasks(id) ON DELETE CASCADE,
  report_date DATE NOT NULL,
  percent_complete SMALLINT CHECK (percent_complete >= 0 AND percent_complete <= 100),
  comment TEXT,
  reported_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_progress_taskdate ON progress_reports(task_id, report_date);

-- Bảng lịch sử trạng thái (audit)
CREATE TABLE task_status_history (
  id BIGSERIAL PRIMARY KEY,
  task_id BIGINT REFERENCES tasks(id) ON DELETE CASCADE,
  old_status TEXT,
  new_status TEXT,
  changed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  changed_by TEXT,
  note TEXT
);

-- Bảng users (nhẹ) — nếu cần xác thực sau này
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Một view tiện lợi: trạng thái hiện tại và % tiến độ mới nhất
CREATE OR REPLACE VIEW task_overview AS
SELECT
  t.*,
  COALESCE(p.latest_percent, 0) as latest_percent,
  p.latest_date
FROM tasks t
LEFT JOIN (
  SELECT pr.task_id,
         pr.percent_complete AS latest_percent,
         pr.report_date AS latest_date
  FROM progress_reports pr
  JOIN (
    -- chọn báo cáo mới nhất cho từng task
    SELECT task_id, max(report_date) as max_date FROM progress_reports GROUP BY task_id
  ) m ON pr.task_id = m.task_id AND pr.report_date = m.max_date
) p ON p.task_id = t.id;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ============================
-- Cơ quan (Agencies)
-- ============================
INSERT INTO agencies(code, name, contact_person, contact_email)
VALUES
('BKHCN','Bộ Khoa học và Công nghệ','Huỳnh Thành Đạt','huynhdat@most.gov.vn'),
('BTTTT','Bộ Thông tin và Truyền thông','Nguyễn Mạnh Hùng','hungnm@mic.gov.vn'),
('BKHDT','Bộ Kế hoạch và Đầu tư','Nguyễn Chí Dũng','dungnc@mpi.gov.vn'),
('UBND_HN','UBND Thành phố Hà Nội','Trần Sỹ Thanh','thanhts@hanoi.gov.vn');

-- ============================
-- Nhiệm vụ (Tasks)
-- ============================
INSERT INTO tasks(code, title, description, unit, target_value, baseline_value, start_date, due_date, status, priority, created_by)
VALUES
('T01','Xây dựng nền tảng dữ liệu quốc gia',
 'Hoàn thành khung kỹ thuật, tiêu chuẩn dữ liệu cho 5 hệ dữ liệu trọng tâm',
 'hoàn thành/đề án',
 'Hoàn thành trong Q4 2025',
 'Chưa có',
 '2025-04-01','2025-12-31',
 'not_started',1,'admin'),

('T02','Phát triển Data Center quốc gia',
 'Hoàn thiện quy hoạch, thu hút đầu tư hạ tầng DC quy mô trung-lớn',
 'giai đoạn',
 'Hoàn tất giai đoạn 1 - 2026',
 'Chưa có',
 '2025-04-01','2026-12-31',
 'not_started',1,'admin'),

('T03','Tăng công bố quốc tế',
 'Tăng số lượng bài báo khoa học ISI/Scopus hàng năm của Việt Nam',
 '%/năm',
 '10%/năm',
 '5%',
 '2025-01-01','2028-12-31',
 'in_progress',2,'bkhn');

-- ============================
-- Phân công (Assignments)
-- ============================
INSERT INTO task_assignments(task_id, agency_id, role)
SELECT t.id, a.id, 'chu_tri'
FROM tasks t JOIN agencies a ON a.code='BKHCN' WHERE t.code='T01';

INSERT INTO task_assignments(task_id, agency_id, role)
SELECT t.id, a.id, 'phoi_hop'
FROM tasks t JOIN agencies a ON a.code='BTTTT' WHERE t.code='T01';

INSERT INTO task_assignments(task_id, agency_id, role)
SELECT t.id, a.id, 'chu_tri'
FROM tasks t JOIN agencies a ON a.code='BTTTT' WHERE t.code='T02';

INSERT INTO task_assignments(task_id, agency_id, role)
SELECT t.id, a.id, 'chu_tri'
FROM tasks t JOIN agencies a ON a.code='BKHCN' WHERE t.code='T03';

INSERT INTO task_assignments(task_id, agency_id, role)
SELECT t.id, a.id, 'phoi_hop'
FROM tasks t JOIN agencies a ON a.code='BKHDT' WHERE t.code='T03';

-- ============================
-- Báo cáo tiến độ (Progress Reports)
-- ============================
INSERT INTO progress_reports(task_id, report_date, percent_complete, comment, reported_by)
SELECT t.id, '2025-06-30', 10, 'Đã khảo sát yêu cầu, lập đề cương khung dữ liệu quốc gia', 'Huỳnh Thành Đạt'
FROM tasks t WHERE t.code='T01';

INSERT INTO progress_reports(task_id, report_date, percent_complete, comment, reported_by)
SELECT t.id, '2025-07-31', 25, 'Hoàn thiện bản mẫu dữ liệu, chuẩn bị thử nghiệm', 'Huỳnh Thành Đạt'
FROM tasks t WHERE t.code='T01';

INSERT INTO progress_reports(task_id, report_date, percent_complete, comment, reported_by)
SELECT t.id, '2025-08-15', 15, 'Đã xây dựng xong đề án tiền khả thi cho DC quốc gia', 'Nguyễn Mạnh Hùng'
FROM tasks t WHERE t.code='T02';

INSERT INTO progress_reports(task_id, report_date, percent_complete, comment, reported_by)
SELECT t.id, '2025-07-01', 20, 'Số bài báo ISI/Scopus nộp tăng nhẹ so với cùng kỳ', 'Nguyễn Chí Dũng'
FROM tasks t WHERE t.code='T03';
------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- checking--
SELECT * FROM agencies;

SELECT code, title, status, due_date FROM tasks;

SELECT t.code as task, a.code as agency, ta.role
FROM task_assignments ta
JOIN tasks t ON ta.task_id = t.id
JOIN agencies a ON ta.agency_id = a.id;

SELECT t.code as task, pr.report_date, pr.percent_complete, pr.comment, pr.reported_by
FROM progress_reports pr
JOIN tasks t ON pr.task_id = t.id
ORDER BY pr.report_date;

SELECT code, title, status, latest_percent, latest_date
FROM task_overview;





v