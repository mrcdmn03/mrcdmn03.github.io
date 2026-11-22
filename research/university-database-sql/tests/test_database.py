"""Simple automated checks for the case study data and relationships."""
import sqlite3
import unittest
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / "sql"

class TestUniversityDatabase(unittest.TestCase):
    def setUp(self):
        self.db = sqlite3.connect(":memory:")
        self.db.execute("PRAGMA foreign_keys = ON")
        self.db.executescript((BASE / "01_schema.sql").read_text(encoding="utf-8"))
        self.db.executescript((BASE / "02_seed.sql").read_text(encoding="utf-8"))

    def tearDown(self):
        self.db.close()

    def test_counts(self):
        for table, count in {"Courses": 3, "Tutors": 6, "Modules": 9,
                             "Students": 10, "Course_Module": 13, "Enrolment": 24}.items():
            self.assertEqual(self.db.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0], count)

    def test_courses(self):
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM Students WHERE Course_ID='CS'").fetchone()[0], 4)

    def test_optional_module(self):
        self.assertEqual(
            self.db.execute("SELECT Module_Code FROM Modules WHERE Is_Optional=1 AND Module_ID NOT IN (SELECT Module_ID FROM Enrolment)").fetchall(),
            [("BDA707",)],
        )

    def test_foreign_keys(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO Course_Module VALUES ('UNKNOWN', 'M101')")

if __name__ == "__main__":
    unittest.main()
