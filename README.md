# Replication code: hate speech in Danish Facebook comments

This repository contains the code used for **[TODO: paper title]**. The pipeline

1. trains DanskBERT classifiers on a manually coded sample of Facebook comments,
2. uses them to label a large set of unlabelled comments,
3. builds the analysis dataset (incl. categorisation of Facebook pages),
4. topic-models the posts the comments were written under (BERTopic),
5. merges the topics onto the comment data,
6. estimates multilevel logistic regressions (comments nested in posts), and
7. draws the forest plots shown in the paper.

**The data are not included.** The comments are user-generated content from
Facebook and contain hate speech, so neither the raw data nor the trained
model weights are shared here [TODO: add a data-availability statement / contact
for access requests, and a link to the models if you decide to publish them].
The folder structure and the expected input files are documented below so the
code can be inspected and, with comparable data, re-run.

---

## Repository structure

| Step | Folder | Language | What it does | Main input → main output |
|---|---|---|---|---|
| 1 | `1_train_classifiers/` | Python (Jupyter) | Fine-tunes DanskBERT for four binary outcomes (see below) | `manual_codings.csv` → `final_model_{hs,exp,imp,imp_nstereo}/` |
| 2 | `2_label_comments/` | Python (Jupyter) | Labels the unlabelled comments with the trained models | `../data/all_unlabelled.csv` → `../data/all_labelled*.csv` |
| 3 | `3_build_dataset/` | Stata 19 | Combines manual and predicted labels, categorises pages into `post_sender` and `news_type`, creates post IDs | `manual_codings.csv`, `all_labelled*.csv` → `data_final_cleaned.csv`, `posts_for_topic_modelling.csv` |
| 4 | `4_topic_modeling/` | Python (Jupyter) | Embeds posts and fits BERTopic | `posts_for_topic_modelling.csv` → `posts_topic_ids.csv` |
| 5 | `5_merge_topics/` | Stata 19 | Merges topic IDs and topic labels onto the comments | `data_final_cleaned.csv`, `posts_topic_ids.csv` → `data_final_topics.csv` |
| 6 | `6_regressions/` | R + Python | Null models, 12 multilevel logistic regressions, descriptives of comments per post | `data_final_topics.csv` → `results_nullmodels_R.csv`, `results_multilevel_R.csv`, `comments_per_post.{png,pdf}` |
| 7 | `7_figures/` | Python (Jupyter) | Forest plots of the odds ratios | `results_multilevel_R.csv` → `figures/figur1_model1_model2.{png,pdf}`, `figures/figur2_model3.{png,pdf}` |

Run the steps in numerical order. Within each folder the scripts are
independent of each other, except in step 4 (`BERTopic_embeddings.ipynb` must be
run before `BERTopic_posts.ipynb`).

### Files that must be moved between steps

The scripts read and write in their working directory, with one exception: the
notebooks in step 2 use `../data/`, i.e. a `data/` folder in the repository root.

- **1 → 2:** the notebooks in step 2 unpack `final_model_<name>.zip`. Zip the
  model folders from step 1 so that the model files (`config.json`,
  `model.safetensors`, …) are at the *top level* of the archive, and place the
  four zip files in `2_label_comments/`.
- **2 → 3:** copy `all_labelled.csv` (hate speech overall), `all_labelled_exp.csv`,
  `all_labelled_imp.csv` and `all_labelled_imp_nstereo.csv` to the folder you run
  the Stata do-file from, together with `manual_codings.csv`.
- **3 → 4, 3 → 5, 4 → 5, 5 → 6:** copy the CSV files named in the table above.
- **6 → 7:** `forest_plots.ipynb` expects `results_multilevel_R.csv` in its own
  folder (or pass the path as a command-line argument if run as a script).

---

## Input data (not included)

**`manual_codings.csv`** – manually coded comments. Columns used by the code:
`global_id`, `comment_text`, `created_time`, `page_name`, `post_id`, `post_text`,
and the binary codes `hs`, `exp`, `imp`, `imp_nstereo`, `exp_only`, `imp_only`.

**`all_unlabelled.csv`** – the comments to be labelled. Must contain
`comment_text` and `global_id` (used to merge the predictions in step 3), plus the
post and page variables listed above.

### Variables in the analysis dataset (`data_final_topics.csv`)

