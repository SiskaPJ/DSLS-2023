--No 1
	select year(OrderDate) order_year, 
		month(OrderDate) order_month,
		count(CustomerID) count_customer
	from dbo.Orders
	where year(OrderDate) = 1997
	group by year(OrderDate) , 
		month(OrderDate) 
	;

--No 2
	select concat(LastName,', ', FirstName) employee_name
	from dbo.Employees
	where Title = 'Sales Representative'

--No 3
SELECT TOP 5 c.ProductID, c.ProductName, SUM(b.Quantity) as 'Quantity'
FROM Orders as a
JOIN [Order Details] as b on b.OrderID = a.OrderID
JOIN Products as c on c.ProductID = b.ProductID
WHERE YEAR(a.OrderDate) = '1997' AND MONTH(a.OrderDate) = '1'
GROUP BY c.ProductID, c.ProductName
ORDER BY Quantity DESC;

--No 4
SELECT d.CompanyName
FROM Orders as a
JOIN [Order Details] as b on b.OrderID = a.OrderID
JOIN Products as c on c.ProductID = b.ProductID
JOIN Customers as d on d.CustomerID = a.CustomerID
WHERE YEAR(a.OrderDate) = '1997' AND MONTH(a.OrderDate) = '6' AND c.ProductName = 'Chai';

--No 5
WITH TOTAL_PRICE AS (SELECT ORDERID,UnitPrice*Quantity AS Total_Price
FROM [Order Details]),
category_price as(select *, 
case when Total_Price <=100 then '<=100' 
when Total_Price >100 and Total_Price <= 250 then '100<x<=250' 
when Total_Price >250 and Total_Price <= 500 then '250<x<=500' 
else '>500' end as category
from TOTAL_PRICE)

select count(distinct OrderID) as total_orderID, category from category_price group by category

--No 6
SELECT DISTINCT(c.CompanyName)
FROM Customers as c
JOIN Orders as o on o.CustomerID = c.CustomerID
JOIN [Order Details] as od on od.OrderID = o.OrderID
WHERE od.Quantity*od.UnitPrice > 500;

--No 7
;WITH MonthsCTE(m) as
(
    SELECT 1 m
    UNION ALL 
    SELECT m+1
    FROM MonthsCTE
    WHERE m < 12
)
SELECT m [Month], t.*
FROM MonthsCTE
CROSS APPLY 
(
    SELECT TOP 5
		b.ProductName, 
		SUM(a.Quantity*a.UnitPrice) as 'Sales'
    FROM [Order Details] as a
	JOIN Products as b on b.ProductID = a.ProductID
	JOIN Orders as c on c.OrderID = a.OrderID
    WHERE  MONTH(c.OrderDate) = MonthsCTE.m
    GROUP BY b.ProductName
    ORDER BY Sales DESC
) t

--No 8
CREATE VIEW specific_order_details AS
SELECT 
	OrderID,
	[Order Details].ProductID,
	ProductName,
	[Order Details].UnitPrice,
	Quantity,
	Discount,
	[Order Details].UnitPrice * Quantity AS RetailPrice,
	[Order Details].UnitPrice * Quantity * Discount AS Disc,
	([Order Details].UnitPrice * Quantity) - ([Order Details].UnitPrice * Quantity * Discount) AS PriceAfterDisc
FROM [Order Details]
INNER JOIN Products ON [Order Details].ProductID = Products.ProductID

--No 9
CREATE PROCEDURE Invoice @CustomerID nvarchar(5) AS
SELECT a.CustomerID, a.CompanyName, b.OrderID, b.OrderDate, b.RequiredDate, b.ShippedDate
FROM Customers as a
JOIN Orders as b on b.CustomerID = a.CustomerID
WHERE a.CustomerID = @CustomerID;
EXEC Invoice @CustomerID = 'QUEEN';
