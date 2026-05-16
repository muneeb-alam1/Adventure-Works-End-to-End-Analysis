-------------------------- CUSTOMER DEMOGRAPHIC -----------------------

-- What is the average revenue generated per customer?
SELECT ROUND(SUM(s.OrderQuantity * p.ProductPrice) /
COUNT(DISTINCT s.CustomerKey),2) AS Revenue_per_customer
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey;


-- How many unique customers made purchases?
SELECT COUNT(DISTINCT CustomerKey) AS Unique_customers
FROM sales_data;


-- Which top 10 customers generated the highest revenue?
SELECT c.CustomerKey, c.FullName,
SUM(s.OrderQuantity) AS Total_units,
COUNT( DISTINCT s.OrderNumber) AS Total_orders,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue
FROM Sales_Data s JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY c.CustomerKey, c.FullName
ORDER BY Total_revenue DESC
LIMIT 10;


-- Which customer occupations contribute the highest revenue?
SELECT c.Occupation, COUNT(DISTINCT s.CustomerKey) AS Total_customers,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue
FROM Sales_Data s JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY c.Occupation
ORDER BY Total_revenue DESC;


-- Which gender contributes more revenue?
SELECT IFNULL(c.Gender, "Not Defined") AS Gender, COUNT(DISTINCT s.CustomerKey) AS Total_customers,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue
FROM Sales_Data s
JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY c.Gender
ORDER BY Total_revenue DESC;


-- Identify customers who place multiple orders.
SELECT c.CustomerKey, FullName,
COUNT(DISTINCT s.OrderNumber) AS Total_orders,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue
FROM Sales_Data s JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY c.CustomerKey, FullName
HAVING COUNT(DISTINCT s.OrderNumber) > 1
ORDER BY Total_orders DESC;


-- Which income groups contribute the highest revenue?
SELECT CASE
WHEN c.AnnualIncome > 150000 THEN 'Very High'
WHEN c.AnnualIncome > 100000 THEN 'High'
WHEN c.AnnualIncome > 50000 THEN 'Average'
ELSE 'Low'
END AS Income_level,
COUNT(DISTINCT s.CustomerKey) AS Total_customers,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue
FROM Sales_Data s
JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY Income_level
ORDER BY Total_revenue DESC;


-- Do homeowners generate more revenue compared to non homeowners?
SELECT c.HomeOwner, COUNT(DISTINCT s.CustomerKey) AS Total_customers,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * p.ProductPrice) /
COUNT(DISTINCT s.CustomerKey),2) AS Revenue_Per_Customer
FROM Sales_Data s
JOIN Customer_Lookup c
ON s.CustomerKey = c.CustomerKey
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY c.HomeOwner
ORDER BY Total_revenue DESC;
