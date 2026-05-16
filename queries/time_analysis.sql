-------------------------- TIME ANALYSIS -----------------------

-- How has yearly revenue changed compared to previous years YoY%?
WITH Yearlyrevenue AS (
SELECT YEAR(c.CalendarDate) AS Yearr,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Revenue
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr)
SELECT Yearr, Revenue, LAG(Revenue) OVER(ORDER BY Yearr) AS Previous_year_revenue,
ROUND(((Revenue - LAG(Revenue) OVER(ORDER BY Yearr))/
NULLIF(LAG(Revenue) OVER(ORDER BY Yearr), 0)) * 100,2) AS YoY_growth_Percentage
FROM Yearlyrevenue;


-- How much is revenue growing or declining MoM%?
WITH Monthlyrevenue AS (
SELECT YEAR(c.CalendarDate) AS Yearr,
MONTH(c.CalendarDate) AS Month_num,
MONTHNAME(c.CalendarDate) AS Month_name,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Revenue
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr, Month_Num, 3)
SELECT Yearr, Month_name, Revenue,
LAG(Revenue) OVER(ORDER BY Yearr, Month_num) AS Previous_month_revenue,
ROUND(((Revenue - LAG(Revenue) OVER(ORDER BY Yearr, Month_num)) /
NULLIF(LAG(Revenue) OVER(ORDER BY Yearr, Month_num), 0)) * 100,2) AS Growth_percentage
FROM Monthlyrevenue;


-- How has revenue trended over time by month?
SELECT YEAR(c.CalendarDate) AS Yearr,
MONTH(c.CalendarDate) AS Month_num,
MONTHNAME(c.CalendarDate) AS Month_name,
ROUND(SUM(s.OrderQuantity * p.ProductPrice), 1) AS Monthly_revenue
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr, Month_num, Month_name
ORDER BY Yearr, Month_num;


-- How does cumulative revenue grow over time?
WITH Cumulativerevenue AS (
SELECT YEAR(c.CalendarDate) AS Yearr,
MONTH(c.CalendarDate) AS Month_num,
MONTHNAME(c.CalendarDate) AS Month_name,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Revenue
FROM Sales_Data s
JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr, Month_num, Month_name)
SELECT Yearr, Month_name, Revenue,
ROUND(SUM(Revenue) OVER(ORDER BY Yearr, Month_num),2) AS Running_total_revenue 
FROM Cumulativerevenue;


-- How is monthly profit performing compared to the previous month?
WITH MonthlyProfit AS (
SELECT YEAR(c.CalendarDate) AS Yearr,
MONTH(c.CalendarDate) AS Month_num,
MONTHNAME(c.CalendarDate) AS Month_name,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 2) AS Profit
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr, Month_num, Month_name)
SELECT Yearr ,Month_name, Profit,
LAG(Profit) OVER(ORDER BY Yearr, Month_num) AS Previous_Month_Profit,
ROUND(((Profit - LAG(Profit) OVER(ORDER BY Yearr, Month_num))
/ NULLIF(LAG(Profit) OVER(ORDER BY Yearr, Month_num), 0)) * 100, 2) AS Profit_growth_percentage
FROM MonthlyProfit;


-- How is the business performing year over year in terms of revenue, profit, orders, avg order value, and profit margin?
SELECT YEAR(c.CalendarDate) AS Yearr,
ROUND(SUM(s.OrderQuantity * p.ProductPrice),2) AS Total_revenue,
ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),2) AS Total_profit,
COUNT(DISTINCT s.OrderNumber) AS Total_Orders,
ROUND(SUM(s.OrderQuantity * p.ProductPrice) /
COUNT(DISTINCT s.OrderNumber),2) AS Avg_order_value,
ROUND((SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) / 
NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0)) * 100, 2) AS Profit_margin_percentage
FROM Sales_Data s JOIN Product_Lookup p
ON s.ProductKey = p.ProductKey
JOIN Calendar_Lookup c
ON s.OrderDate = c.CalendarDate
GROUP BY Yearr
ORDER BY Yearr;