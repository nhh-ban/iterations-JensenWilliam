[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/WRI89Flt)
# BAN400: Problem set for the Machine Learning session

Name: William Jensen

In this lecture, we take a closer look at the term *machine learning* and its various manifestations: Predictive analytics, statistical learning, AI, or whatever you want to call it. There is no clear consensus across disciplines what characteristics define these areas of analysis and distinguish them from each other. For example, a conservative statistician might say that all of this is just nonlinear regression. On the other hand, there has been a strong tendency over the past two or three decades towards predictive models that can best be described as *algorithms* rather than statistical *models*. Maybe a change in terminology is warranted for this reason. Leo Breiman's landmark 2001 paper [Statistical Modeling: The two cultures](https://doi.org/10.1214/ss/1009213726) is a readable account of this distinction from more than twenty years ago. (The title is a nod to "The Two Cultures", an influential book by C.P. Snow that poked into the alleged division between science and the humanities. Read more about that [on this Wikipedia article](https://en.wikipedia.org/wiki/The_Two_Cultures)).

The main objectives of this lesson are:

1. Become familiar with the basic terminology of machine learning (training, validation, testing) and some standard methods/models.
2. Learn the basic syntax of `tidymodels`, a collection of R-packages for training, validating, and fitting machine learning models to data.

You can dive into this topic further by following the steps below. This is way more work than what can be done in a week for a single course, so you must choose how you want to spend your time.

**Date:**

**Name:**

**Student number:**

## :information_source: Problem 1
Update the personal information above.

## Problem 2: Go over the case study from the lecture.

In the lecture, we did an example on the mail spam data. The R-script for that example and the data set are included in this repository. If you did not attend the lecture or did not work through the script during the class, you should go over the script now and make sure that you understand the steps.

## Problem 3: Predict spam e-mail using the Random Forest.
The classification tree is a relatively simple method. However, one particular issue that often limits the predictive power of this method is that its performance is very dependent on which variable is used to make the initial split. This problem can be avoided by using the *random forest*. The idea is that we grow many trees on [resampled](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) versions of the training data, but for each split in each tree, only a random subset of variables is available for splitting. The prediction is then averaged over all such trees. This way, we can smooth out the dominating influence of the most important predictor. All this may sound technical (and it is), but it is easy to fit the random forest to the mail spam data if we know the tidymodels syntax.

Do this and compare the results with the single classification tree.

- When setting up the model you must swap out `decision_tree()` with `rand_forest()`. Look at `?rand_forest` to see the tuning parameters. It is not important to tune the `trees`- parameter (the number of trees we grow, just set it to 1000 for a big forest, or maybe 100 or less to make the tuning run faster). You can tune `mtry` and `min_n`. You can set the engine to `ranger`; this is the package used to fit the model. This package must be installed if you do not already have it (`install.packages("ranger")`).
- When specifying the search grid for the two tuning parameters, we need to specify the possible range of `mtry`, the number of variables available at each split. Instead of writing `mtry()` as an argument to the `grid_latin_hypercube()`-function, you can for instance write `mtry(range = c(1, length(names)/2))`, where `length(names)` is the number of variables in the data set. This way, we will not search for values of `mtry` higher than p/2, where p is the number of predictors.
- Other than that, you can just copy all the steps from the decision tree, just making new variable names along the way (for example, swapping out `tree` with `rf` everywhere).

## Problem 4: Predict spam e-mail using xgBoost.
The random forest can be improved in a couple of somewhat technical ways, leading to the very popular xgboost-algorithm; see for example [this article for details](https://en.wikipedia.org/wiki/XGBoost). See also [this master thesis from NTNU](https://ntnuopen.ntnu.no/ntnu-xmlui/handle/11250/2433761) (with almost 200 citations in the scientific literature!!!). You must install the `xgboost`-package to do this.

Tune an xgboost model to the e-mail spam data set. Does it give better predictions than the random forest? You can look at [this blog post](https://juliasilge.com/blog/xgboost-tune-volleyball/) for a demonstration of tuning xgboost using tidymodels. Still, it is just a matter of repeating the steps from the two problems above, but swapping out the modeling function from `decision_tree()` or `rand_forest()` to `boost_tree()`, and figuring out which parameters to tune. Here you can refer to the blog post above for setting up the parameter grid. In particular, she refers to the training data set in the `grid_latin_hypercube()`-function. You must, of course, change that to `spam_train` or whatever the training data set is called in your environment.

## Problem 5: Further reading 1
Chapters 22 and 23 of [R4DS](https://r4ds.had.co.nz/) give a gentle introduction to the very basics of statistical modeling, with code-alongs and exercises, but without using the `tidymodels` framework. Working through these chapters will give you a fundamental understanding of the concepts.

## Problem 6: Further reading 2
[Tidy Modeling with R](https://www.tmwr.org/) is an online book dedicated to modeling in the `tidymodels` ecosystem. This is an excellent resource if you want to specialize in this topic. Working through chapters 6 and 7, for instance, will give you a better understanding of the unified syntax that we employed in problems 2--4.

## Problem 7: Additional case studies
[Supervised Machine Learning Case Studies in R](https://supervised-ml-course.netlify.app/) is an online course that provides four machine learning case studies of increasing complexity. All four studies are based on the `tidymodels` framework. They can be completed in the browser, or you can copy the code into a local project on your own system. All steps are covered in detail from start to finish and include solutions to all the steps. You can use these projects for additional training of your modeling skills and general data wrangling, exploration, and visualization.
