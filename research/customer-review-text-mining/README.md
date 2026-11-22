# Customer Review Text Mining & Sentiment Analysis

**MSc Data Science coursework · Data Mining and Sentiment Analysis · January 2026**

This project examines women's clothing e-commerce reviews to understand product feedback using **R, tidytext, lexicon-based sentiment analysis and LDA topic modelling**.

## Academic project and provenance

My original assessment report analyses **23,486 records with 11 columns** from a dataset named `MS4S09 Assessment 1 Dataset.csv`. The report includes R code, charts and recorded outputs, but the separate original `.R` source file and CSV are not currently included in this repository.

The `scripts/analysis.R` file is a **portfolio recreation based on the code and methods in my original assessment report**, with clearer file handling and an optional LDA step. It is **not represented as an unmodified original submission**. The `data/example_reviews.csv` file is **fictional demonstration data**, not the assessment dataset.

## Questions explored

- Which words and product attributes occur most frequently in customer feedback?
- What do the Bing, AFINN and NRC sentiment lexicons suggest about the language used?
- Can Latent Dirichlet Allocation (LDA) reveal themes in the reviews?
- How do lexical sentiment scores vary across one- to five-star customer ratings?

## Findings recorded in the academic report

| Measure | Recorded result |
| --- | ---: |
| Review records | 23,486 |
| Positive-word matches (Bing) | 102,311 |
| Negative-word matches (Bing) | 25,621 |
| LDA topic count | 4 |
| Most frequent terms after filtering | dress (10,460); love (8,916); size (8,687); fit (7,238) |

The report identifies themes relating to **fit and size, comfort and material, appearance and general satisfaction**. Its AFINN scores increase across star ratings, but this is an association and **does not establish model accuracy, causal effects, or the proportion of satisfied customers**. These are **reported figures**, not independently reproduced here.

## Run the portfolio recreation

Install R (RStudio optional), open a terminal in this project folder, then run:

```bash
Rscript setup_packages.R
Rscript scripts/analysis.R data/example_reviews.csv
```

The example data are intentionally small and **do not reproduce the original numeric results**. Results are written to `outputs/`.

To run against the original coursework dataset after checking redistribution rights, put your own copy in a local `data/` folder and run:

```bash
Rscript scripts/analysis.R "data/MS4S09 Assessment 1 Dataset.csv" --lda
```

`--nrc` additionally runs NRC emotion analysis; the first run may request a licensed lexicon download through the textdata package. `--lda` enables four-topic LDA modelling. It is omitted by default because fitting the full document-term matrix can be computationally expensive. The input CSV must contain `Review Text` and `Rating` columns.

## Files

- `scripts/analysis.R` — reconstructed reproducible workflow, with data cleaning, word counts, sentiment lexicons, rating analysis and optional LDA.
- `setup_packages.R` — package installation script.
- `data/example_reviews.csv` — explicitly fictional demo reviews to test pipeline inputs.
- `.gitignore` — excludes original datasets, generated outputs and local R files.

## Analytical limitations and ethics

- Lexicon word matches are **not a measure of how many reviewers are happy**. A review can contain both positive and negative words.
- Word-based dictionaries may misinterpret **negation, irony and context**, such as “not good”.
- The original AFINN-per-rating code reported mean scores for matched words; the portfolio script additionally aggregates **per review** to make the unit of analysis explicit.
- Topics from LDA require interpretation; four topics were chosen for coursework interpretability, not through an independently optimised model-selection procedure.
- The original reviews CSV is **not republished** because its redistribution licence has not been verified.
- The script has been checked for structure but **has not been run in an R environment here**; full reproducibility against the original dataset remains to be validated.

## Skills demonstrated

R · tidytext · text preprocessing · tokenisation · stopword removal · frequency analysis · sentiment analysis (Bing, AFINN, NRC) · LDA topic modelling · data visualisation · analytical reporting

---

**Repository context:** This is a coursework-derived, transparently documented case study rather than a production sentiment-classification system.