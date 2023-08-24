
--SUBQUERIES
	SELECT SalesOrderID, SalesOrderDetailID, LineTotal, 
	ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC) AS LineTotalRanking
	FROM Sales.SalesOrderDetail

	-- Select where ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC) AS LineTotalRanking = 1
	
	SELECT *  
	FROM 
	(SELECT SalesOrderID, SalesOrderDetailID, LineTotal, 
	ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC) AS LineTotalRanking
	FROM Sales.SalesOrderDetail) as a
	WHERE LineTotalRanking = 1

--	Exercise 1


--Write a query that displays the three most expensive orders, per vendor ID, from the Purchasing.PurchaseOrderHeader table. 

SELECT 	PurchaseOrderID,
	VendorID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue
	FROM 
	(SELECT [PurchaseOrderID], VendorID,OrderDate, TaxAmt,Freight, TotalDue,
	ROW_NUMBER() OVER(PARTITION BY VendorID ORDER BY TotalDue DESC) as TotalRank
	FROM Purchasing.PurchaseOrderHeader) as a
	WHERE TotalRank <=3





--Exercise 2


--Modify your query from the first problem, such that the top three purchase order amounts are returned, regardless of how many records are returned per Vendor Id.



SELECT PurchaseOrderID,
	VendorID,
	OrderDate,
	TaxAmt,
	Freight,
	TotalDue
	FROM 
	(SELECT [PurchaseOrderID], VendorID,OrderDate, TaxAmt,Freight, TotalDue,
	DENSE_RANK() OVER(PARTITION BY VendorID ORDER BY TotalDue DESC) as TotalRank
	FROM Purchasing.PurchaseOrderHeader) as a
	WHERE TotalRank <=3




	-- SCALAR SUBQUERIES
--	Exercise 1


--Create a query that displays all rows and the following columns from the HumanResources.Employee table:

--BusinessEntityID

--JobTitle

--VacationHours

--Also include a derived column called "MaxVacationHours" that returns the maximum amount of vacation hours for any one employee, in any given row.


SELECT BusinessEntityID, 
JobTitle, VacationHours,
(SELECT MAX(VacationHours) FROM HumanResources.Employee) as MaxVacationHours
FROM HumanResources.Employee

--Exercise 2


--Add a new derived field to your query from Exercise 1, which returns the percent an individual employees' vacation hours are, of the maximum vacation hours for any employee. For example, the record for the employee with the most vacation hours should have a value of 1.00, or 100%, in this column.


SELECT BusinessEntityID, 
JobTitle, VacationHours,
(SELECT MAX(VacationHours) FROM HumanResources.Employee) as MaxVacationHours,
(VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee



--Exercise 3


--Refine your output with a criterion in the WHERE clause that filters out any employees whose vacation hours are less then 80% of the maximum amount of vacation hours for any one employee. In other words, return only employees who have at least 80% as much vacation time as the employee with the most vacation time.

SELECT BusinessEntityID, 
JobTitle, VacationHours,
(SELECT MAX(VacationHours) FROM HumanResources.Employee) as MaxVacationHours,
(VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee
WHERE (VacationHours * 1.0) / (SELECT MAX(VacationHours) FROM HumanResources.Employee) >= 0.8



-- Correlated Subqueries

SELECT SalesOrderID, OrderQty,
(SELECT COUNT(*) FROM Sales.SalesOrderDetail b WHERE b.SalesOrderID = a.SalesOrderID )MultiOrderCount
FROM Sales.SalesOrderDetail a 

--Correlated Subqueries - Exercises
--Exercise 1


--Write a query that outputs all records from the Purchasing.PurchaseOrderHeader table. Include the following columns from the table:

--PurchaseOrderID

--VendorID

--OrderDate

--TotalDue

--Add a derived column called NonRejectedItems which returns, for each purchase order ID in the query output, the number of line items from the Purchasing.PurchaseOrderDetail table which did not have any rejections (i.e., RejectedQty = 0). Use a correlated subquery to do this.

SELECT 

	PurchaseOrderID,
	VendorID, 
	OrderDate,
	TotalDue,
		(Select 
		COUNT(*) 
		FROM Purchasing.PurchaseOrderDetail b
		WHERE a.PurchaseOrderID = b.PurchaseOrderID 
		AND b.RejectedQty = 0) as NonRejectedItems 

FROM Purchasing.PurchaseOrderHeader a


--Exercise 2


--Modify your query to include a second derived field called MostExpensiveItem.

--This field should return, for each purchase order ID, the UnitPrice of the most expensive item for that order in the Purchasing.PurchaseOrderDetail table.

--Use a correlated subquery to do this as well.

SELECT 

	PurchaseOrderID,
	VendorID, 
	OrderDate,
	TotalDue,
		(Select 
		COUNT(*) 
		FROM Purchasing.PurchaseOrderDetail b
		WHERE a.PurchaseOrderID = b.PurchaseOrderID 
		AND b.RejectedQty = 0) as NonRejectedItems ,
		(
		SELECT MAX(UnitPrice) 
		FROM  Purchasing.PurchaseOrderDetail b
		WHERE a.PurchaseOrderID = b.PurchaseOrderID
        ) as MostExpensiveItem

FROM Purchasing.PurchaseOrderHeader a


--EXISTS - Exercises
--Exercise 1




--Select the following columns:

--PurchaseOrderID

--OrderDate

--SubTotal

--TaxAmt

--Sort by purchase order ID.

SELECT a.PurchaseOrderID, a.OrderDate, a.SubTotal, a.TaxAmt  FROM 
Purchasing.PurchaseOrderHeader a
WHERE EXISTS 
(SELECT 1 FROM Purchasing.PurchaseOrderDetail b 
WHERE a.PurchaseOrderID = b.PurchaseOrderID
AND b.OrderQty > 500)
ORDER BY 1 

--Exercise 2


--Modify your query from Exercise 1 as follows:

--Select all records from the Purchasing.PurchaseOrderHeader table such that there is at least one item in the order with an order quantity greater than 500, AND a unit price greater than $50.00.

--Select ALL columns from the Purchasing.PurchaseOrderHeader table for display in your output.


SELECT a.*  FROM 
Purchasing.PurchaseOrderHeader a
WHERE EXISTS 
(SELECT 1 FROM Purchasing.PurchaseOrderDetail b 
WHERE a.PurchaseOrderID = b.PurchaseOrderID
AND b.OrderQty > 500 AND b.UnitPrice > 50)
ORDER BY 1 


--Exercise 3


--Select all records from the Purchasing.PurchaseOrderHeader table such that NONE of the items within the order have a rejected quantity greater than 0.

--Select ALL columns from the Purchasing.PurchaseOrderHeader table using the "SELECT *" shortcut.

SELECT a.*  FROM 
Purchasing.PurchaseOrderHeader a
WHERE EXISTS 
(SELECT 1 FROM Purchasing.PurchaseOrderDetail b 
WHERE a.PurchaseOrderID = b.PurchaseOrderID
AND b.RejectedQty > 0)
ORDER BY 1 