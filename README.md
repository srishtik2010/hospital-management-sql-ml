# 🏥 Hospital Management System SQL + Patient Readmission Prediction (ML)

> **Author:** Srishti Kashyap | B.Tech Biotechnology | IMS Engineering College  
> **Tools:** MySQL · Python · Pandas · Scikit-learn · Matplotlib · Seaborn

---

## 📌 Project Overview

A two-part end-to-end data project simulating a real-world Hospital Management System:

1. **SQL Module** — Relational database design with CRUD operations, stored procedures, and analytical queries
2. **ML Module** — Patient readmission prediction using Python (Pandas + Scikit-learn)

---

## 🗂️ Project Structure

```
hospital_project/
│
├── sql/
│   ├── 01_schema.sql              # Database schema & indexes
│   ├── 02_data.sql                # Sample data inserts
│   └── 03_crud_and_procedures.sql # CRUD + Stored Procedures + Analytical Queries
│
├── python/
│   └── readmission_prediction.py  # EDA + Feature Engineering + ML Model
│
└── README.md
```

---

## 🛢️ SQL Module Highlights

| Feature | Details |
|---|---|
| Tables | 6 (Departments, Doctors, Patients, Admissions, Medications, Billing) |
| Relationships | Foreign Keys across all tables |
| CRUD Operations | INSERT, SELECT (with JOINs), UPDATE, DELETE |
| Stored Procedures | AdmitPatient, GetBillingSummary, DeptLoadReport, CheckReadmissions |
| Analytical Queries | Revenue trends, Doctor performance, Diagnosis frequency, Pending payments |
| Indexes | Optimized on patient_name, admit_date, diagnosis, payment_status |

---

## 🤖 ML Module Highlights

| Feature | Details |
|---|---|
| Dataset | 500 patient records (synthetic) |
| Target Variable | `readmitted` (0 = No, 1 = Yes within 30 days) |
| Features Used | Age, Stay Days, Medications, Lab Tests, Bill, Prior Admissions, Chronic Disease |
| Models Compared | Logistic Regression, Random Forest, Gradient Boosting |
| Best Model | Gradient Boosting Classifier |
| Evaluation | AUC-ROC Score, Confusion Matrix, Cross-Validation (5-fold) |
| Output | Readmission probability % + Risk Level for new patients |

---

## ⚙️ How to Run

### SQL
```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p hospital_db < sql/02_data.sql
mysql -u root -p hospital_db < sql/03_crud_and_procedures.sql
```

### Python
```bash
pip install pandas numpy matplotlib seaborn scikit-learn
python python/readmission_prediction.py
```

---

## 📊 Sample Output

```
Patient Risk Level       : HIGH RISK ⚠️
Readmission Probability  : 74.3%
```

---

## 🔑 Key Skills Demonstrated

- **Database Design** — Normalization, relationships, indexing
- **SQL** — Complex JOINs, subqueries, aggregations, stored procedures
- **CRUD Operations** — Full lifecycle data management
- **Python / Pandas** — Data cleaning, feature engineering, EDA
- **Machine Learning** — Classification, model comparison, AUC evaluation
- **Data Visualization** — Heatmaps, ROC curves, feature importance plots
