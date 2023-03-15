--Uploaded an Excel with Sales Data from the Period of Last Quarter (October, November, December) in the Year 2019.
--DATA CLEANING USING SQL
-- 1. Verify if Table is loaded successfully. 
SELECT * 
FROM SalesAnalyticsProject..SalesData

-- 2.Remove Bad Data that is irrelevant to Columns Data 
----Before Removing let's see how many rows are showing up for eg. We should have data like Purchase Address, product, NULL Values i.e, similar to the Header rows.
SELECT * 
FROM SalesAnalyticsProject..SalesData
WHERE Product = 'Product'

----ALTER TABLE SalesAnalyticsProject.SalesData (Found that no need to use Alter Table when deleting unwanted data.)
DELETE FROM SalesData 
WHERE Product = 'Product'

---- Let's Verify if unwanted data is deleted or not it should show 0 rows 
SELECT * 
FROM SalesAnalyticsProject..SalesData
WHERE Product = 'Product'

-- 3. Standardize the Date Formats 
---- Before Formatting the Date. Let's see how Order Date is pulling up 
SELECT [Order Date]
FROM SalesAnalyticsProject..SalesData

---- Tested the Convert statement to pull date only.
SELECT [Order Date], CONVERT(date,[Order Date])  AS FixedOrderDate
FROM SalesAnalyticsProject..SalesData

---- Using ALTER statement to add a new column OrderDate as DATE DataType.
ALTER TABLE SalesAnalyticsProject..SalesData 
ADD OrderDate DATE;

----Using UPDATE statement to update the OrderDate by Converting [Order Date] to DATE DataType.
UPDATE SalesAnalyticsProject..SalesData
SET OrderDate = CONVERT(date,[Order Date])
;

--UPDATE SalesData 
--SET OrderDate = CONVERT(date,[Order Date])
--;
---- Let's Verify if new column is added for Order Date or not.
SELECT *
FROM SalesAnalyticsProject..SalesData

-- 4. Splitting the Purchase Address to Address Line, City, StateCD, ZipCode
----4.1 Split the Purchase Address using PARSENAME function so that we get columns - AddressLine, CityName & StateCD_ZipCode.
----Before Splitting the Purchase Address. Let's see how Purchase Address is showing up 
SELECT [Purchase Address]
FROM SalesAnalyticsProject..SalesData

---- We can see there is comma seperator after Address as well as City Name and Space between State code and Zipcode
---- Use PARSENAME String function to seperate the columns and REPLACE Statement by comma to period.(To see if query is pulling correct records)
SELECT [Purchase Address]
	 , PARSENAME(REPLACE([Purchase Address],',','.'),3)   AS AddressLine
     , PARSENAME(REPLACE([Purchase Address],',','.'),2)   AS CityName
	 , PARSENAME(REPLACE([Purchase Address],',','.'),1)   AS StateCD_ZipCode
FROM SalesAnalyticsProject..SalesData

---- Use ALTER Statement to add columns AddressLine, CityName and StateCD and ZipCode. 
ALTER TABLE SalesAnalyticsProject..SalesData
ADD AddressLine nvarchar(255)
  , CityName nvarchar(255)
  , StateCD_ZipCode nvarchar(255) 
 ;

 ---- Update the SalesDate with New Columns AddressLine, CityName, StateCD and ZipCode.
UPDATE SalesAnalyticsProject..SalesData
 SET AddressLine = PARSENAME(REPLACE([Purchase Address],',','.'),3)
   , CityName = PARSENAME(REPLACE([Purchase Address],',','.'),2)
   , StateCD_ZipCode = PARSENAME(REPLACE([Purchase Address],',','.'),1)
;

---- Let's Veriy if Updated Columns are reflecting or not
SELECT *
FROM SalesAnalyticsProject..SalesData

----4.2 Split the StateCD and ZipCode using SUBSTRING Function 
----Before Splitting the StateCD_ZipCode. Let's see how StateCD_ZipCode is pulling 
SELECT StateCD_ZipCode
FROM SalesAnalyticsProject..SalesData

----Use SUBSTRING Function to see how data is pulling
SELECT StateCD_ZipCode
     , SUBSTRING(StateCD_ZipCode, 1, 3)  AS StateCD
	 , SUBSTRING(StateCD_ZipCode, 4, LEN(StateCD_ZipCode))   AS ZipCode
