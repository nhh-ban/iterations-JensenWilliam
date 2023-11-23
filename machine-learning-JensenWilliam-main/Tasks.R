
#Install packages
install.packages("tidymodels")
install.packages("rpart.plot")


# Load packages -----
library(readr)
library(dplyr)
library(tidymodels)
library(rpart)           # For decision trees
library(rpart.plot)      # Separate package for plotting trees


getwd()

# Read data ------
names <- 
  read_csv("spambase/spambase.names", 
         skip = 32,
         col_names = FALSE) %>% 
  separate(X1,
           into = c("name", "drop"),
           sep = ":") %>% 
  select(-drop) %>% 
  bind_rows(tibble(name = "spam")) %>% 
  pull
  
spam <- 
  read_csv("spambase/spambase.data", col_names = names) %>% 
  mutate(spam = as.factor(spam))

# What is the distribution of spam e-mail in the data set?
spam %>% 
  group_by(spam) %>% 
  summarize(n_emails = n()) %>% 
  mutate(share = n_emails/sum(n_emails))

spam %>%
  group_by(spam) %>%
  summarize(n_emails = n()) %>%
  mutate(share = n_emails/sum(n_emails))

# Split the data into training and test data, and divide the training data into
# folds for cross-validaton.
set.seed(1)
spam_split <- initial_split(spam, strata = spam)
spam_train <- training(spam_split)
spam_test  <- testing (spam_split)

spam_folds <- vfold_cv(spam_train, strata = spam, v = 3)  # v = 5 or 10 is more common

# Specify the recipe, that is common for all models
spam_recipe <- 
  recipe(spam ~ ., data = spam) 

## DECISION TREE -------------

# Specify the decistion tree
tree_mod <- 
  decision_tree(
    tree_depth = tune(),
    min_n = tune()) %>%
  set_mode("classification") %>% 
  set_engine("rpart") 

# Set up the workflow
tree_workflow <- 
  workflow() %>% 
  add_model(tree_mod) %>% 
  add_recipe(spam_recipe)

# Make a search grid for the k-parameter
tree_grid <- 
  grid_latin_hypercube(
    tree_depth(),
    min_n(),
    size = 10
)

# Calculate the cross-validated AUC for all the k's in the grid
tree_tune_result <- 
  tune_grid(
    tree_workflow,
    resamples = spam_folds,
    grid = tree_grid,
    control = control_grid(save_pred = TRUE)
  )

# Which parameter combination is the best?
tree_tune_result %>%
  select_best(metric = "roc_auc") 

# Put the best parameters in the workflow
tree_tuned <- 
  finalize_workflow(
    tree_workflow,
    parameters = tree_tune_result %>% select_best(metric = "roc_auc")
  )

# Fit the model
fitted_tree <- 
  tree_tuned %>% 
  fit(data = spam_train)

# Plot the model
rpart.plot(fitted_tree$fit$fit$fit)

# Predict the train and test data
predictions_tree_test <- 
  fitted_tree %>% 
  predict(new_data = spam_test,
          type = "prob") %>% 
  mutate(truth = spam_test$spam) 

predictions_tree_train <- 
  fitted_tree %>% 
  predict(new_data = spam_train,
          type = "prob") %>% 
  mutate(truth = spam_train$spam) 


# Calculate the AUC
auc_tree <-
  predictions_tree_test %>% 
  roc_auc(truth, .pred_0) %>% 
  mutate(where = "test") %>% 
  bind_rows(predictions_tree_train %>% 
              roc_auc(truth, .pred_0) %>% 
              mutate(where = "train")) %>% 
  mutate(model = "decision_tree")

## RANDOM FOREST -------------

# Specify the random forest model
rf_mod <- 
  rand_forest(
    mtry = tune(),
    min_n = tune(),
    trees = 1000) %>%
  set_mode("classification") %>% 
  set_engine("ranger") 


# Set up the workflow for the random forest
rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(spam_recipe)

# Make a search grid for the tuning parameters
rf_grid <- 
  grid_latin_hypercube(
    mtry(range = c(1, length(names)/2)),
    min_n(),
    size = 10
  )

# Calculate the cross-validated AUC for all parameters in the grid
rf_tune_result <- 
  tune_grid(
    rf_workflow,
    resamples = spam_folds,
    grid = rf_grid,
    control = control_grid(save_pred = TRUE)
  )

