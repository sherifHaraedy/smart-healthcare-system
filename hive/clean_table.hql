USE healthcare_db;

DROP TABLE IF EXISTS patient_clean;

CREATE TABLE patient_clean AS
SELECT
    age, sex, cp, trestbps, chol,
    fbs, restecg, thalach, exang,
    oldpeak, slope, ca, thal, target
FROM patient_raw
WHERE
    age      IS NOT NULL AND age > 0 AND age < 120
    AND trestbps IS NOT NULL AND trestbps > 0
    AND chol     IS NOT NULL AND chol > 0
    AND thalach  IS NOT NULL AND thalach > 0
    AND ca       IN (0, 1, 2, 3)
    AND thal     IN (0, 1, 2, 3)
    AND target   IN (0, 1);

SELECT
    'raw'   AS source, COUNT(*) AS total_records FROM patient_raw
UNION ALL
SELECT
    'clean' AS source, COUNT(*) AS total_records FROM patient_clean;