FROM SalesAnalyticsProject..SalesData

----Use ALTER Statement to add columns of StateCD and ZipCode
ALTER TABLE SalesAnalyticsProject..SalesData
ADD StateCD   NVARCHAR(2)
  , ZipCode NVARCHAR(5) 
;

----Use Update Statement to update columns of StateCD and ZipCode with data.
UPDATE SalesAnalyticsProject..SalesData
SET StateCD = TRIM(SUBSTRING(StateCD_ZipCode, 1, 3))
  , ZipCode = TRIM(SUBSTRING(StateCD_ZipCode, 4, LEN(StateCD_ZipCode)))
;

----Let's verify if data is updated is successfully updated or not. 
SELECT *
FROM SalesAnalyticsProject..SalesData

--5. Create a Column that shows what Category does a product belongs to
---- Before adding a Column Category. Let's see how Product is pulling 
SELECT DISTINCT Product
FROM SalesAnalyticsProject..SalesData

---- Let's use CASE Statement to get Category to see how query result is pulling based on product.
SELECT Product
     , CASE WHEN Product IN('Flatscreen TV','LG Washing Machine','LG Dryer') THEN 'Electronics'
	        WHEN Product IN('Google Phone','Vareebadd Phone','iPhone') THEN 'Phones'
			WHEN Product IN('USB-C Charging Cable','AAA Batteries (4-pack)','AA Batteries (4-pack)','Lightning Charging Cable') THEN 'Chargers'
			WHEN Product IN('Bose SoundSport Headphones','Wired Headphones','Apple Airpods Headphones') THEN 'HeadPhones'
			WHEN Product IN('27in 4K Gaming Monitor','34in Ultrawide Monitor','20in Monitor','27in FHD Monitor') THEN 'Monitors'
			WHEN Product IN('ThinkPad Laptop','Macbook Pro Laptop')  THEN 'Laptops'
		END                                   AS Category
FROM SalesAnalyticsProject..SalesData
--WHERE Product is null

----Use ALTER Statement to ADD Column Category 
ALTER TABLE SalesAnalyticsProject..SalesData
ADD Category nvarchar(20)
;

----Use UPDATE Statement to update data in Category column
UPDATE SalesAnalyticsProject..SalesData
SET    Category = 
       CASE WHEN Product IN('Flatscreen TV','LG Washing Machine','LG Dryer') THEN 'Electronics'
	        WHEN Product IN('Google Phone','Vareebadd Phone','iPhone') THEN 'Phones'
			WHEN Product IN('USB-C Charging Cable','AAA Batteries (4-pack)','AA Batteries (4-pack)','Lightning Charging Cable') THEN 'Chargers'
			WHEN Product IN('Bose SoundSport Headphones','Wired Headphones','Apple Airpods Headphones') THEN 'HeadPhones'
			WHEN Product IN('27in 4K Gaming Monitor','34in Ultrawide Monitor','20in Monitor','27in FHD Monitor') THEN 'Monitors'
			WHEN Product IN('ThinkPad Laptop','Macbook Pro Laptop')  THEN 'Laptops'
		END  
;

----Let's Verify if Column is added successfully or not
SELECT *
FROM SalesAnalyticsProject..SalesData

--6. Update the Column Quantity Ordered Data Type FLOAT to INT and OrderID Data Type FLOAT to NVARCHAR. 
---- Updating QuantityOrdered Data Type from FLOAT to INT
ALTER TABLE SalesAnalyticsProject..SalesData
ALTER COLUMN QuantityOrdered INT
; 

----Updating OrderID Data Type from FLOAT to NVARCHAR
ALTER TABLE SalesAnalyticsProject..SalesData
ALTER COLUMN OrderID varchar(10) 
;

--7. DROP irrelevant columns from the Table. 
----Before Droping irrelevant data. Let's see how columns are pulling
SELECT *
FROM SalesAnalyticsProject..SalesData

----Let's DROP Order Date, Purchase Address, StateCD_ZipCode
ALTER TABLE SalesAnalyticsProject..SalesData
DROP COLUMN [Order Date], [Purchase Address], StateCd_ZipCode
;

