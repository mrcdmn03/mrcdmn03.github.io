#!/usr/bin/env python3
"""Execute the original two Hadoop Streaming tasks locally, using Python only."""
import argparse
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent


def stream_job(input_file, mapper_name, reducer_name, sort_keys=False):
    text = Path(input_file).read_bytes()
    # Mirror Hadoop TextInputFormat, which skips a UTF-8 BOM on the first record.
    if text.startswith(b"\xef\xbb\xbf"):
        text = text[3:]
    mapper = subprocess.run([sys.executable, str(ROOT / "scripts" / mapper_name)],
                            input=text, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    lines = mapper.stdout.splitlines(keepends=True)
    if sort_keys:
        lines = sorted(lines)  # Emulates the Hadoop shuffle/sort for a single reducer.
    reducer = subprocess.run([sys.executable, str(ROOT / "scripts" / reducer_name)],
                             input=b"".join(lines), stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, check=True)
    return reducer.stdout.decode("utf-8")


def main():
    parser = argparse.ArgumentParser(description="Local execution of the coursework's two streaming jobs")
    parser.add_argument("--carol", type=Path, default=ROOT / "data" / "A_Christmas_Carol.txt")
    parser.add_argument("--moby", type=Path, default=ROOT / "data" / "Moby_Dick_or_The_Whale.txt")
    parser.add_argument("--output", type=Path, default=ROOT / "results" / "local_run")
    args = parser.parse_args()
    for x in (args.carol, args.moby):
        if not x.is_file():
            parser.error(f"Missing {x}. See data/README.md for source texts.")
    args.output.mkdir(parents=True, exist_ok=True)
    words = stream_job(args.carol, "word_count_mapper.py", "word_count_reducer.py", True)
    sentences = stream_job(args.moby, "total_sentences_mapper.py", "total_sentences_reducer.py")
    (args.output / "word_counts.tsv").write_text(words, encoding="utf-8")
    (args.output / "sentence_count.tsv").write_text(sentences, encoding="utf-8")
    freqs = []
    for line in words.splitlines():
        word, count = line.split("\t")
        freqs.append((word, int(count)))
    freqs.sort(key=lambda item: (-item[1], item[0]))
    print("Top 10 words (A Christmas Carol):")
    for word, count in freqs[:10]:
        print(f"{word}\t{count}")
    print(f"\nSentence markers (Moby Dick): {sentences.strip()}")
    print("\nSaved to:", args.output)


if __name__ == "__main__":
    main()
