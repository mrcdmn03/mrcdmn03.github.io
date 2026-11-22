# Statutory Homelessness in England — Statistical Trend Analysis

**MS4S08 · Applied Statistics for Data Science · University of South Wales · Group Assessment 1**

An applied statistics group project on quarterly recorded statutory homelessness duties in England between **2018 Q2 and 2025 Q2**. The original group work used SAS for descriptive analysis, statistical tests and reporting. This portfolio supplies a **new Python reproduction** of selected analyses, not the original SAS source code.

## Data and scope

The CSV contains **29 quarterly England-level aggregate records** from a cleaned 2025 coursework snapshot of official government statistics. It retains year, quarter, initial assessments, total prevention/relief duty, prevention duty and relief duty counts. It does not contain personal information or local-authority-level observations.

2018 contains **three** quarters and 2025 **two**. Annual means reflect available quarters, not complete-year totals. The dataset is an assignment snapshot, **not the latest government release**.

## Main results

| Reported analysis | Result |
|---|---|
| Pearson correlation between quarterly prevention and relief duty counts | r ≈ 0.232, p ≈ 0.225 |
| OLS total duty vs year | Slope ≈ +2,633 per year, R² ≈ 0.652 |
| Annual mean quarterly total duty: 2018 | ~65,370 |
| Annual mean quarterly total duty: 2024 | ~83,673 |
| One-way ANOVA for differences between years | p < 0.0001 in original SAS report |

The Python program recomputes descriptive yearly summaries, Pearson correlation, simple OLS and one-way ANOVA, and exports charts. Small rounding differences from the submitted SAS report can occur in the cleaned input data.

## Reproduce

Requires Python 3.10+:

~~~bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python scripts/analyse.py
python -m unittest discover -s tests -v
~~~

Results are written to outputs/summary.json and outputs/annual_summary.csv. Plots show annual means, the fitted time trend and the relationship between prevention and relief duties.

## What the analysis cannot establish

The number of recorded duties is not a direct census of all people experiencing homelessness. This is a descriptive observational analysis, **not a causal evaluation of the Homelessness Reduction Act (2018)**. Quarterly observations are time-dependent and unevenly grouped across years; simple OLS and ANOVA assumptions warrant caution. The original poster contained other statistical comparisons and conclusions; the code here focuses on the reproducible parts.

## Origin, licence and attribution

Source: UK Ministry of Housing, Communities and Local Government, [Statutory homelessness live tables](https://www.gov.uk/government/statistical-data-sets/live-tables-on-homelessness), via a 2025 academic group data-cleaning exercise. **Contains public sector information licensed under the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).** The government may revise historical releases.

**Group coursework:** This analysis was carried out as part of a student team. My retained files document exploratory analysis, summary statistics, correlation, ANOVA and regression. The project does not present all team contributions as mine.

Technologies: Python · pandas · SciPy · statsmodels · EDA · ANOVA · linear regression · Pearson correlation · data quality · visualisation.