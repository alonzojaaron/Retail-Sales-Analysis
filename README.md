# Retail-Sales-Analysis
## Project Overview
**Project Title:** Retail Sales Analysis  
**Stack:** SQL  

This Retail Sales Analysis project uses SQL to evaluate sales performance, profitability, and customer segments. It calculates revenue, profit, and margins, and identifies high-sales but low-margin categories, with added age group segmentation and data validation to ensure accurate insights.

## Objectives
1. **Set up retail sales database** – Create and structure the database to store transactional retail data for analysis.
2. **Perform data cleaning** – Identify and correct inconsistencies, missing values, and data quality issues.
3. **Perform business analysis to generate insights** – Analyze results to uncover actionable insights for decision-making.

## Project Structure
#### 1. Database Setup
Initialize the retail sales database and define the core table structure to store transactional data, including customer details, product categories, pricing, cost (COGS), and total sales, ensuring proper data types and a primary key for data integrity.

```sql
CREATE TABLE [dbo].[retail_sales](
	[transactions_id] [smallint] NOT NULL,
	[sale_date] [date] NOT NULL,
	[sale_time] [time](7) NOT NULL,
	[customer_id] [tinyint] NOT NULL,
	[gender] [nvarchar](50) NOT NULL,
	[age] [tinyint] NULL,
	[category] [nvarchar](50) NOT NULL,
	[quantity] [tinyint] NULL,
	[price_per_unit] [smallint] NULL,
	[cogs] [float] NULL,
	[total_sale] [smallint] NULL,
 CONSTRAINT [PK_retail_sales] PRIMARY KEY CLUSTERED 
```
#### 2. Data Cleaning
Identify and remove data quality issues such as duplicate records and missing values to ensure the dataset is accurate, consistent, and reliable for analysis.

```sql
-- 1. Check duplicate transactions
SELECT
    transactions_id,
    COUNT(*) AS duplicate_count
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;

--2. Check null values
SELECT *
FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	OR total_sale IS NULL;

-- 3. Delete null values
DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	cogs IS NULL
	OR total_sale IS NULL;
```

#### 3. Business Analysis
Analyze sales performance and profitability across different dimensions such as product categories, customer segments, and time trends to generate actionable business insights for decision-making.  

#### 3.1. Revenue and Sales Performance
**1. What is the total revenue and sales trend over time (daily, monthly, yearly)?**  
```sql
-- a. Daily
SELECT
	sale_date,
	COUNT(transactions_id) AS total_orders,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY sale_date
ORDER BY total_revenue DESC;

-- b. Monthly
SELECT
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month_number,
    DATENAME(month, sale_date) AS month_name,
    COUNT(transactions_id) AS total_orders,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date),
    DATENAME(month, sale_date)
ORDER BY
    year,
    month_number;

-- c. Yearly
SELECT
	YEAR(sale_date) AS year,
	COUNT(transactions_id) AS total_orders,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY YEAR(sale_date)
ORDER BY YEAR(sale_date);
```
Sales show a strong seasonal peak in Q4 (September–December), indicating high holiday-driven demand that should be prioritized for planning and promotions. The first half of the year is weaker, presenting opportunities for targeted campaigns to boost demand. Overall revenue remains relatively flat from ₱452,825 (2022) to ₱458,895 (2023), despite an increase in orders, suggesting stagnant average order value. This highlights the need to focus on pricing, upselling, or product mix improvements to drive growth.


