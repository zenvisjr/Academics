from pyspark.sql import SparkSession
from pyspark.sql.functions import col, dense_rank
from pyspark.sql.window import Window
import time

# Initializing a Spark session
spark = SparkSession.builder.appName("HousePricingAnalysis").getOrCreate()

start = time.time()

# Loading the dataset from .csv file
df = spark.read.csv("House_Pricing.csv", header=True, inferSchema=True)

# Listing the countries that we require
requiredCountries = ['GREATER LONDON', 'CLEVELAND', 'ESSEX']

# Filter the DataFrame for selected countries
df = df.filter(col('Country').isin(requiredCountries))

# Define a window spec that partitions by 'Country' and orders by 'Price' descending
windowSpec = Window.partitionBy("Country").orderBy(col("Price").desc())

# Using the dense_rank function to get the rank of each transaction within each country
rankedDF = df.withColumn("rank", dense_rank().over(windowSpec))

# Finding the second highest transaction by filtering on rank
secondHighest = rankedDF.filter(col("rank") == 2)


# Collecting the second highest transactions of given countries
secondHighestList = secondHighest.collect()

#Finding the max value of transaction from second highest transaction of given countries
max = 0
for transaction in secondHighestList:
    if max < int(transaction['Price']):
        max = int(transaction['Price'])


end = time.time()
totalTime = end - start

# Printing the final result
print(f"Second highest transaction is {max} which is transacted in {transaction['Country']}.")
print(f"Total time taken by the process: {totalTime} seconds")


