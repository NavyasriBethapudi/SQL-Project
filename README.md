# SQL-Project
Data Cleaning, Exploring, Analyzing and Reporting through SQL Queries

1. COVID-19 DATA EXPLORING PROJECT -

   I have taken this project inspired by AlexTheAnalyst a Youtuber he has done a project on this COVID dataset on exploring the data. Most of the queries written will be similar. 
   
   This Project contains data of how many people have been in contact with COVID and some of the fields contain Infected Cases, Deaths and got Vaccinated from March 2020 to as of Current Month i.e., March 2023. 
   
   I have formatted the some of the data via Excels and splitted into two excels. 
   1. COVIDDEATHS.xlsx -> Contains Covid Cases & Covid Deaths Data.
   2. COVIDVACCINATIONS.xlsx -> Contains Covid Vaccinations Data.
   
   Dataset ref link -> https://ourworldindata.org/covid-deaths 


2. SALES DATA ANALYSIS PROJECT - 

    I have taken this Sales Dataset from the Kaggle.com and inspired from the AlexTheAnalyst a Youtuber who has done Data Cleaning on Nashville Housing Data. But for a change I have considered to take Sales Data. 
    
    Dataset Ref Link -> https://www.kaggle.com/datasets/knightbearr/sales-product-data 
    
    STEP 1 -> This Dataset provides the information related to Purchasing a Product via online or offline Like Order ID, Quantity of Orders Placed, Shipping Address, Product Details and Order Date. So, Download the Dataset.
    
    STEP 2 -> In this Dataset we have multiple excels. So, I have merged 3 excels of Last Quarter of FY 2019 i.e, October, November, December. 
    
    STEP 3 -> Fix the Date Format before uploading the excel to Sql server. I have tried without Fixing the Date format but that errored out as Order Date has 2 different date types(character and date formats mixed). So, I have fixed that error first before uploading to server.
    
    STEP 4 -> Upload the Excel to SQL Server and Clean the Data.
            
            These are the some of the steps i have taken - 
            1. Format the Data Type of the Column Headers or Variables.
            2. Remove Duplicates
            3. Delete Irrelevant data 
            4. Split the Address to Address Line, City, State Code, Zip Code.
            5. Make sure there are no nulls. 
            6. Delete the Data is not required (Only if you think it is not neccessary)
            
    STEP 5 -> Analyze the Data after cleaning the data. 
    
              Below are the Few Questions you can refer - 
              1. Which product category is the most profitable and which one is the least profitable?
              2. What is the total number of products sold for StateCD - NewYork and how does it compare to the previous month? 
              3. What is the monthly sales trend for Last Quarter of the Year 2019? Which month had the highest sales and which month had the lowest sales?
              4. What is the percentage of sales per month and how does it vary by states and product category?
    
    Thanks!!
    
