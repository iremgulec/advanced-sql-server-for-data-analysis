-- WINDOW FUNCTION
-- PARTITION BY

--Exercise 1


--Create a query with the following columns:



--“Name” from the Production.Product table, which can be alised as “ProductName”

--“ListPrice” from the Production.Product table

--“Name” from the Production. ProductSubcategory table, which can be alised as “ProductSubcategory”*

--“Name” from the Production.ProductCategory table, which can be alised as “ProductCategory”**



SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 

--Exercise 2


--Enhance your query from Exercise 1 by adding a derived column called

--"AvgPriceByCategory " that returns the average ListPrice for the product category in each given row.

SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
AVG(a.ListPrice) OVER(PARTITION BY c.Name) AS AvgPriceByCategory
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


--Exercise 3


--Enhance your query from Exercise 2 by adding a derived column called

--"AvgPriceByCategoryAndSubcategory" that returns the average ListPrice for the product category AND subcategory in each given row.

SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
AVG(a.ListPrice) OVER() AS AvgPriceByCategory,
AVG(a.ListPrice) OVER(PARTITION BY c.Name, b.Name) AS AvgPriceByCategoryAndSubcategory
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 

--Exercise 4:


--Enhance your query from Exercise 3 by adding a derived column called

--"ProductVsCategoryDelta" that returns the result of the following calculation:



--A product's list price, MINUS the average ListPrice for that product’s category.


SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
AVG(a.ListPrice) OVER() AS AvgPriceByCategory,
AVG(a.ListPrice) OVER(PARTITION BY c.Name, b.Name) AS AvgPriceByCategoryAndSubcategory,
a.ListPrice- (AVG(a.ListPrice) OVER(PARTITION BY c.name)) 
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


-- ROW_NUMBER()
--Exercise 1


--Create a query with the following columns (feel free to borrow your code from Exercise 1 of the PARTITION BY exercises):

SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


--Exercise 2


--Enhance your query from Exercise 1 by adding a derived column called

--"Price Rank " that ranks all records in the dataset by ListPrice, in descending order. That is to say, the product with the most expensive price should have a rank of 1, and the product with the least expensive price should have a rank equal to the number of records in the dataset.

SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
ROW_NUMBER() OVER(ORDER BY a.ListPrice DESC) as 'Price Rank' 
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


--Exercise 3


--Enhance your query from Exercise 2 by adding a derived column called

--"Category Price Rank" that ranks all products by ListPrice – within each category - in descending order. In other words, every product within a given category should be ranked relative to other products in the same category.

SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
ROW_NUMBER() OVER(ORDER BY a.ListPrice DESC) as 'Price Rank',
ROW_NUMBER() OVER(PARTITION BY c.Name ORDER BY a.ListPrice DESC) as 'Category Price Rank'
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


--Exercise 4


--Enhance your query from Exercise 3 by adding a derived column called

--"Top 5 Price In Category" that returns the string “Yes” if a product has one of the top 5 list prices in its product category, and “No” if it does not. 
SELECT a.Name as ProductName, a.ListPrice, b.Name as ProductSubcategory , c.Name as ProductCategory,
ROW_NUMBER() OVER(ORDER BY a.ListPrice DESC) as 'Price Rank',
ROW_NUMBER() OVER(PARTITION BY c.Name ORDER BY a.ListPrice DESC) as 'Category Price Rank',
CASE
    WHEN ROW_NUMBER() OVER(PARTITION BY c.Name ORDER BY a.ListPrice DESC)  BETWEEN  1 AND 5 THEN 'Yes'
    ELSE 'No'
END as 'Top 5 Price In Category'
FROM Production.Product a 
JOIN  Production.ProductSubcategory b ON a.ProductSubcategoryID = b.ProductSubcategoryID
JOIN  Production.ProductCategory c ON b.ProductCategoryID = c.ProductCategoryID 


-- LEAD AND LAG 
--Exercise 1
                                                                                               

SELECT a.PurchaseOrderID, a.OrderDate, a.TotalDue, b.name as VendorName FROM Purchasing.PurchaseOrderHeader a
INNER JOIN  Purchasing.Vendor b ON a.VendorID = b.BusinessEntityID
WHERE YEAR(OrderDate) > 2013 AND a.TotalDue >= 500;


--Exercise 2


--Modify your query from Exercise 1 by adding a derived column called

--"PrevOrderFromVendorAmt", that returns the “previous” TotalDue value (relative to the current row) within the group of all orders with the same vendor ID. We are defining “previous” based on order date.	


SELECT a.PurchaseOrderID, a.OrderDate, a.TotalDue, b.name as VendorName,
LAG(a.TotalDue) OVER(PARTITION BY a.VendorID ORDER BY a.OrderDate)
FROM Purchasing.PurchaseOrderHeader a
INNER JOIN  Purchasing.Vendor b ON a.VendorID = b.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013 AND a.TotalDue >= 500
ORDER BY a.VendorID, a.OrderDate

--Exercise 3


--Modify your query from Exercise 2 by adding a derived column called

--"NextOrderByEmployeeVendor", that returns the “next” vendor name (the “name” field from Purchasing.Vendor) within the group of all orders that have the same EmployeeID value in Purchasing.PurchaseOrderHeader. Similar to the last exercise, we are defining “next” based on order date.

SELECT a.PurchaseOrderID, a.OrderDate, a.TotalDue, b.name as VendorName,
LAG(a.TotalDue) OVER(PARTITION BY a.VendorID ORDER BY a.OrderDate) PrevOrderFromVendorAmt,
LEAD(b.Name) OVER(PARTITION BY a.EmployeeID ORDER BY a.OrderDate) NextOrderByEmployeeVendor 
FROM Purchasing.PurchaseOrderHeader a
INNER JOIN  Purchasing.Vendor b ON a.VendorID = b.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013 AND a.TotalDue >= 500
ORDER BY a.EmployeeID, a.OrderDate


--Exercise 4


--Modify your query from Exercise 3 by adding a derived column called "Next2OrderByEmployeeVendor" that returns, within the group of all orders that have the same EmployeeID, the vendor name offset TWO orders into the “future” relative to the order in the current row. The code should be very similar to Exercise 3, but with an extra argument passed to the Window Function used.
SELECT a.PurchaseOrderID, a.OrderDate, a.TotalDue, b.name as VendorName,
LAG(a.TotalDue) OVER(PARTITION BY a.VendorID ORDER BY a.OrderDate) PrevOrderFromVendorAmt,
LEAD(b.Name) OVER(PARTITION BY a.EmployeeID ORDER BY a.OrderDate) NextOrderByEmployeeVendor, 
LEAD(B.Name,3) OVER(PARTITION BY A.EmployeeID ORDER BY A.OrderDate) Next2OrderByEmployeeVendor
FROM Purchasing.PurchaseOrderHeader a
INNER JOIN  Purchasing.Vendor b ON a.VendorID = b.BusinessEntityID
WHERE YEAR(OrderDate) >= 2013 AND a.TotalDue >= 500
ORDER BY a.EmployeeID, a.OrderDate


