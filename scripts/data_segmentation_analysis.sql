-- Data segmentation
-- Segment products into cost ranges and count how many products fall into each segment

WITH product_segment AS (SELECT
	product_key
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END AS cost_range
FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(cost_range) AS total_products
FROM product_segment
GROUP BY cost_range;


--------------------------------------------------------------------------------
WITH segmented_customer AS (
	SELECT
		s.customer_key,
		SUM(sales_amount) AS total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
	GROUP BY s.customer_key
)
SELECT 
	CASE WHEN lifespan > 12 AND total_spending > 5000 THEN  'VIP'
		 WHEN lifespan > 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segment,
	COUNT(customer_key) AS total_customer
FROM segmented_customer
GROUP BY CASE WHEN lifespan > 12 AND total_spending > 5000 THEN  'VIP'
		 WHEN lifespan > 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
		 END 
