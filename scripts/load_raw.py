
from pathlib import Path

import duckdb


# Project paths
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data" / "raw"
DB_PATH = PROJECT_ROOT / "olist.duckdb"


# Source CSV files and their raw table names
TABLES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "products": "olist_products_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
}


def load_raw_data():
    """Load the Olist CSV files into DuckDB raw schema."""

    # Connect to the DuckDB database file
    con = duckdb.connect(str(DB_PATH))

    try:
        # Create the raw schema
        con.execute("CREATE SCHEMA IF NOT EXISTS raw")

        for table_name, file_name in TABLES.items():

            csv_path = DATA_DIR / file_name

            if not csv_path.exists():
                raise FileNotFoundError(
                    f"Missing dataset file: {csv_path}"
                )

            # Safely escape the file path for SQL
            csv_path_sql = str(csv_path).replace("\\", "/")
            csv_path_sql = csv_path_sql.replace("'", "''")

            # Load CSV into the raw schema
            sql = f"""
                CREATE OR REPLACE TABLE raw.{table_name} AS
                SELECT *
                FROM read_csv_auto(
                    '{csv_path_sql}',
                    header = true
                )
            """

            con.execute(sql)

            # Check loaded row count
            row_count = con.execute(
                f"SELECT COUNT(*) FROM raw.{table_name}"
            ).fetchone()[0]

            print(
                f"Loaded raw.{table_name}: "
                f"{row_count:,} rows"
            )

        print("\nAll raw tables loaded successfully.")

    finally:
        con.close()


if __name__ == "__main__":
    load_raw_data()
