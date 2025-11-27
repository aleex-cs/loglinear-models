# Load the data from an Excel file
setwd("C:\\Users\\alexc\\Documents\\GitHub\\loglineal-models")
tablasb <- read_excel("tablasb.xlsx",col_names = FALSE)

# Extract individual 5x5 contingency tables from the Excel file
t1 <- tablasb[1:5, ]
t2 <- tablasb[8:12, ]
t3 <- tablasb[15:19, ]
t4 <- tablasb[22:26, ]
t5 <- tablasb[29:33, ]

# Function to fit various log-linear models to a 5x5 contingency table
models <- function(table) {
  # Convert table to a vector of counts
  vec <- as.vector(as.matrix(table))
  n <- length(vec)
  
  # Create factor variables for rows (f) and columns (c)
  f <- gl(5, 1, n, labels = c("F1", "F2", "F3", "F4", "F5"))
  c <- gl(5, 5, n, labels = c("C1", "C2", "C3", "C4", "C5"))
  
  # Combine into a data frame
  dat <- data.frame("f" = f, "c" = c, "count" = vec)
  y <- vec  # Response variable for GLM
  
  # Fit different log-linear models
  m1 <- glm(y ~ 1, family = poisson)          # Null model
  m2 <- glm(y ~ f * c, family = poisson)      # Saturated model
  m3 <- glm(y ~ f + c, family = poisson)      # Independence model
  
  # Uniform association model
  v <- as.numeric(c) * as.numeric(f)
  m4 <- glm(y ~ f + c + v, family = poisson)
  
  # Symmetry model
  sime <- as.numeric(f) * as.numeric(c)
  sime[7] <- 33  # Adjust one element for model coding
  sime <- as.factor(sime)
  m5 <- glm(y ~ sime, family = poisson)
  
  # Quasi-symmetry model
  m6 <- glm(y ~ f + c + sime, family = poisson(link = "log"))
  
  # Quasi-independence model
  qq <- c(1,0,0,0,0,0,2,0,0,0,0,0,3,0,0,0,0,0,4,0,0,0,0,0,5)
  m7 <- glm(y ~ f + c + factor(qq), family = poisson(link = "log"))
  
  # Row effects model
  xf2 <- rep(0, 25); xf3 <- rep(0, 25); xf4 <- rep(0, 25); xf5 <- rep(0, 25)
  xf2[6:10] <- c(1:5); xf3[11:15] <- c(1:5); xf4[16:20] <- c(1:5); xf5[21:25] <- c(1:5)
  m8 <- glm(y ~ f + c + xf2 + xf3 + xf4 + xf5, family = poisson)
  
  # Column effects model
  xc2 <- as.vector(t(matrix(xf2, 5, 5)))
  xc3 <- as.vector(t(matrix(xf3, 5, 5)))
  xc4 <- as.vector(t(matrix(xf4, 5, 5)))
  xc5 <- as.vector(t(matrix(xf5, 5, 5)))
  m9 <- glm(y ~ f + c + xc2 + xc3 + xc4 + xc5, family = poisson)
  
  # Compile goodness-of-fit p-values and AIC for each model
  
  salida <- cbind(
    "P_Value" = round(c(
      1 - pchisq(m1$deviance, m1$df.residual),
      1 - pchisq(m2$deviance, m2$df.residual),
      1 - pchisq(m3$deviance, m3$df.residual),
      1 - pchisq(m4$deviance, m4$df.residual),
      1 - pchisq(m5$deviance, m5$df.residual),
      1 - pchisq(m6$deviance, m6$df.residual),
      1 - pchisq(m7$deviance, m7$df.residual),
      1 - pchisq(m8$deviance, m8$df.residual),
      1 - pchisq(m9$deviance, m9$df.residual)
    ), 6),
    "AIC" = AIC(m1, m2, m3, m4, m5, m6, m7, m8, m9)$AIC
  )
  
  # Name the rows for clarity
  rownames(salida) <- c(
    "Null model",
    "Saturated model",
    "Independence model",
    "Uniform association model",
    "Symmetry model",
    "Quasi-symmetry model",
    "Quasi-independence model",
    "Row effects model",
    "Column effects model"
  )
  
  # List of all models
  mods <- list(m1, m2, m3, m4, m5, m6, m7, m8, m9)
  
  # Select model with minimum AIC
  best_model <- mods[[which.min(salida[,2])]]
  
  # Test for marginal homogeneity (SI vs QS)
  devSI <- deviance(m5); dfSI <- df.residual(m5)
  devQS <- deviance(m6); dfQS <- df.residual(m6)
  dev_diff <- devSI - devQS; df_diff <- dfSI - dfQS
  pval <- 1 - pchisq(dev_diff, df_diff)
  test <- round(cbind(devSI, dfSI, devQS, dfQS, dev_diff, df_diff, pval), 6)
  
  return(list(
    "Models" = salida,
    "Best_Model" = summary(best_model),
    "Marginal_Homogeneity_Test" = test
  ))
}

# Apply function to each table
models(t1)
models(t2)
models(t3)
models(t4)
models(t5)
