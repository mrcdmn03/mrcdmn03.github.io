"""Unit tests for the actual Hadoop Streaming mapper/reducer interface."""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from run_local import stream_job

class StreamingTests(unittest.TestCase):
    def test_wordcount_merges_repeated_words(self):
        raw = stream_job(ROOT / "samples" / "carol_sample.txt",
                         "word_count_mapper.py", "word_count_reducer.py", True)
        lines = dict(row.split("\t") for row in raw.splitlines())
        self.assertEqual(lines["the"], "3")
        self.assertEqual(lines["cat"], "3")
        self.assertEqual(lines["dog"], "2")
        self.assertEqual(lines["and"], "1")

    def test_sentence_count_sample(self):
        raw = stream_job(ROOT / "samples" / "moby_sample.txt",
                         "total_sentences_mapper.py", "total_sentences_reducer.py")
        self.assertEqual(raw.strip(), "Total sentences\t4")

    def test_empty_mapper_input(self):
        import subprocess
        p = subprocess.run([sys.executable, str(ROOT / "scripts" / "word_count_reducer.py")],
                           input=b"", capture_output=True, check=True)
        self.assertEqual(p.stdout, b"")

    def test_sentence_reducer_empty(self):
        import subprocess
        p = subprocess.run([sys.executable, str(ROOT / "scripts" / "total_sentences_reducer.py")],
                           input=b"", capture_output=True, check=True)
        self.assertEqual(p.stdout.decode().strip(), "Total sentences\t0")

if __name__ == "__main__":
    unittest.main()
