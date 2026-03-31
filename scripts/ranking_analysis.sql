-- Which 5 products generate the highest revenue?
SELECT TOP 5
	s.product_key,
	p.product_name,
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY s.product_key, p.product_name, p.category
ORDER BY total_sales DESC;

SELECT *
FROM (
	SELECT	
		p.product_name,
		SUM(s.sales_amount) AS total_sales,
		ROW_NUMBER() OVER( ORDER BY SUM(s.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
	GROUP BY p.product_name)t
WHERE rank_products <= 5;

-- Which 5 products generate the lowest revenue?
SELECT TOP 5
	s.product_key,
	p.product_name,
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY s.product_key, p.product_name, p.category
ORDER BY total_sales;

-- Top 10 customers who have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY SUM(s.sales_amount) DESC;

-- The lowest 3 customers 
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders
