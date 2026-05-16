-------------------------- KPI SUMMARY -----------------------

-- What are the overall business performance KPIs including revenue, profit, orders, and profit margin?
SELECT ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2) AS Total_profit,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage,
COUNT(DISTINCT s.OrderNumber) AS Total_orders,
SUM(s.OrderQuantity) AS Total_units_sold,
ROUND(SUM(s.OrderQuantity * p.ProductPrice) / COUNT(DISTINCT s.OrderNumber), 2) AS Average_order_value,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / COUNT(DISTINCT s.OrderNumber), 2) AS Average_profit_per_order
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey;


-- Which product categories generate the highest number of orders, units sold and revenue contributions etc?
SELECT  pc.CategoryName, COUNT(DISTINCT s.OrderNumber) AS Total_orders,
SUM(s.OrderQuantity) AS Total_units_sold,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2) AS Total_profit,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage,
ROUND((SUM(s.OrderQuantity * p.ProductPrice) /
(SELECT  SUM(s2.OrderQuantity * p2.ProductPrice)
FROM Sales_Data s2
JOIN Product_Lookup p2
ON s2.ProductKey = p2.ProductKey)) * 100,2) AS Revenue_contribution_percentage
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Product_Subcategories_Lookup ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN Product_Categories_Lookup pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.CategoryName
ORDER BY Total_orders DESC;


-- Which product subcategories generate the highest number of orders, units sold and revenue etc?
SELECT  ps.SubcategoryName, COUNT(DISTINCT s.OrderNumber) AS Total_orders,
SUM(s.OrderQuantity) AS Total_units_sold,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2) AS Total_profit,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Product_Subcategories_Lookup ps
ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN Product_Categories_Lookup pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY ps.SubcategoryName
ORDER BY Total_orders DESC;


-- What percentage of customers placed more than one order?
SELECT ROUND((COUNT(DISTINCT CASE WHEN Order_Count > 1 THEN CustomerKey 
END) * 100.0) /
COUNT(DISTINCT CustomerKey),2) AS Repeat_customer_rate FROM 
(SELECT s.CustomerKey, COUNT(DISTINCT s.OrderNumber) AS Order_Count
FROM Sales_Data s
GROUP BY s.CustomerKey) t;

