# ============================================================
#  HOSPITAL PATIENT READMISSION PREDICTION
#  Author  : Srishti Kashyap
#  Tools   : Python, Pandas, NumPy, Scikit-learn, Matplotlib, Seaborn
#  Goal    : Predict whether a discharged patient will be re-admitted
#            within 30 days using ML classification
# ============================================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import (classification_report, confusion_matrix,
                             roc_auc_score, roc_curve, ConfusionMatrixDisplay)
import warnings
warnings.filterwarnings('ignore')

# ── STEP 1: GENERATE SYNTHETIC HOSPITAL DATASET ─────────────
np.random.seed(42)
n = 500

departments   = ['Cardiology', 'Neurology', 'Orthopaedics', 'General Medicine', 'Emergency']
ward_types    = ['General', 'Semi-Private', 'ICU', 'Emergency']
diagnoses     = ['Hypertension', 'Diabetes', 'Arrhythmia', 'Migraine',
                 'Fracture', 'Viral Fever', 'Chest Pain', 'Epilepsy']
blood_groups  = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']

df = pd.DataFrame({
    'patient_id'      : range(1, n + 1),
    'age'             : np.random.randint(20, 85, n),
    'gender'          : np.random.choice(['Male', 'Female'], n),
    'blood_group'     : np.random.choice(blood_groups, n),
    'department'      : np.random.choice(departments, n),
    'ward_type'       : np.random.choice(ward_types, n),
    'diagnosis'       : np.random.choice(diagnoses, n),
    'stay_days'       : np.random.randint(1, 21, n),
    'num_medications' : np.random.randint(1, 8, n),
    'lab_tests_done'  : np.random.randint(1, 10, n),
    'total_bill'      : np.random.randint(5000, 80000, n),
    'prev_admissions' : np.random.choice([0, 1, 2, 3], n, p=[0.5, 0.3, 0.15, 0.05]),
    'chronic_disease' : np.random.choice([0, 1], n, p=[0.6, 0.4]),
    'emergency_admit' : np.random.choice([0, 1], n, p=[0.7, 0.3]),
})

# Target: readmitted within 30 days (higher risk for older, chronic, emergency patients)
risk_score = (
    (df['age'] > 60).astype(int) * 0.3 +
    df['chronic_disease'] * 0.25 +
    df['emergency_admit'] * 0.2 +
    (df['prev_admissions'] > 1).astype(int) * 0.15 +
    (df['stay_days'] > 10).astype(int) * 0.1
)
df['readmitted'] = (risk_score + np.random.uniform(0, 0.2, n) > 0.5).astype(int)

print("=" * 60)
print("  HOSPITAL PATIENT READMISSION PREDICTION")
print("=" * 60)
print(f"\n📊 Dataset Shape   : {df.shape}")
print(f"🔁 Readmission Rate: {df['readmitted'].mean() * 100:.1f}%")
print(f"\n{df.head()}\n")

# ── STEP 2: DATA CLEANING & EDA ─────────────────────────────
print("\n── DATA QUALITY CHECK ──")
print(df.isnull().sum())
print(f"\nDuplicates: {df.duplicated().sum()}")
print(f"\nBasic Stats:\n{df.describe()}")

# Distribution plots
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Hospital Data — Exploratory Data Analysis', fontsize=16, fontweight='bold')

# Age distribution
axes[0,0].hist(df['age'], bins=20, color='steelblue', edgecolor='white')
axes[0,0].set_title('Age Distribution')
axes[0,0].set_xlabel('Age'); axes[0,0].set_ylabel('Count')

# Readmission by Department
dept_readmit = df.groupby('department')['readmitted'].mean().sort_values()
axes[0,1].barh(dept_readmit.index, dept_readmit.values, color='coral')
axes[0,1].set_title('Readmission Rate by Department')
axes[0,1].set_xlabel('Readmission Rate')

# Ward Type vs Readmission
ward_counts = df.groupby(['ward_type','readmitted']).size().unstack()
ward_counts.plot(kind='bar', ax=axes[0,2], color=['#2ecc71','#e74c3c'], edgecolor='white')
axes[0,2].set_title('Ward Type vs Readmission')
axes[0,2].set_xlabel('Ward Type'); axes[0,2].tick_params(rotation=30)
axes[0,2].legend(['Not Readmitted','Readmitted'])

# Stay Days vs Readmission
df.boxplot(column='stay_days', by='readmitted', ax=axes[1,0],
           boxprops=dict(color='steelblue'))
axes[1,0].set_title('Stay Days vs Readmission')
axes[1,0].set_xlabel('Readmitted (0=No, 1=Yes)')

# Chronic Disease Impact
chronic = df.groupby('chronic_disease')['readmitted'].mean()
axes[1,1].bar(['No Chronic Disease','Chronic Disease'], chronic.values,
              color=['#27ae60','#c0392b'])
axes[1,1].set_title('Chronic Disease vs Readmission Rate')
axes[1,1].set_ylabel('Readmission Rate')

# Correlation Heatmap
num_cols = ['age','stay_days','num_medications','lab_tests_done',
            'total_bill','prev_admissions','chronic_disease',
            'emergency_admit','readmitted']
corr = df[num_cols].corr()
sns.heatmap(corr, annot=True, fmt='.2f', cmap='RdYlGn',
            ax=axes[1,2], linewidths=0.5)
axes[1,2].set_title('Feature Correlation Heatmap')

