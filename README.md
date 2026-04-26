# Retail-Sales-Analysis
## Project Overview
**Project Title:** Retail Sales Analysis  
**Stack:** SQL  

This Retail Sales Analysis project uses SQL to evaluate sales performance, profitability, and customer segments. It calculates revenue, profit, and margins, and identifies high-sales but low-margin categories, with added age group segmentation and data validation to ensure accurate insights.

## Objectives
1. **Set up retail sales database** – Create and structure the database to store transactional retail data for analysis.
2. **Perform data cleaning** – Identify and correct inconsistencies, missing values, and data quality issues.
3. **Conduct exploratory data analysis** – Explore the dataset to understand patterns, trends, and key metrics.
4. **Perform business analysis to generate insights** – Analyze results to uncover actionable insights for decision-making.

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
#### 1. Data Cleaning

```sql

```