| Variable | Description |
|---|---|
| `hs_total`, `exp_total`, `imp_total`, `imp_nstereo_total` | Outcomes: hate speech (overall), explicit hate speech, implicit hate speech, negative stereotyping (0/1). The manual code where the comment was manually coded, otherwise the classifier prediction. |
| `label_source` | 1 = manual annotation, 2 = classifier prediction (DanskBERT) |
| `post_sender` | News / Politicians / Parties (reference category in the models: Politicians) |
| `news_type` | 11 categories of news pages (reference category: National) |
| `new_post_id` | Post identifier (a post is identified by `page_name` × `post_text`); the clustering variable in the regressions |
| `topic_id` | BERTopic topic of the post: `0` = largest topic ("Generic captions/reactions", reference category), `-1` = outlier (excluded from Model 3) |

---

## Methods in brief

**Classifiers (step 1).** `vesteinn/DanskBERT` fine-tuned for sequence
classification with a maximum input length of 256 tokens. One notebook per outcome:

| Notebook | Outcome | Sample restriction |
|---|---|---|
| `DanskBERT_hs` | hate speech vs. none | none |
| `DanskBERT_exp` | explicit hate speech vs. none | drops implicit-only hate speech |
| `DanskBERT_imp` | implicit hate speech vs. none | drops explicit-only hate speech |
| `DanskBERT_nstereo` | negative stereotyping vs. none | drops hate speech not coded as negative stereotyping |

Each notebook makes a stratified 80/10/10 train/dev/test split, runs a grid search
over learning rate (1e-5 to 5e-5) × batch size (16, 32) with up to 6 epochs and
early stopping on dev macro-F1, retrains with the best configuration and evaluates
**once** on the test set. The random seed is 1512 throughout, and deterministic
settings are enabled.

**Topic modelling (step 4).** Posts are embedded with
`sentence-transformers/paraphrase-multilingual-mpnet-base-v2` and clustered with
BERTopic (UMAP with `random_state = 1512`, HDBSCAN with `min_cluster_size = 300`,
Danish stop words, 1–2-grams). Outliers are reduced with the embeddings strategy
(threshold 0.4) and topics are renumbered by size.

**Regressions (step 6).** Multilevel logistic regressions
(`lme4::glmer`, binomial, random intercept for post, Laplace approximation,
`bobyqa` optimiser) for 4 outcomes × 3 predictor sets (post sender, news type,
post topic) = 12 models, plus one null model per outcome. The scripts report odds
ratios with Wald 95 % confidence intervals, the random-intercept variance and the ICC
(latent-variable formulation, π²/3). The analysis sample is up to 163,724 comments in
up to 46,346 posts, depending on the model and outcome.

---

## Software and hardware

- **Python 3.13** (training: 3.13.12; labelling: 3.13.13; topic modelling,
  descriptives and figures: 3.13.5). A GPU is needed in practice for steps 1, 2 and the
  embedding step in 4.
- Steps 1 and 2 install **pinned package versions** in their first cell. Run that
  cell first and then restart the kernel, as noted in the notebook. At the end of each
  training notebook, the versions of all imported packages are printed.
- Steps 4, 6 (`data_distributions.ipynb`) and 7 do not pin package versions. They use
  `numpy`, `pandas`, `matplotlib`, `scipy`, `sentence-transformers`, `bertopic`,
  `umap-learn`, `hdbscan`, `scikit-learn`, `stopwordsiso` and `openpyxl`
  [TODO: add the versions used, e.g. from `pip list`].
- **R** with `lme4`, `dplyr` and `parallel` [TODO: R version]. Both R scripts write
  their `sessionInfo()` to `sessionInfo_*.txt`. The scripts use `parallel::mclapply`
  and therefore run on Linux and macOS but not in parallel on Windows. If memory is
  limited, lower `mc.cores`.
- **Stata 19** (`version 19`) for steps 3 and 5.
- The notebooks in step 1 contain a workaround for downloading the model from
  Hugging Face on a restricted HPC platform (`snapshot_download` with
  `allow_patterns`). It can be replaced with a regular `from_pretrained` call elsewhere.

---

## License, citation and contact

[TODO: license, e.g. MIT for the code] · [TODO: citation / DOI] · [TODO: contact]
