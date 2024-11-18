from pyspark.sql import SparkSession
from pyspark.sql.functions import count
import time

# Initializing a Spark session
spark = SparkSession.builder.appName("HousePricingAnalysis").getOrCreate()

start = time.time()

# Loading the dataset from .csv file
df = spark.read.csv("House_Pricing.csv", header=True, inferSchema=True)

# Grouping by 'Country' and counting no of transactions of each group
transactionCount = df.groupBy("Country").agg(count("*").alias("TransactionCount"))

transactionCount.write.csv("2023202020_q2", header=True)

end = time.time()
totalTime = end - start
print(f"Total time taken by the process: {totalTime} seconds")
