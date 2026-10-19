--challenge 1 :Top 10 customers by revenue
SELECT c.companyName,
     ROUND(SUM(od.unitPrice * quantity *(1-discount)),2)
	 AS totalsalesRevenue
FROM customers AS c
LEFT JOIN orders AS O
ON c.customerID = o.customerID
LEFT JOIN order_details AS od
ON od.orderID = o.orderID
GROUP BY companyName
ORDER BY totalsalesRevenue DESC
LIMIT 10;

--challenge 2 :AverageOrder
SELECT
     ROUND(SUM(od.unitPrice * od.quantity * (1-od.discount))/ 
	 COUNT(DISTINCT(o.orderID))
	 ,2) AS avgsalesRevenue
FROM orders AS o
LEFT JOIN order_details AS od
ON od.orderID = o.orderID;
	 
	 
SELECT
    strftime('%Y-%m', o.orderDate) AS yearMonth,
    ROUND(
        SUM(od.unitPrice * od.quantity * (1 - od.discount)),
        2
    ) AS totalRevenue
FROM orders AS o
LEFT JOIN order_details AS od
    ON o.orderID = od.orderID
GROUP BY strftime('%Y-%m', o.orderDate)
ORDER BY yearMonth ASC;

SELECT p.productName
FROM products AS p
LEFT JOIN order_details AS od
ON od.productID = p.productID
WHERE od.productID IS NULL
GROUP BY p.productName;


SELECT productName,
     SUM(quantity) AS quantitySold
FROM products AS p
LEFT JOIN order_details AS od
ON od.productID = p.productID
GROUP BY productName
ORDER BY quantitySold ASC
LIMIT 10;

SELECT productName,
    ROUND(SUM(od.unitPrice * od.quantity *(1-od.discount)),2) 
	AS totalsalesRevenue
FROM products AS p
LEFT JOIN order_details AS od
ON od.productID = p.productID
GROUP BY productName
ORDER BY totalsalesRevenue ASC
LIMIT 10;	

SELECT companyNme,
     ROUND(SUM(o.shipperID))/COUNT(o.shipperID),2) 
	 AS AvgshippingCost
 FROM shiipers AS s
 LEFT JOIN orders AS o
 ON s.shipperID = o.shipperID
 GROUP BY companyName,
		  AvgshippingCost
ORDER BY avgshippingCost;
SELECT
    s.companyName AS shippingProvider,
    COUNT(o.orderID) AS totalOrders,
    ROUND(AVG(o.freight), 2) AS averageShippingCost
FROM shippers AS s
LEFT JOIN orders AS o
    ON s.shipperID = o.shipperID
GROUP BY s.companyName
ORDER BY averageShippingCost DESC;	

--SUBQUERIES
SELECT productName,unitPrice
FROM products  
WHERE unitPrice >
(SELECT AVG(unitPrice)
 FROM products)
ORDER BY unitPrice DESC;

SELECT companyName,
 ROUND(SUM(od.unitPrice*od.quantity*(1-discount)),2) AS totalsalesRevenue
 FROM customers AS c
 JOIN orders AS o
 ON c.customerID = o.customerID
 LEFT JOIN order_details AS od
 ON od.orderID = o.orderID
 GROUP BY companyName
 ORDER BY totalsalesRevenue DESC
 WHERE totalsalesRevenue >
 (
 SELECT ROUND(

 SELECT ROUND(AVG(totalsalesRevenue), 2) AS averageCustomerSpending
FROM (
    SELECT companyName,
           SUM(od.unitPrice * od.quantity * (1 - discount)) AS totalsalesRevenue
    FROM customers AS c
    JOIN orders AS o
        ON c.customerID = o.customerID
    LEFT JOIN order_details AS od
        ON od.orderID = o.orderID
    GROUP BY companyName
) AS customer_totals;

SELECT
    companyName,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS totalsalesRevenue
FROM customers AS c
JOIN orders AS o
    ON c.customerID = o.customerID
LEFT JOIN order_details AS od
    ON od.orderID = o.orderID
GROUP BY c.customerID, companyName

HAVING SUM(od.unitPrice * od.quantity * (1 - od.discount)) >
(
    SELECT AVG(totalsalesRevenue)
    FROM (
        SELECT
            c2.customerID,
            SUM(od2.unitPrice * od2.quantity * (1 - od2.discount)) AS totalsalesRevenue
        FROM customers AS c2
        JOIN orders AS o2
            ON c2.customerID = o2.customerID
        LEFT JOIN order_details AS od2
            ON od2.orderID = o2.orderID
        GROUP BY c2.customerID
    ) AS customer_totals
)

ORDER BY totalsalesRevenue DESC;

-- Expensive products by category
SELECT
    c.categoryName,
    p.productName,
    p.unitPrice
FROM products AS p
JOIN categories AS c
    ON p.categoryID = c.categoryID
WHERE p.unitPrice = (
    SELECT MAX(p2.unitPrice)
    FROM products AS p2
    WHERE p2.categoryID = p.categoryID
)
ORDER BY c.categoryName;


--Top 5 customers by  revenue
WITH customerRevenue AS (
    SELECT c.companyName,
	 SUM(od.unitPrice *od.quantity *(1-od.discount)) AS totalRevenue
FROM customers AS c 
 JOIN orders AS o
 ON c.customerID = o.customerID
 JOIN order_details AS od
ON od.orderID = o.orderID
GROUP BY c.companyName,c.customerID
)
SELECT
 companyName,
 ROUND(totalRevenue,2) AS totalRevenue
 FROM customerRevenue
 ORDER BY totalRevenue DESC
 LIMIT 5;
 
 
 --MontlySales comparison
 WITH monthlySales AS (
 SELECT
	strftime('%Y-%m', o.orderDate) AS salesMonth,
	SUM(od.unitPrice * od.quantity *(1-od.discount)) AS monthlyRevenue
FROM orders AS o
JOIN order_details AS od
   ON od.orderID = o.orderID
GROUP BY strftime('%Y-%m',o.orderDate) 
)
SELECT 
	  salesMonth,
    ROUND(monthlyRevenue,2) AS monthlyRevenue
FROM monthlySales
WHERE monthlyRevenue > (
 SELECT AVG(monthlyRevenue)
 FROM monthlySales
 )
 ORDER BY monthlyRevenue DESC;
 
 
-- : Product Revenue Comparison
 WITH productRevenue AS (
    SELECT
        p.productID,
        p.productName,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS totalRevenue
    FROM products AS p
    JOIN order_details AS od
        ON p.productID = od.productID
    GROUP BY p.productID, p.productName
)
SELECT
    productName,
    ROUND(totalRevenue, 2) AS totalRevenue
FROM productRevenue
WHERE totalRevenue > (
    SELECT AVG(totalRevenue)
    FROM productRevenue
)
ORDER BY totalRevenue DESC;