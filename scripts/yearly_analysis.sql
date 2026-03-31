SELECT 
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_Sale,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM  (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)
