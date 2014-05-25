GettingAndCleaningData_ClassProject
===================================

Class Project / Peer Reviewed Assignment for May 2014 run of Getting and Cleaning Data, Coursera


Most of this README file is based on the comments in the code, which is also in the same
repository.

The script starts by reading in data.  The R script is assumed to be in the same directory as the 
README.txt, so the directories "train/" and "test/" are in the same directory.  The files
"features.txt" and "activity_labels.txt" should also be present in this directory.  
The feature names initially load up as factors, but should be converted to characters in order
to be able to use grep afterwards.

The number of observations in the test and training sets are found and the two 
initial dataframes are combined by converting them to matrices, adding them row-wise (so the 
total number of rows is the sum of the number of rows of the two) and converting the result 
back to a dataframe. Note that the combined dataframe has test observations first, 
training observations second.

To extract the columns that have only mean and std values, the script first looks 
at the featurelist dataframe, read in from features.txt, with grepl to obtain the relevant variable names.
grepl is used with the patterns "mean()","Mean" and "std()."  The resulting logical vectors
are combined with an OR operation to subset 86 variables (columns) out of the original large dataset.
The resulting dataframe includes only those variables that are mean or std calculation values, as 
specified.  

(Note that the last seven variables in the feature list are also 
means, "used on the angle() variable," as described in the
included file features_info.txt.  The "Mean" grep finds those.)

The subject identifiers and activity labels are added to the dataframe.  The numeric
activity labels are kept in for easier averaging operations later in the project,
but the verbal descriptive labels are also added in a column of their own.  See below for column names.

To create the tidy dataset with average values of the measurements only, we start with the 
information in the original dataset's README.txt file, stating there are 30 subjects performing
6 activities.  This will give 180 observations (rows) in the final dataframe, which are organized 
such that the average measurement values for each of the 6 activities are listed for subject 1, then 
for subject 2, then for subject 3, etc.  See the output dataframe "SamsungData_Tidy_Averages.csv" in the 
repository.  Once the columns for subject ID and activity labels (numeric and verbal/descriptive) 
are created in the final dataframe, the rest is filled in by taking the averages of subsets of the
intermediary dataframe described above jointly with the subject ID and the activity ID.  

(The critical code line is "mean(XMeanStdOnly[XMeanStdOnly$subjectID==k&XMeanStdOnly$activityLabelID==l , meas])" where k and l are subject ID and activity ID, which are being swept through in a for loop.)

The final column names in the output dataframe "SamsungData_Tidy_Averages" are as follows:


subjectID:  The subject performing the activity
activityLabelID: The numeric label for the activity being performed
activityLabel: The verbal descriptive label for the activity being performed, 
corresponding to activityLabelID
tBodyAcc-mean()-X etc.: These keep the original variable names from the dataset, but the values are 
average values across that activity for that subject as specified by the row.

