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

##### 3.1. Revenue and Sales Performance
###### 1. What is the total revenue and sales trend over time (daily, monthly, yearly)? ######
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

###### 2. Which days of the week generate the highest sales? ######
```sql
SELECT 
	DATENAME(WEEKDAY, sale_date) AS day,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATENAME(WEEKDAY, sale_date)
ORDER BY total_revenue DESC;
```
Sales are highest on Sundays, followed by Mondays and Saturdays, indicating stronger customer activity during weekends and the start of the week. In contrast, Tuesdays show the lowest performance, suggesting weaker midweek demand. This pattern highlights an opportunity to maximize promotions and staffing on peak days, while using targeted discounts or campaigns during slower weekdays to balance sales performance.

###### 3. Find out best selling month in each year. ######
```sql
WITH ranking AS (
SELECT
	DATENAME(YEAR, sale_date) AS year,
	DATENAME(MONTH, sale_date) AS month,
	AVG(total_sale) AS average_sale,
	RANK() OVER(PARTITION BY DATENAME(YEAR, sale_date) ORDER BY AVG(total_sale) DESC) AS rank
FROM retail_sales
GROUP BY 
	DATENAME(YEAR, sale_date),
	DATENAME(MONTH, sale_date)
)
SELECT
	year,
	month,
	average_sale
FROM ranking
WHERE rank = 1;
```
The best-performing months differ by year, with July 2022 and February 2023 achieving the highest average sales, indicating that peak performance is not limited to the holiday season.

###### 4. Are sales growing or declining?  ######
```sql
SELECT
	YEAR(sale_date) AS year,
	MONTH(sale_date) AS month,
	SUM(total_sale) AS total_revenue,
	LAG(SUM(total_sale)) OVER(ORDER BY YEAR(sale_date), MONTH(sale_date)) AS prev_month_revenue,
	SUM(total_sale) - LAG(SUM(total_sale)) OVER(ORDER BY YEAR(sale_date), MONTH(sale_date)) AS growth
FROM retail_sales
GROUP BY
	YEAR(sale_date),
	MONTH(sale_date)
ORDER BY year, month;
```
Sales show fluctuating month-to-month performance rather than consistent growth, with notable spikes during September–December in both years, confirming strong seasonal demand.

###### 5. What are the peak sales hours during the day?  ######
```sql
SELECT 
	DATEPART(HOUR, sale_time) AS hour,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY total_revenue DESC;
```
Sales peak during the evening hours (5 PM–10 PM), with the highest revenue at 7 PM, indicating strong after-work shopping behavior. Morning to early afternoon shows moderate activity, while late-night sales are minimal.

##### 3.2. Product & Category Insights
###### 1. Which product categories generate the most revenue? ######
```sql
SELECT
	category,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;
```
Electronics generates the highest revenue, closely followed by Clothing, with Beauty slightly behind, indicating relatively balanced performance across categories.

###### 2. Which categories have the highest volume vs highest profit (cogs vs total_sale)? ######
```sql
SELECT
	category,
	SUM(quantity) AS total_quantity,
	SUM(total_sale) AS total_revenue,
	ROUND(SUM(cogs), 2) AS total_cogs,
	ROUND(SUM(total_sale - cogs), 2) AS total_profit,
	ROUND(
		(SUM(total_sale - cogs) * 1.0 / NULLIF(SUM(total_sale), 0)) * 100,
		2
	) AS total_margin_pct
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;
```
Clothing generates the highest profit and volume, making it the most efficient category overall, while Electronics leads in revenue but has the lowest margin, indicating higher costs or pricing pressure. Beauty shows the highest profit margin but lower volume, suggesting strong profitability per sale but less demand. This highlights an opportunity to scale Beauty sales, optimize Electronics costs or pricing, and maintain Clothing as a balanced top performer.

###### 3. What categories are underperforming or declining over time? ######
```sql
WITH category_trend AS (
	SELECT
		category,
		YEAR(sale_date) AS year,
		MONTH(sale_date) AS month,
		SUM(total_sale) AS total_revenue
	FROM retail_sales
	GROUP BY
		category,
		YEAR(sale_date),
		MONTH(sale_date)
)
SELECT
	category,
	year,
	month,
	total_revenue,
	LAG(total_revenue) OVER(PARTITION BY category ORDER BY year, month) AS prev_revenue,
	total_revenue - LAG(total_revenue) OVER(PARTITION BY category ORDER BY year, month) AS growth
FROM category_trend
ORDER BY category, year;
```
All categories show high volatility with no consistent decline, but clear seasonal spikes in Q4 (September–December). Electronics exhibits the most fluctuation, with sharp drops and spikes, indicating unstable demand. Beauty shows signs of decline toward late 2023, particularly after October, suggesting weakening momentum. Clothing remains relatively stable but still experiences periodic dips. Overall, performance is season-driven rather than consistently growing, highlighting the need to stabilize demand during off-peak months and reduce reliance on seasonal surges.

