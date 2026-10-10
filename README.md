# Adventure Works Sales Analysis SQL + Power BI

## 📌 Project Overview
This project covers the complete data analyst workflow from structured data exploration in MySQL 
to an interactive multi page business dashboard in Power BI. It analyzes 2.5 years of global sales data 
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

## Project Objectives

Adventure Works is a global bicycle manufacturer and retailer selling across North America, Europe, and the Pacific. Leadership needs to understand which products and regions drive revenue, how customer demographics influence purchasing behavior, and where profitability can be improved so they can make smarter decisions around pricing, inventory, and market expansion.

This project answers those questions using structured SQL analysis across eight related tables covering 2.5 years of global order data, then visualizes the findings in an interactive Power BI dashboard. Specifically, the analysis aims to:

- Calculate core KPIs: total revenue, profit, order volume, return rate, and average order value
- Evaluate product performance across categories, subcategories, and individual products
- Identify top performing and underperforming products by revenue, orders, and return rate
- Analyze customer demographics including income level, and occupation
- Map revenue and order volume distribution across all countries and regions globally
- Track year-over-year and month-over-month revenue and profit growth trends
- Provide data backed product, pricing, and marketing recommendations

---

## Database Schema

The dataset consists of **8 related tables**:

<img width="983" height="569" alt="image" src="https://github.com/user-attachments/assets/08250f14-ad70-47df-b2e0-5f515b0ca37d" />




---

## Data Cleaning & Transformation
 
The raw dataset was cleaned and transformed in MySQL before analysis to ensure consistency,
correct data types, and reliable joins across all tables.
 
- Removed duplicate customer records and deleted rows with invalid non numeric customer IDs
- Corrected data types across customer, sales, and returns tables, numeric and date columns
  were imported as text and cast to their proper types
- Standardised name casing and prefix formatting so all customer names displayed consistently across
  the dashboard
- Created a derived full name column by combining prefix, first name, and last name into a single
  display ready field
- Decoded the home owner flag from Y/N to Yes/No for cleaner slicer and label display
- Converted all date columns from raw text strings to proper date format, which was a  prerequisite for
  the Calendar Table join and all time intelligence DAX functions in Power BI


---


## SQL Techniques Used

**Multi Table Joins & Aggregations**: linking Sales, Product, Customer, Territory, Returns, and Calendar 
tables to compute revenue, profit, and order counts across multiple dimensions including product, category, 
region, customer segment, and time period

**CTEs + Window Functions**: used to calculate revenue contribution percentages, month over month
and year over year growth rates, and running cumulative totals without collapsing result sets

**LAG() for Trend Analysis**: applied across monthly and yearly partitions to detect revenue growth
or decline between periods, producing both absolute and percentage change columns in a single query

**Date/Time Functions**: extracting `YEAR`, `MONTH`, and `MONTHNAME` from the Calendar lookup table
to build seasonal trend analysis, annual performance summaries, and cumulative revenue growth over 2.5 years


---

## What I Built

**SQL Layer**
- Comprehensive SQL queries using **Multi Table Joins**, **Aggregations**, **CTEs**, **Window Functions**, and **Subqueries**
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

## Query Preview

A few highlights from the SQL queries written in this project.


---

### 1. Which product categories generate the highest number of orders, units sold and revenue contributions?

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

<img width="783" height="99" alt="image" src="https://github.com/user-attachments/assets/742efad3-8014-406a-a712-2ca458e68cf7" />



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

<img width="343" height="334" alt="image" src="https://github.com/user-attachments/assets/72cd0a05-a9eb-4ec5-91c9-aa7276f44d7b" />




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

<img width="420" height="346" alt="image" src="https://github.com/user-attachments/assets/73d3fd99-486e-4a07-8ec7-f662602b402c" />




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

<img width="421" height="83" alt="image" src="https://github.com/user-attachments/assets/693f2441-2973-44fc-a89a-091ea697ab6a" />



---

## DAX Measures Preview

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

## Challenges & Solutions


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

## Power BI Dashboard

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

## 🖼️ Dashboard Preview

#### Page 1: Executive Dashboard

<img width="1032" height="551" alt="image" src="https://github.com/user-attachments/assets/4bdd22ec-e7ef-40e3-a17a-5b0b5b522428" />



#### Page 2: Map

<img width="1027" height="548" alt="image" src="https://github.com/user-attachments/assets/1358bfa3-ee45-4121-b8de-a9192482b03a" />



#### Page 3: Product Detail

