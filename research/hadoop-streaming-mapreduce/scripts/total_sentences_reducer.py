#!/usr/bin/env python3
"""Reducer adapted from code shown in the submitted technical report."""
import sys

total = 0
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    key, value = line.split("\t", 1)
    if key != "sentence":
        raise ValueError(f"Unexpected mapper key: {key!r}")
    total += int(value)
print(f"Total sentences\t{total}")
