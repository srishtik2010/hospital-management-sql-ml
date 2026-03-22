-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM — DATABASE SCHEMA
--  Author : Srishti Kashyap
--  Tools  : MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- ── 1. DEPARTMENTS ──────────────────────────────────────────
CREATE TABLE departments (
    dept_id      INT AUTO_INCREMENT PRIMARY KEY,
    dept_name    VARCHAR(100) NOT NULL,
    floor_no     INT,
    head_doctor  VARCHAR(100),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── 2. DOCTORS ──────────────────────────────────────────────
CREATE TABLE doctors (
    doctor_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    speciality   VARCHAR(100),
    dept_id      INT,
    phone        VARCHAR(15),
    email        VARCHAR(100) UNIQUE,
    joining_date DATE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- ── 3. PATIENTS ─────────────────────────────────────────────
CREATE TABLE patients (
    patient_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    dob             DATE,
    gender          ENUM('Male','Female','Other'),
    blood_group     VARCHAR(5),
    phone           VARCHAR(15),
    email           VARCHAR(100),
    address         TEXT,
    registered_on   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── 4. ADMISSIONS ───────────────────────────────────────────
CREATE TABLE admissions (
    admission_id    INT AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT NOT NULL,
    doctor_id       INT NOT NULL,
    dept_id         INT NOT NULL,
    admit_date      DATE NOT NULL,
    discharge_date  DATE,
    diagnosis       VARCHAR(255),
    ward_type       ENUM('General','Semi-Private','ICU','Emergency'),
    total_bill      DECIMAL(10,2),
    status          ENUM('Admitted','Discharged','Under Observation') DEFAULT 'Admitted',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id),
    FOREIGN KEY (dept_id)    REFERENCES departments(dept_id)
);

-- ── 5. MEDICATIONS ──────────────────────────────────────────
CREATE TABLE medications (
    med_id          INT AUTO_INCREMENT PRIMARY KEY,
    admission_id    INT NOT NULL,
    medicine_name   VARCHAR(150),
    dosage          VARCHAR(50),
    frequency       VARCHAR(50),
    prescribed_by   INT,
    prescribed_on   DATE,
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id),
    FOREIGN KEY (prescribed_by) REFERENCES doctors(doctor_id)
);

-- ── 6. BILLING ──────────────────────────────────────────────
CREATE TABLE billing (
    bill_id         INT AUTO_INCREMENT PRIMARY KEY,
    admission_id    INT NOT NULL,
    room_charges    DECIMAL(10,2) DEFAULT 0,
    medicine_charges DECIMAL(10,2) DEFAULT 0,
    lab_charges     DECIMAL(10,2) DEFAULT 0,
    doctor_fees     DECIMAL(10,2) DEFAULT 0,
    total_amount    DECIMAL(10,2) GENERATED ALWAYS AS
                    (room_charges + medicine_charges + lab_charges + doctor_fees) STORED,
    payment_status  ENUM('Paid','Pending','Partial') DEFAULT 'Pending',
    bill_date       DATE,
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
);

-- ── INDEXES for performance ──────────────────────────────────
CREATE INDEX idx_patient_name   ON patients(full_name);
CREATE INDEX idx_admit_date     ON admissions(admit_date);
CREATE INDEX idx_diagnosis      ON admissions(diagnosis);
CREATE INDEX idx_payment_status ON billing(payment_status);
