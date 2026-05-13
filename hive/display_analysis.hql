USE healthcare_db;

-- Risk distribution
SELECT
    CASE WHEN target = 1 THEN 'At Risk' ELSE 'Not At Risk' END AS status,
    COUNT(*) AS patient_count
FROM patient_clean
GROUP BY target;

-- Average stats by risk group
SELECT
    CASE WHEN target = 1 THEN 'At Risk' ELSE 'Not At Risk' END AS status,
    ROUND(AVG(age), 1)      AS avg_age,
    ROUND(AVG(chol), 1)     AS avg_cholesterol,
    ROUND(AVG(trestbps), 1) AS avg_blood_pressure,
    ROUND(AVG(thalach), 1)  AS avg_max_heart_rate
FROM patient_clean
GROUP BY target;

-- Risk rate by gender
SELECT
    CASE WHEN sex = 1 THEN 'Male' ELSE 'Female' END AS gender,
    COUNT(*)                                          AS total,
    SUM(target)                                       AS at_risk,
    ROUND(SUM(target) / COUNT(*) * 100, 1)           AS risk_pct
FROM patient_clean
GROUP BY sex;