-- Task 3: SQL for Data Analysis
-- Database: Ecommerce SQLite sample database
-- Run after scripts/setup_database.py has created ecommerce.db.
-- Revenue is calculated from order_items.quantity * products.price.
-- For this analysis, revenue includes all order statuses unless a query explicitly filters them.

-- 1. SELECT, WHERE and ORDER BY: list higher-value products
SELECT product_id, product_name, category, price
FROM products
WHERE price >= 1500
ORDER BY price DESC;

-- 2. GROUP BY + aggregate functions: total revenue and units by product
SELECT p.product_name,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM order_items AS oi
INNER JOIN products AS p ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC;

-- 3. INNER JOIN: orders with their customer details
SELECT o.order_id, c.customer_name, c.city, o.order_date, o.status
FROM orders AS o
INNER JOIN customers AS c ON c.customer_id = o.customer_id
ORDER BY o.order_date;

-- 4. LEFT JOIN: include customers even if they have no orders
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS number_of_orders
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY number_of_orders DESC, c.customer_name;

-- 5. RIGHT JOIN: include every product, including products never ordered.
-- SQLite 3.39.0+ supports RIGHT JOIN. If using an older SQLite version,
-- reverse the tables and use LEFT JOIN instead.
SELECT p.product_id, p.product_name, oi.order_id, oi.quantity
FROM order_items AS oi
RIGHT JOIN products AS p ON p.product_id = oi.product_id
ORDER BY p.product_id;

-- 6. Subquery: customers whose total spend is above the average customer spend
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * p.price), 2) AS total_spend
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(oi.quantity * p.price) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(oi2.quantity * p2.price) AS customer_total
        FROM orders AS o2
        JOIN order_items AS oi2 ON oi2.order_id = o2.order_id
        JOIN products AS p2 ON p2.product_id = oi2.product_id
        GROUP BY o2.customer_id
    )
)
ORDER BY total_spend DESC;

-- 7. AVG: average order value
SELECT ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT o.order_id, SUM(oi.quantity * p.price) AS order_total
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    JOIN products AS p ON p.product_id = oi.product_id
    GROUP BY o.order_id
);

-- 8. GROUP BY: revenue by customer city
SELECT c.city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(oi.quantity * p.price), 2) AS revenue
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
GROUP BY c.city
ORDER BY revenue DESC;

-- 9. View: reusable product performance summary
CREATE VIEW IF NOT EXISTS product_sales_summary AS
SELECT p.product_id, p.product_name, p.category,
       COALESCE(SUM(oi.quantity), 0) AS units_sold,
       ROUND(COALESCE(SUM(oi.quantity * p.price), 0), 2) AS revenue
FROM products AS p
LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- Query the view
SELECT * FROM product_sales_summary ORDER BY revenue DESC;

-- 10. Indexes: improve lookups and joins on frequently used columns
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);

-- Inspect query plan (SQLite-specific)
EXPLAIN QUERY PLAN
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 3
ORDER BY order_date;
