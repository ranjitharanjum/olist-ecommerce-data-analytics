-- Olist business analysis queries
-- Use these against the cleaned analytical dataset or SQL-exported tables.

-- 1) Total revenue and average order value
SELECT
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(AVG(order_revenue), 2) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(price) AS order_revenue,
        MAX(price) AS price
    FROM olist_order_items
    GROUP BY order_id
) t;

-- 2) Revenue by state
SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue
FROM olist_orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- 3) Monthly revenue trend
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM olist_orders o
JOIN olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;

-- 4) Top product categories by revenue
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items oi
JOIN olist_products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- 5) Orders with multiple payment transactions (to validate duplication risk)
SELECT
    order_id,
    COUNT(*) AS payment_row_count,
    ROUND(SUM(payment_value), 2) AS payment_total
FROM olist_order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_row_count DESC, payment_total DESC;

-- 6) Seller performance by revenue
SELECT
    s.seller_id,
    s.seller_city,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders_served
FROM olist_order_items oi
JOIN olist_sellers s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_city
ORDER BY revenue DESC
LIMIT 20;