##### 3.3. Customer Behavior & Segmentation
###### 1. Who are your top customers by total spend? ######
```sql
SELECT
	customer_id,
	COUNT(transactions_id) AS total_orders,
	SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC;
```
Customer 3 and 1 contribute the highest number of orders at 76 each, making them the most active and highest-value customers.

###### 2. What is the average spend per customer? ######
```sql
SELECT
	AVG(total_spent) AS average_spend_per_customer
FROM (
	SELECT
		customer_id,
		SUM(total_sale) AS total_spent
	FROM retail_sales
	GROUP BY customer_id
) AS t;
```
The average spend per customer is ₱5,882, which represents a baseline for customer value in the business.

###### 3. How does purchasing behavior differ by: ######
```sql
-- a. Gender
SELECT
	category,
	gender,
	COUNT(customer_id) AS total_customers,
	SUM(quantity) AS total_orders,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- b. Age Group
SELECT
	CASE
		WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
	END AS age_group,
	COUNT(customer_id) AS total_customers,
	SUM(quantity) AS total_orders,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY
	CASE
		WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
	END
ORDER BY total_customers DESC;
```
Purchasing behavior shows clear differences across both gender and age groups. By gender, females slightly dominate in Beauty and Clothing sales, while males contribute higher revenue in Electronics, indicating category-specific preferences. By age group, the 50+ segment is the highest contributor in both orders and revenue, making it the most valuable customer group.

##### 3.4. Time-Based Buying Patterns
###### 1. How do sales vary by time of day (Morning/Afternoon/Evening)? ######
```sql
SELECT
	shift,
	COUNT(transactions_id) AS total_orders,
	SUM(total_sale) AS total_revenue
FROM (
	SELECT
		CASE
			WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift,
		transactions_id,
		total_sale
	FROM retail_sales
) AS t
GROUP BY shift
ORDER BY total_orders DESC;
```
Sales are heavily concentrated in the Evening shift, which generates the highest revenue and order volume, indicating peak customer activity after work hours.

###### 2. What categories are popular during morning, afternoon, and evening? ######
```sql
WITH category_shift AS (
	SELECT
		category,
		CASE
			WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift,
		SUM(quantity) AS total_orders,
		SUM(total_sale) AS total_revenue
	FROM retail_sales
	GROUP BY
		CASE
			WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END,
		category
)
SELECT
	category,
	shift,
	total_orders,
	total_revenue,
	ranking
FROM (
	SELECT
		*,
		RANK() OVER(PARTITION BY shift ORDER BY total_revenue DESC) AS ranking
	FROM category_shift
) AS t
WHERE ranking = 1;
```
Customer preferences vary by time of day, with Electronics dominating Afternoon and Evening sales, indicating strong demand for higher-value or tech-related purchases later in the day. In contrast, Clothing leads in the Morning, suggesting earlier shopping behavior for apparel-related items.

##### 3.5. Pricing & Profitability Analysis
###### 1. Which categories have high sales but low margins? ######
```sql
WITH category_perf AS (
	SELECT
		category,
		COUNT(transactions_id) AS total_orders,
		SUM(total_sale) AS total_revenue,
		SUM(total_sale - cogs) AS total_profit,
		ROUND(
			(SUM(total_sale - cogs) * 1.0 / NULLIF(SUM(total_sale), 0)) * 100,
			2
		) AS margin_profit_pct
	FROM retail_sales
	GROUP BY category
)
SELECT
	category,
	total_orders
	total_revenue,
	total_profit
FROM category_perf
WHERE 
	total_revenue > (SELECT AVG(total_revenue) FROM category_perf)
	AND margin_profit_pct < (SELECT AVG(margin_profit_pct) FROM category_perf)
ORDER BY total_revenue;
```
Electronics is the only category that shows high sales but relatively lower profit margin compared to other categories, meaning it drives strong revenue but is less efficient in converting sales into profit. While Electronics is a key revenue driver, the business should focus on cost optimization, pricing strategy review, or product mix improvement to increase profitability without sacrificing sales volume.

