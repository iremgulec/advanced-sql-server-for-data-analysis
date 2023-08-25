--Recursive CTEs - Exercises
--Exercise 1
--Use a recursive CTE to generate a list of all odd numbers between 1 and 100.



WITH NumberSeries AS (
SELECT 1 AS MyNumber
UNION ALL 

SELECT MyNumber + 2
FROM NumberSeries
WHERE MyNumber BETWEEN 1 AND 98 )

SELECT MyNumber 
FROM
NumberSeries;


--Exercise 2


--Use a recursive CTE to generate a date series of all FIRST days of the month (1/1/2021, 2/1/2021, etc.)

--from 1/1/2020 to 12/1/2029.

WITH DateSeries AS 
(
SELECT CAST('1-1-2020' AS DATE) AS MyDate

UNION ALL
SELECT 
DATEADD(MONTH, 1, MyDate)
FROM DateSeries 
WHERE MyDate < CAST('12-1-2029' AS DATE)
)

SELECT 
MyDate 
FROM DateSeries
OPTION(MAXRECURSION 120)

