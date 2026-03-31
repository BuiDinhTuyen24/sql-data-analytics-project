-- Part tho whole analysis
-- Which categories contribute the most to overall sales
SELECT
	category,
	sales_rev,
	CAST(ROUND(CAST(sales_rev AS float)/SUM(sales_rev) OVER() *100.0,2) AS VARCHAR) + '%' AS percentage
FROM(
SELECT 
	category,
	SUM(sales_amount) AS sales_rev
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY category)t
ORDER BY sales_rev DESC
