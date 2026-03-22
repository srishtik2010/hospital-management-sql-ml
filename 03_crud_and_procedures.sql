-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM — CRUD & STORED PROCEDURES
--  Author : Srishti Kashyap
-- ============================================================
USE hospital_db;

-- ════════════════════════════════════════════════════════════
--  CRUD OPERATIONS
-- ════════════════════════════════════════════════════════════

-- ── CREATE ───────────────────────────────────────────────────
-- Register a new patient
INSERT INTO patients (full_name, dob, gender, blood_group, phone, address)
VALUES ('Neha Saxena', '1995-08-12', 'Female', 'A+', '9812345678', 'Rohini, Delhi');

-- Admit a patient
INSERT INTO admissions (patient_id, doctor_id, dept_id, admit_date, diagnosis, ward_type, status)
VALUES (LAST_INSERT_ID(), 1, 1, CURDATE(), 'Hypertension Follow-up', 'General', 'Admitted');

-- ── READ ────────────────────────────────────────────────────
-- All currently admitted patients with doctor & department info
SELECT
    p.patient_id,
    p.full_name        AS patient_name,
    p.blood_group,
    a.diagnosis,
    a.ward_type,
    a.admit_date,
    d.full_name        AS doctor_name,
    dep.dept_name
FROM admissions a
JOIN patients    p   ON a.patient_id = p.patient_id
JOIN doctors     d   ON a.doctor_id  = d.doctor_id
JOIN departments dep ON a.dept_id    = dep.dept_id
WHERE a.status = 'Admitted';

-- ── UPDATE ──────────────────────────────────────────────────
-- Discharge a patient and update bill
UPDATE admissions
SET    status = 'Discharged', discharge_date = CURDATE(), total_bill = 21000
WHERE  admission_id = 3;

-- Mark a bill as paid
UPDATE billing
SET    payment_status = 'Paid'
WHERE  admission_id = 4;

-- ── DELETE ──────────────────────────────────────────────────
-- Remove a test/duplicate patient record
DELETE FROM patients WHERE patient_id = 9 AND full_name = 'Neha Saxena';

-- ════════════════════════════════════════════════════════════
--  STORED PROCEDURES
-- ════════════════════════════════════════════════════════════

DELIMITER $$

-- ── SP 1: Admit a new patient in one call ───────────────────
CREATE PROCEDURE AdmitPatient(
    IN  p_name      VARCHAR(100),
    IN  p_dob       DATE,
    IN  p_gender    VARCHAR(10),
    IN  p_blood     VARCHAR(5),
    IN  p_phone     VARCHAR(15),
    IN  p_address   TEXT,
    IN  p_doctor_id INT,
    IN  p_dept_id   INT,
    IN  p_diagnosis VARCHAR(255),
    IN  p_ward      VARCHAR(20),
    OUT p_patient_id INT,
    OUT p_admission_id INT
)
BEGIN
    INSERT INTO patients (full_name, dob, gender, blood_group, phone, address)
    VALUES (p_name, p_dob, p_gender, p_blood, p_phone, p_address);
    SET p_patient_id = LAST_INSERT_ID();

    INSERT INTO admissions (patient_id, doctor_id, dept_id, admit_date, diagnosis, ward_type, status)
    VALUES (p_patient_id, p_doctor_id, p_dept_id, CURDATE(), p_diagnosis, p_ward, 'Admitted');
    SET p_admission_id = LAST_INSERT_ID();

    SELECT CONCAT('Patient admitted successfully. Patient ID: ', p_patient_id,
                  ' | Admission ID: ', p_admission_id) AS result;
END $$

-- ── SP 2: Generate patient billing summary ──────────────────
CREATE PROCEDURE GetBillingSummary(IN p_patient_id INT)
BEGIN
    SELECT
        p.full_name,
        a.admission_id,
        a.admit_date,
        a.discharge_date,
        a.diagnosis,
        b.room_charges,
        b.medicine_charges,
        b.lab_charges,
        b.doctor_fees,
        b.total_amount,
        b.payment_status
    FROM patients p
    JOIN admissions a ON p.patient_id = a.patient_id
    JOIN billing    b ON a.admission_id = b.admission_id
    WHERE p.patient_id = p_patient_id
    ORDER BY a.admit_date DESC;
END $$

-- ── SP 3: Department-wise patient load report ───────────────
CREATE PROCEDURE DeptLoadReport()
BEGIN
    SELECT
        dep.dept_name,
        COUNT(a.admission_id)                                  AS total_admissions,
        SUM(CASE WHEN a.status = 'Admitted' THEN 1 ELSE 0 END) AS currently_admitted,
        SUM(CASE WHEN a.status = 'Discharged' THEN 1 ELSE 0 END) AS discharged,
        ROUND(AVG(DATEDIFF(COALESCE(a.discharge_date, CURDATE()), a.admit_date)), 1) AS avg_stay_days
    FROM departments dep
    LEFT JOIN admissions a ON dep.dept_id = a.dept_id
    GROUP BY dep.dept_name
    ORDER BY total_admissions DESC;
END $$

-- ── SP 4: Readmission check (same patient, within 30 days) ──
CREATE PROCEDURE CheckReadmissions()
BEGIN
    SELECT
        p.full_name,
        p.patient_id,
        a1.admission_id  AS first_admission,
        a1.discharge_date,
        a2.admission_id  AS readmission_id,
        a2.admit_date    AS readmit_date,
        DATEDIFF(a2.admit_date, a1.discharge_date) AS days_gap
    FROM admissions a1
    JOIN admissions a2 ON  a1.patient_id = a2.patient_id
                       AND a2.admit_date > a1.discharge_date
                       AND DATEDIFF(a2.admit_date, a1.discharge_date) <= 30
    JOIN patients p    ON  p.patient_id = a1.patient_id
    ORDER BY days_gap;
END $$

DELIMITER ;

-- ════════════════════════════════════════════════════════════
--  ADVANCED ANALYTICAL QUERIES
-- ════════════════════════════════════════════════════════════

-- Query 1: Top doctors by number of patients handled
SELECT
    d.full_name AS doctor_name,
    d.speciality,
    COUNT(a.admission_id) AS patients_handled,
    ROUND(AVG(DATEDIFF(COALESCE(a.discharge_date, CURDATE()), a.admit_date)), 1) AS avg_treatment_days
FROM doctors d
JOIN admissions a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.full_name, d.speciality
ORDER BY patients_handled DESC;

-- Query 2: Monthly revenue trend
SELECT
    DATE_FORMAT(b.bill_date, '%Y-%m') AS month,
    COUNT(b.bill_id)                  AS total_bills,
    SUM(b.total_amount)               AS total_revenue,
    SUM(CASE WHEN b.payment_status = 'Pending' THEN b.total_amount ELSE 0 END) AS pending_amount
FROM billing b
GROUP BY month
ORDER BY month;

-- Query 3: Patients with pending payments > 10,000
SELECT
    p.full_name,
    p.phone,
    a.diagnosis,
    b.total_amount,
    b.payment_status
FROM billing b
JOIN admissions a ON b.admission_id = a.admission_id
JOIN patients   p ON a.patient_id   = p.patient_id
WHERE b.payment_status IN ('Pending','Partial')
  AND b.total_amount > 10000
ORDER BY b.total_amount DESC;

-- Query 4: Diagnosis frequency analysis
SELECT
    diagnosis,
    COUNT(*) AS case_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM admissions), 2) AS percentage
FROM admissions
GROUP BY diagnosis
ORDER BY case_count DESC;