----Let's Verify if above rows were dropped or not
SELECT *
FROM SalesAnalyticsProject..SalesData

--8. Remove Duplicate Data from the SalesData Table.
----Before removing duplicates. let's see how data is pulling - Am using COUNT() Function to see how many rows of data is showing up
SELECT COUNT(*)
FROM SalesAnalyticsProject..SalesData

----Use CTE and ROW_NUM() Function to get the row count. That should show how many duplicates records were found.
WITH RowVsCTE 
AS (
SELECT *
     , ROW_NUMBER() OVER (PARTITION BY Product
									 , QuantityOrdered
									 , Price
									 , OrderDate
									 , AddressLine
									 , CityName
									 , StateCD
									 , ZipCode
									 , Category
							ORDER BY OrderID
							) row_num
FROM SalesAnalyticsProject..SalesData
)
SELECT *
FROM RowVsCTE
WHERE row_num > 1
ORDER BY OrderID 

----DELETE the Duplicate Rows 
WITH RowVsCTE 
AS (
SELECT *
     , ROW_NUMBER() OVER (PARTITION BY Product
									 , QuantityOrdered
									 , Price
									 , OrderDate
									 , AddressLine
									 , CityName
									 , StateCD
									 , ZipCode
									 , Category
							ORDER BY OrderID
							) row_num
FROM SalesAnalyticsProject..SalesData
)
DELETE
FROM RowVsCTE
WHERE row_num > 1
--ORDER BY OrderID 

----Let's Verify now how many records were showing up 
SELECT COUNT(*)
FROM SalesAnalyticsProject..SalesData

---- 9. Verify if SalesData has only the period of Last Quarter of Year 2019 and Remove if we have any dates other than that.
---- Before Removing those dates. Let's see how data is pulling order by OrderDate
SELECT COUNT(*) 
FROM SalesAnalyticsProject..SalesData
--ORDER BY OrderDate DESC

----Let's create a query to pull date of Year 2020.
SELECT *
FROM SalesAnalyticsProject..SalesData
WHERE YEAR(OrderDate) = 2020

----Let's DELETE these rows. So, we only have 2019 data.
DELETE 
FROM SalesAnalyticsProject..SalesData
WHERE YEAR(OrderDate) = 2020

----Let's verify the query to see if we have any 2020 rows left
SELECT *
FROM SalesAnalyticsProject..SalesData
WHERE YEAR(OrderDate) = 2020

---- let's see how many unique orders placed and Get their Total Price based on Product
SELECT OrderID
     , SUM(QuantityOrdered)  AS OrdersPlaced
     , SUM(Price)      AS TotalPrice
FROM SalesAnalyticsProject..SalesData
--WHERE OrderID = 319313
GROUP BY ROLLUP(OrderID)

--DATA ANALYSIS USING SQL TO REPORT IN DASHBOARD.
-- 1. Which product category is the most profitable and which one is the least profitable?
----Getting the Highly Profitable Products sold resulting in Category
SELECT TOP(1) Category
     , SUM(cast(Price  as bigint))   AS Price
FROM SalesAnalyticsProject..SalesData  
GROUP BY Category
ORDER BY 2 DESC

----Getting the Least Profitable Products sold resulting in Category
SELECT TOP(1) Category
     , SUM(cast(Price  as bigint))   AS Price
FROM SalesAnalyticsProject..SalesData  
GROUP BY Category
ORDER BY 2 

---- For Dashboard purpose 
SELECT Category
     , SUM(cast(Price  as bigint))   AS Price
FROM SalesAnalyticsProject..SalesData  
GROUP BY Category
ORDER BY 2

-- 2.What is the total number of products sold for StateCD - NewYork and how does it compare to the previous month? 
----Query for Nov 2019 - Oct 2019
SELECT *
FROM SalesAnalyticsProject..SalesData

------Query for Nov 2019 
SELECT Product AS Product_NOV
      ,SUM(QuantityOrdered)   AS Total_Products_Sold_NOV
FROM SalesAnalyticsProject..SalesData
WHERE StateCD = 'NY'
  AND OrderDate BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY Product
ORDER BY 2 

