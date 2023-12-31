

/*Create a query with the following columns:
FirstName and LastName, from the Person.Person table
JobTitle, from the HumanResources.Employee table
Rate, from the HumanResources.EmployeePayHistory table
A derived column called "AverageRate" that returns the average of all values in the "Rate" column, in each row
"MaximumRate" that returns the largest of all values in the "Rate" column, in each row.
"DiffFromAvgRate" that returns the result of the following calculation:
"PercentofMaxRate" that returns the result of the following calculation:An employees's pay rate, DIVIDED BY the maximum of all values in the "Rate" column, times 100.*/


SELECT 
 B.FirstName,
 B.LastName,
 C.JobTitle,
 A.Rate,
 AverageRate = AVG(A.Rate) OVER(),
 MaximumRate = MAX(A.Rate) OVER(),
 DiffFromAvgRate = A.Rate - AVG(A.Rate) OVER(),
 PercentofMaxRate = (A.Rate / MAX(A.Rate) OVER()) * 100

FROM AdventureWorks2019.HumanResources.EmployeePayHistory A
	JOIN AdventureWorks2019.Person.Person B
		ON A.BusinessEntityID = B.BusinessEntityID
	JOIN AdventureWorks2019.HumanResources.Employee C
		ON A.BusinessEntityID = C.BusinessEntityID

/*Create a query with the following columns:
“Name” from the Production.Product table, which can be alised as “ProductName”
“ListPrice” from the Production.Product table
“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”
“Name” from the Production.ProductCategory table, which can be alised as “ProductCategory”
"AvgPriceByCategory " that returns the average ListPrice for the product category in each given row.
"AvgPriceByCategoryAndSubcategory" that returns the average ListPrice for the product category AND subcategory in each given row.
"ProductVsCategoryDelta" that returns the result of the following calculation:
A product's list price, MINUS the average ListPrice for that product’s category.*/

select 
ProductName = A.Name ,
A.ListPrice,
ProductSubcategory = B.Name,
ProductCategory = C.Name,
AvgPricebyCategory = Avg(A.ListPrice) over(partition by C.Name),
AvgPricebyCategoryandSubcategory = avg(A.Listprice) over( partition by B.Name,C.Name),
ProductvsCategoryDelta = A.Listprice -  Avg(A.ListPrice) over(partition by C.Name)


from AdventureWorks2019.Production.Product A
	join adventureworks2019.Production.Productsubcategory B
		ON A.ProdUCtSubcategoryID = B.ProdUCtSubcategoryID
	join adventureworks2019.Production.Productcategory C
		ON B.ProductCategoryID = C.ProductCategoryID

/*"Price Rank " that ranks all records in the dataset by ListPrice, in descending order.
"Category Price Rank" that ranks all products by ListPrice – within each category - in descending order.
"Top 5 Price In Category" that returns the string “Yes” if a product has one of the top 5 list prices in its product category, and “No” if it does not*/

SELECT 
  ProductName = A.Name,
  A.ListPrice,
  ProductSubcategory = B.Name,
  ProductCategory = C.Name,
  PriceRank = ROW_NUMBER() OVER ( ORDER BY A.ListPrice DESC),
  CategoryPriceRank = ROW_NUMBER() OVER ( PARTITION BY C.Name ORDER BY A.ListPrice DESC) ,
  Top5PriceInCategory = CASE 
		WHEN ROW_NUMBER() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC) <= 5 THEN 'Yes'
		ELSE 'No'
	END



FROM AdventureWorks2019.Production.Product A
  JOIN AdventureWorks2019.Production.ProductSubcategory B
    ON A.ProductSubcategoryID = B.ProductSubcategoryID
  JOIN AdventureWorks2019.Production.ProductCategory C
    ON B.ProductCategoryID = C.ProductCategoryID

/*2.14  add a derived column called “Category Price Rank With Rank” that uses the RANK function to rank all products by ListPrice – within each category - in descending order
eturn a true top 5 products by price, assuming we want to see the top 5 distinct prices AND we want “ties” (by price) to all share the same rank. */

