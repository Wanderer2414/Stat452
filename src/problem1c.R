# Use analysis_data[train_id, ] only. Add focused plots and summaries.
train_df <- analysis_data[train_id, ]

# Pairwise correlation among predictors
cor_matrix <- cor(
  train_df[, predictors],
  use = "complete.obs"
)

knitr::kable(
  round(cor_matrix, 2),
  caption = "Pairwise correlation matrix among predictors"
)


# Response Distribution 
hist(y_train)
summary(y_train)

# Predictor Distribution
boxplot(train_df$lcavol)
boxplot(train_df$lweight)
#.....


# Correlation between predictors and response
cor_response <- cor(
  train_df[, predictors],
  train_df$lpsa
)

knitr::kable(
  round(cor_response, 2),
  caption = "Correlation between predictors and lpsa"
)


# Check multicollinearity using VIF
library(car)

vif_model <- lm(
  lpsa ~ .,
  data = train_df[, c("lpsa", predictors)]
)

vif_values <- vif(vif_model)

knitr::kable(
  round(vif_values, 2),
  caption = "Variance Inflation Factor (VIF)"
)


# Predictor-response plots
par(mfrow = c(2,4))

for (var in predictors) {
  plot(
    train_df[[var]],
    train_df$lpsa,
    xlab = var,
    ylab = "lpsa",
    main = paste(var, "vs lpsa"),
    pch = 19
  )

  abline(
    lm(train_df$lpsa ~ train_df[[var]]),
    col = "red"
  )
}

par(mfrow = c(1,1))
