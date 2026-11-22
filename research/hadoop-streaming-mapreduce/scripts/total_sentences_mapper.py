#!/usr/bin/env python3
"""Counts [.?!] punctuation marks, matching the original coursework method."""
import re
import sys

for line in sys.stdin:
    sentences = re.findall(r"[.!?]", line)
    for sentence in sentences:
        print("sentence\t1")
