# Multilevel logistic regression with random intercept on post-level (lme4)

Sys.setenv(OPENBLAS_NUM_THREADS = 1, OMP_NUM_THREADS = 1)

# 4 binary outcomes x 3 models = 12 models.
#   Model 1: post_sender  (reference: Politicians)
#   Model 2: news_type  (reference: National)
#   Model 3: topic_id    (reference: "Generic captions/reactions" = topic 0;
#                         "Outlier" = topic -1 excluded)

# Installing packages (if needed):
# install.packages(c("lme4", "dplyr", "parallel"))

# Loading packages:
library(lme4)
library(dplyr)
library(parallel)

# Configuration

df <- read.csv("data_final_topics.csv", na.strings = c("", "NA"))  
cluster <- "new_post_id"

outcomes <- c(
  "Hate speech"           = "hs_total",
  "Explicit hate speech"  = "exp_total",
  "Implicit hate speech"  = "imp_total",
  "Negative stereotyping" = "imp_nstereo_total"
)

# Prepare variables and model references

df$post_sender <- relevel(factor(df$post_sender), ref = "Politicians")
df$news_type <- relevel(factor(df$news_type), ref = "National")
df$topic_id   <- relevel(factor(df$topic_id),   ref = "Generic captions/reactions")

models <- list(
  "Model 1" = list(var = "post_sender", keep = function(d) d),
  "Model 2" = list(var = "news_type", keep = function(d) d),
  "Model 3" = list(var = "topic_id",   keep = function(d) d[d$topic_id != "Outlier", ])
)

# Helper function: adapt a single model and aggregate the results

fit_one <- function(data, outcome, var, model_name, outcome_label) {
  data <- data[!is.na(data[[outcome]]) & !is.na(data[[var]]), ]
  data[[var]] <- droplevels(data[[var]])        
  
  formula <- as.formula(paste0(outcome, " ~ ", var, " + (1 | ", cluster, ")"))
  
  fit <- glmer(
    formula, data = data, family = binomial,
    control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
  )
  
  # Fixed effects with odds ratios with 95 % Wald confidence intervals
  est <- summary(fit)$coefficients
  ci  <- confint(fit, parm = "beta_", method = "Wald")
  
  tab <- data.frame(
    model   = model_name,
    outcome = outcome_label,
    term    = sub(paste0("^", var), "", rownames(est)),
    b       = est[, "Estimate"],
    se      = est[, "Std. Error"],
    z       = est[, "z value"],
    p       = est[, "Pr(>|z|)"],
    OR      = exp(est[, "Estimate"]),
    OR_low  = exp(ci[, 1]),
    OR_high = exp(ci[, 2]),
    row.names = NULL
  )
  
  # Random intercept: variance and ICC (latent variable: pi^2 / 3)
  var_re <- as.data.frame(VarCorr(fit))$vcov[1]
  tab$n_comments  <- nrow(data)
  tab$n_posts     <- length(unique(data[[cluster]]))
  tab$re_variance <- var_re
  tab$icc         <- var_re / (var_re + pi^2 / 3)
  tab$singular    <- isSingular(fit)
  tab
}

# Run all 12 models
grid <- expand.grid(
  model_name = names(models),
  outcome_label = names(outcomes),
  stringsAsFactors = FALSE
)

# Run one combination (returns NULL if it fails)
run <- function(i) {
  m <- grid$model_name[i]
  o <- grid$outcome_label[i]
  spec <- models[[m]]
  tryCatch(
    fit_one(spec$keep(df), outcomes[[o]], spec$var, m, o),
    error = function(e) {
      message("ERROR in ", m, " | ", o, ": ", conditionMessage(e))
      NULL
    }
  )
}

# Number of cores: as many as the machine has, but at most the number of models
n_cores <- min(nrow(grid), parallel::detectCores())
cat("Runs on", n_cores, "cores\n")

results <- mclapply(seq_len(nrow(grid)), run, mc.cores = n_cores)
all <- bind_rows(results)

# Save results
write.csv(all, "results_multilevel_R.csv", row.names = FALSE)
print(all %>% mutate(across(where(is.numeric), ~ round(.x, 3))))

cat("\n=== Random intercept pr. model ===\n")
all %>%
  distinct(model, outcome, n_comments, n_posts, re_variance, icc) %>%
  mutate(across(c(re_variance, icc), ~ round(.x, 3))) %>%
  print()

# Software-versions
writeLines(capture.output(sessionInfo()), "sessionInfo_regression_models.txt")
