#setting working directory
setwd("C:/Users/lenovo/Desktop/sem 3/ML")
#checking working directory
getwd()

df1 <- read.csv(file ="German-Credit_1.csv" ,header = TRUE)
df2 <- read.csv(file = "German-Credit_2.csv",header = TRUE)

head(df1)
head(df2)


#merging both dfs by common variable OBS
df3 <- merge(x=df1,y=df2,by = "OBS",all = T)
head(df3)
colnames(df1)
colnames(df2)
colnames(df3)

#datatype of each variables
str(df3)
#numerical distribution of variables
summary(df3)

#vector of all numeriacal colums
num_Attr <- c("DURATION","AMOUNT","INSTALL_RATE"  ,"AGE" ,"NUM_CREDITS","NUM_DEPENDENTS" )
#setdiff helps to find difference btw 2 vectors
#cat_attr = full_df - num_attr
cat_Attr <- setdiff(x=colnames(df3),y=num_Attr)

#converting OBS to charecter type
df3$OBS <- as.character(df3$OBS)

#####sample
test_vector <- c(0,1,1,1,0,1,0,1,0,1,0,0,1,1,0)
test_vector

fac_vector <- as.factor(test_vector)
fac_vector

reconverted_vec <- as.numeric(fac_vector)
reconverted_vec
######

#numeric ->> charecter ->> factor
df3$RESPONSE <- as.factor(as.character(df3$RESPONSE))

df_cat <- subset(df3,select = cat_Attr)
df3[,cat_Attr]<- data.frame(apply(df_cat,2, function(x) as.factor(as.character(x))))
str(df3)

#handling missing values
#no of nas in each column
colSums(is.na(x=df3))
#total no. of nas in df3
sum(is.na(df3))

#dropping records with missing values
#omit removes na values entirely
#removing na values from df3 and saving it in df4
df4 <- na.omit(df3)
dim(df4)
sum(is.na(df4))


#Impting/substituting missing values
#install.packages("DMwR")
library(DMwR)

#Using functions from the DMwR package we can replace the missing values with our best estimate of those points

# utility function to obtain the number of the rows in a data frame that have a "large" number of unknown values.
manyNAs(df3,0.1)
df3_imputed <- centralImputation(data = df3)
sum(is.na(df3_imputed))

df3_imputed1 <- knnImputation(data = df3,k=5)
sum(is.na(df3_imputed1))


#binning
#install.packages("infotheo")
library(infotheo)

#####sample
x <- c(5,6,7,8,8,8,8,8,11,20,21,22)
length(x)
x0 <- discretize(x, disc = "equalfreq", nbins = 4)
table(x0)
x0

x1 <- discretize(x, disc = "equalwidth", nbins = 4)
table(x1)
############

#binning the amount
AmtBin <- discretize(df3_imputed$AMOUNT, disc="equalfreq",nbins=4)
table(AmtBin)
AmtBin <- discretize(df3_imputed$AMOUNT, disc="equalwidth",nbins=4)
table(AmtBin)


#Dummy variable creation
#install.packages("dummies")
library(dummies)

df_ex <- datasets::warpbreaks
df_ex

table(df_ex$tension)
dummy_ex <-  dummy(df_ex$tension)
head(dummy_ex)

df_cat <- subset(df3_imputed,select =cat_Attr)
df_cat_dummies <- data.frame(apply(df_cat, 2, function(x) dummy(x)))
dim(df_cat_dummies)

#Standardizing	the	data
##We can standardize and make the variables unitless, this can help us reduce the effectn of variables that have extreme ranges

#install.packages("vegan")
library(vegan)

df_num <- df3_imputed[, num_Attr]
df_num2 <- decostand(x = df_num, method = "range") # using range method
summary(df_num2)
df_num3 <- decostand(x = df_num, method = "standardize")
summary(df_num3)
df_final <- cbind(df_num3,df_cat)
head(df_final)

rows <- seq(1,1000,1)
set.seed(123)
trainRows <- sample(rows,600)
train_data <- df_final[trainRows,]
test_data <- df_final[-c(trainRows),]
dim(train_data)
dim(test_data)


#model buiding
lm_model <- lm(AMOUNT~DURATION, data=train_data)
summary(lm_model)

## Including Plot
# Store the final dataset in the df variable
df <- df_final
## Histogram
hist(df$AGE)
hist(df$AGE,col = "purple")

## Box plot
boxplot(df$AGE,horizontal = TRUE)

boxplot(AMOUNT~RESPONSE, data = df, xlab ="TARGET", ylab = "AMOUNT", main ="Continuous v/s Categorical")


## Bar plot
barplot(table(df$RESPONSE))
## Bar plot with colour
barplot(table(df$RESPONSE),col="red")


## Scatter Plot
plot(x=df$AGE,y =df$AMOUNT ,xlab = "DURATION",ylab="AMOUNT",main= "Continuous v/s Continuous",col="yellow")



