# Read in data.  The R script is assumed to be in the same directory as the 
# README.txt, so the directories "train/" and "test/" are in the same directory.

X_train <- read.table("train/X_train.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)
X_test<- read.table("test/X_test.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)

# Read in the subject identifiers and corresponding activity identifiers for
# each data vector in X_test and X_train.

subjectID_train <- read.table("train/subject_train.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)
activityLabel_train <- read.table("train/y_train.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)
subjectID_test <- read.table("test/subject_test.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)
activityLabel_test <- read.table("test/y_test.txt",header=FALSE,sep="",dec=".",blank.lines.skip=TRUE)

# Read in the feature list, name the columns of the resulting dataframe "FeatNo" for number
# and "FeatName" for feature name, and convert the feature names to character from factor
# in order to be able to use grep afterwards. Do the same for activity list for later use.

featurelist <- read.table("features.txt",header=FALSE, sep="")
names(featurelist) <- c("FeatNo","FeatName")
featurelist$FeatName <- as.character(featurelist$FeatName)

activitylist <- read.table("activity_labels.txt",header=FALSE,sep="")
names(activitylist) <- c("ActivityNo","ActivityName")
activitylist$ActivityName <- as.character(activitylist$ActivityName)

# Find the number of test and training subjects (observations); convert the 
# two initial dataframes to matrices in order to combine them

notestsub <- nrow(X_test)
notrainsub <- nrow(X_train)
novariables <- ncol(X_test)

Xtestmat <- as.matrix(X_test)
Xtrainmat <- as.matrix(X_train)

# Combine the matrices and recast into a dataframe
# STEP 1 OF THE PROJECT IS COMPLETE HERE

traingroupstart <- notestsub+1L
traingroupend <- notestsub+notrainsub

Xmergemat <- matrix(nrow=(notestsub+notrainsub) , ncol=novariables)
Xmergemat[ 1:notestsub , 1:novariables ] = Xtestmat
Xmergemat[traingroupstart:traingroupend , 1:novariables] = Xtrainmat
Xmerged <- as.data.frame(Xmergemat)
names(Xmerged) <- featurelist$FeatName
# STEP 1 OF THE PROJECT IS COMPLETE HERE
# Note that the combined dataframe has test observations first, 
# training observations second

# Extract the columns that have only mean and std values
# First look at the featurelist dataframe with
# grep to obtain the relevant variable names
# Note that the last seven variables in the feature list are also 
# means, "used on the angle() variable," as described in the
# included file features_info.txt.  The second "Mean" grep finds those.

meanFeatureList <- grepl("mean()",featurelist$FeatName)
meanFeatureList2 <- grepl("Mean",featurelist$FeatName)
stdFeatureList <- grepl("std()",featurelist$FeatName)

meanStdFeatureList <- meanFeatureList | meanFeatureList2 | stdFeatureList

# Now draw out only those columns with mean or std features from Xmerged
# STEP 2 OF THE PROJECT IS COMPLETE HERE
XMeanStdOnly <- Xmerged[,meanStdFeatureList]
# STEP 2 OF THE PROJECT IS COMPLETE HERE

# Add the subject identifiers and activity labels using a similar technique
# to what was used to merge the big dataframe of the observation vectors above
# Remember that the combined dataframe has test observations followed
# by training observations.

subjecttrainmat <- as.matrix(subjectID_train)
subjecttestmat <- as.matrix(subjectID_test)
activitytrainmat <- as.matrix(activityLabel_train)
activitytestmat <- as.matrix(activityLabel_test)

submergemat <- matrix(nrow=(notestsub+notrainsub) , ncol=1)
submergemat[1:notestsub] = subjecttestmat
submergemat[traingroupstart:traingroupend] = subjecttrainmat
subjectID_merged <- as.data.frame(submergemat)
names(subjectID_merged) = c("subjectID")

actmergemat <- matrix(nrow=(notestsub+notrainsub) , ncol=1)
actmergemat[1:notestsub] = activitytestmat
actmergemat[traingroupstart:traingroupend] = activitytrainmat
activityLabel_merged <- as.data.frame(actmergemat)
names(activityLabel_merged) = c("activityLabelID")

# Convert the activity dataframe to descriptive activity names in this step.
actmergevec <- as.vector(actmergemat)
getactname <- function (actno) { activitylist$ActivityName[actno] }
activityLabels <- getactname(activityLabel_merged$activityLabelID)
activityLabel_merged$activityLabel <- activityLabels

# merge the subject ID and activity labels with measurement and features
# STEPS 3 and 4 OF THE PROJECT ARE COMPLETE HERE
XMeanStdOnly$subjectID <- subjectID_merged$subjectID
XMeanStdOnly$activityLabelID <- activityLabel_merged$activityLabelID
XMeanStdOnly$activityLabel <- activityLabel_merged$activityLabel
# STEPS 3 and 4 OF THE PROJECT ARE COMPLETE HERE

# For the tidy dataset with average values of the measurements only,
# first create an empty dataset
# The names of the measurement averages will stay the same as the names of the 
# measurements.
# There are 30 subjects performing 6 activities as stated in the project's README.txt.

subjlist <- c(1:30)
actlist <- c(1:6)
finalrowno <- length(subjlist)*length(actlist)
subjectvector <- vector(mode="numeric",length=finalrowno)
for (k in subjlist){
    print(k)
    for (l in actlist){
        print(c(l,(k-1)*length(actlist)+l))
        subjectvector[(k-1)*length(actlist)+l] <- subjlist[k]
    }
}

X_Averages_names <- data.frame(subjectID=subjectvector)
X_Averages_names$activityLabelID <- rep(actlist,length(subjlist))
X_Averages_names$activityLabel <- getactname(X_Averages_names$activityLabelID)

toaver_namelist <- names(XMeanStdOnly)[1:86]
measurementlist <- c(1:86)

X_Averages_mat=matrix(data=NA,nrow=finalrowno,ncol=length(toaver_namelist))
for (meas in measurementlist){
    for (k in subjlist){
        for (l in actlist){
            averhere <- 
                    mean(XMeanStdOnly[XMeanStdOnly$subjectID==k&XMeanStdOnly$activityLabelID==l , meas])
            X_Averages_mat[(k-1)*length(actlist)+l,meas] <- averhere
        }
    }
}

# MERGE THE SUBJECT, ACTIVITY ID And ACTIVITY LABEL COLUMNS
# WITH THE AVERAGED DATA
# STEP 5 OF THE PROJECT IS COMPLETE HERE
X_Averages <- as.data.frame(X_Averages_mat)
colnames(X_Averages)<-toaver_namelist
X_Averages_Final <- cbind(X_Averages_names,X_Averages)
# STEP 5 OF THE PROJECT IS COMPLETE HERE

#colnames(testdf) <- c("subjectID","activityLabelID","activityLabel",toaver_namelist)



