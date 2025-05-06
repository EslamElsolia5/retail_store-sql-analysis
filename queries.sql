-- -- /Orders per Seller/
-- SELECT 
-- 	s.seller_id,
-- 	COUNT(oi.order_id) AS orders
-- FROM sellers AS s
-- INNER JOIN order_items AS oi
-- ON s.seller_id = oi.seller_id
-- GROUP BY s.seller_id
-- ORDER BY orders DESC
-- SELECT datname FROM pg_database;
-- -------------------------------------------------
-- -- /Total Revenue per Seller/
-- SELECT
-- 	s.seller_id,
-- 	ROUND(SUM(oi.price) :: numeric, 2) AS price
-- FROM sellers AS s
-- INNER JOIN order_items AS oi
-- ON s.seller_id = oi.seller_id
-- GROUP BY s.seller_id
-- ORDER BY price DESC
-- -- --------------------------------------------------
-- /Seller_delay/
-- WITH order_seller_details AS 
-- 	(SELECT 
-- 		oi.seller_id,
-- 		o.order_approved_at,
-- 		o.order_delivered_carrier_date
-- 	 FROM orders AS o
-- 	 INNER JOIN order_items AS oi
-- 	 ON o.order_id = oi.order_id
-- 	 INNER JOIN sellers AS s
-- 	 ON oi.seller_id = s.seller_id)
-- SELECT
-- 	osd.seller_id,
-- 	ABS(AVG(DATE_PART('day', order_approved_at - order_delivered_carrier_date))) AS total_delay_days
-- FROM order_seller_details AS osd
-- WHERE order_approved_at IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
-- GROUP BY osd.seller_id
-- ORDER BY total_delay_days DESC
-- --------------------------------------------------------------------------------------
-- -- /TOP 10 Products Sold/
-- SELECT
-- 	product_category_name,
-- 	COUNT(*) AS number_of_products
	
-- FROM products
-- GROUP BY product_category_name
-- ORDER BY number_of_products DESC
-- LIMIT 10;
-- -- -------------------------------------------------
-- /Revenue for each product_category/
-- WITH products_details AS (SELECT *
-- 	FROM products AS p
-- 	INNER JOIN order_items AS oi
-- 	ON p.product_id = oi.product_id)
-- SELECT
-- 	pd.product_category_name AS category,
-- 	AVG(op.payment_value) AS revenue
-- FROM order_payments AS op
-- INNER JOIN products_details AS pd
-- ON op.order_id = pd.order_id
-- WHERE pd.product_category_name IS NOT NULL AND op.payment_value IS NOT NULL
-- GROUP BY pd.product_category_name
-- ORDER BY revenue DESC
-- -- ---------------------------------------------------------------
-- /Product_Segmentation/
-- WITH product_segments AS 
-- 	(SELECT
-- 		product_category_name,
-- 		price,
-- 		CASE WHEN price < 2000 THEN 'Below 2000'
-- 		 	 WHEN price BETWEEN 2000 AND 4000 THEN '2000-4000'
-- 		     ELSE 'Above 4000'
-- 	    END AS cost_range

-- 	 FROM products AS p
-- 	 INNER JOIN order_items AS oi
-- 	 ON p.product_id = oi.product_id
-- 	 WHERE product_category_name IS NOT NULL)
-- SELECT 
-- 	cost_range,
-- 	COUNT(DISTINCT product_category_name) AS num_of_products
-- FROM product_segments
-- GROUP BY cost_range
-- ORDER BY num_of_products
-- ----------------------------------------------------------------------------------
-- -- /Total Revenue by Year/
-- SELECT
-- 	EXTRACT(YEAR FROM order_delivered_carrier_date) AS year,
-- 	ROUND(SUM(payment_value) :: NUMERIC, 2) AS total_payments

-- FROM orders AS o
-- INNER JOIN order_payments AS op
-- ON o.order_id = op.order_id
-- WHERE order_delivered_carrier_date IS NOT NULL
-- GROUP BY EXTRACT(YEAR FROM order_delivered_carrier_date)
-- ORDER BY SUM(payment_value)
-- -- ----------------------------------------------------------
-- -- /Avg profit by start of month/
-- SELECT
-- 	DATE_TRUNC('month', order_delivered_customer_date) AS start_of_month,
-- 	ROUND(AVG(payment_value - price) :: NUMERIC, 2) AS avg_profit
-- FROM orders AS o
-- INNER JOIN order_payments AS op
-- ON o.order_id = op.order_id
-- INNER JOIN order_items AS oi
-- ON op.order_id = oi.order_id
-- WHERE order_delivered_customer_date IS NOT NULL
-- GROUP BY DATE_TRUNC('month', order_delivered_customer_date)
-- ORDER BY avg_profit
-- -- ------------------------------------------------------------
-- -- /Revenue by city/
-- WITH payment_details AS (SELECT
-- 		*
-- 	FROM orders AS o
-- 	INNER JOIN order_payments AS op
-- 	ON o.order_id = op.order_id)

-- SELECT
-- 	customer_city,
-- 	ROUND(SUM(payment_value) :: NUMERIC, 2) AS Revenue
-- FROM payment_details AS pd
-- INNER JOIN customers AS c
-- ON pd.customer_id = c.customer_id
-- WHERE customer_city IS NOT NULL
-- GROUP BY customer_city
-- ORDER BY Revenue DESC
-- -- --------------------------------------------------------------
-- /Revenue Overtime/
-- SELECT
-- 	start_of_month,
-- 	ROUND(total_revenue :: NUMERIC, 2) AS revenue,
-- 	ROUND(SUM(total_revenue)
-- 		OVER(PARTITION BY EXTRACT(YEAR FROM start_of_month) ORDER BY start_of_month) :: NUMERIC, 2) AS running_revenue
	
-- FROM(SELECT 
-- 			DATE_TRUNC('month', order_delivered_customer_date) AS start_of_month,
-- 			SUM(payment_value) AS total_revenue
-- 		FROM orders AS o
-- 		INNER JOIN order_payments AS op
-- 		ON o.order_id = op.order_id
-- 		WHERE order_delivered_customer_date IS NOT NULL
-- 		GROUP BY DATE_TRUNC('month', order_delivered_customer_date)) AS t
-- -------------------------------------------------------------------------------
-- /%On-time Delivery/
-- SELECT
-- 	delivery_status,
-- 	ROUND((COUNT(*) / SUM(COUNT(*)) OVER()) * 100, 2) AS delivered_status_percentage
-- FROM
-- 	(SELECT
-- 		order_id,
-- 		CASE WHEN DATE_PART('day',order_delivered_customer_date - order_estimated_delivery_date) < 0 THEN 'On-Time'
-- 			 ELSE 'Late'
-- 		END AS delivery_status
-- 	 FROM orders
-- 	 WHERE order_delivered_customer_date IS NOT NULL)
-- GROUP BY delivery_status
------------------------------------------------------------------------------
--  /Tracking Sales Performance/
-- SELECT 
-- 	DATE_PART('year', order_delivered_customer_date) AS year,
-- 	payment_value,
-- 	LAG(payment_value, 1) OVER(PARTITION BY DATE_PART('year', order_delivered_customer_date))
-- FROM order_payments AS op
-- INNER JOIN orders AS o
-- ON op.order_id = o.order_id
-- ORDER BY year
-- -----------------------------------------------------------------------------------------



















