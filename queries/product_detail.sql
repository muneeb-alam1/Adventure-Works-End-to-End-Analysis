-------------------------- PRODUCT DETAIL -----------------------

-- What percentage of total business revenue is contributed by each product?
SELECT p.ProductName, ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Product_revenue,
ROUND((SUM(s.OrderQuantity * p.ProductPrice) /
NULLIF(SUM(SUM(s.OrderQuantity * p.ProductPrice)) OVER (), 0)) * 100, 2)
AS Revenue_contribution_percentage
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Revenue_contribution_percentage DESC;


-- Which products generate high revenue but relatively low profit?
SELECT p.ProductName,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),2) AS Total_profit,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Profit_margin_percentage
LIMIT 10;


-- Which products are experiencing declining sales trends over time?
WITH MonthlySales AS (
SELECT p.ProductName,
YEAR(c.CalendarDate) AS Sales_year, MONTH(c.CalendarDate) AS Month_num,
MONTHNAME(c.CalendarDate) AS Month_name,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Monthly_revenue
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY 1,2,3,4),
WithLag AS (
SELECT ProductName, Sales_year, Month_num, Month_name, Monthly_revenue,
LAG(Monthly_revenue) OVER(PARTITION BY ProductName
ORDER BY Sales_year, Month_num) AS Previous_month_revenue
FROM MonthlySales)
SELECT ProductName, Sales_year, Month_name, Monthly_revenue,
Previous_month_revenue,
ROUND(((Monthly_revenue - Previous_month_revenue) /
NULLIF(Previous_month_revenue, 0)) * 100, 2) AS MoM_change_percentage
FROM WithLag
WHERE Monthly_revenue < Previous_month_revenue
ORDER BY ProductName, Sales_year, Month_num;


-- Which top 10 products generate the highest revenue and profit?
SELECT p.ProductName, ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_Revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),2) AS Total_Profit
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Which top 10 products appear in the highest number of orders?
SELECT p.ProductName, COUNT(DISTINCT s.OrderNumber) AS Total_orders,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Total_orders DESC
LIMIT 10;


-- Which products have the highest return counts?
SELECT p.ProductName, SUM(r.ReturnQuantity) AS Total_returns
FROM Returns_Data r
JOIN Product_Lookup p
ON r.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Total_returns DESC;


-- Which product subcategory has the highest number of orders?
SELECT ps.SubcategoryName, COUNT(DISTINCT s.OrderNumber) AS Total_orders
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Product_Subcategories_Lookup ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
GROUP BY ps.SubcategoryName
ORDER BY Total_orders DESC
LIMIT 1;