# Which parameter combination is the best for the random forest?
rf_tune_result %>%
  select_best(metric = "roc_auc") 

# Put the best parameters in the workflow for the random forest
rf_tuned <- 
  finalize_workflow(
    rf_workflow,
    parameters = rf_tune_result %>% select_best(metric = "roc_auc")
  )

# Fit the random forest model
fitted_rf <- 
  rf_tuned %>% 
  fit(data = spam_train)

# Predict the train and test data using the random forest model
predictions_rf_test <- 
  fitted_rf %>% 
  predict(new_data = spam_test,
          type = "prob") %>% 
  mutate(truth = spam_test$spam) 

predictions_rf_train <- 
  fitted_rf %>% 
  predict(new_data = spam_train,
          type = "prob") %>% 
  mutate(truth = spam_train$spam) 

# Calculate the AUC for the random forest model
auc_rf <-
  predictions_rf_test %>% 
  roc_auc(truth, .pred_0) %>% 
  mutate(where = "test") %>% 
  bind_rows(predictions_rf_train %>% 
              roc_auc(truth, .pred_0) %>% 
              mutate(where = "train")) %>% 
  mutate(model = "random_forest")

# Compare the AUC of the decision tree and random forest
results <- bind_rows(auc_tree, auc_rf)
print(results)


"""
The random forest significantly outperformed the decision tree, both on the training
and test datasets. This is not surprising as random forests are an ensemble method 
that typically performs better than single decision trees.
Both models have higher AUCs on the training data compared to the test data, 
indicating they fit the training data slightly better. This is a usual observation 
in machine learning. The random forest's AUCs, especially on the test data, are 
very high, indicating that it's a very strong model for this particular task of 
spam detection.

"""

install.packages("xgboost")
library(xgboost)
library(tidymodels)


xgb_mod <- 
  boost_tree(
    mode = "classification",
    trees = 1000,
    min_n = tune(),
    tree_depth = tune(),
    learn_rate = tune(),
    loss_reduction = tune()
  ) %>%
  set_engine("xgboost")


# Set up the workflow for the random forest
xgb_workflow <- 
  workflow() %>% 
  add_model(xgb_mod) %>% 
  add_recipe(spam_recipe)

# Make a search grid for the tuning parameters
rf_grid <- 
  grid_latin_hypercube(
    mtry(range = c(1, length(names)/2)),
    min_n(),
    size = 10
  )

#Specify the Parameter Grid for Tuning
xgb_grid <-
  grid_latin_hypercube(
    min_n(),
    tree_depth(),
    learn_rate(),
    loss_reduction(),
    size = 10
  )

# Tune the model
xgb_tune_result <- 
  tune_grid(
    xgb_workflow,
    resamples = spam_folds,
    grid = xgb_grid,
    control = control_grid(save_pred = TRUE)
  )

# Find the best parameters and finalize the workflow
best_xgb_params <- xgb_tune_result %>% select_best(metric = "roc_auc")

xgb_tuned <- 
  finalize_workflow(
    xgb_workflow,
    parameters = best_xgb_params
  )

# Fit the model with the best parameters
fitted_xgb <- xgb_tuned %>% fit(data = spam_train)

predictions_xgb_test <- 
  fitted_xgb %>% 
  predict(new_data = spam_test, type = "prob") %>% 
  mutate(truth = spam_test$spam)

predictions_xgb_train <- 
  fitted_xgb %>% 
  predict(new_data = spam_train, type = "prob") %>% 
  mutate(truth = spam_train$spam)

auc_xgb <-
  predictions_xgb_test %>% 
  roc_auc(truth, .pred_0) %>% 
  mutate(where = "test") %>% 
  bind_rows(predictions_xgb_train %>% 
              roc_auc(truth, .pred_0) %>% 
              mutate(where = "train")) %>% 
  mutate(model = "xgboost")

# Compare the AUC of the decision tree and random forest with xgb_boost
results <- bind_rows(auc_tree, auc_rf, auc_xgb)
print(results)

"""
Summary:
On an email spam dataset, the Random Forest model outperformed both the Decision Tree
and XGBoost in classification accuracy, as indicated by AUC values. 
However, there's potential overfitting with Random Forest. Ensemble methods, like 
Random Forest and XGBoost, are more effective than a single Decision Tree for this task.

"""









