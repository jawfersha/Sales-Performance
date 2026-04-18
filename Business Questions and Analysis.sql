SELECT count(*) from calender;
SELECT count(*) from customers;
SELECT count(*) from products;
SELECT count(*) from sales;
SELECT count(*) from stores;

SELECT * from
sales s
JOIN customers C ON c.customer_id = s.customer_id
JOIN Products P ON p.product_id = s.product_id
JOIN stores st on st.store_id = s.store_id
JOIN calender ct on ct.date = s.order_date

-- Business Analysis Question

-- 1. What is the total revenue, cost, and profit?
SELECT 
round(SUM(revenue)::numeric,2) as Total_revenue,
round(SUM(cost)::numeric,2) as Total_cost,
round(SUM(profit)::numeric,2) as Total_profit
FROM sales;

-- 2. How are sales trending over time (monthly)

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue)::numeric,2) AS revenue
FROM sales
GROUP BY month
ORDER BY month;

-- 3. How are sales trending over time (Yearly)
SELECT 
	DATE_TRUNC('Year', order_date) AS Year,
	COUNT(*) AS Total_orders,
	ROUND(SUM(revenue)::NUMERIC,2) AS Total_revenue
FROM Sales
GROUP BY Year
ORDER BY Year;

-- 4. Which months have the highest and lowest sales?
(
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(revenue):: NUMERIC,2) AS total_revenue,
    'Highest' AS type
FROM sales
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 1
)

UNION ALL

(
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(revenue) AS total_revenue,
    'Lowest' AS type
FROM sales
GROUP BY month
ORDER BY total_revenue ASC
LIMIT 1
);


-- 5. Which products generate the highest to lowest revenue?
SELECT
	p.product_id,
	p.product_name,
	round(sum(s.revenue):: numeric,2) AS total_revenue
FROM sales s
JOIN products p
ON p.product_id = s.product_id
GROUP BY p.product_id , p.product_name
ORDER BY total_revenue DESC;

-- 6. Which products generate the highest profit
SELECT 
	p.product_id,
	p.product_name,
	round(sum(s.revenue):: numeric,2) AS total_revenue
FROM sales s
JOIN products p
ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
limit 1;
	
-- 7. Which products have high sales but low profit?

SELECT 
    p.product_id,
    p.product_name,
    ROUND(SUM(s.revenue)::numeric, 2) AS total_revenue,
    ROUND(SUM(s.profit)::numeric, 2) AS total_profit
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC, total_profit ASC;

-- 8. Who are the top customers by revenue?

SELECT 
    s.customer_id,
    ROUND(SUM(s.revenue)::numeric, 2) AS total_revenue
FROM sales s
JOIN customers c
    ON c.customer_id = s.customer_id
GROUP BY s.customer_id
ORDER BY total_revenue DESC;

-- 9. How many repeat customers do we have?

SELECT COUNT(*) repeated_customers
FROM 
(
SELECT customer_id
FROm sales
GROUP BY customer_id
HAVING COUNT(order_id)>1
) sub;

-- 10. What is the average order value per customer?

SELECT s.customer_id,
	round(sum(s.revenue):: numeric / count (distinct s.order_id), 2) as Avg_order_value
FROM sales s
GROUP BY s.customer_id
ORDER BY Avg_order_value DESC;

-- 11. Which stores generate the highest revenue?

SELECT s.store_id,
	st.store_name,
	round(SUM(s.revenue):: numeric,2) AS total_revenue 
	FROM
sales s
JOIN stores st
ON st.store_id = s.store_id
GROUP BY s.store_id, st.store_name
ORDER BY total_revenue DESC;

-- 12. Which stores are underperforming?

SELECT s.store_id,
	st.store_name,
	round(SUM(s.revenue):: numeric,2) AS total_revenue 
	FROM
sales s
JOIN stores st
ON st.store_id = s.store_id
GROUP BY s.store_id, st.store_name
ORDER BY total_revenue ASC;

-- 13. What is the overall profit margin?

SELECT 
    SUM(s.profit) / SUM(s.revenue) * 100 AS profit_margin_percentage
FROM sales s;

-- 14. Which products have the highest profit margin?

SELECT s.product_id,
	p.product_name, 
	SUM(s.profit) / SUM(s.revenue) * 100 AS profit_margin_percentage
FROM sales s
JOIN products p
ON p.product_id = s.product_id
GROUP BY s.product_id, p.product_name
ORDER BY profit_margin_percentage DESC;

-- 15. Which day of the week generates the most sales?

SELECT 
    TO_CHAR(order_date, 'Day') AS day_name,
    ROUND(SUM(revenue)::numeric, 2) AS total_revenue
FROM sales
GROUP BY day_name
ORDER BY total_revenue DESC;

-- 16. Are weekends or weekdays more profitable?

SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM order_date) IN (0,6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(profit)::numeric AS total_profit
FROM sales
GROUP BY day_type
ORDER BY total_profit DESC;
