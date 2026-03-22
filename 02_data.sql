-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM — SAMPLE DATA
-- ============================================================
USE hospital_db;

-- Departments
INSERT INTO departments (dept_name, floor_no, head_doctor) VALUES
('Cardiology',        2, 'Dr. Arjun Mehta'),
('Neurology',         3, 'Dr. Priya Sharma'),
('Orthopaedics',      1, 'Dr. Rajan Verma'),
('Emergency',         0, 'Dr. Sneha Kapoor'),
('General Medicine',  1, 'Dr. Amit Tiwari');

-- Doctors
INSERT INTO doctors (full_name, speciality, dept_id, phone, email, joining_date) VALUES
('Dr. Arjun Mehta',   'Cardiologist',      1, '9811001001', 'arjun@hospital.com',  '2018-06-01'),
('Dr. Priya Sharma',  'Neurologist',       2, '9811002002', 'priya@hospital.com',  '2019-03-15'),
('Dr. Rajan Verma',   'Orthopaedic',       3, '9811003003', 'rajan@hospital.com',  '2017-11-20'),
('Dr. Sneha Kapoor',  'Emergency Med',     4, '9811004004', 'sneha@hospital.com',  '2020-01-10'),
('Dr. Amit Tiwari',   'General Physician', 5, '9811005005', 'amit@hospital.com',   '2016-08-05');

-- Patients
INSERT INTO patients (full_name, dob, gender, blood_group, phone, address) VALUES
('Ramesh Kumar',   '1975-04-10', 'Male',   'O+',  '9900001111', 'Delhi'),
('Sunita Devi',    '1988-07-22', 'Female', 'A+',  '9900002222', 'Noida'),
('Vikram Singh',   '1965-01-30', 'Male',   'B+',  '9900003333', 'Gurugram'),
('Anjali Gupta',   '1992-09-14', 'Female', 'AB-', '9900004444', 'Faridabad'),
('Mohan Lal',      '1955-12-05', 'Male',   'O-',  '9900005555', 'Delhi'),
('Kavita Yadav',   '1980-03-18', 'Female', 'A-',  '9900006666', 'Meerut'),
('Deepak Tomar',   '1998-06-25', 'Male',   'B-',  '9900007777', 'Delhi'),
('Pooja Mishra',   '1970-11-08', 'Female', 'O+',  '9900008888', 'Agra');

-- Admissions
INSERT INTO admissions (patient_id, doctor_id, dept_id, admit_date, discharge_date, diagnosis, ward_type, total_bill, status) VALUES
(1, 1, 1, '2024-01-05', '2024-01-12', 'Hypertension',         'Semi-Private', 28000, 'Discharged'),
(2, 2, 2, '2024-02-10', '2024-02-18', 'Migraine',             'General',      15000, 'Discharged'),
(3, 3, 3, '2024-03-01', NULL,          'Knee Replacement',    'Semi-Private',  NULL, 'Admitted'),
(4, 1, 1, '2024-03-15', '2024-03-20', 'Chest Pain',           'ICU',          52000, 'Discharged'),
(5, 5, 5, '2024-04-02', '2024-04-07', 'Diabetes Type 2',      'General',      12000, 'Discharged'),
(1, 4, 4, '2024-05-10', '2024-05-11', 'Hypertension Relapse', 'Emergency',    18000, 'Discharged'),
(6, 2, 2, '2024-06-20', NULL,          'Epilepsy',            'General',       NULL, 'Under Observation'),
(7, 5, 5, '2024-07-15', '2024-07-18', 'Viral Fever',          'General',       8000, 'Discharged'),
(8, 1, 1, '2024-08-01', '2024-08-10', 'Arrhythmia',           'ICU',          65000, 'Discharged'),
(2, 3, 3, '2024-09-05', '2024-09-12', 'Slip Disc',            'Semi-Private', 22000, 'Discharged');

-- Billing
INSERT INTO billing (admission_id, room_charges, medicine_charges, lab_charges, doctor_fees, payment_status, bill_date) VALUES
(1,  8000,  5000,  3000, 12000, 'Paid',    '2024-01-12'),
(2,  4800,  3000,  2000,  5200, 'Paid',    '2024-02-18'),
(4, 20000, 12000,  8000, 12000, 'Partial', '2024-03-20'),
(5,  2500,  4000,  2000,  3500, 'Paid',    '2024-04-07'),
(6,  5400,  6000,  2500,  4100, 'Paid',    '2024-05-11'),
(8, 10000,  5000,  2000,  8000, 'Pending', '2024-07-18'),
(9, 25000, 18000, 10000, 12000, 'Partial', '2024-08-10'),
(10, 7000,  7000,  3000,  5000, 'Paid',   '2024-09-12');
