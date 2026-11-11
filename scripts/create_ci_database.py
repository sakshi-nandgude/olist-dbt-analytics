
from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "ci_olist.duckdb"

if DB_PATH.exists():
    DB_PATH.unlink()

con = duckdb.connect(str(DB_PATH))

try:
    con.execute("CREATE SCHEMA raw")

    # Customers
    con.execute("""
        CREATE TABLE raw.customers (
            customer_id VARCHAR,
            customer_unique_id VARCHAR,
            customer_zip_code_prefix INTEGER,
            customer_city VARCHAR,
            customer_state VARCHAR
        )
    """)

    con.execute("""
        INSERT INTO raw.customers VALUES
        ('C001', 'U001', 10001, 'sao paulo', 'SP'),
        ('C002', 'U001', 10002, 'sao paulo', 'SP'),
        ('C003', 'U002', 20001, 'rio de janeiro', 'RJ')
    """)

    # Orders
    con.execute("""
        CREATE TABLE raw.orders (
            order_id VARCHAR,
            customer_id VARCHAR,
            order_status VARCHAR,
            order_purchase_timestamp TIMESTAMP,
            order_approved_at TIMESTAMP,
            order_delivered_carrier_date TIMESTAMP,
            order_delivered_customer_date TIMESTAMP,
            order_estimated_delivery_date TIMESTAMP
        )
    """)

    con.execute("""
        INSERT INTO raw.orders VALUES
        ('O001', 'C001', 'delivered',
         '2018-01-05 10:00:00',
         '2018-01-05 11:00:00',
         '2018-01-06 09:00:00',
         '2018-01-08 12:00:00',
         '2018-01-10 00:00:00'),

        ('O002', 'C002', 'delivered',
         '2018-02-05 10:00:00',
         '2018-02-05 11:00:00',
         '2018-02-06 09:00:00',
         '2018-02-12 12:00:00',
         '2018-02-10 00:00:00'),

        ('O003', 'C003', 'canceled',
         '2018-03-05 10:00:00',
         NULL, NULL, NULL,
         '2018-03-15 00:00:00')
    """)

    # Order items
    con.execute("""
        CREATE TABLE raw.order_items (
            order_id VARCHAR,
            order_item_id INTEGER,
            product_id VARCHAR,
            seller_id VARCHAR,
            shipping_limit_date TIMESTAMP,
            price DOUBLE,
            freight_value DOUBLE
        )
    """)

    con.execute("""
        INSERT INTO raw.order_items VALUES
        ('O001', 1, 'P001', 'S001',
         '2018-01-07 00:00:00', 100.00, 10.00),

        ('O001', 2, 'P002', 'S001',
         '2018-01-07 00:00:00', 50.00, 5.00),

        ('O002', 1, 'P001', 'S001',
         '2018-02-07 00:00:00', 80.00, 8.00),

        ('O003', 1, 'P002', 'S001',
         '2018-03-07 00:00:00', 40.00, 4.00)
    """)

    # Products
    con.execute("""
        CREATE TABLE raw.products (
            product_id VARCHAR,
            product_category_name VARCHAR,
            product_name_lenght INTEGER,
            product_description_lenght INTEGER,
            product_photos_qty INTEGER,
            product_weight_g INTEGER,
            product_length_cm INTEGER,
            product_height_cm INTEGER,
            product_width_cm INTEGER
        )
    """)

    con.execute("""
        INSERT INTO raw.products VALUES
        ('P001', 'electronics', 20, 100, 2,
         500, 20, 10, 15),

        ('P002', 'furniture', 25, 150, 3,
         1200, 30, 20, 25)
    """)

    # Payments
    con.execute("""
        CREATE TABLE raw.payments (
            order_id VARCHAR,
            payment_sequential INTEGER,
            payment_type VARCHAR,
            payment_installments INTEGER,
            payment_value DOUBLE
        )
    """)

    con.execute("""
        INSERT INTO raw.payments VALUES
        ('O001', 1, 'credit_card', 1, 165.00),
        ('O002', 1, 'boleto', 1, 88.00),
        ('O003', 1, 'voucher', 1, 44.00)
    """)

    print("CI database created successfully.")

    tables = con.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw'
        ORDER BY table_name
    """).fetchall()

    print("Created raw tables:")
    for table in tables:
        print(f"- {table[0]}")

finally:
    con.close()
