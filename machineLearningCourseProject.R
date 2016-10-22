#install.packages('RCurl')
library(RCurl)
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)

set.seed(777)

#loading Testing and Training sets
testingUrl <- getURL("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv")
testingset <- read.csv(text = testingUrl, na.strings=c("NA","#DIV/0!", ""))

trainingUrl <- getURL("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv")
trainingset  <- read.csv(text = trainingUrl, na.strings=c("NA","#DIV/0!", ""))

# Perform exploratory analysis
 dim(trainingset); 
 dim(testingset); 
 
 summary(trainingset); 
 summary(testingset); 

 str(trainingset); 
 str(testingset); 

 head(trainingset); 
 head(testingset);     


# Delete columns with all missing values
trainingset<-trainingset[,colSums(is.na(trainingset)) == 0]
testingset <-testingset[,colSums(is.na(testingset)) == 0]

# Delete all irrelevant variables: user_name, 
# raw_timestamp_part_1, raw_timestamp_part_2, 
# cvtd_timestamp, new_window, 
# and  num_window (columns 1 to 7). 
trainingset   <-trainingset[,-c(1:7)]
testingset <-testingset[,-c(1:7)]

# partition the data so that 75% of the training dataset 
# into training and the remaining 25% to testing
traintrainset <- createDataPartition(y=trainingset$classe, 
                                     p=0.75, list=FALSE)
TrainTrainingSet <- trainingset[traintrainset, ] 
TestTrainingSet <- trainingset[-traintrainset, ]

# We will crate a plot of the outcome variable
# It will help us to see the frequency 
# of each levels in the TrainTrainingSet 
# data set and compare them.
plot(TrainTrainingSet$classe, 
     col=1:length(TrainTrainingSet$classe), 
     main="Levels of variable 'classe'", 
     xlab="classe", ylab="Frequency")

#Building Decision Tree Prediction model

predictionTreeModel <- rpart(classe ~ ., data=TrainTrainingSet, method="class")
treeModelPrediction <- predict(predictionTreeModel, TestTrainingSet, type = "class")

# Plot the Decision Tree
rpart.plot(predictionTreeModel, main="Classification Tree", extra=102, under=TRUE, faclen=0, tweak=2)

# Test results on our TestTrainingSet data set:
confusionMatrix(treeModelPrediction, TestTrainingSet$classe)

#Building Random Forest Prediction model
randomForestModel <- randomForest(classe ~. , data=TrainTrainingSet, method="class")
randomForestPrediction <- predict(randomForestModel, TestTrainingSet, type = "class")

# Test results on TestTrainingSet data set:
confusionMatrix(randomForestPrediction, TestTrainingSet$classe)

# predict outcome levels on the original Testing data set using Random Forest algorithm
predictfinal <- predict(randomForestModel, testingset, type="class")
predictfinal
