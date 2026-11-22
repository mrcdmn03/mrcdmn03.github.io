"""Execute the IS4S761 case study with Python's built-in SQLite engine."""
from pathlib import Path
import sqlite3

BASE = Path(__file__).resolve().parent / "sql"


def main():
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys = ON")
    db.executescript((BASE / "01_schema.sql").read_text(encoding="utf-8"))
    db.executescript((BASE / "02_seed.sql").read_text(encoding="utf-8"))

    parts = (BASE / "03_analysis_queries.sql").read_text(encoding="utf-8").split("-- Query ")[1:]
    for part in parts:
        number, _, rest = part.partition(":")
        rows = db.execute(rest.split("\n", 1)[1].strip())
        print("\nQUERY", number.strip(), "|", ", ".join(c[0] for c in rows.description))
        for row in rows:
            print("  ", " | ".join(str(value) for value in row))
    db.close()


if __name__ == "__main__":
    main()
