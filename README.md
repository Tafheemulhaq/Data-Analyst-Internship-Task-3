# Ecommerce SQL Data Analysis

**Internship Task 3 — SQL for Data Analysis**

## Objective
Use SQL to extract and analyze structured ecommerce data. This project demonstrates filtering, sorting, grouping, joins, subqueries, aggregate functions, views, and indexes using SQLite.

## Dataset
A small, synthetic ecommerce dataset is included in `data/`:
- 20 customers
- 12 products
- 30 orders
- Order line items in `order_items.csv`

All names, emails, and transactions are fictional and created for this learning project. Revenue is calculated as `quantity × product price`. Unless a query says otherwise, the examples do not exclude cancelled or returned orders.

## Repository structure
```text
.
├── data/
│   ├── customers.csv
│   ├── products.csv
│   ├── orders.csv
│   └── order_items.csv
├── scripts/
│   └── setup_database.py
├── sql/
│   └── analysis_queries.sql
├── screenshots/
│   ├── 01_product_revenue.png
│   ├── 02_customer_orders.png
│   ├── 03_city_revenue.png
│   └── 04_view_summary.png
├── ecommerce.db
└── interview_questions.md
```

## How to run
Python 3 and SQLite are sufficient; no third-party Python packages are required.

1. Clone or download this repository.
2. From the repository root, run:
   ```bash
   python scripts/setup_database.py
   ```
   This recreates `ecommerce.db` from the CSV files.
3. Open `ecommerce.db` using DB Browser for SQLite, SQLiteStudio, or the `sqlite3` command-line tool.
4. Execute `sql/analysis_queries.sql`.

The RIGHT JOIN example requires SQLite 3.39.0 or newer. On older SQLite versions, rewrite it by putting `products` on the left side of a LEFT JOIN.

## SQL concepts demonstrated
| Concept | Demonstration |
|---|---|
| SELECT, WHERE, ORDER BY | Filter and sort products |
| GROUP BY | Aggregate sales by product and city |
| INNER JOIN | Match orders to customers |
| LEFT JOIN | Retain customers with zero orders |
| RIGHT JOIN | Retain products with no matching order item |
| Subquery | Compare customer spend with average customer spend |
| SUM and AVG | Revenue, units sold, and average order value |
| View | `product_sales_summary` |
| Indexes | Index customer, order, product, and date lookup columns |
| Query plan | `EXPLAIN QUERY PLAN` |

## Notes
- `ecommerce.db` is included so the database can be explored immediately.
- The setup script can rebuild the database from the CSV files.
- The screenshots show selected query results generated from the included database.
- This is a learning dataset, not real business or customer information.
