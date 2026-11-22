#!/usr/bin/env bash
# Run the reconstructed jobs on an existing Hadoop/HDFS cluster.
# Requires HADOOP_STREAMING_JAR to point to your installed streaming jar.
set -euo pipefail

: "${HADOOP_STREAMING_JAR:?Set HADOOP_STREAMING_JAR=/path/to/hadoop-streaming.jar}"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"
CAROL="${1:-data/A_Christmas_Carol.txt}"
MOBY="${2:-data/Moby_Dick_or_The_Whale.txt}"
[[ -f "$CAROL" && -f "$MOBY" ]] || { echo "Missing book inputs; see data/README.md" >&2; exit 2; }

hadoop fs -mkdir -p /input /input_sentences
hadoop fs -put -f "$CAROL" /input/A_Christmas_Carol.txt
hadoop fs -put -f "$MOBY" /input_sentences/Moby_Dick_or_The_Whale.txt
hadoop fs -rm -r -f /output_wordcount /output_sentences || true

hadoop jar "$HADOOP_STREAMING_JAR" \
  -D mapreduce.job.reduces=1 \
  -files scripts/word_count_mapper.py,scripts/word_count_reducer.py \
  -input /input/A_Christmas_Carol.txt -output /output_wordcount \
  -mapper 'python3 word_count_mapper.py' -reducer 'python3 word_count_reducer.py'

hadoop jar "$HADOOP_STREAMING_JAR" \
  -D mapreduce.job.reduces=1 \
  -files scripts/total_sentences_mapper.py,scripts/total_sentences_reducer.py \
  -input /input_sentences/Moby_Dick_or_The_Whale.txt -output /output_sentences \
  -mapper 'python3 total_sentences_mapper.py' -reducer 'python3 total_sentences_reducer.py'

printf '\nTop ten words:\n'
hadoop fs -cat /output_wordcount/part-* | sort -k2,2nr | head -10
printf '\nSentence marker count:\n'
hadoop fs -cat /output_sentences/part-*
