# Applied Statistics — Regression, PCA & Customer Segmentation

**MS4S08 · MSc Data Science · University of South Wales · Individual Assessment 2**

This case study documents three SAS Studio coursework analyses and provides a separate, runnable Python reproduction of the methods. **The Python scripts were prepared for this portfolio, not submitted as the original SAS code.**

| Study | Original data | Techniques |
|---|---:|---|
| Car purchase preferences | 100 records | Correlation, multiple regression, diagnostics |
| Employee wellbeing survey | 120 records, 14 variables | PCA, scree plot, explained variance |
| Gym member motivation | 100 records | Standardisation, K-Means (k=3), cluster profiles |

## Findings from my SAS assessment

The car-value model was statistically significant (reported p < 0.0001), but had modest explanatory power (**R² ≈ 0.24**). Advertising and comfort were statistically significant positive predictors; age, salary and maintenance were not. Associations do not prove causation.

The employee-wellbeing PCA did **not** reveal a small, clearly interpretable set of factors. Retaining all components is not meaningful dimensionality reduction.

For gym motivations, the original assessment interpreted three groups using fitness, social, facilities and cost priorities. Cluster numbering is arbitrary and the reproducible Python K-Means solution is not guaranteed to match SAS cluster assignments.

## Run locally

Requires Python 3.10+. From this project directory:

~~~bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python scripts/generate_demo.py
python scripts/analyse.py --input-dir data/demo --output-dir outputs/demo
python -m unittest discover -s tests -v
~~~

**The demonstration data are independently generated and fictional.** They are not the original university coursework datasets and do not reproduce the original numerical results.

To analyse a legitimately obtained copy of the original coursework CSV files, place them in an untracked data/original directory with names TaskA_CarPurchase.csv, TaskB_Wellbeing.csv and TaskC_GymMotivation.csv. Run:

~~~bash
python scripts/analyse.py --input-dir data/original --output-dir outputs/actual
~~~

## Technical provenance and limitations

The original coursework used SAS Studio menu-based statistical procedures. Source datasets from the course are not republished because their distribution terms have not been verified. This Python translation uses statsmodels OLS, standardised PCA and standardised K-Means; exact outputs can differ from the original SAS configuration. Cluster characteristics are descriptions, not validated behavioural segments.

Skills: Python · pandas · NumPy · SciPy · statsmodels · scikit-learn · regression · EDA · PCA · K-Means · reporting.