# 🚴 Adventure Works Sales Analysis SQL + Power BI


This project covers the complete data analyst workflow from structured data exploration in MySQL 
to an interactive multi page business dashboard in Power BI. It analyzes three years of global sales data 
from the Adventure Works bicycle company to uncover revenue trends, product performance, customer demographics, 
and geographic market distribution.


**Tools used:** MySQL · MySQL Workbench · Power BI  
**Skills demonstrated:** Data Cleaning & Transformation · Multi-Table Joins · Aggregations · CTEs 
· Window Functions · Subqueries · Date/Time Functions · DAX · Data Modeling · Data Visualization

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![Tool](https://img.shields.io/badge/Tool-MySQL%20Workbench-orange)
![PowerBI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## 🎯 Project Objectives

Adventure Works is a global bicycle manufacturer and retailer selling across North America, Europe, and the Pacific. Leadership needs to understand which products and regions drive revenue, how customer demographics influence purchasing behavior, and where profitability can be improved so they can make smarter decisions around pricing, inventory, and market expansion.

This project answers those questions using structured SQL analysis across eight related tables covering three years of global order data, then visualizes the findings in an interactive Power BI dashboard. Specifically, the analysis aims to:

- Calculate core KPIs: total revenue, profit, profit margin, order volume, return rate, and average order value
- Evaluate product performance across categories, subcategories, and individual products
- Identify top-performing and underperforming products by revenue, orders, and return rate
- Analyze customer demographics including income level, occupation, gender, and homeownership status
- Map revenue and order volume distribution across all countries and regions globally
- Track year-over-year and month-over-month revenue and profit growth trends
- Provide data-backed product, pricing, and marketing recommendations

---

## 🗄️ Database Schema

The dataset consists of **8 related tables**:

<img width="986" height="571" alt="image" src="https://github.com/user-attachments/assets/41316721-464e-43cc-a472-b9a0d7f7a74a" />



---

## 🧹 Data Cleaning & Transformation
 
The raw dataset was cleaned and transformed in MySQL before analysis to ensure consistency,
correct data types, and reliable joins across all tables.
 
- Removed duplicate customer records and deleted rows with invalid non-numeric customer IDs
- Corrected data types across customer, sales, and returns tables — numeric and date columns
  were imported as text and cast to their proper types
- Standardised name casing and prefix formatting so all customer names displayed consistently across
  the dashboard
- Created a derived full name column by combining prefix, first name, and last name into a single
  display-ready field
- Decoded the home owner flag from Y/N to Yes/No for cleaner slicer and label display
- Converted all date columns from raw text strings to proper date format, which was a prerequisite for
  the Calendar Table join and all time intelligence DAX functions in Power BI


---


### SQL Techniques Used

**Multi-Table Joins & Aggregations**: linking Sales, Product, Customer, Territory, Returns, and Calendar 
tables to compute revenue, profit, and order counts across multiple dimensions including product, category, 
region, customer segment, and time period

**CTEs + Window Functions**: used to calculate revenue contribution percentages, month-over-month
and year-over-year growth rates, and running cumulative totals without collapsing result sets

**LAG() for Trend Analysis**: applied across monthly and yearly partitions to detect revenue growth
or decline between periods, producing both absolute and percentage change columns in a single query

**Date/Time Functions**: extracting `YEAR`, `MONTH`, and `MONTHNAME` from the Calendar lookup table
to build seasonal trend analysis, annual performance summaries, and cumulative revenue growth over three years


---

## 🛠️ What I Built

**SQL Layer**
- End-to-end **data cleaning and transformation** duplicate detection, invalid record removal, data type correction, name 
  standardisation, derived column creation, flag decoding, and date formatting across tables before any analysis began
- Comprehensive SQL queries using **Multi-Table Joins**, **Aggregations**, **CTEs**, **Window Functions**, and **Subqueries**
- Executive KPI summary covering total revenue, profit, margin percentage, orders, units sold, and average order value etc
- Product performance analysis covering top/bottom products by revenue, orders, return counts, and profit margin
- Geographic analysis including revenue, profit margin, customer count, and revenue per customer by country and region
- Customer demographic breakdown by income level, occupation, gender, homeownership, and repeat purchase behavior
- Time series analysis with MoM% and YoY% revenue and profit trends using `LAG()` and cumulative running totals

**Power BI Layer**
- Interactive multi-page dashboard connected to the full analyzed dataset
- DAX measures for total revenue, profit, return rate, MoM% change, and what-if adjusted profit simulation
- **Product Detail drill-through page** with gauge charts comparing monthly orders, revenue, and profit against targets,
  paired with a dynamic **Price Adjustment (%)** what-if parameter to model live pricing scenarios
- **Interactive world map page** with region filter buttons (Europe, North America, Pacific) visualizing
  order volume by country as proportional bubbles
- **Customer Detail page** featuring income level and occupation breakdowns alongside a sortable
  Top 100 Customers leaderboard
- Custom DAX measures stored in a **dedicated Measures Table** for clean model organisation
- Custom navigation buttons for seamless page switching across all dashboard pages

---

## 🔍 Query Preview

A few highlights from the SQL queries written in this project.


---

### 1. Which product categories generate the highest number of orders, units sold and revenue contributions etc?

```sql
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
```

**Output**

<img width="786" height="104" alt="image" src="https://github.com/user-attachments/assets/61e37aca-db31-46c5-838a-f9be272299cb" />


---

### 2. Which product categories perform best in each country?

```sql
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
```

**Output**

<img width="345" height="338" alt="image" src="https://github.com/user-attachments/assets/4b56da98-0cd0-4be9-a400-bbd4d398897c" />



### 3. Identify customers who place multiple orders.

```sql
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
```

**Output**

<img width="423" height="347" alt="image" src="https://github.com/user-attachments/assets/69c3d17c-b2a9-4d09-8918-e7f2b06d8a96" />



### 4. How has yearly revenue changed compared to previous years YoY%?

```sql
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
```

**Output**

<img width="425" height="84" alt="image" src="https://github.com/user-attachments/assets/05a7999e-0559-4c94-9d9c-bae46a135526" />


---

## 🧮 DAX Measures Preview

A few highlights from the DAX measures written in this project.

### 1. 90 Day Rolling Profit

```dax
90 Day Rolling Profit = CALCULATE([Total Profit],
DATESINPERIOD('Calendar Lookup'[Date], MAX('Calendar Lookup'[Date]), -90,DAY))  
```

### 2. Total Orders (Customer Details)

```dax
Total Orders (Customer Details) = IF(
HASONEVALUE('Customer Lookup'[CustomerKey]), [Total Orders], "-")
```

### 3. Adjusted Price

```dax
Adjusted Price = [Average Retail Price] * (1 + 'Price Adjustment (%)'[Price Adjustment (%) Value])
```

### 4. High Ticket Orders

```dax
High Ticket Orders = CALCULATE([Total Orders],FILTER('Product Lookup','Product Lookup'[ProductPrice]
 > [Overall Average Price]))
```

---

## ⚠️ Challenges & Solutions


**Challenge 1:**
Top 100 Customers table showing identical values and inflated order counts. When the year slicer was filtered to 2020,
every customer in the table showed the same revenue figure and the Top Customer card showed one person with 812 orders.
The issue was filter context with no single customer resolved, the measures were aggregating across all customers and
returning the same total for every row.
 
**Solution:** Created three DAX measures using `HASONEVALUE` that only return a customer's actual name, orders, and 
revenue when a single customer is in context otherwise displaying "Multiple Customers" and "-" to make the ambiguous
state visible instead of silently wrong.
 
```dax
Full Name (Customer Details) =
IF(
    HASONEVALUE('Customer Lookup'[CustomerKey]),
    MAX('Customer Lookup'[Full Name]),
    "Multiple Customers"
)
```
 
```dax
Total Orders (Customer Details) =
IF(
    HASONEVALUE('Customer Lookup'[CustomerKey]),
    [Total Orders],
    "-"
)
```
 
```dax
Total Revenue (Customer Details) =
IF(
    HASONEVALUE('Customer Lookup'[CustomerKey]),
    [Total Revenue],
    "-"
)
```

**Challenge 2:**
The Product Detail page needed to simulate how a price increase or decrease would affect profit in real time
for any selected product without permanently altering any underlying source data or requiring separate
scenario tables.

**Solution:** Built a **What-If Parameter** in Power BI using a Price Adjustment slider, then wrote
an Adjusted Profit DAX measure that applies the selected percentage against each product's order quantity
and price dynamically. This allows leadership to model live pricing scenarios directly on the dashboard,
comparing Total Profit against Adjusted Profit in a single visual without touching the source data.

**Challenge 3:** 
To identify which products were losing revenue month over month, each row needed to reference that same product's 
previous month value. A standard `GROUP BY` flattens everything into one row per group so there is nothing to compare against.
 
**Solution:** Used a two step CTE the first grouped monthly revenue by product, the second applied `LAG()` partitioned by 
product name so each product's prior month revenue appeared in the current row. The outer query then filtered only months
where current revenue dropped below the previous, isolating declining products without any self joins.

**Challenge 4:** Displaying multiple product metrics against targets without cluttering the page.The Product Detail
page needed to show orders, revenue, and profit each compared to their monthly target but building a separate visual
set for each metric would make the page unusable.
 
**Solution:** Used gauge charts to show actual vs target compactly for each metric, then added a metric selection slicer
that let users switch between Orders, Revenue, Profit, Returns, and Return Rate within a single trend visual. One clean 
page covered all five metrics without any layout compromise.


---

## 📊 Power BI Dashboard

The SQL findings were then visualized in an interactive Power BI dashboard. The dashboard translates
query results into clear business visuals that a non technical stakeholder can explore and act on.

### Dashboard Pages

A **6-page interactive Power BI dashboard**, each page designed to answer one core business question:

**Executive Dashboard**: What are the overall sales numbers, revenue trends, and top-performing products?  
**Map**: Which countries and regions generate the most orders and revenue globally?  
**Product Detail**: How is a specific product performing against its monthly targets, and what happens if the price changes?  
**Customer Detail**: Who are our customers, and which demographic segments drive the most revenue?   
**Q&A**: Natural language query interface for ad-hoc data exploration  
**Decomposition Tree**: Visual breakdown of revenue drivers across all dimensions  

### Dashboard Preview

#### Page 1: Executive Dashboard

<img width="948" height="505" alt="image" src="https://github.com/user-attachments/assets/28de5ab4-e4f2-4fad-a52b-3a1fcd74ce93" />


#### Page 2: Map

<img width="941" height="504" alt="image" src="https://github.com/user-attachments/assets/83d26a92-81ef-4faf-bff6-c2173045368f" />


#### Page 3: Product Detail

<img width="941" height="503" alt="image" src="https://github.com/user-attachments/assets/7cfa917e-91ba-4bd5-9f1e-96c83d04cdb8" />


#### Page 4 — Customer Detail

<img width="943" height="504" alt="image" src="https://github.com/user-attachments/assets/e0d4e8f3-d2ef-4b37-993a-7afe1aed74cf" />


---

## 📊 Key Insights

**Revenue & Profitability KPIs**
- Total revenue generated: **$24.9M** across three years of operations
- Total profit: **$10.5M** reflecting a strong overall profit margin of approximately **42%**
- Total orders placed: **25.2K** with a low return rate of **2.1%** across all product categories
- Most recent monthly revenue reached **$1.83M**, up **+3.31%** from the prior month

**Product Performance**
- **Accessories** leads all categories in order volume at **16983 orders**, making it the highest frequency purchase category
- **Bikes** generates the highest revenue at **$23.64M** despite fewer orders, reflecting its significantly higher price point per unit
- **Tires and Tubes** is the single most ordered product type; **Shorts** carries the highest return rate across the catalog
- **Water Bottle (30 oz.)** appears in **3,983 orders** the most ordered individual product in the entire catalog
- **Sport-100 Helmet (Red)** generates **$73,444** in revenue and carries a 3.33% return rate, the highest among top products

**Geographic Distribution**
- The **United States** is the dominant market by both revenue and total order volume
- **Australia** records **6,060 orders**, making it the strongest market in the Pacific region
- Revenue and orders span **6 countries** across Europe, North America, and the Pacific with meaningful presence in all three regions

**Customer Demographics**
- **17.4K unique customers** generated an average of **$1.4K revenue per customer** across the three year period
- The **Average income group** accounts for the highest order volume at **11.6K orders**, outpacing both High and Low income segments
- **Professional** occupation is the leading segment at **7.9K orders**, followed by Skilled at **5.9K**
- **Mr. Maurice Shan** is the top individual customer generating **$12,408** across 6 orders
- Revenue per customer has shown a consistent declining trend over time, signaling a need for targeted retention and upsell strategies

**Time & Revenue Trends**
- Revenue trended consistently upward from **January 2020 through January 2022**, with a visible acceleration through the second half of 2021
- Monthly orders declined slightly at **-0.88%** while monthly revenue grew **+3.31%**, suggesting average order value is 
increasing even as order frequency softens
- Monthly returns held at **166**, up slightly from 169 the prior month, remaining well within an acceptable threshold

---

## 💡 Business Recommendations

1. **Protect and scale the Bikes category:** Bikes generate the majority of total revenue and should
   remain the core focus for inventory planning, demand forecasting, pricing strategy, and marketing
   investment.

2. **Increase accessory attachment rate to improve average order value:** Accessories drive the highest
   purchase frequency, creating strong cross-sell potential. Bundle offers, checkout recommendations,
   and post-purchase campaigns can increase margin without additional customer acquisition costs.

3. **Prioritize retention and upselling strategies:** Revenue per customer has declined over time,
   indicating weakening customer value. Loyalty initiatives, personalized recommendations, and lifecycle
   marketing should focus on increasing repeat purchases and basket size.

4. **Investigate high-return product categories to reduce margin leakage:** Shorts and several
   top-selling products show elevated return rates. A detailed review of sizing accuracy, product
   quality, and customer expectations could significantly reduce avoidable returns.

5. **Focus growth investment on high-performing markets:** The United States and Australia should
   remain priority markets due to their strong revenue performance and higher-value customer behavior.
   Secondary markets should use localized campaigns and optimized product positioning to drive
   selective growth.

6. **Target high-value customer segments more aggressively:** Professional and skilled-worker groups
   generate the strongest demand. Marketing and CRM strategies should prioritize these segments with
   personalized messaging and premium product bundles.

7. **Use 2021–2022 as the primary forecasting baseline:** 2020 data appears structurally inconsistent
   due to unusually low order volume and high average order value. Forecasting models and performance
   targets should rely primarily on the more stable 2021–2022 period.


---

## 🚀 How to Use

### SQL Analysis
1. Clone or download this repository
2. Import the dataset from the `data/` folder into MySQL
3. Open MySQL Workbench and run the files in the `queries/` folder in order
4. Each file is organized by analysis section and includes inline comments explaining the business
   question, the approach, and the insight derived

### Power BI Dashboard
1. Download the `.pbix` file from the `dashboard/` folder
2. Open in Power BI Desktop
3. Use the region buttons on the Map page, the product selector on Product Detail, and the
   year slicer on Customer Detail to explore findings interactively
4. Use the **Price Adjustment (%)** slider on the Product Detail page to model pricing scenarios
   and compare Total Profit against Adjusted Profit in real time

---

## 📌 Future Improvements
- Customer segmentation using RFM analysis to identify high-value, at-risk, and lapsed customer
  groups for targeted re-engagement
- Predictive revenue forecasting using trend extrapolation across the three-year dataset to project
  quarterly performance
- Publish the dashboard to Power BI Service for a live shareable link accessible without Power BI Desktop
