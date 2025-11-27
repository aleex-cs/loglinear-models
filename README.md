# loglinear-models

## Overview
This repository contains an analysis of bidimensional contingency tables measured on an ordinal scale using log-linear models. The goal is to explore associations between pairs of variables, identify the best-fitting model for each table, and test for marginal homogeneity between rows and columns.

## Data
The dataset `tablasb.xlsx` contains multiple 5x5 contingency tables extracted from observational data. Each table corresponds to a pair of ordinal variables.  
Directory structure: `data/tablasb.xlsx`

## Methods
We fit several log-linear models to each table:

1. **Null model**: Assumes constant cell counts across the table.  
2. **Saturated model**: Fits all possible interactions (perfect fit).  
3. **Independence model**: Assumes row and column variables are independent.  
4. **Uniform association model**: Includes a linear-by-linear association term.  
5. **Symmetry model**: Assumes the table is symmetric.  
6. **Quasi-symmetry model**: Combines symmetry with main effects.  
7. **Quasi-independence model**: Independence with adjustment for structural zeros.  
8. **Row effects model**: Adjusts for row-specific effects.  
9. **Column effects model**: Adjusts for column-specific effects.

For each model, we calculate:

- **Deviance and goodness-of-fit p-values**  
- **AIC for model comparison**

We select the **best-fitting model** based on minimum AIC and interpret the estimated parameters, checking the adjusted odds ratios. Additionally, we test for **marginal homogeneity** between rows and columns (SI vs QS models).

## Code
All analysis is implemented in R. The script is: `scripts/loglinear_analysis.R`


### Example Usage

```r
# Load libraries and data
library(readxl)
tablasb <- read_excel("data/tablasb.xlsx", col_names = FALSE)

# Extract tables
t1 <- tablasb[1:5, ]
t2 <- tablasb[8:12, ]

# Run analysis
source("scripts/loglinear_analysis.R")
models(t1)
models(t2)
```

## Results

Results are saved in the results/ folder. Each table's output includes:
- P-values for goodness-of-fit tests for all models
- Summary of the best-fitting model
- Test of marginal homogeneity

## License

This project is licensed under the MIT License.