SELECT 
  ProductName = A.Name,
  A.ListPrice,
  ProductSubcategory = B.Name,
  ProductCategory = C.Name,
  PriceRank = ROW_NUMBER() OVER ( ORDER BY A.ListPrice DESC),
  CategoryPriceRank = ROW_NUMBER() OVER ( PARTITION BY C.Name ORDER BY A.ListPrice DESC) ,
  CategoryPriceRankWithRank = RANK() OVER ( PARTITION BY C.Name ORDER BY A.ListPrice DESC),
  CategoryPriceRankWithDenseRank = Dense_RANK() OVER ( PARTITION BY C.Name ORDER BY A.ListPrice DESC),
  Top5PriceInCategory = CASE 
		WHEN Dense_Rank() OVER(PARTITION BY C.Name ORDER BY A.ListPrice DESC) <= 5 THEN 'Yes'
		ELSE 'No'
	END


FROM AdventureWorks2019.Production.Product A
  JOIN AdventureWorks2019.Production.ProductSubcategory B
    ON A.ProductSubcategoryID = B.ProductSubcategoryID
  JOIN AdventureWorks2019.Production.ProductCategory C
    ON B.ProductCategoryID = C.ProductCategoryID


/*2.16Create a query with the following columns:
“PurchaseOrderID” from the Purchasing.PurchaseOrderHeader table
“OrderDate” from the Purchasing.PurchaseOrderHeader table
“TotalDue” from the Purchasing.PurchaseOrderHeader tablE
“Name” from the Purchasing.Vendor table, which can be aliased as “VendorName”
a derived column called"PrevOrderFromVendorAmt", that returns the “previous” TotalDue value (relative to the current row) within the group of all orders with the same vendor ID. We are defining “previous” based on order date.
 a derived column called"NextOrderByEmployeeVendor", that returns the “next” vendor name (the “name” field from Purchasing.Vendor) within the group of all orders that have the same EmployeeID value in Purchasing.PurchaseOrderHeader.
 Similar to the last exercise, we are defining “next” based on order date.adding a derived column called "Next2OrderByEmployeeVendor" that returns, within the group of all orders that have the same EmployeeID, the vendor name offset TWO orders into the “future” relative to the order in the current row. */


Select
[PurchaseOrderID],
[OrderDate],
[TotalDue],
VendorName = [Name],
PrevOrdeFromVendorAmt = lag(A.TotalDue) OVER(PARTITION BY ( A.VendorID) ORDER BY (A.OrderDate)),
NextOrderByEmployeeVendor = LEAD(B.Name) OVER(PARTITION BY A.EmployeeID ORDER BY A.OrderDate),
Next2OrderByEmployeeVendor = LEAD(B.Name,2) OVER(PARTITION BY A.EmployeeID ORDER BY A.OrderDate)


FROM [AdventureWorks2019].[Purchasing].[PurchaseOrderHeader] A
	JOIN  [AdventureWorks2019].[Purchasing].[Vendor] B
	ON A.[VendorID] = B.[BusinessEntityID] 

WHERE YEAR(A.orderdate) >= 2013
AND TotalDue > 500



/* 1)Create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
BusinessEntityID
JobTitle
VacationHours
Also include a derived column called "MaxVacationHours" that returns the maximum amount of vacation hours for any one employee, in any given row.
2)Add a new derived field to your query from Exercise 1, which returns the percent an individual employees' vacation hours are, of the maximum vacation hours for any employee
3)Refine your output with a criterion in the WHERE clause that filters out any employees whose vacation hours are less then 80% of the maximum amount of vacation hours for any one employee. */


select
[BusinessEntityID],
[JobTitle],
[VacationHours],
MaxVacationHours = (SELECT MAX ([VacationHours]) FROM [AdventureWorks2019].[HumanResources].[Employee]),
PercentOfMaxVacationHours = ([VacationHours]*1.0) /(SELECT MAX ([VacationHours]) FROM [AdventureWorks2019].[HumanResources].[Employee])

from [AdventureWorks2019].[HumanResources].[Employee]

WHERE ([VacationHours]*1.0) /(SELECT MAX ([VacationHours]) FROM [AdventureWorks2019].[HumanResources].[Employee]) >= 0.80



