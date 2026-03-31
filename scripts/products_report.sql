/*
================================================================================
Products report
================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors.

Hightlights:
	1. Gathers essential fields such as names, ages, and transactions details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregated customer-level metrics:
		- Total orders
		- Total sales
		- Total quantity purchases
		- Total products
		- Lifespan(in months)
	4. Calculates valuable KPIs:
		- Recency
		- Average order value
		- Average monthly spend
===============================================================================
1) Base query: Retrieves core columns from tables
*/
CREATE VIEW gold.reports_products AS
WITH base_query AS (
	SELECT
		s.order_number,
		s.customer_key,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
	WHERE order_date IS NOT NULL),
intermediate_query AS(
	SELECT
		product_key,
		product_name,
		category,
		cost,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price,
		MAX(order_date) AS last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY product_key,
			 product_name,
			 category,
			 cost
)
SELECT 
	product_key,
	product_name,
	category,
	cost,
	last_order_date,
	CONCAT(DATEDIFF(month, last_order_date, GETDATE()), ' ' ,'months') AS recency_in_months,
	CASE WHEN total_sales > 50000 THEN 'High performer'
		 WHEN total_sales >= 10000 THEN 'Mid range'
		 ELSE 'Low performer'
	END AS product_segment,
	total_orders,
	total_quantity,
	total_sales,
	total_customers,
	avg_selling_price,
	-- Average order revenue
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales/total_orders 
	END AS avg_order_revenue,
	-- Average monthly revenue
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/lifespan
	END AS avg_monthly_revenue
FROM intermediate_query

