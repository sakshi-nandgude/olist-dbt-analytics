
from pathlib import Path

import duckdb


PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "olist.duckdb"

con = duckdb.connect(str(DB_PATH), read_only=True)

try:
    tables = con.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw'
        ORDER BY table_name
    """).fetchall()

    print("Raw tables:")
    for table in tables:
        print("-", table[0])

    print("\nOrders sample:")

    result = con.execute("""
        SELECT
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp
        FROM raw.orders
        LIMIT 5
    """).df()

    print(result)

finally:
    con.close()