/* ( CORRELATED SUBQUEIRES)Write a query that outputs all records from the Purchasing.PurchaseOrderHeader table. Include the following columns from the table:
PurchaseOrderID
VendorID
OrderDate
TotalDue

Add a derived column called NonRejectedItems which returns, for each purchase order ID in the query output, the number of line items from the Purchasing.PurchaseOrderDetail table which did not have any rejections (i.e., RejectedQty = 0)
Modify your query to include a second derived field called MostExpensiveItem.

This field should return, for each purchase order ID, the UnitPrice of the most expensive item for that order in the Purchasing.PurchaseOrderDetail table.*/

SELECT
[PurchaseOrderID]
,[VendorID]
,[OrderDate]
,[TotalDue]
,NonRejectedItems = 
( select 
COUNT(*)
FROM [AdventureWorks2019].[Purchasing].[PurchaseOrderDetail] b
WHERE a.[PurchaseOrderID] = b.[PurchaseOrderID]
AND b.[RejectedQty] = 0
)
,MostExpensiveItem = 
(select
max ([UnitPrice])
from [AdventureWorks2019].[Purchasing].[PurchaseOrderDetail] b
where a.[PurchaseOrderID] = b.[PurchaseOrderID])

FROM
[AdventureWorks2019].[Purchasing].[PurchaseOrderHeader] a




/*Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity greater than 500, AND a unit price greater than $50.00.*/

select 
[PurchaseOrderID],
[OrderDate],
[SubTotal],
[TaxAmt]

from [AdventureWorks2019].[Purchasing].[PurchaseOrderHeader] a

where exists 
( select 1 from [AdventureWorks2019].[Purchasing].[PurchaseOrderDetail] b 
where b.[OrderQty] >500 
AND a.[PurchaseOrderID] = b.[PurchaseOrderID] 
AND b.[UnitPrice] > 50 )

order by [PurchaseOrderID]

/*Select all records from the Purchasing.PurchaseOrderHeader table such that NONE of the items within the order have a rejected quantity greater than 0.*/



SELECT
       A.*

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A
WHERE NOT EXISTS (
	SELECT
	1
	FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail B
	WHERE A.PurchaseOrderID = B.PurchaseOrderID
		AND B.RejectedQty > 0
)
ORDER BY 1



/* ( XML PATH function)Create a query that displays all rows from the Production.ProductSubcategory table, and includes the following fields:
The "Name" field from Production.ProductSubcategory, which should be aliased as "SubcategoryName".
A derived field called "Products" which displays, for each Subcategory in Production.ProductSubcategory, a semicolon-separated list of all products from Production.Product contained within the given subcategory uch that only products with a ListPrice value greater than $50 are listed in the "Products" field.*/

select 
SubcategoryName = a.[Name],

Products = stuff (
( select ';' + B.[Name]
from [AdventureWorks2019].[Production].[Product] b
where a.[ProductSubcategoryID] = b.[ProductSubcategoryID]
and b.[ListPrice] >50
for xml path ('')
),
1,1,'')

from [AdventureWorks2019].[Production].[ProductSubcategory] a


/*Using PIVOT, write a query against the HumanResources.Employee table

that summarizes the average amount of vacation time for Sales Representatives, Buyers, and Janitors.such that the results are broken out by Gender. Alias the Gender field as "Employee Gender" in your output*/


SELECT
[Employee Gender] = Gender,
[Sales Representative],
Buyer,
Janitor
FROM
(
SELECT 
JobTitle,
Gender,
VacationHours

FROM AdventureWorks2019.HumanResources.Employee
) A

PIVOT(
AVG(VacationHours)
FOR JobTitle IN([Sales Representative],[Buyer],[Janitor])
) B


/*Use a recursive CTE to generate a date series of all FIRST days of the month (1/1/2021, 2/1/2021, etc.)

from 1/1/2020 to 12/1/2029.*/

WITH Dates AS
(
SELECT
 CAST('01-01-2020' AS DATE) AS MyDate

UNION ALL

SELECT
DATEADD(MONTH, 1, MyDate)
FROM Dates
WHERE MyDate < CAST('12-01-2029' AS DATE)
)

SELECT
MyDate

FROM Dates
OPTION (MAXRECURSION 120)


/*temp tables*/


SELECT 
       OrderDate
	  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
      ,TotalDue
	  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
