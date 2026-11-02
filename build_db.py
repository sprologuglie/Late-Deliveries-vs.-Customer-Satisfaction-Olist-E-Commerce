import duckdb, pathlib

con = duckdb.connect("olist.duckdb")
for f in ["sql/00_load.sql", "sql/02_views.sql"]:
    con.execute(pathlib.Path(f).read_text())
print("DB pronto")