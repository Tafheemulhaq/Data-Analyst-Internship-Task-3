"""Create the SQLite ecommerce database from the CSV files in ../data."""
from pathlib import Path
import csv
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
DB = ROOT / "ecommerce.db"

def load_csv(filename):
    with (DATA / filename).open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def main():
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    cur.executescript("""
    PRAGMA foreign_keys = ON;
    DROP VIEW IF EXISTS product_sales_summary;
    DROP TABLE IF EXISTS order_items;
    DROP TABLE IF EXISTS orders;
    DROP TABLE IF EXISTS products;
    DROP TABLE IF EXISTS customers;

    CREATE TABLE customers (
        customer_id INTEGER PRIMARY KEY,
        customer_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        city TEXT,
        signup_date TEXT
    );
    CREATE TABLE products (
        product_id INTEGER PRIMARY KEY,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL CHECK(price >= 0)
    );
    CREATE TABLE orders (
        order_id INTEGER PRIMARY KEY,
        customer_id INTEGER NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
    );
    CREATE TABLE order_items (
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL CHECK(quantity > 0),
        PRIMARY KEY(order_id, product_id),
        FOREIGN KEY(order_id) REFERENCES orders(order_id),
        FOREIGN KEY(product_id) REFERENCES products(product_id)
    );
    """)
    cur.executemany("INSERT INTO customers VALUES (?,?,?,?,?)",
        [(int(r["customer_id"]),r["customer_name"],r["email"],r["city"],r["signup_date"]) for r in load_csv("customers.csv")])
    cur.executemany("INSERT INTO products VALUES (?,?,?,?)",
        [(int(r["product_id"]),r["product_name"],r["category"],float(r["price"])) for r in load_csv("products.csv")])
    cur.executemany("INSERT INTO orders VALUES (?,?,?,?)",
        [(int(r["order_id"]),int(r["customer_id"]),r["order_date"],r["status"]) for r in load_csv("orders.csv")])
    cur.executemany("INSERT INTO order_items VALUES (?,?,?)",
        [(int(r["order_id"]),int(r["product_id"]),int(r["quantity"])) for r in load_csv("order_items.csv")])
    conn.commit()
    print(f"Database created: {DB}")
    for table in ("customers","products","orders","order_items"):
        count = cur.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"{table}: {count} rows")
    conn.close()

if __name__ == "__main__":
    main()
