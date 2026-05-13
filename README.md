# Healthcare Big Data Analytics Pipeline

A distributed data processing pipeline that analyzes large-scale patient medical records to identify individuals at risk of cardiovascular disease. Built with Apache Hadoop, Hive, and Spark for the CSE322 Big Data Analytics course.

## Overview

This project demonstrates a practical big data engineering workflow:

1. **Data Storage** — Patient records stored across HDFS cluster
2. **Data Processing** — Hadoop/Hive for cleaning and formatting
3. **Machine Learning** — Apache Spark for risk prediction
4. **Results** — Timestamped outputs for analysis and documentation

The pipeline processes ~300 cardiovascular disease records and trains a Random Forest classifier to predict patient risk.

## Tech Stack

| Component | Purpose |
|---|---|
| **HDFS** | Distributed file storage across Hadoop cluster |
| **Apache Hive** | SQL-like queries for data cleaning and formatting |
| **Apache Spark** | In-memory processing and ML classification |
|

## Architecture

```
Raw Dataset (CSV)
    ↓
HDFS (Distributed Storage)
    ↓
Hive (Data Cleaning & Formatting)
    ├─ Raw Table: 300 records
    └─ Clean Table: 250 valid records
    ↓
Spark (Feature Engineering & ML)
    ├─ Train: 200 records (80%)
    └─ Test: 50 records (20%)
    ↓
Predictions & Metrics (Accuracy, AUC, F1)
```

## Quick Start

### 1. Start the Cluster

```bash
make up
```

Wait 40 seconds for all services to initialize. You can monitor progress at:
- HDFS NameNode: http://localhost:9870
- Spark Master: http://localhost:8080

### 2. Run the Full Pipeline

```bash
make pipeline
```

### 4. Capture Results

```bash
make artifacts
```

### 5. Stop the Cluster

```bash
make down
```

### 6. Clean Up

```bash
make clean
```

## Expected Results

After running `make pipeline`, expect:

```
Model Results:
Accuracy : 85.00%
AUC      : 0.9123
F1 Score : 0.8456
```

__Actual metrics depend on data split randomization. Results are saved to `screenshots/summary_*.txt`.__