------Query for Oct 2019 
SELECT Product    AS Product_OCT
      ,SUM(QuantityOrdered)   AS Total_Products_Sold_OCT
FROM SalesAnalyticsProject..SalesData
WHERE StateCD = 'NY'
  AND OrderDate BETWEEN '2019-10-01' AND '2019-10-31'
GROUP BY Product
ORDER BY 2 

----Query for comparing both Products Sold in Oct 2019 to Nov 2019
SELECT A.Product       AS Product
     , SUM(A.QuantityOrdered)   AS Total_Products_Sold_NOV
	 --, B.Product       AS Product_OCT
	 , B.Total_Products_Sold    AS Total_Products_Sold_OCT

FROM SalesAnalyticsProject..SalesData  AS A

JOIN (SELECT Product  
           , SUM(QuantityOrdered)    AS Total_Products_Sold   
	  FROM SalesAnalyticsProject..SalesData
	  WHERE StateCD = 'NY'
	    AND OrderDate BETWEEN '2019-10-01' AND '2019-10-31'
	  GROUP BY Product
	 )  AS  B
ON B.Product = A.Product

WHERE A.StateCD = 'NY'
  AND A.OrderDate BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY A.Product
       , B.Product
	   , b.Total_Products_Sold
ORDER BY 1

----Query for Dec 2019 - Nov 2019
SELECT *
FROM SalesAnalyticsProject..SalesData

------Query for Nov 2019 
SELECT Product AS Product_NOV
      ,SUM(QuantityOrdered)   AS Total_Products_Sold_NOV
FROM SalesAnalyticsProject..SalesData
WHERE StateCD = 'NY'
  AND OrderDate BETWEEN '2019-11-01' AND '2019-11-30'
GROUP BY Product
ORDER BY 2 

------Query for Dec 2019 
SELECT Product    AS Product_DEC
      ,SUM(QuantityOrdered)   AS Total_Products_Sold_DEC
FROM SalesAnalyticsProject..SalesData
WHERE StateCD = 'NY'
  AND OrderDate BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY Product
ORDER BY 2 

----Query for comparing both Products Sold in Dec 2019 to Nov 2019
SELECT A.Product       AS Product
     , SUM(A.QuantityOrdered)   AS Total_Products_Sold_DEC
	 --, B.Product       AS Product_NOV
	 , B.Total_Products_Sold    AS Total_Products_Sold_NOV

FROM SalesAnalyticsProject..SalesData  AS A

JOIN (SELECT Product  
           , SUM(QuantityOrdered)   AS Total_Products_Sold   
	  FROM SalesAnalyticsProject..SalesData
	  WHERE StateCD = 'NY'
	    AND OrderDate BETWEEN '2019-11-01' AND '2019-11-30'
	  GROUP BY Product
	 )  AS  B
ON B.Product = A.Product

WHERE A.StateCD = 'NY'
  AND A.OrderDate BETWEEN '2019-12-01' AND '2019-12-31'
GROUP BY A.Product
       , B.Product
	   , B.Total_Products_Sold  
ORDER BY 1

--3. What is the monthly sales trend for Last Quarter of the Year 2019? Which month had the highest sales and which month had the lowest sales?
----Query to get monthly sales for the Last Quarter of the Year 2019 - For DashBoard Purpose
SELECT DISTINCT MONTH(OrderDate)  AS OrderMonth
     , SUM(Price)         AS Price
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY MONTH(OrderDate)
ORDER BY 2 

----Query to get monthly sales and Below is for the Highest month
SELECT DISTINCT TOP(1) MONTH(OrderDate)  AS OrderMonth
     , SUM(Price)         AS Price
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY MONTH(OrderDate)
ORDER BY 2 DESC
----Query to get monthly sales and Below is for the Lowest month
SELECT DISTINCT TOP(1) MONTH(OrderDate)  AS OrderMonth
     , SUM(Price)         AS Price
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY MONTH(OrderDate)
ORDER BY 2 

--4. What is the percentage of sales per month and how does it vary by states and product category?
----Query to get Percentage of Sales per month by states
--CA	CALIFORNIA
--GA	GEORGIA
--MA	MASSACHUSETTS
--ME	MAINE
--NY	NEW YORK
--OR	OREGON
--TX	TEXAS
--WA	WASHINGTON

