/*
-- Cumulative analysis 
-- Calculate the total sales per month
-- and the running total of sales over times
*/
SELECT 
	order_date,
	total_sales_per_month,
	SUM(total_sales_per_month) OVER(ORDER BY order_date) AS running_total,
	SUM(avg_price) OVER(ORDER BY order_date) AS moving_avg
FROM (SELECT 
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales_per_month,
	AVG(price) AS avg_price
	FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t

-- Analyze the yearly performance of products by comparing their sales to both the avg sales
-- performance of the product and the prev year sales
WITH yearly_product_sales AS(
SELECT 
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
		 ELSE 'Avg'
	END AS avg_change,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increasing'
		 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreasing'
		 ELSE 'No change'
	END AS year_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
