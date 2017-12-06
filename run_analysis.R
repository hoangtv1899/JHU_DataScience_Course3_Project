library(reshape2)
library(dplyr)
library(tidyr)

#download and unzip data
data_link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file_zip <- "UCI_dataset.zip"
if (!file.exists(file_zip)) {
  download.file(data_link,file_zip,method="curl")
}

dir_path = "UCI HAR Dataset"

if (!dir.exists(dir_path)) {
  unzip(file_zip)
}

#read features and activities metadata
features<-read.table(paste(dir_path,'/features.txt',sep=""))
features[,2] <- as.character(features[,2])
activities<-read.table(paste(dir_path,'/activity_labels.txt',sep=""))
activities[,2]<-as.character(activities[,2])

#select only mean and std of measurements
features <- features %>% filter(grepl('mean|std',V2))

#load the train dataset
trainSubject <- read.table(paste(dir_path,'/train/subject_train.txt',sep=""))
trainX <- read.table(paste(dir_path,'/train/X_train.txt',sep=""))[,features$V1]
trainY <- read.table(paste(dir_path,'/train/y_train.txt',sep=""))

train <- cbind(trainSubject,trainY,trainX)

#load the test dataset
testSubject <- read.table(paste(dir_path,'/test/subject_test.txt',sep=""))
testX <- read.table(paste(dir_path,'/test/X_test.txt',sep=""))[,features$V1]
testY <- read.table(paste(dir_path,'/test/y_test.txt',sep=""))

test <- cbind(testSubject,testY,testX)

#merge two dataset
merge_data <- rbind(train,test)
colnames(merge_data) <- c("subject","activity",features$V2)

# turn activities & subjects into factors
merge_data$activity <- factor(merge_data$activity, levels = activities[,1], labels = activities[,2])
merge_data$subject <- as.factor(merge_data$subject)

merge_data.melted <- melt(merge_data, id = c("subject", "activity"))
merge_data.mean <- dcast(merge_data.melted, subject + activity ~ variable, mean)

write.table(merge_data.mean, "tidy_dataset.txt", row.names = FALSE, quote = FALSE)


