"""Optional AWS DynamoDB read-only Scan example (not part of offline tests).

Only runs when explicitly invoked with an existing AWS table. Uses the
standard AWS credential provider chain: no credentials in source files.
DynamoDB Scan operations can incur costs. Never grant broader access than needed.
"""
import argparse
import csv
from pathlib import Path
from decimal import Decimal
from run_queries import FILTERS, PROJECTIONS


def scan_table(table, condition):
    kwargs = {"FilterExpression": condition}
    while True:
        response = table.scan(**kwargs)
        for item in response.get("Items", []):
            yield item
        if "LastEvaluatedKey" not in response:
            break
        kwargs["ExclusiveStartKey"] = response["LastEvaluatedKey"]


def main():
    parser = argparse.ArgumentParser(description="Read-only DynamoDB Scan filters")
    parser.add_argument("--table", required=True, help="Existing DynamoDB table name")
    parser.add_argument("--region", default="us-east-1", help="AWS region")
    parser.add_argument("--output", type=Path, default=Path("results/aws_outputs"))
    args = parser.parse_args()
    try:
        import boto3
        from boto3.dynamodb.conditions import Attr
    except ImportError:
        raise SystemExit("Install boto3 with: python -m pip install -r requirements-aws.txt")
    table = boto3.resource("dynamodb", region_name=args.region).Table(args.table)
    filters = {
        "query1": Attr("Maintenance Incidents 2024").eq(0) & Attr("Maintenance Incidents 2025").gte(1),
        "query2": Attr("Energy Output 2025 (MWh)").lt(50000),
        "query3": Attr("Facility Type").eq("Wind") & Attr("Operational Tier").eq("High-Performance"),
        "query4": Attr("Energy Output 2024 (MWh)").gt(100000) & Attr("Energy Output 2025 (MWh)").gt(100000),
        "query5": Attr("Downtime Hours 2024").gt(8784),
    }
    args.output.mkdir(parents=True, exist_ok=True)
    for name, expression in filters.items():
        values = list(scan_table(table, expression))
        with (args.output / f"{name}.csv").open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=PROJECTIONS[name], extrasaction="ignore")
            writer.writeheader()
            for row in values:
                writer.writerow({key: str(value) if isinstance(value, Decimal) else value
                                 for key, value in row.items() if key in PROJECTIONS[name]})
        print(f"{name}: {len(values)} matching items")


if __name__ == "__main__":
    main()