###### 2. How does price_per_unit affect quantity sold? ######
```sql
SELECT
    price_per_unit,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY price_per_unit
ORDER BY total_quantity_sold DESC;
```
The data shows that moderate-priced items (₱25–₱50) generate the highest total quantity sold, indicating stronger demand for more affordable products. However, higher-priced items (₱300–₱500) still maintain strong transaction counts and relatively high sales volume, suggesting that demand is not strictly price-sensitive and likely depends on product type or perceived value.

##### 3.6. Customer Retention & Frequency
###### 1. How often do customers return and purchase again? ######
```sql
SELECT
	customer_id,
	COUNT(transactions_id) AS total_returns,
	SUM(quantity) AS total_orders
FROM retail_sales
GROUP BY customer_id
ORDER BY total_returns DESC;
```
Customers 3, 1, 4, and 2 show very high repeat purchase activity, indicating strong customer retention and loyalty. These high-frequency buyers contribute significantly more transactions and quantity compared to others, suggesting they are key drivers of sustained revenue.

###### 2. What is the time gap between purchases per customer? ######
```sql
WITH purchase_gaps AS (
	SELECT
		customer_id,
		DATEDIFF(
			DAY,
			LAG(sale_date) OVER(PARTITION BY customer_id ORDER BY sale_date),
			sale_date
		) AS gap_days
	FROM retail_sales
)
SELECT
	customer_id,
	AVG(gap_days * 1.0) AS average_days_between_purchases
FROM purchase_gaps
WHERE gap_days IS NOT NULL
GROUP BY customer_id
ORDER BY average_days_between_purchases;
```
Customer purchasing behavior shows a clear split between high-frequency and low-frequency buyers. Customers 123, 4, 1, 3, 2 returns within 1 to 10 days, indicating strong engagement and repeat buying behavior. However, most customers have a much longer gap of 30+ days between purchases, suggesting infrequent or occasional shopping patterns.

##### 3.7. Demographic Profitability
###### 1. Which demographic group is the most profitable? ######
```sql
SELECT
	gender,
	CASE
		WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
	END AS age_group,
	COUNT(transactions_id) AS total_transactions,
	SUM(total_sale - cogs) AS total_profit,
	ROUND(
		(SUM(total_sale - cogs * 1.0) / NULLIF(SUM(total_sale), 0)) * 100,
		2
	) AS margin_profit_pct
FROM retail_sales
GROUP BY 
	gender,
	CASE
		WHEN age < 20 THEN 'Below 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50+'
	END
ORDER BY total_profit DESC;
```
The most profitable segment is Male customers aged 50+, contributing the highest total profit, followed by Female customers aged 50+, making older customers the most valuable demographic overall. This indicates that the 50+ age group is the strongest profit driver regardless of gender, combining both high spending and consistent purchasing behavior.

###### 2. Do certain groups prefer specific categories (Top Category per Demographic)? ######
```sql
WITH demog_category AS (
	SELECT
		gender,
		CASE
			WHEN age < 20 THEN 'Below 20'
			WHEN age BETWEEN 20 AND 29 THEN '20-29'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50+'
		END AS age_group,
		category,
		COUNT(transactions_id) AS total_orders
	FROM retail_sales
	GROUP BY
		gender,
		CASE
			WHEN age < 20 THEN 'Below 20'
			WHEN age BETWEEN 20 AND 29 THEN '20-29'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50+'
		END,
		category
)
SELECT
	*
FROM (
	SELECT
		*,
		RANK() OVER(PARTITION BY gender, age_group ORDER BY total_orders DESC) AS ranking
	FROM demog_category
) AS t
WHERE ranking = 1
```
Customer preferences vary significantly across demographics. Clothing is the dominant category for most groups, especially females aged 40+ and males aged 20–40, making it the most universally preferred product. However, Electronics leads among younger females and older males (50+), indicating strong tech-oriented demand in these segments. Beauty is more niche, appearing as the top choice mainly among young males and some younger females.

### Summary
Overall, the retail analysis shows that sales performance is strongly influenced by seasonality, customer concentration, and time-based buying behavior. While revenue remains relatively stable year-over-year, growth is limited and heavily driven by peak periods and a small group of high-value customers. Category performance is mixed, with some generating high revenue but lower margins, indicating opportunities to improve profitability through better pricing and cost strategies.

**Key Insights:**
- Sales peak strongly in Q4 (Sep–Dec), showing clear seasonal dependence
- Evening hours and weekends generate the highest revenue
- Electronics and Clothing are the main revenue drivers, with varying profit efficiency
- 50+ age group and top customers contribute the most to overall profit





