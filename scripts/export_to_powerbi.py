
from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "olist.duckdb"
EXPORT_DIR = PROJECT_ROOT / "data" / "processed"

EXPORT_DIR.mkdir(parents=True, exist_ok=True)

# Final datasets required by Power BI
TABLES = {
    "fct_orders": "orders.csv",
    "dim_customers": "customers.csv",
    "dim_products": "products.csv",
    "mart_monthly_revenue": "monthly_revenue.csv",
    "int_order_items_enriched": "product_sales.csv",
}

con = duckdb.connect(str(DB_PATH), read_only=True)

try:
    for table_name, file_name in TABLES.items():

        output_path = EXPORT_DIR / file_name

        # Confirm the model exists
        exists = con.execute("""
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = 'main'
              AND table_name = ?
        """, [table_name]).fetchone()[0]

        if not exists:
            raise ValueError(
                f"Model not found: main.{table_name}"
            )

        # Export model to CSV
        escaped_path = str(output_path).replace("\\", "/")
        escaped_path = escaped_path.replace("'", "''")

        con.execute(f"""
            COPY (
                SELECT *
                FROM main.{table_name}
            )
            TO '{escaped_path}'
            (HEADER, DELIMITER ',')
        """)

        row_count = con.execute(
            f"SELECT COUNT(*) FROM main.{table_name}"
        ).fetchone()[0]

        print(f"Exported {table_name}: {row_count:,} rows")
        print(f"Saved to: {output_path}")

    print("\nAll Power BI datasets exported successfully!")

finally:
    con.close()
