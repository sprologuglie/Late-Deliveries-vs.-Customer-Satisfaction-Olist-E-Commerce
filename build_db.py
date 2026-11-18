"""Build olist.duckdb: load the CSVs from data/ and create the views.

Run from the repository root:  python build_db.py
The notebook calls build() so it always works on a fresh database.
"""
import pathlib

import duckdb

SQL_FILES = ["sql/00_load.sql", "sql/02_views.sql"]
CSV_FILES = [
    "olist_customers_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv",
]


def build(db_path="olist.duckdb"):
    """Create (or refresh) the database and return an open connection."""
    missing = [f for f in CSV_FILES if not pathlib.Path("data", f).exists()]
    if missing:
        raise FileNotFoundError(
            f"Missing in data/: {', '.join(missing)}. Download the dataset from Kaggle "
            "(see README) and run this script from the repository root."
        )
    con = duckdb.connect(db_path)
    for f in SQL_FILES:
        con.execute(pathlib.Path(f).read_text())
    print("Database ready")
    return con


if __name__ == "__main__":
    build().close()