plt.tight_layout()
plt.savefig('eda_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("\n✅ EDA charts saved → eda_analysis.png")

# ── STEP 3: FEATURE ENGINEERING ─────────────────────────────
df_ml = df.drop(columns=['patient_id'])

# Encode categoricals
le = LabelEncoder()
for col in ['gender', 'blood_group', 'department', 'ward_type', 'diagnosis']:
    df_ml[col] = le.fit_transform(df_ml[col])

# New features
df_ml['bill_per_day']       = df_ml['total_bill'] / (df_ml['stay_days'] + 1)
df_ml['high_risk_age']      = (df_ml['age'] > 60).astype(int)
df_ml['complex_case']       = ((df_ml['num_medications'] >= 5) |
                                (df_ml['lab_tests_done'] >= 7)).astype(int)

X = df_ml.drop('readmitted', axis=1)
y = df_ml['readmitted']

# Scale
scaler  = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42, stratify=y)

print(f"\n── FEATURE ENGINEERING ──")
print(f"Training samples : {X_train.shape[0]}")
print(f"Test samples     : {X_test.shape[0]}")
print(f"Features         : {X.columns.tolist()}")

# ── STEP 4: MODEL TRAINING & COMPARISON ─────────────────────
models = {
    'Logistic Regression'      : LogisticRegression(max_iter=500, random_state=42),
    'Random Forest'            : RandomForestClassifier(n_estimators=100, random_state=42),
    'Gradient Boosting (Best)' : GradientBoostingClassifier(n_estimators=100, random_state=42),
}

print("\n── MODEL COMPARISON ──")
results = {}
for name, model in models.items():
    model.fit(X_train, y_train)
    cv_scores = cross_val_score(model, X_scaled, y, cv=5, scoring='roc_auc')
    y_pred    = model.predict(X_test)
    auc       = roc_auc_score(y_test, model.predict_proba(X_test)[:,1])
    results[name] = {'model': model, 'auc': auc, 'cv_mean': cv_scores.mean()}
    print(f"\n{name}:")
    print(f"  AUC Score   : {auc:.4f}")
    print(f"  CV AUC Mean : {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")
    print(classification_report(y_test, y_pred, target_names=['Not Readmitted','Readmitted']))

# ── STEP 5: BEST MODEL — DETAILED EVALUATION ────────────────
best_name  = 'Gradient Boosting (Best)'
best_model = results[best_name]['model']
y_pred     = best_model.predict(X_test)
y_proba    = best_model.predict_proba(X_test)[:,1]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle(f'Model Evaluation — {best_name}', fontsize=14, fontweight='bold')

# Confusion Matrix
ConfusionMatrixDisplay.from_predictions(
    y_test, y_pred,
    display_labels=['Not Readmitted','Readmitted'],
    ax=axes[0], colorbar=False, cmap='Blues')
axes[0].set_title('Confusion Matrix')

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, y_proba)
axes[1].plot(fpr, tpr, color='darkorange', lw=2,
             label=f'AUC = {roc_auc_score(y_test, y_proba):.3f}')
axes[1].plot([0,1],[0,1],'k--')
axes[1].set_title('ROC Curve'); axes[1].set_xlabel('False Positive Rate')
axes[1].set_ylabel('True Positive Rate'); axes[1].legend()

# Feature Importance
fi = pd.Series(best_model.feature_importances_, index=X.columns).sort_values(ascending=True)
fi.tail(10).plot(kind='barh', ax=axes[2], color='steelblue')
axes[2].set_title('Top 10 Feature Importances')

plt.tight_layout()
plt.savefig('model_evaluation.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"\n✅ Model evaluation charts saved → model_evaluation.png")

# ── STEP 6: PREDICTION FUNCTION ─────────────────────────────
def predict_readmission(patient_data: dict) -> dict:
    """
    Predict readmission risk for a new patient.
    patient_data keys: age, gender, stay_days, num_medications,
                       lab_tests_done, total_bill, prev_admissions,
                       chronic_disease, emergency_admit
    """
    sample = pd.DataFrame([patient_data])
    sample['bill_per_day']  = sample['total_bill'] / (sample['stay_days'] + 1)
    sample['high_risk_age'] = (sample['age'] > 60).astype(int)
    sample['complex_case']  = ((sample['num_medications'] >= 5) |
                                (sample['lab_tests_done'] >= 7)).astype(int)
    # Fill any missing categorical columns with 0 (already encoded)
    for col in X.columns:
        if col not in sample.columns:
            sample[col] = 0
    sample_scaled = scaler.transform(sample[X.columns])
    prob   = best_model.predict_proba(sample_scaled)[0][1]
    label  = "HIGH RISK ⚠️" if prob >= 0.5 else "LOW RISK ✅"
    return {"readmission_probability": round(prob * 100, 2), "risk_level": label}

# Demo prediction
sample_patient = {
    'age': 68, 'gender': 1, 'blood_group': 4, 'department': 0,
    'ward_type': 2, 'diagnosis': 2, 'stay_days': 12,
    'num_medications': 6, 'lab_tests_done': 8, 'total_bill': 62000,
    'prev_admissions': 2, 'chronic_disease': 1, 'emergency_admit': 1
}
result = predict_readmission(sample_patient)
print("\n── LIVE PREDICTION DEMO ──")
print(f"Patient Risk Level        : {result['risk_level']}")
print(f"Readmission Probability   : {result['readmission_probability']}%")

print("\n✅ Project complete! Files generated:")
print("   • eda_analysis.png")
print("   • model_evaluation.png")
