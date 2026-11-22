# Customer review text mining — portfolio recreation from MSc coursework report.
# The original dataset is not distributed. This script supports a fictional demo CSV.
# Run from the project root:
# Rscript scripts/analysis.R data/example_reviews.csv [--lda]

args <- commandArgs(trailingOnly = TRUE)
data_path <- if (length(args) >= 1 && !startsWith(args[1], "--")) args[1] else "data/example_reviews.csv"
run_lda <- "--lda" %in% args

required <- c("readr", "dplyr", "tidyr", "tidytext", "ggplot2")
if (run_lda) required <- c(required, "topicmodels")
missing <- setdiff(required, rownames(installed.packages()))
if (length(missing)) {
  stop("Missing R packages: ", paste(missing, collapse = ", "),
       ". Run Rscript setup_packages.R from the project directory.")
}
if (!file.exists(data_path)) stop("Input file not found: ", data_path)

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(tidytext)
  library(ggplot2)
})

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
reviews <- readr::read_csv(data_path, show_col_types = FALSE)
required_cols <- c("Review Text", "Rating")
if (!all(required_cols %in% names(reviews))) {
  stop("Input CSV must have columns: ", paste(required_cols, collapse = ", "))
}
reviews <- reviews %>%
  mutate(doc_id = row_number(),
         review_text = as.character(.data[["Review Text"]]),
         rating = suppressWarnings(as.integer(.data[["Rating"]])))
valid_reviews <- reviews %>%
  filter(!is.na(review_text), nzchar(trimws(review_text)))

# Retain the review ID for correctly grouped sentiment and topic modelling.
tokens_all <- valid_reviews %>%
  select(doc_id, rating, review_text) %>%
  tidytext::unnest_tokens(word, review_text)

tokens_clean <- tokens_all %>%
  anti_join(tidytext::stop_words, by = "word")

frequencies <- tokens_clean %>%
  count(word, sort = TRUE)
write_csv(frequencies, "outputs/word_frequencies.csv")

bing_words <- tokens_all %>%
  inner_join(tidytext::get_sentiments("bing"), by = "word")
bing_counts <- bing_words %>%
  count(sentiment, name = "word_matches")
write_csv(bing_counts, "outputs/bing_word_matches.csv")

nrc_words <- tokens_all %>%
  inner_join(tidytext::get_sentiments("nrc"), by = "word")
nrc_counts <- nrc_words %>%
  count(sentiment, name = "word_matches", sort = TRUE)
write_csv(nrc_counts, "outputs/nrc_emotion_matches.csv")

afinn_by_review <- tokens_all %>%
  inner_join(tidytext::get_sentiments("afinn"), by = "word") %>%
  group_by(doc_id) %>%
  summarise(sentiment_score = sum(value), .groups = "drop")

# Zero means no AFINN terms matched for this review.
review_scores <- valid_reviews %>%
  select(doc_id, rating) %>%
  left_join(afinn_by_review, by = "doc_id") %>%
  mutate(sentiment_score = replace_na(sentiment_score, 0))
write_csv(review_scores, "outputs/afinn_review_scores.csv")

rating_summary <- review_scores %>%
  filter(!is.na(rating)) %>%
  group_by(rating) %>%
  summarise(review_count = n(),
            average_score = mean(sentiment_score),
            .groups = "drop")
write_csv(rating_summary, "outputs/afinn_by_rating.csv")

p_words <- frequencies %>%
  slice_head(n = 15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col(fill = "#087b79") +
  coord_flip() +
  labs(title = "Most frequent review terms", x = NULL, y = "Word count") +
  theme_minimal()
ggsave("outputs/top_words.png", p_words, width = 8, height = 5, dpi = 150)

p_bing <- ggplot(bing_counts, aes(sentiment, word_matches)) +
  geom_col(fill = "#087b79") +
  labs(title = "Bing lexicon matches", x = NULL, y = "Word matches") +
  theme_minimal()
ggsave("outputs/bing_sentiment.png", p_bing, width = 7, height = 4, dpi = 150)

p_rating <- ggplot(rating_summary, aes(rating, average_score)) +
  geom_line() + geom_point(size = 2, colour = "#087b79") +
  labs(title = "Mean per-review AFINN score by rating",
       x = "Star rating", y = "Mean sum of matched AFINN values") +
  theme_minimal()
ggsave("outputs/sentiment_by_rating.png", p_rating, width = 7, height = 4, dpi = 150)

if (run_lda) {
  if (n_distinct(tokens_clean$doc_id) < 4L) {
    stop("LDA with 4 topics requires at least four non-empty documents.")
  }
  dtm <- tokens_clean %>%
    count(doc_id, word) %>%
    tidytext::cast_dtm(document = doc_id, term = word, value = n)
  set.seed(123)
  lda_model <- topicmodels::LDA(dtm, k = 4, control = list(seed = 123))
  top_terms <- tidytext::tidy(lda_model, matrix = "beta") %>%
    group_by(topic) %>%
    slice_max(beta, n = 10, with_ties = FALSE) %>%
    ungroup()
  write_csv(top_terms, "outputs/lda_top_terms.csv")
}
message("Finished. Inspect outputs/ for CSV summaries and charts.")
