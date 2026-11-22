#!/usr/bin/env python3
"""Word-count mapper reconstructed from the submitted report's code screenshot."""
import string
import sys

for line in sys.stdin:
    line = line.strip().lower()
    words = line.split()
    for word in words:
        word = word.strip(string.punctuation)
        if word and word.isalpha():
            print(f"{word}\t1")