----Let's see how many states were there using distinct statement
SELECT DISTINCT StateCD
              ,     CASE WHEN StateCD = 'TX' THEN 'Texas'
                     WHEN StateCD = 'ME' THEN 'Maine'
					 WHEN StateCD = 'WA' THEN 'Washington'
					 WHEN StateCD = 'MA' THEN 'Massachusetts'
					 WHEN StateCD = 'NY' THEN 'New York'
					 WHEN StateCD = 'CA' THEN 'California'
					 WHEN StateCD = 'OR' THEN 'Oregon'
					 WHEN StateCD = 'GA' THEN 'Georgia'
				END                  AS States
     , SUM(Price)         AS Price
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY StateCD
ORDER BY 2 

----Let's create the TEMP Table use above query created. 
DROP TABLE IF EXISTS MonthlySales
CREATE TABLE MonthlySales
(
 StateCD   nvarchar(2) not null 
,States  varchar(13)  not null
,TotalSales numeric
);

----Insert data into New TEMP Table created 
INSERT INTO MonthlySales
SELECT DISTINCT StateCD
              ,     CASE WHEN StateCD = 'TX' THEN 'Texas'
                     WHEN StateCD = 'ME' THEN 'Maine'
					 WHEN StateCD = 'WA' THEN 'Washington'
					 WHEN StateCD = 'MA' THEN 'Massachusetts'
					 WHEN StateCD = 'NY' THEN 'New York'
					 WHEN StateCD = 'CA' THEN 'California'
					 WHEN StateCD = 'OR' THEN 'Oregon'
					 WHEN StateCD = 'GA' THEN 'Georgia'
				END                  AS States
     , SUM(Price)         AS Price
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY StateCD
--ORDER BY 2

----Let's Verify if TEMP Table created successfully or not
SELECT * 
FROM MonthlySales

----Let's create a query to calculate total sales per month 
SELECT A.States 
	 , (B.Price/A.TotalSales)*100    AS OctSales
	 , (C.Price/A.TotalSales)*100    AS NovSales
	 , (D.Price/A.TotalSales)*100    AS DecSales
FROM MonthlySales   AS A
JOIN (SELECT StateCD   
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 10
	  GROUP BY StateCD
) AS B
ON B.StateCD = A.StateCD
JOIN (SELECT StateCD   
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 11
	  GROUP BY StateCD
) AS C
ON C.StateCD = A.StateCD
JOIN (SELECT StateCD   
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 12
	  GROUP BY StateCD
) AS D
ON D.StateCD = A.StateCD 
GROUP BY A.States
		, A.TotalSales
		, B.Price
		, C.Price
		, D.Price
ORDER BY 1

----Query to get Percentage of Sales per month by product category
----Let's see how many Category were there using distinct statement
SELECT DISTINCT Category 
     , SUM(Price)         AS TotalSales
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY Category
ORDER BY 2 

----Let's create the CTE Fucntion to use above query created. 
WITH CMonthSales (Category, TotalSales)
AS
(
SELECT DISTINCT Category 
     , SUM(Price)         AS TotalSales
FROM SalesAnalyticsProject..SalesData
WHERE MONTH(OrderDate) BETWEEN 10 AND 12
GROUP BY Category
--ORDER BY 2 
)
SELECT A.Category
	 , (B.Price/A.TotalSales)*100    AS OctSales
	 , (C.Price/A.TotalSales)*100    AS NovSales
	 , (D.Price/A.TotalSales)*100    AS DecSales
FROM CMonthSales   AS A
JOIN (SELECT Category  
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 10
	  GROUP BY Category
) AS B
ON B.Category = A.Category
JOIN (SELECT Category   
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 11
	  GROUP BY Category
) AS C
ON C.Category = A.Category
JOIN (SELECT Category 
           , SUM(Price)   AS Price
	  FROM SalesAnalyticsProject..SalesData
	  WHERE MONTH(OrderDate) = 12
	  GROUP BY Category
) AS D
ON D.Category = A.Category
GROUP BY A.Category
		, A.TotalSales
		, B.Price
		, C.Price
		, D.Price
ORDER BY 1
