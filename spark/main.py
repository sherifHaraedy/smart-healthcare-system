# -*- coding: utf-8 -*-

from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler, StandardScaler
from pyspark.ml.classification import RandomForestClassifier
from pyspark.ml.evaluation import (
    BinaryClassificationEvaluator,
    MulticlassClassificationEvaluator,
)
from pyspark.ml import Pipeline

def main():
    # Initialize Spark session with Hive support
    spark = SparkSession.builder \
        .appName("HealthcareRiskPrediction") \
        .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
        .config("spark.sql.warehouse.dir", "hdfs://namenode:9000/user/hive/warehouse") \
        .enableHiveSupport() \
        .getOrCreate()
    
    spark.sparkContext.setLogLevel("WARN")
    
    # Load cleaned data from Hive
    print("\n[1/4] Loading cleaned data from Hive...")
    df = spark.sql("SELECT * FROM healthcare_db.patient_clean")
    df = df.withColumnRenamed("target", "label")
    print("Records loaded: {}".format(df.count()))
    df.show(5)
    
    # Define feature columns and build ML pipeline
    print("\n[2/4] Building ML pipeline...")
    feature_cols = [
        "age", "sex", "cp", "trestbps", "chol",
        "fbs", "restecg", "thalach", "exang",
        "oldpeak", "slope", "ca", "thal",
    ]
    
    assembler = VectorAssembler(inputCols=feature_cols, outputCol="raw_features")
    scaler = StandardScaler(inputCol="raw_features", outputCol="features")
    rf = RandomForestClassifier(
        featuresCol="features",
        labelCol="label",
        numTrees=100,
        seed=42,
    )
    
    pipeline = Pipeline(stages=[assembler, scaler, rf])
    
    # Split data and train model
    print("\n[3/4] Training Random Forest classifier...")
    train_df, test_df = df.randomSplit([0.8, 0.2], seed=42)
    model = pipeline.fit(train_df)
    
    # Evaluate model on test set
    print("\n[4/4] Evaluating model on test data...")
    predictions = model.transform(test_df)
    predictions.select("age", "chol", "trestbps", "label", "prediction").show(15)
    
    # Calculate metrics
    accuracy = MulticlassClassificationEvaluator(
        labelCol="label",
        metricName="accuracy"
    ).evaluate(predictions)
    
    auc = BinaryClassificationEvaluator(
        labelCol="label"
    ).evaluate(predictions)
    
    f1_score = MulticlassClassificationEvaluator(
        labelCol="label",
        metricName="f1"
    ).evaluate(predictions)
    
    # Print results
    print("\nModel Results:")
    print("Accuracy : {:.2f}%".format(accuracy * 100))
    print("AUC      : {:.4f}".format(auc))
    print("F1 Score : {:.4f}".format(f1_score))
    
    # Save predictions to HDFS
    predictions.select("age", "chol", "trestbps", "label", "prediction") \
        .write.mode("overwrite") \
        .csv("hdfs://namenode:9000/healthcare/predictions/")
    
    print("Predictions written to: hdfs://namenode:9000/healthcare/predictions/")
    
    spark.stop()


if __name__ == "__main__":
    main()