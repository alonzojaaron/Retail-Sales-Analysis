-------------------- RETAIL SALES ANALYSIS --------------------
SELECT * FROM retail_sales;

-- Total count of rows 
SELECT
	COUNT(*) AS row_count
FROM retail_sales;

---- DATA CLEANING ----

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

---- EXPLORATORY DATA ANALYSIS ----

-- How many sales?
SELECT
	COUNT(*) AS sale_count
FROM retail_sales;

-- How many unique customers?
SELECT
	COUNT(DISTINCT customer_id) AS customer_count
FROM retail_sales;

-- How many unique categories?
SELECT
	COUNT(DISTINCT category) AS category_Count
FROM retail_sales;

-- List of unique categories?
SELECT
	DISTINCT category
FROM retail_sales;


---- DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS ----

-- Revenue and Sales Performance --

-- 1. What is the total revenue and sales trend over time (daily, monthly, yearly)?
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

-- 2. Which days of the week generate the highest sales?
SELECT 
	DATENAME(WEEKDAY, sale_date) AS day,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATENAME(WEEKDAY, sale_date)
ORDER BY total_revenue DESC;

-- 3. Find out best selling month in each year.
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

-- 4. Are sales growing or declining? 
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

-- 5. What are the peak sales hours during the day?
SELECT 
	DATEPART(HOUR, sale_time) AS hour,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY DATEPART(HOUR, sale_time)
ORDER BY total_revenue DESC;

-- Product & Category Insights --
-- 1. Which product categories generate the most revenue?
SELECT
	category,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- 2. Which categories have the highest volume vs highest profit (cogs vs total_sale)?
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

-- 3. What categories are underperforming or declining over time?
-- Step 1: Monthly Revenue per Category
SELECT
	category,
	YEAR(sale_date) AS year,
	MONTH(sale_date) AS month,
	SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY
	category,
	YEAR(sale_date),
	MONTH(sale_date);

-- Step 2: Add Trend (growth vs previous month)
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

-- 4. What is the average basket size (quantity per transaction) per category?
SELECT
	category,
	AVG(quantity * 1.0) AS avg_items_per_transaction,
	SUM(quantity) AS total_items_sold,
	COUNT(transactions_id) total_transactions
FROM retail_sales
GROUP BY category
ORDER BY avg_items_per_transaction DESC;

-- Customer Behavior & Segmentation --
-- 1. Who are your top customers by total spend?
SELECT
	customer_id,
	COUNT(transactions_id) AS total_orders,
	SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC;

-- 2. What is the average spend per customer?
SELECT
	AVG(total_spent) AS average_spend_per_customer
FROM (
	SELECT
		customer_id,
		SUM(total_sale) AS total_spent
	FROM retail_sales
	GROUP BY customer_id
) AS t;

-- 3. How does purchasing behavior differ by:
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
	MIN(age) AS min_age,
	MAX(age) AS max_age
FROM retail_sales;

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

-- 4. Which age groups contribute the most revenue?
SELECT
	TOP 1
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
ORDER BY total_revenue DESC;


-- Time-Based Buying Patterns --
-- 1. How do sales vary by time of day (Morning/Afternoon/Evening)?
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

-- 2. What categories are popular during morning, afternoon, and evening?
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

-- Pricing & Profitability Analysis --
-- 1. Which categories have high sales but low margins?
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

-- 2. How does price_per_unit affect quantity sold?
SELECT
    price_per_unit,
    SUM(quantity) AS total_quantity_sold,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY price_per_unit
ORDER BY total_quantity_sold DESC;


-- Customer Retention & Frequency --

-- 1. How often do customers return and purchase again?
SELECT
	customer_id,
	COUNT(transactions_id) AS total_returns,
	SUM(quantity) AS total_orders
FROM retail_sales
GROUP BY customer_id
ORDER BY total_returns DESC;

-- 2. What is the time gap between purchases per customer?
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


-- 3. Who are one-time vs repeat buyers?
SELECT
	customer_id,
	CASE
		WHEN COUNT(transactions_id) > 1 THEN 'Repeat Buyer'
		ELSE 'First-time Buyer'
	END AS customer_classification
FROM retail_sales
GROUP BY customer_id
ORDER BY customer_classification;


-- Demographic Profitability --
-- 1. Which demographic group is the most profitable?
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
ORDER BY total_profit DESC


-- 2. Do certain groups prefer specific categories (Top Category per Demographic)?
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

-------------------- END --------------------