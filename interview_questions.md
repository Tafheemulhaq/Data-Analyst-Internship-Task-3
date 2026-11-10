# SQL Interview Questions — Task 3

### 1. What is the difference between WHERE and HAVING?
`WHERE` filters individual rows before grouping and aggregation. `HAVING` filters groups after `GROUP BY` and is commonly used with aggregate expressions such as `SUM()` or `COUNT()`.

### 2. What are the different types of joins?
- **INNER JOIN:** returns rows with matching keys in both tables.
- **LEFT JOIN:** returns every row from the left table and matching rows from the right; unmatched right-side values are `NULL`.
- **RIGHT JOIN:** returns every row from the right table and matching rows from the left.
- **FULL OUTER JOIN:** returns matched rows plus unmatched rows from both sides (support depends on the database).
- **CROSS JOIN:** returns the Cartesian product of the two tables.

### 3. How do you calculate average revenue per user in SQL?
First calculate each user's revenue, then average those user-level totals. For example:
```sql
SELECT AVG(user_revenue)
FROM (
    SELECT o.customer_id, SUM(oi.quantity * p.price) AS user_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY o.customer_id
) AS customer_totals;
```
This version averages spending among customers who placed at least one order. To include customers with no orders as zero-revenue users, start from `customers` and use LEFT JOIN with `COALESCE`.

### 4. What are subqueries?
A subquery is a query nested inside another SQL statement. It can return a scalar value, a list of values, or a derived table used by the outer query. The project uses a subquery to compare each customer's spend with average customer spend.

### 5. How do you optimize a SQL query?
Use indexes on columns frequently used for joins and selective filters; select only needed columns; avoid unnecessary operations; inspect the query plan with `EXPLAIN`/`EXPLAIN QUERY PLAN`; and validate performance on realistic data. Indexes add storage and can slow writes, so they should be chosen based on query patterns.

### 6. What is a view in SQL?
A view is a named query that can be queried like a table. It generally stores the query definition rather than a separate copy of the result. The project creates `product_sales_summary` to reuse product-level sales calculations.

### 7. How would you handle NULL values in SQL?
Check for missing values with `IS NULL` or `IS NOT NULL`; replace them when appropriate with `COALESCE()`; use `NULLIF()` to avoid invalid division; and decide whether missing values should be excluded, retained, or treated as zero based on the meaning of the data. Avoid treating every NULL as zero without considering context.
