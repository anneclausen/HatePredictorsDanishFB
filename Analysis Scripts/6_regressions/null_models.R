Sys.setenv(OPENBLAS_NUM_THREADS = 1, OMP_NUM_THREADS = 1)

# Installing packages (if needed):
#install.packages(c("lme4", "dplyr" )) 

#Loading packages:
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


# NULL-models (empty model, one pr. outcome)

null_model <- function(outcome_label) {
  outcome <- outcomes[[outcome_label]]
  d <- df[!is.na(df[[outcome]]), ]
  
  fit <- glmer(
    as.formula(paste0(outcome, " ~ 1 + (1 | ", cluster, ")")),
    data = d, family = binomial, 
    control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 2e5))
  )
  
  var_re <- as.data.frame(VarCorr(fit))$vcov[1]
  data.frame(
    outcome      = outcome_label,
    intercept_b  = fixef(fit)[["(Intercept)"]],
    intercept_OR = exp(fixef(fit)[["(Intercept)"]]),
    re_variance  = var_re,
    icc          = var_re / (var_re + pi^2 / 3),
    n_comments   = nrow(d),
    n_posts      = length(unique(d[[cluster]])),
    singular     = isSingular(fit)
  )
}

null_res <- bind_rows(mclapply(names(outcomes), null_model, mc.cores = 4))
write.csv(null_res, "results_nullmodels_R.csv", row.names = FALSE)
print(null_res %>% mutate(across(where(is.numeric), ~ round(.x, 3))))

# Software versions
writeLines(capture.output(sessionInfo()), "sessionInfo_null_models.txt")
