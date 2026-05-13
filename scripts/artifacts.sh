#!/bin/bash
set -e
export MSYS_NO_PATHCONV=1

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUT="screenshots"

mkdir -p "$OUT"

echo "Capturing Pipeline Artifacts"
echo "============================"

echo ""
echo "[1/5] Capturing HDFS directory layout..."
docker exec namenode hdfs dfs -ls -R /healthcare \
    > "$OUT/hdfs_layout_$TIMESTAMP.txt"
echo "Saved: $OUT/hdfs_layout_$TIMESTAMP.txt"

echo ""
echo "[2/5] Capturing Hive table row counts..."
docker exec hive-server hive -e "
USE healthcare_db;
SELECT 'raw'   AS table_name, COUNT(*) AS total_rows FROM patient_raw
UNION ALL
SELECT 'clean' AS table_name, COUNT(*) AS total_rows FROM patient_clean;
" > "$OUT/hive_counts_$TIMESTAMP.txt"
echo "Saved: $OUT/hive_counts_$TIMESTAMP.txt"

echo ""
echo "[3/5] Capturing Hive analytics queries..."
docker exec hive-server hive -f /hive/3_analytics.hql \
    > "$OUT/hive_analytics_$TIMESTAMP.txt"
echo "Saved: $OUT/hive_analytics_$TIMESTAMP.txt"

echo ""
echo "[4/5] Capturing Spark prediction results..."
docker exec namenode hdfs dfs -cat /healthcare/predictions/* \
    > "$OUT/spark_predictions_$TIMESTAMP.txt"
echo "Saved: $OUT/spark_predictions_$TIMESTAMP.txt"

echo ""
echo "[5/5] Generating summary report..."
cat > "$OUT/summary_$TIMESTAMP.txt" << EOF
Healthcare Pipeline - Run Summary
Generated: $(date)

[HDFS Directories]
$(docker exec namenode hdfs dfs -ls /healthcare/raw)

[Hive Tables]
$(docker exec hive-server hive -e "USE healthcare_db; SHOW TABLES;" 2>/dev/null)

[Row Counts]
$(cat "$OUT/hive_counts_$TIMESTAMP.txt")

[Spark Model Results]
$(tail -10 "$OUT/spark_predictions_$TIMESTAMP.txt")
EOF
echo "Saved: $OUT/summary_$TIMESTAMP.txt"

echo ""
echo "============================"
echo "All artifacts saved"
echo "Location: $OUT/"
echo "============================"
echo ""
ls -lh "$OUT/"