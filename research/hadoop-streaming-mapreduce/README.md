# Hadoop Streaming & MapReduce — Text Analytics

**MS4S21 · Big Data Engineering and its Applications | MSc Data Science | University of South Wales (2026)**

This portfolio project reproduces two practical tasks documented in my Big Data Engineering coursework: **word-frequency analysis of Charles Dickens's *A Christmas Carol*** and **sentence-ending punctuation counting in Herman Melville's *Moby Dick*** using **Python mapper/reducer scripts, Hadoop Streaming, HDFS and YARN**.

## What I did in the coursework

For Task B.1, I created a Python mapper to emit one `word<TAB>1` record for each eligible word and a reducer to sum the counts by word. I loaded the text into HDFS, ran Hadoop Streaming and inspected its `part-00000` output.

For Task B.2, I implemented a mapper that emits one `sentence<TAB>1` record for every `.`, `!` or `?`, followed by a reducer that sums the counts. I tested the mapper/reducer combination locally before submitting a Hadoop job.

The original report includes terminal screenshots of the mapper and reducer code, running Hadoop services, HDFS uploads and the final outputs. **The original `.py` source files themselves were not present in the supplied archive.** The four Python scripts in this repository were therefore **reconstructed directly from those screenshots**, with minor safeguards and comments. They are not presented as original uploaded source files.

## Reported results and independent local check

| Analysis | Result |
| --- | --- |
| *A Christmas Carol* most frequent word | **the — 1,786** |
| Next most frequent words | and (1,131), of (863), a (767), to (741) |
| *Moby Dick* sentence-ending punctuation count | **10,969** |

The `10,969` figure is the value in **Figure 15 of the original report**, independently corroborated by counting `[.!?]` in the exact supplied text. The report's initial figure index contains a transposition (`10,699`); its final screenshot and discussion use `10,969`.

The ebook files include Project Gutenberg front/back matter and licence text. This algorithm counts punctuation marks, **not** grammatically valid sentence boundaries. Abbreviations, ellipses, headings and metadata can affect the result. It would be misleading to present this as a linguistic sentence count.

The word-frequency results were also reproduced locally from the same source edition using the reconstructed mapper/reducer algorithm. **A new Hadoop cluster execution was not performed for this portfolio.**

## How MapReduce works here

1. **Map:** Read input text, output `word<TAB>1` or `sentence<TAB>1` records.
2. **Shuffle/sort:** Group identical mapper keys (the local runner emulates this by sorting the word records).
3. **Reduce:** Sum the values for each key.
4. **Store:** Hadoop writes job results into HDFS output files; YARN handles cluster resource scheduling.

## Project layout

```text
scripts/
  word_count_mapper.py
  word_count_reducer.py
  total_sentences_mapper.py
  total_sentences_reducer.py
samples/                      # Test inputs included in the repository
tests/test_streaming.py       # Four local automated tests
run_local.py                  # Runs both streaming tasks without Hadoop
run_hadoop.sh                 # Hadoop/HDFS/YARN wrapper
results/                      # Verified source report values and SHA-256 hashes
data/README.md                # Ebook edition and download instructions
```

## Run locally — Python 3.9+, no external packages

1. Download or clone the portfolio, then open `research/hadoop-streaming-mapreduce/`.
2. Download Project Gutenberg [ebook #30368](https://www.gutenberg.org/ebooks/30368) and [ebook #2701](https://www.gutenberg.org/ebooks/2701), or copy the original texts from my coursework archive.
3. Save the full-text files in `data/` named `A_Christmas_Carol.txt` and `Moby_Dick_or_The_Whale.txt`. **The supplied editions matter** if you need the exact historical figures.
4. Execute:

```bash
python3 -m unittest discover -s tests -v
python3 run_local.py
```

The runner removes an initial UTF-8 BOM to match Hadoop TextInputFormat behaviour and produces `results/local_run/word_counts.tsv` and `results/local_run/sentence_count.tsv`. The unit tests **run without downloading the novels**.

## Run on Hadoop

This part requires an existing configured Hadoop installation with HDFS, YARN, Python 3 available on workers and a Streaming JAR:

```bash
export HADOOP_STREAMING_JAR=/path/to/hadoop-streaming-<version>.jar
bash run_hadoop.sh
```

The script uploads inputs to `/input/` and `/input_sentences/`, runs both jobs with one reducer and displays HDFS outputs. **Review the HDFS paths before running in a shared cluster:** the script clears `/output_wordcount` and `/output_sentences`. Hadoop was **not installed or retested in the preparation environment**.

## Data provenance and sharing

- Original evidence: `Question 2 - Technical Report.pdf` from my MS4S21 assessment and two novel text files in the source ZIP.
- Reports and locally checked results: [`results/`](results/).
- Source text edition SHA-256 hashes: [`results/source_checksums.json`](results/source_checksums.json).
- Books: **Project Gutenberg**, [*A Christmas Carol* #30368](https://www.gutenberg.org/ebooks/30368) and [*Moby Dick* #2701](https://www.gutenberg.org/ebooks/2701). Follow its [licensing/reuse policy](https://www.gutenberg.org/policy/license.html) when redistributing.
- Original novel files, screenshots, lecturer materials and original academic report are **not published in this repository**. This is a reconstructed, tested local portfolio version, with clear attribution and limitations.
