rm(list = ls()) #clean up

#Read CSV file
datasetFull <- read.csv(file="Training data set.csv",head=TRUE,sep=",")

#Extract past v1 clicks (col=1) and timestamps (col=15) from datasetFull
#v1 - response variable: yVector
#v15 - predictor variable: x1Vector 
yVectorIndex = 1
xVectorIndex = 15
completeV1RowsTotal = 696             #broswer v1 (col=1) only has 696 filled rows
completeTimestampRowsTotal = 731      #timestamp (col=15) has 731 filled rows
yVector <- datasetFull[1:completeV1RowsTotal, yVectorIndex] #extracts rows 1 to completeV1RowsTotal of column yVectorIndex
#features for generating the model
xVectorInitial <- datasetFull[1:completeV1RowsTotal, xVectorIndex] 
#features for prediction
xVectorPredict <- datasetFull[(completeV1RowsTotal+2):completeTimestampRowsTotal-1, xVectorIndex] #for prediction

#Plot v1 
par(pch=20, col="dodgerblue3")
plot(yVector, type="o", 
     main="Historical Hourly Clicks on v1 Browser",
     xlab="Time instance (hourly record: Dec-12 to Jan-9)",
     ylab="Clicks")

#We want to split the timestamp into four separate info: 
#hour, day, days to Christmas (holiday1), and days to New year's (holiday2)
#save each info in a separate numeric vector
hourVector <- numeric() 
dayVector <- numeric() 
daysToHoliday1Vector <- numeric() 
daysToHoliday2Vector <- numeric() 
#these vectors are for prediction, which will do after the model is created
hourVectorPredict <- numeric() 
dayVectorPredict <- numeric() 
daysToHoliday1VectorPredict <- numeric() 
daysToHoliday2VectorPredict <- numeric() 

#Initialize day 1 values
week = 1      #increment until end of data
day = 1       #increment until end of week
dayFull = 1   #increment until end of data 
#variable limits
hourLimit = 0       #one day covers 0000-hour to 2300-hour range; 0 limit signifies 0000-hour of the succeeding day 
dayLimit = 7        #seven days in a week 
holiday1Index = 14  #25th of December is 14th day in the datset
holiday2Index = 21  #1st of January is 21st day in the dataset 
rowEntryCount = 1
for (rowEntry in xVectorInitial){
  #date format: "12-12-2016 0:00:00"
  colonIndex = regexpr(':', rowEntry) #extract pattern index
  hourStartIndex = colonIndex[1]-2
  hourEndIndex = colonIndex[1]-1
  hourString = substr(rowEntry, hourStartIndex, hourEndIndex) #two-digit hour
  hour = as.numeric(hourString) #convert string to numeric
  #hour record format: set mid-day as max number (12), 1300 is encoded like 1100 (11)
  if (hour>12){
    hour = 12-(hour-12)
  }
  #append extracted data to respective vectors
  hourVector[rowEntryCount] <- hour
  dayVector[rowEntryCount] <- day
  daysToHoliday1Vector[rowEntryCount] <- abs(dayFull-holiday1Index)
  daysToHoliday2Vector[rowEntryCount] <- abs(dayFull-holiday2Index)
  #increment/reset day and week variables accordingly
  if ((hour == hourLimit)&&(rowEntryCount!=1)){
    day = day + 1 #start to day 1 of new week
    dayFull = dayFull + 1 #counts all days in the dataset
  }
  if (day > dayLimit){
    week = week + 1 #new week
    day = 1 #reset day for the new week
  }
  rowEntryCount = rowEntryCount + 1
}

#Fill in the vectors for prediction - repeat above
rowEntryCount = 1
day = 2         #Prediction starts on Tuesday, January 10th
for (rowEntry in xVectorPredict){
  #date format: "12-12-2016 0:00:00"
  colonIndex = regexpr(':', rowEntry) #extract pattern index
  hourStartIndex = colonIndex[1]-2
  hourEndIndex = colonIndex[1]-1
  hourString = substr(rowEntry, hourStartIndex, hourEndIndex) #two-digit hour
  hour = as.numeric(hourString) #convert string to numeric
  #hour record format: set mid-day as max number (12), 1300 is encoded like 1100 (11)
  if (hour>12){
    hour = 12-(hour-12)
  }
  #append extracted data to respective vectors
  hourVectorPredict[rowEntryCount] <- hour
  dayVectorPredict[rowEntryCount] <- day
  daysToHoliday1VectorPredict[rowEntryCount] <- abs(dayFull-holiday1Index)
  daysToHoliday2VectorPredict[rowEntryCount] <- abs(dayFull-holiday2Index)
  #increment/reset day and week variables accordingly
  if ((hour == hourLimit)&&(rowEntryCount!=1)){
    day = day + 1 #start to day 1 of new week
    dayFull = dayFull + 1 #counts all days in the dataset
  }
  if (day > dayLimit){
    week = week + 1 #new week
    day = 1 #reset day for the new week
  }
  rowEntryCount = rowEntryCount + 1
}

#Vectors for creating the model are complete
#Merge everything into a final data frame
datasetFinal <- data.frame(
  clicks = yVector,
  timeOfDay = hourVector,
  dayOfWeek = dayVector,
  daysToChristmas = daysToHoliday1Vector,
  daysToNewYear = daysToHoliday2Vector
)
par(pch=20, col="dodgerblue3") #plot inter-variable relationship
plot(datasetFinal) 

#Time to model data
fitModelNew <- lm(clicks ~ timeOfDay+daysToChristmas+daysToNewYear, data=datasetFinal) 
print(summary(fitModelNew)) # show results

plot(yVector, type="o",col="dodgerblue3",
  main="Fitted vs. Actual Values",
  xlab="Time instance (hourly record: Dec-12 to Jan-9)",
  ylab="Clicks")
par(pch=20)
lines(fitted(fitModelNew), type="o", col="coral3")
legend(10, 420, legend=c("Fitted", "Actual"),
       col=c("coral3", "dodgerblue3"), lty=1:1, cex=0.8)

#Time to perform prediction using generated model
#Merge all vectors containing features that will be used for prediction into a data frame
featuresPredict <- data.frame(
  timeOfDay = hourVectorPredict,
  dayOfWeek = dayVectorPredict,
  daysToChristmas = daysToHoliday1VectorPredict,
  daysToNewYear = daysToHoliday2VectorPredict
)
predictResult = predict(fitModelNew, featuresPredict, interval="predict")
print(summary(predictResult[,1]))
par(pch=20, col="coral3")
plot(predictResult[,1], type="o",
     main="Click Predictions for v1 browser",
     xlab="Time instance (hourly record: Jan-10 to Jan-11)",
     ylab="Clicks")