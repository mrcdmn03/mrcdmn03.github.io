"""Local-only tests; no network calls or AWS account required."""
import csv
import json
from pathlib import Path
import tempfile
import unittest
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from generate_synthetic import generate  # noqa: E402
from run_queries import read_documents, normalise, run, FILTERS, PROJECTIONS  # noqa: E402


class QueryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)
        self.input = self.folder / "synthetic.jsonl"
        self.rows = generate(self.input)

    def test_synthetic_records_have_unique_partition_keys(self):
        self.assertEqual(len(self.rows), 40)
        self.assertEqual(len({r["Facility ID"] for r in self.rows}), 40)
        self.assertTrue(all(r["Facility ID"].startswith("DEMO-") for r in self.rows))

    def test_json_parser_and_types(self):
        loaded = [normalise(x["Item"]) for x in read_documents(self.input)]
        self.assertEqual(self.rows, loaded)

    def test_five_filters_match_expected_conditions(self):
        for name, condition in FILTERS.items():
            matches = [r for r in self.rows if condition(r)]
            self.assertGreater(len(matches), 0, f"Missing synthetic examples for {name}")
        anomalies = [r for r in self.rows if FILTERS["query5"](r)]
        self.assertEqual(len(anomalies), 1)
        self.assertEqual(anomalies[0]["Facility ID"], "DEMO-001")

    def test_csv_outputs_have_correct_columns_and_lengths(self):
        summary = run(self.input, self.folder / "out")
        self.assertEqual(summary["input_records"], 40)
        for name, predicate in FILTERS.items():
            with (self.folder / "out" / f"{name}.csv").open(newline="", encoding="utf-8") as f:
                rd = csv.DictReader(f)
                self.assertEqual(rd.fieldnames, PROJECTIONS[name])
                rows = list(rd)
            self.assertEqual(len(rows), sum(predicate(r) for r in self.rows))
        saved = json.loads((self.folder / "out" / "summary.json").read_text())
        self.assertEqual(saved, summary)

    def test_duplicate_partition_key_is_rejected(self):
        with self.input.open("a", encoding="utf-8") as f:
            f.write(self.input.read_text().splitlines()[0] + "\n")
        with self.assertRaisesRegex(ValueError, "Duplicate Facility ID"):
            run(self.input, self.folder / "out")


if __name__ == "__main__":
    unittest.main()