INTO #Sales
FROM AdventureWorks2019.Sales.SalesOrderHeader


SELECT
OrderMonth,
TotalSales = SUM(TotalDue)
INTO #SalesMinusTop10
FROM #Sales
WHERE OrderRank > 10
GROUP BY OrderMonth



SELECT 
       OrderDate
	  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
      ,TotalDue
	  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
INTO #Purchases
FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader


SELECT
OrderMonth,
TotalPurchases = SUM(TotalDue)
INTO #PurchasesMinusTop10
FROM #Purchases
WHERE OrderRank > 10
GROUP BY OrderMonth



SELECT
A.OrderMonth,
A.TotalSales,
B.TotalPurchases

FROM #SalesMinusTop10 A
	JOIN #PurchasesMinusTop10 B
		ON A.OrderMonth = B.OrderMonth

ORDER BY 1

DROP TABLE #Sales
DROP TABLE #SalesMinusTop10
DROP TABLE #Purchases
DROP TABLE #PurchasesMinusTop10


/* Update exercise*/

CREATE TABLE #SalesOrders
(
 SalesOrderID INT,
 OrderDate DATE,
 TaxAmt MONEY,
 Freight MONEY,
 TotalDue MONEY,
 TaxFreightPercent FLOAT,
 TaxFreightBucket VARCHAR(32),
 OrderAmtBucket VARCHAR(32),
 OrderCategory VARCHAR(32),
 OrderSubcategory VARCHAR(32)
)

INSERT INTO #SalesOrders
(
 SalesOrderID,
 OrderDate,
 TaxAmt,
 Freight,
 TotalDue,
 OrderCategory
)

SELECT
 SalesOrderID,
 OrderDate,
 TaxAmt,
 Freight,
 TotalDue,
 OrderCategory = 'Non-holiday Order'

FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]

WHERE YEAR(OrderDate) = 2013


UPDATE #SalesOrders
SET 
TaxFreightPercent = (TaxAmt + Freight)/TotalDue,
OrderAmtBucket = 
	CASE
		WHEN TotalDue < 100 THEN 'Small'
		WHEN TotalDue < 1000 THEN 'Medium'
		ELSE 'Large'
	END


UPDATE #SalesOrders
SET TaxFreightBucket = 
	CASE
		WHEN TaxFreightPercent < 0.1 THEN 'Small'
		WHEN TaxFreightPercent < 0.2 THEN 'Medium'
		ELSE 'Large'
	END


UPDATE #SalesOrders
SET  OrderCategory = 'Holiday'
FROM #SalesOrders
WHERE DATEPART(quarter,OrderDate) = 4


UPDATE #SalesOrders
SET OrderSubcategory = OrderCategory + ' - ' + OrderAmtBucket

SELECT * FROM #SalesOrders

DROP TABLE #SalesOrders

/*------------------------------------------------------------------------------------------------------------------------------*/
/*OPTIMIZING WITH UPDATES STAATMENTS : */

-- Create the temporary table #PersonContactInfo
CREATE TABLE #PersonContactInfo
(
    BusinessEntityID INT,
    Title VARCHAR(8),
    FirstName VARCHAR(50),
    MiddleName VARCHAR(50),
    LastName VARCHAR(50),
    PhoneNumber VARCHAR(25),
    PhoneNumberTypeID INT, -- Corrected to INT
    PhoneNumberType VARCHAR(25),
    EmailAddress VARCHAR(50)
)

-- Insert data into #PersonContactInfo from AdventureWorks2019.Person.Person
INSERT INTO #PersonContactInfo
(
    BusinessEntityID,
    Title,
    FirstName,
    MiddleName,
    LastName
)
SELECT
    BusinessEntityID,
    Title,
    FirstName,
    MiddleName,
    LastName
FROM AdventureWorks2019.Person.Person

-- Update PhoneNumber and PhoneNumberTypeID columns
UPDATE A
SET
    PhoneNumber = B.PhoneNumber,
    PhoneNumberTypeID = B.PhoneNumberTypeID
FROM #PersonContactInfo A
JOIN AdventureWorks2019.Person.PersonPhone B
ON A.BusinessEntityID = B.BusinessEntityID

