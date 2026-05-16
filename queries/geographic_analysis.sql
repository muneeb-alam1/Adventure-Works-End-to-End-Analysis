-------------------------- GEOGRAPHIC ANALYSIS -----------------------

-- What percentage of total revenue is contributed by each region?
SELECT t.Region, ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
ROUND((SUM(s.OrderQuantity * p.ProductPrice) /
NULLIF(SUM(SUM(s.OrderQuantity * p.ProductPrice)) OVER (), 0)) * 100, 2)
AS Revenue_contribution_percentage FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Region
ORDER BY Revenue_contribution_percentage DESC;


-- Identify which countries or regions generate the highest revenue.
SELECT t.Country, t.Region, ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
COUNT(DISTINCT s.OrderNumber) AS Total_Orders
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country, t.Region
ORDER BY Total_revenue DESC;


-- Which countries generate the highest revenue?
SELECT t.Country, ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
SUM(s.OrderQuantity) AS Total_Units_Sold
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country
ORDER BY Total_revenue DESC;


-- Which countries generate the highest profit margins?
SELECT t.Country, ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),2) AS Total_profit,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country
ORDER BY Profit_margin_percentage DESC;


-- Which product categories perform best in each country?
SELECT t.Country, pc.CategoryName,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Product_Subcategories_Lookup ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN Product_Categories_Lookup pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country, pc.CategoryName
ORDER BY t.Country, Total_revenue DESC;


-- Which countries have the highest number of unique customers?
SELECT t.Country, COUNT(DISTINCT s.CustomerKey) AS Total_customers
FROM Sales_Data s JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country
ORDER BY Total_customers DESC;


-- Which countries generate the highest revenue per customer?
SELECT t.Country, COUNT(DISTINCT s.CustomerKey) AS Total_customers,
ROUND(SUM(s.OrderQuantity * p.ProductPrice) /
COUNT(DISTINCT s.CustomerKey),2) AS Revenue_per_customer
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Territory_Lookup t
ON s.TerritoryKey = t.SalesTerritoryKey
GROUP BY t.Country
ORDER BY Revenue_Per_Customer DESC;