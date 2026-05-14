#!/bin/bash
set -e
export MSYS_NO_PATHCONV=1

echo "Healthcare Big Data Pipeline"
echo "============================"

echo ""
echo "[1/4] Starting Docker cluster..."
docker compose up -d
echo "Waiting for services to be ready..."
sleep 3
echo "Docker cluster started"

echo ""
echo "Installing Python dependencies..."
docker exec -u 0 spark-master pip3 install --no-cache-dir --prefer-binary numpy==1.21.6

echo ""
echo "[2/4] Uploading dataset to HDFS..."
docker exec namenode hdfs dfs -mkdir -p /healthcare/raw
docker exec namenode hdfs dfs -put -f /data/heart.csv /healthcare/raw/
docker exec namenode hdfs dfs -ls /healthcare/raw/
echo "Dataset uploaded successfully"

echo ""
echo "[3/4] Running Hive pipeline..."
docker exec hive-server hive -f /hive/form_table.hql
echo "Raw table created"

docker exec hive-server hive -f /hive/clean_table.hql
echo "Data cleaned"

docker exec hive-server hive -f /hive/display_analysis.hql
echo "Analytics queries completed"

echo ""
echo "[4/4] Submitting Spark ML job..."
docker exec -e PYSPARK_PYTHON=/usr/bin/python3 spark-master /spark/bin/spark-submit \
    --master spark://spark-master:7077 \
    /app/spark/main.py
echo "Predictions completed"

echo ""
echo "============================"
echo "Pipeline finished successfully"
echo "Run: ./scripts/artifacts.sh"
echo "to capture results"
echo "============================"