<img width="1029" height="551" alt="image" src="https://github.com/user-attachments/assets/72a4aabd-261f-41fd-9c0a-08619eac4cc6" />


#### Page 4: Customer Detail

<img width="1030" height="551" alt="image" src="https://github.com/user-attachments/assets/a40e4076-8ab2-409b-b6f7-acde33d496b9" />



---

## 📊 Key Insights

**Revenue & Profitability KPIs**
- **$24.9M** revenue and **$10.5M** profit from Jan 2020 to Jun 2022, a margin of about **42%**
- **25.2K** orders with a low **2.1%** return rate
- Jan-Jun 2022 vs Jan-Jun 2021: revenue **+211%**, profit **+211%**, orders **+594%**. Most of this comes from Accessories 
  and Clothing launching in July 2021. Bikes alone grew **3.3x** in orders.
- Most recent monthly revenue reached **$1.83M**, up **+3.31%** from the prior month


**Product Performance**
- Bikes generates in **95%** of revenue (**$23.64M**) and **93%** of profit, even with fewer orders than Accessories
- Accessories have the most orders **16,983** but only **3.6%** of revenue **$0.91M**. Their margin is the highest **62.8%** vs **41.1%** for Bikes.
- Bikes make up about **96%** of returned value. Shorts have the highest return rate **4.24%** of any subcategory


**Geographic Distribution**
- The United States is the largest market **$7.9M** revenue **32%** from **8,700** orders
- Australia is close behind at **$7.4M** from **6,060** orders, with the highest average order **$1,224** vs **$913** in the US
- Canada is third in orders but last in revenue **$1.77M**, with an average order of only **$585**


**Customer Demographics**
- **17.4K unique customers** generated an average of **$1.4K revenue per customer** across the period
- The **Average income group** accounts for the highest order volume at **11.6K orders**, outpacing both High and Low income segments
- Professional is the top occupation by orders **7.9K** and spends the most per customer **$1.62K**, followed by Management **$1.59K**
- High and Very High income customers spend **$2.0K-$2.2K** each, vs **$1.2K** for Low income


**Time & Revenue Trends**
- Monthly revenue stayed between **$330K and $670K** until June 2021, then rose from **$815K** in July 2021 to **$1.83M** in June 2022
- 2020 looks different because only Bikes were sold: **2,630** orders at a **$2,435** average order value, vs **$872** in 2021 and **$776** in H1 2022
- In June 2022, orders fell 0.88% while revenue grew 3.31%, so average order value rose from $817 to $851
- Monthly returns held at **166**, down slightly from 169 the previous month


---

## Business Recommendations

1. **Protect and scale the Bikes category:** Bikes generates 95% of revenue and 93% of profit and should
   remain the core focus for inventory planning, demand forecasting, pricing strategy, and marketing
   investment.

2. **Sell bigger accessories, not just more of them:** About **88%** of bike orders since July 2021 already 
   include an accessory or clothing item. The gap is price: accessories have a **62.8%** margin but only **3.6%** 
   of revenue. Bundle bikes with helmets, racks, and hydration packs to raise order value.

3. **Reduce bike returns first:** Bikes account for about 96% of returned value, led by Road Bikes and
   Mountain Bikes. Shorts and Sport-100 Helmets have higher return rates but a very small financial
   impact, so they are quick sizing and fit checks rather than priorities.

4. **Focus growth on the US and Australia, and lift order value in Canada:** The two markets generate 62% of revenue.
   Canada has the third highest order count but the lowest average order ($585), so upselling there has room to grow.

5. **Focus on the customers who spend most:** Professional and Management customers spend the most per person, and High
   and Very High income customers spend nearly twice as much as Low income. Premium bundles and personalized offers fit them best

6. **Forecast from July 2021 onward, with caution:** The July 2021 category launch changed the business, so
   2020 and early 2021 are not comparable. Only 12 months of data exist since then, so treat projections as
   provisional until a full seasonal cycle is observed.

---

## How to Use

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

## Future Improvements
- Customer segmentation using RFM analysis to identify high value, at risk, and lapsed customer
  groups for targeted re engagement
- Predictive revenue forecasting using trend extrapolation across the dataset to project
  quarterly performance


## Contact
Feel free to reach out if you'd like to connect or discuss this project:
- **LinkedIn:** [linkedin.com/in/muneeb-alam0](https://www.linkedin.com/in/muneeb-alam0/)
- **Email:** muneebalam140@gmail.com
