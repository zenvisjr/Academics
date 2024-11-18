from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, dense_rank
from pyspark.sql.window import Window
import time

# Initializing a Spark session
spark = SparkSession.builder.appName("HousePricingAnalysis").getOrCreate()

start = time.time()

# Loading the dataset from .csv file
df = spark.read.csv("House_Pricing.csv", header=True, inferSchema=True)

# Grouping by 'Country' and counting no of transactions of each group
transactionCount = df.groupBy("Country").agg(count("*").alias("TransactionCount"))

# Define a window spec for ranking countries based on transaction count
windowSpec = Window.orderBy(col("TransactionCount").desc())

# Ranking countries by transaction count
rankedCountries = transactionCount.withColumn("rank", dense_rank().over(windowSpec))

# Filtering the second rank out of rankedCountries
secondMostTransCountry = rankedCountries.filter(col("rank") == 2)

# Collecting the results
finalAns = secondMostTransCountry.collect()

end = time.time()
totalTime = end - start

# Printing the results
for row in finalAns:
    print(f"Country with the second most transactions is '{row['Country']}' with {row['TransactionCount']} transactions.")
    break

print(f"Total time taken by the process: {totalTime} seconds")

