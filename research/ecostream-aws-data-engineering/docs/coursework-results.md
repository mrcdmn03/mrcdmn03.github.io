# Coursework evidence: original DynamoDB result counts

The five filters below are taken from the author's MS4S21 practical coursework
and were independently recomputed **locally on the supplied 100-record dataset**
before preparing this portfolio. The provided original records and CSV files
are intentionally withheld from this public repository because their
redistribution permission was not established.

| Task | Filter logic | Original matching records |
| --- | --- | ---: |
| 1 | `Maintenance Incidents 2024 = 0 AND Maintenance Incidents 2025 >= 1` | 11 |
| 2 | `Energy Output 2025 (MWh) < 50000` | 23 |
| 3 | `Facility Type = Wind AND Operational Tier = High-Performance` | 18 |
| 4 | `Energy Output 2024 (MWh) > 100000 AND Energy Output 2025 (MWh) > 100000` | 35 |
| 5 | `Downtime Hours 2024 > 8784` | 1 |

The fifth validation is a data-quality rule: **2024 was a leap year** with
`366 × 24 = 8784` hours. A facility cannot be down for more than 8784 hours
in that calendar year. The original report identified one inconsistent record.

These figures describe the *source coursework*. The synthetic sample in
`data/synthetic_telemetry.jsonl` deliberately has different values and therefore
different query counts. Do not present the synthetic output as the original
university dataset or as operational business data.
