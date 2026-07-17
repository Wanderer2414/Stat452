# STAT452 Project-Based Quiz 1
## Project Structure
```
Group04_ProjectQuiz1.Rmd (Main report file)
README.md       
references.bib
data/
    prostate.csv (Origin dataset)
```
---

## Requirements

- R (version 4.6.1+)
- RStudio

Install the required packages before rendering:
```r
install.packages(c( "tidyverse", "glmnet", "broom", "knitr", "car"))
```
---

## Reproducing the report
1. Open a clean R session.
2. Open the project folder in RStudio.
3. Ensure the dataset is located at: `data/prostate.csv`
4. Render: `Group04_ProjectQuiz1.Rmd`

---

## Reproducibility
The following random seeds are fixed to ensure reproducibility:

| Purpose | Seed |
|---------|----:|
| Train/Test Split | 240204 |
| Cross Validation | 240304 |
| Fixed ReLU Features | 240404 |
These seeds guarantee identical data splits, cross-validation folds, and randomly generated ReLU features across different machines.

---

## Holdout Evaluation
The holdout response `y_test` are not used during:
- exploratory data analysis,
- preprocessing,
- feature engineering,
- model fitting,
- hyperparameter tuning.
They first enter the analysis in **4D Section** when computing the final RMSE and MAE of the locked models.



