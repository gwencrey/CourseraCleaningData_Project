##
##      This is the run_analysis script for Coursera Cleaning Data course.
##      This reads data from directory folder into tidy data set 
##              called "allWantedData" and summarizes data into a tide set
##              called "averages".
##

library(dplyr)

## Read Activity Labels for future use

activityLabelPath <- "./data/activity_labels.txt"
activityLabels <- read.table(activityLabelPath, quote = "")
names(activityLabels) <- c("identifier", "activity")

## Read Feature Labels 

featuresPath <- "./data/features.txt"
featureLabels <- read.table(featuresPath, quote = "")
names(featureLabels) <- c("identifier", "feature")

wantedFeatures <- featureLabels[grep("mean|std", featureLabels$feature),]
wantedFeatures$feature <- gsub("[()]", "", wantedFeatures$feature)


## Read Train Data for wanted features

trainDataPath <- "./data/train/X_train.txt"
trainData <- read.table(trainDataPath, quote = "", colClasses = "numeric")

# Read train data activities

trainActivityPath <- "./data/train/y_train.txt"
trainActivities <- read.table(trainActivityPath, quote ='', 
                              colClasses = "character")
trainActivities <- as.data.frame(trainActivities)
class(trainActivities[,1]) <- "string"

# Sub activity identifiers for descriptive labels
for (i in 1:nrow(activityLabels)) {
        trainActivities[,1] <- gsub(activityLabels[i,1], activityLabels[i,2], 
                               trainActivities[,1])
}

trainActivities[,1] <- as.factor(trainActivities[,1])

# Read train data subjects

trainSubjectPath <- "./data/train/subject_train.txt"
trainSubjects <- read.table(trainSubjectPath, quote ='', 
                              colClasses = "factor")

wantedTrainData <- trainData[,wantedFeatures$identifier]
wantedTrainData <- cbind(trainSubjects, trainActivities, wantedTrainData)
names(wantedTrainData) <- c("subject", "activity", wantedFeatures$feature)

## Read Test Data for wanted features

testDataPath <- "./data/test/X_test.txt"
testData <- read.table(testDataPath, quote = "", colClasses = "numeric")

testActivityPath <- "./data/test/y_test.txt"
testActivities <- read.table(testActivityPath, quote ='', 
                             colClasses = "character")
testActivities <- as.data.frame(testActivities)
class(testActivities[,1]) <- "string"

# Sub activity identifiers for descriptive labels
for (i in 1:nrow(activityLabels)) {
        testActivities[,1] <- gsub(activityLabels[i,1], activityLabels[i,2], 
                               testActivities[,1])
}

testActivities[,1] <- as.factor(testActivities[,1])

# Read test data subjects

testSubjectPath <- "./data/test/subject_test.txt"
testSubjects <- read.table(testSubjectPath, quote ='', 
                            colClasses = "factor")

wantedTestData <- testData[,wantedFeatures$identifier]
wantedTestData <- cbind(testSubjects, testActivities, wantedTestData)
names(wantedTestData) <- c("subject", "activity", wantedFeatures$feature)

## Merge test and train data

allWantedData <- merge(wantedTestData, wantedTrainData, all = TRUE)

## Calculate averages of variables over subjects and activities

averages <- allWantedData %>% group_by(activity, subject) %>% 
        summarise_each(mean)


## save tidy data

write.csv(allWantedData, file = "./tidyData/allWantedData.csv")
write.csv(averages, file = "./tidyData/averages.csv")
