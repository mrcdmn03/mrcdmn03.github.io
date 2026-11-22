"""Tests for data-structure utilities adapted from IS4S761 coursework."""
import tempfile
import unittest
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from data_structures import (
    load_data_from_file_into_2D_list,
    load_data_from_file_into_dictionary,
    return_sublist_from_either_dictionary_or_2D_list,
    return_sublist_total_from_either_dictionary_or_2D_list,
    return_sublist_mean_from_either_dictionary_or_2D_list,
    return_sublist_median_from_either_dictionary_or_2D_list,
    return_total_value_from_either_dictionary_or_2D_list,
    recursive_return_max_value_from_either_dictionary_or_2D_list,
)

class DataStructuresTests(unittest.TestCase):
    def setUp(self):
        self.data = {"Revenue": ["20", "30", "40"], "Costs": ["3", "5"]}
        self.rows = [["Revenue", "20", "30", "40"], ["Costs", "3", "5"]]

    def test_loaders(self):
        with tempfile.TemporaryDirectory() as temp:
            p = Path(temp) / "sample.txt"
            p.write_text("COLUMN Revenue\n20\n30\n40\nCOLUMN Costs\n3\n5\nEND\n")
            self.assertEqual(load_data_from_file_into_dictionary(str(p)), self.data)
            self.assertEqual(load_data_from_file_into_2D_list(str(p)), self.rows)

    def test_aggregations(self):
        for sample in (self.data, self.rows):
            self.assertEqual(return_sublist_from_either_dictionary_or_2D_list(sample, "Revenue"), ["20","30","40"])
            self.assertEqual(return_sublist_total_from_either_dictionary_or_2D_list(sample, "Revenue"), 90.0)
            self.assertEqual(return_sublist_mean_from_either_dictionary_or_2D_list(sample, "Revenue"), 30.0)
            self.assertEqual(return_sublist_median_from_either_dictionary_or_2D_list(sample, "Revenue"), 30.0)
            self.assertEqual(return_total_value_from_either_dictionary_or_2D_list(sample), 98.0)
            self.assertEqual(recursive_return_max_value_from_either_dictionary_or_2D_list(sample, "Revenue"), 40.0)

    def test_missing_key(self):
        self.assertIsNone(return_sublist_total_from_either_dictionary_or_2D_list(self.data, "Missing"))

    def test_even_length_median(self):
        self.assertEqual(return_sublist_median_from_either_dictionary_or_2D_list(self.data, "Costs"), 4.0)

    def test_invalid_numeric_value(self):
        self.assertIsNone(return_sublist_mean_from_either_dictionary_or_2D_list({"Bad":["not-a-number"]}, "Bad"))

if __name__ == "__main__":
    unittest.main()
