---
title: "Machine Learning Project"
author: "Bill Wolf"
date: "Friday, December 19, 2014"
output: html_document
---

This file describes building a random forest model to predict how a weight 
lifting exercise performed based on accelerometer measurements on the belt, 
forearm, arm and dumbell of 6 test subjects.  The "how" was quantified into
"correctly" and 5 specific incorrect ways.
  
As requested the model is trained and then used to predict results for 20 
additional blind test records.
  
1. After loading the training and blind test records I partitioned the training data
into training and test partitions.

```{r}
set.seed(1235) # set to make this repeatable

options(warn=-1)
library(caret)
library(randomForest)

# load data (training file and test file)
training.data<-read.csv( "pml-training.csv", na.strings=c("NA","", "#DIV/0!"))
exam.data<-read.csv( "pml-testing.csv", na.strings=c("NA","", "#DIV/0!"))

# clean the data (strip irrelevant leading fields & colums that are more than 1/2 NA values)
training.data<-training.data[,8:ncol(training.data)]
training.data<-training.data[,colSums(is.na(training.data)) < (nrow(training.data)/2)]

# split training set into training and testing paritions
inTrain <- createDataPartition(y=training.data$classe, p=0.75, list=FALSE )
training.set <- training.data[inTrain,]
testing.set <- training.data[-inTrain,]
```

2. Create a model to predict the "how outcome" (classe variable in the training
data).  I chose to use random forest because of accuracy and because explicit
additional cross validation is not required.  Another benefit of this approach
is the ability to see the relative importance of model variables.  In this case
roll_ belt, pitch_ belt and yaw_ belt are the most important. 

```{r}
# create random forest
model<-randomForest(classe ~ ., training.set, ntree=100, importance=TRUE)
head(model$importance)
```


3.  Make predictions with the test partition of the training data and evaluate
using a confusion matrix. As shown this model is higly accurate, with an out
of sample error against the test partition of 99.3%.

```{r}
# evaluate model with testing partition
predictions<-predict(model,newdata=testing.set)
confusion<-confusionMatrix(predictions,testing.set$classe)
confusion
```

4.  Since the model is acceptably accurate make additional predicitions against
the blind test set. The model got all 20 of the test cases right
when I uploaded them to the class grading website.  

```{r}
exam.predictions<-predict(model,newdata=exam.data)
```

5.  Write out the blind test set predictions using the pml_ write_files function 
provided as part of the assignment. I didnt bother to include that code here 