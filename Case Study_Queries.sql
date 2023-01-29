--Product Analysis
--No 1. Top 10 Product by Avg Discount
SELECT TOP 10 p.ProductName AS "Product",
	ROUND(AVG(od.Discount)*100,2) AS "Avg. Discount (%)"
FROM [Order Details] od
INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY 2 DESC;

--No 2. 10 worst selling products by sales value include products that have at least been sold onces
Select TOP 10 od.OrderID, p.ProductName, od.Quantity, SUM(od.UnitPrice * od.Quantity *(1-od.Discount)) AS Total_sales  
FROM  Products p 
JOIN  [Order Details] od
ON p.ProductID = od.ProductID
JOIN Orders o 
ON o.OrderID = od.OrderID
WHERE od.Quantity = 1
GROUP BY od.Quantity, od.OrderID, p.ProductName
ORDER BY Total_sales

--No 3. Top 10 products by revenue after discounts
SELECT TOP 10 p.ProductName AS Product,
	ROUND(SUM((od.UnitPrice * od.Quantity * (1 -od.Discount))),2) AS "Revenue"
FROM [Order Details] od
INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY 2 DESC;

--No 4. Top 10 products by quantity order
SELECT TOP 10 p.ProductName AS Product,
	SUM(od.Quantity) AS "Quantity"
FROM [Order Details] od
INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY 2 DESC;

--No 5. %Revenue by product categories
SELECT c.CategoryName AS "Category",
	ROUND((SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) / 
		(SELECT SUM(UnitPrice * Quantity * (1 - Discount)) FROM [Order Details]))*100,2) AS "% of Revenue"
FROM [Order Details] od
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY 2 DESC;

--No 6. Best month for sale products in terms of sales value
SELECT Month(o.OrderDate) AS Month, SUM(od.UnitPrice * od.Quantity *(1-od.Discount)) AS Total_sales
FROM Orders o 
JOIN [Order Details] od 
ON o.OrderID = od.OrderID
GROUP BY Month(o.OrderDate)
ORDER BY Total_sales DESC

--Customer Analysis
--No 7. Categorize customers into groups, based on how much they ordered in 1997. The customer grouping categories are 0 to 1,000, 1,000 to 5,000, 5,000 to 10,000, and over 10,000.
SELECT
	customers.CustomerID,
	customers.CompanyName,
	TotalOrderAmount = SUM(order_details.UnitPrice * order_details.Quantity),
	CASE
		WHEN SUM(order_details.UnitPrice * order_details.Quantity) > 10000 THEN 'Very High'
		WHEN SUM(order_details.UnitPrice * order_details.Quantity) BETWEEN 5000 AND 10000 THEN 'High'
		WHEN SUM(order_details.UnitPrice * order_details.Quantity) BETWEEN 1000 AND 5000 THEN 'Medium'
		ELSE 'Low'
	END AS Category

FROM Northwind.dbo.Customers AS customers

JOIN Northwind.dbo.Orders AS orders
	ON customers.CustomerID = orders.CustomerID
JOIN Northwind.dbo.[Order Details] AS order_details
	ON orders.OrderID = order_details.OrderID 

WHERE
	orders.OrderDate >= '19970101'
	and orders.OrderDate < '19980101'

GROUP BY
	customers.CustomerID,
	customers.CompanyName

ORDER BY
	TotalOrderAmount DESC

--No 8. Top 5 country where have the most customers
SELECT TOP 5 Country, COUNT(CustomerID) AS number_of_Customer FROM Customers
GROUP BY Country
Order by number_of_Customer DESC

--Employee Analysis
--No 9. The percentage of late orders over total orders
WITH AllOrders AS
(SELECT
	 EmployeeID, COUNT(*) AS TotalOrders
FROM
	Orders
GROUP BY
	EmployeeID
),
LateOrders AS
(SELECT
	 EmployeeID, COUNT(*) AS TotalOrders
FROM
	Orders
WHERE
	RequiredDate < ShippedDate
GROUP BY
	EmployeeID
)
	

SELECT
	Employees.EmployeeID,
	Employees.LastName,
	Allorders = AllOrders.TotalOrders,
	Lateorders = LateOrders.TotalOrders,
	PercentLateOrder = CAST(ROUND((LateOrders.TotalOrders*1.00/AllOrders.TotalOrders)*100, 2) as float)

FROM Employees
JOIN AllOrders
ON Employees.EmployeeID = AllOrders.EmployeeID
JOIN LateOrders
ON Employees.EmployeeID = LateOrders.EmployeeID

--No 10. Top 5 Sales Person
SELECT Top 5 e.EmployeeID, COUNT(o.OrderID) AS Total_Orders
FROM Employees e JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
ORDER BY Total_Orders DESC