-- Update PhoneNumberType column
UPDATE A
SET PhoneNumberType = B.Name
FROM #PersonContactInfo A
JOIN AdventureWorks2019.Person.PhoneNumberType B
ON A.PhoneNumberTypeID = B.PhoneNumberTypeID

-- Update EmailAddress column
UPDATE A
SET EmailAddress = B.EmailAddress
FROM #PersonContactInfo A
JOIN AdventureWorks2019.Person.EmailAddress B
ON A.BusinessEntityID = B.BusinessEntityID

-- Select data from #PersonContactInfo
SELECT * FROM #PersonContactInfo

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*Exercise 1

Update your calendar lookup table with a few holidays of your choice that always fall on the same day of the year - for example, New Year's.


Exercise 2

Using your updated calendar table, pull all purchasing orders that were made on a holiday. It's fine to simply select all columns via SELECT *.


Exercise 3

Again using your updated calendar table, now pull all purchasing orders that were made on a holiday that also fell on a weekend*/

--Exercise 1

UPDATE AdventureWorks2019.dbo.Calendar
SET
HolidayFlag =
	CASE
		WHEN DayOfMonthNumber = 1 AND MonthNumber = 1 THEN 1
		WHEN DayOfMonthNumber = 4 AND MonthNumber = 7 THEN 1
		WHEN DayOfMonthNumber = 11 AND MonthNumber = 11 THEN 1
		WHEN DayOfMonthNumber = 25 AND MonthNumber = 12 THEN 1
		ELSE 0
	END


--Exercise 2

SELECT
A.*

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A
	JOIN AdventureWorks2019.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.HolidayFlag = 1

--Exercise 3

SELECT
A.*

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A
	JOIN AdventureWorks2019.dbo.Calendar B
		ON A.OrderDate = B.DateValue

WHERE B.HolidayFlag = 1
	AND B.WeekendFlag = 1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Let's say your company pays once per month, on the 15th.

If it's already the 15th of the current month (or later), the previous pay period will run from the 15th of the previous month, to the 14th of the current month.

If on the other hand it's not yet the 15th of the current month, the previous pay period will run from the

15th two months ago to the 14th on the previous month.*/
DECLARE @Today DATE = CAST(GETDATE() AS DATE)

SELECT @Today

DECLARE @Current14 DATE = DATEFROMPARTS(YEAR(@Today),MONTH(@Today),14)

DECLARE @PayPeriodEnd DATE = 
	CASE
		WHEN DAY(@Today) < 15 THEN DATEADD(MONTH,-1,@Current14)
		ELSE @Current14
	END

DECLARE @PayPeriodStart DATE = DATEADD(DAY,1,DATEADD(MONTH,-1,@PayPeriodEnd))


SELECT @PayPeriodStart
SELECT @PayPeriodEnd

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Exercise 1

Create a user-defined function that returns the percent that one number is of another.
For example, if the first argument is 8 and the second argument is 10, the function should return the string "80.00%".
The function should solve the "integer division" problem by allowing you to divide an integer by another integer, and yet get an accurate decimal result.

Exercise 2

Store the maximum amount of vacation time for any individual employee in a variable.
Then create a query that displays all rows and the following columns from the AdventureWorks2019.HumanResources.Employee table:
BusinessEntityID
JobTitle
VacationHours
Then add a derived field called "PercentOfMaxVacation", which returns the percent an individual employees' vacation hours are of the maximum vacation hours for any employee*/

--Exercise 1

CREATE FUNCTION dbo.ufnIntegerPercent(@Numerator INT, @Denominator INT)
RETURNS VARCHAR(8)
AS   
BEGIN

	DECLARE @Decimal FLOAT  = (@Numerator * 1.0) / @Denominator

	RETURN FORMAT(@Decimal, 'P')

END

--Exercise 2

DECLARE @MaxVacationHours INT = (SELECT MAX(VacationHours) FROM AdventureWorks2019.HumanResources.Employee)

SELECT
	BusinessEntityID,
	JobTitle,
	VacationHours,
	PercentOfMaxVacation = dbo.ufnIntegerPercent(VacationHours, @MaxVacationHours)

FROM AdventureWorks2019.HumanResources.Employee

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


















