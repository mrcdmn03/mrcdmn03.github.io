# Python Data Structures & Statistical Functions

**Principles of Computing (IS4S761) | MSc Data Science coursework | 2025**

A collection of eight data-handling functions from my original Python programming assignment. The program parses column-oriented text files into **2D lists** and **dictionaries** and calculates totals, mean, median, and maximum (including a recursive maximum). These exercises demonstrate fundamental Python logic, validation, file I/O and algorithmic thinking without third-party packages.

## How to run the tests

Python **3.10+** and the standard library only.

From the portfolio repository root:
```bash
python3 -m unittest discover -s research/python-data-structures/tests -v
```
Or from this project folder:
```bash
python3 -m unittest discover -s tests -v
```

## Example input

```text
COLUMN Revenue
20
30
40
COLUMN Costs
3
5
END
```

The data loader can represent this as:
```python
[["Revenue", "20", "30", "40"], ["Costs", "3", "5"]]
# or
{"Revenue": ["20", "30", "40"], "Costs": ["3", "5"]}
```

## What changed for publication

The function logic is retained from my original Python coursework submission. Instructor-written exercise instructions embedded as comments were removed and the source was formatted for readability. Separate unit tests were added to make the behaviour easy to check.

This is a foundational academic programming exercise rather than a production data analytics library; no university teaching slides or solutions are included.
