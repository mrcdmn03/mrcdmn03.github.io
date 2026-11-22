"""Offline reproduction of five coursework DynamoDB Scan filters.

The original coursework used the AWS Console and its own dataset. This
standalone Python implementation runs against separate synthetic examples.
No AWS account, AWS SDK, credentials or network access is required.
"""
from __future__ import annotations
import argparse
import csv
import json
from pathlib import Path
from typing import Callable

ROOT = Path(__file__).resolve().parents[1]
FIELDS = [
    "Facility ID", "Facility Type", "Operational Tier", "Country",
    "Energy Output 2024 (MWh)", "Energy Output 2025 (MWh)",
    "Maintenance Incidents 2024", "Maintenance Incidents 2025",
    "Downtime Hours 2024", "Downtime Hours 2025",
]
NUMERIC = set(FIELDS[4:])
FILTERS: dict[str, Callable[[dict], bool]] = {
    "query1": lambda r: r["Maintenance Incidents 2024"] == 0 and r["Maintenance Incidents 2025"] >= 1,
    "query2": lambda r: r["Energy Output 2025 (MWh)"] < 50000,
    "query3": lambda r: r["Facility Type"] == "Wind" and r["Operational Tier"] == "High-Performance",
    "query4": lambda r: r["Energy Output 2024 (MWh)"] > 100000 and r["Energy Output 2025 (MWh)"] > 100000,
    "query5": lambda r: r["Downtime Hours 2024"] > 8784,
}
PROJECTIONS = {
    "query1": FIELDS,
    "query2": ["Facility ID", "Country"],
    "query3": ["Facility ID"],
    "query4": FIELDS,
    "query5": FIELDS,
}


def read_documents(path: Path) -> list[dict]:
    """Read newline-delimited DynamoDB JSON (or adjacent JSON objects)."""
    text = path.read_text(encoding="utf-8-sig")
    decoder = json.JSONDecoder()
    index, items = 0, []
    while index < len(text):
        while index < len(text) and text[index].isspace():
            index += 1
        if index >= len(text):
            break
        obj, index = decoder.raw_decode(text, index)
        if not isinstance(obj, dict) or not isinstance(obj.get("Item"), dict):
            raise ValueError("Each object must contain a DynamoDB JSON 'Item' object")
        items.append(obj)
    return items


def normalise(item: dict) -> dict:
    values = {}
    for name in FIELDS:
        if name not in item:
            raise ValueError(f"Required field missing: {name}")
        typed = item[name]
        if name in NUMERIC:
            if "N" not in typed:
                raise ValueError(f"{name} must use DynamoDB N format")
            values[name] = int(typed["N"])
        else:
            if "S" not in typed:
                raise ValueError(f"{name} must use DynamoDB S format")
            values[name] = str(typed["S"])
    return values


def run(input_file: Path, output_folder: Path) -> dict[str, int]:
    rows = [normalise(obj["Item"]) for obj in read_documents(input_file)]
    if len({row["Facility ID"] for row in rows}) != len(rows):
        raise ValueError("Duplicate Facility ID found; partition keys must be unique")
    output_folder.mkdir(parents=True, exist_ok=True)
    summary = {"input_records": len(rows)}
    for name, predicate in FILTERS.items():
        selected = [row for row in rows if predicate(row)]
        fields = PROJECTIONS[name]
        with (output_folder / f"{name}.csv").open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            writer.writerows({field: row[field] for field in fields} for row in selected)
        summary[name] = len(selected)
    (output_folder / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    return summary


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Recreate the five EcoStream Scan filters locally")
    p.add_argument("--input", type=Path, default=ROOT / "data" / "synthetic_telemetry.jsonl")
    p.add_argument("--output", type=Path, default=ROOT / "results" / "generated")
    args = p.parse_args()
    result = run(args.input, args.output)
    print(json.dumps(result, indent=2))
