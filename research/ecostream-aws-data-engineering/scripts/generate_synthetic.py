"""Generate reproducible, fictional energy-telemetry sample records.

These records are newly generated and are NOT copied from the university dataset.
"""
from pathlib import Path
import json
import random

FIELDS = (
    "Facility ID", "Facility Type", "Operational Tier", "Country",
    "Energy Output 2024 (MWh)", "Energy Output 2025 (MWh)",
    "Maintenance Incidents 2024", "Maintenance Incidents 2025",
    "Downtime Hours 2024", "Downtime Hours 2025",
)
NUMERIC_FIELDS = set(FIELDS[4:])


def build_rows(count: int = 40, seed: int = 2026) -> list[dict]:
    rng = random.Random(seed)
    types = ["Solar", "Wind", "Hydro", "Biomass", "Geothermal"]
    countries = ["UK", "US", "DE", "FR", "CA", "JP"]
    records = []
    for idx in range(count):
        output_24 = rng.randrange(25000, 140001, 500)
        output_25 = max(10000, output_24 + rng.randrange(-16000, 16001, 500))
        records.append({
            "Facility ID": f"DEMO-{idx + 1:03d}",
            "Facility Type": types[idx % len(types)],
            "Operational Tier": "High-Performance" if idx % 3 != 0 else "Standard Efficiency",
            "Country": countries[idx % len(countries)],
            "Energy Output 2024 (MWh)": output_24,
            "Energy Output 2025 (MWh)": output_25,
            "Maintenance Incidents 2024": 0 if idx % 4 == 0 else rng.randint(1, 5),
            "Maintenance Incidents 2025": rng.randint(1, 5) if idx % 4 == 0 else rng.randint(0, 5),
            "Downtime Hours 2024": 9800 if idx == 0 else rng.randint(0, 180),
            "Downtime Hours 2025": rng.randint(0, 180),
        })
    return records


def as_dynamodb_json(row: dict) -> dict:
    return {"Item": {key: {"N": str(value)} if key in NUMERIC_FIELDS else {"S": value}
                     for key, value in row.items()}}


def generate(path: Path, count: int = 40) -> list[dict]:
    rows = build_rows(count)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(as_dynamodb_json(row), ensure_ascii=False) + "\n")
    return rows


if __name__ == "__main__":
    destination = Path(__file__).resolve().parents[1] / "data" / "synthetic_telemetry.jsonl"
    rows = generate(destination)
    print(f"Generated {len(rows)} fictional records in {destination}")
