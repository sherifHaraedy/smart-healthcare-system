CREATE DATABASE IF NOT EXISTS healthcare_db;
USE healthcare_db;

CREATE EXTERNAL TABLE IF NOT EXISTS patient_raw (
    age       INT,
    sex       INT,
    cp        INT,
    trestbps  INT,
    chol      INT,
    fbs       INT,
    restecg   INT,
    thalach   INT,
    exang     INT,
    oldpeak   DOUBLE,
    slope     INT,
    ca        INT,
    thal      INT,
    target    INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/healthcare/raw/'
TBLPROPERTIES ("skip.header.line.count"="1");

SELECT COUNT(*) AS total_raw_records FROM patient_raw;