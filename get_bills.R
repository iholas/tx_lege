############
# A script to read in Bills and Bills Details from Open State API 
# Proect: Texas Bipartisanship by Mark Clayton Hand
# Script Author: Igor Holas 
# Date: 06-19-2017
###########

#package jsonlite to read in JSON files
# install.packages('jsonlite')
# install.packages('plyr')
library(jsonlite)
library(plyr)

# Getting files from Open State API v1 
# docs: http://docs.openstates.org/en/latest/api/
#A user must obtain their own API Key from: https://openstates.org/api/register/
# After consulting with Open State, the v1 of API struggles with large data downloads,
# so the code below downaloads a file per state, per term, per chamber
# After the files are downsloaded, one data-frame per term is created

bills1 <- fromJSON("https://openstates.org/api/v1/bills/?state=tx&search_window=session&chamber=lower&apikey=880451ec-4611-405c-b206-f4e4947e61e3")
bills2 <- fromJSON("https://openstates.org/api/v1/bills/?state=tx&search_window=session&chamber=upper&apikey=880451ec-4611-405c-b206-f4e4947e61e3")
bills <- rbind(bills1,  bills2)


# getting bills details (mainly whether bill was signed into law 1/0)
# is done per bill ID from the bills data frame

action_dates_df <- data.frame("passed_upper" = character(),
                              "passed_lower" = character(),
                              "last" = character(),
                              "signed" = character(),
                              "first" = character(),
                              "bill_id" = factor())
sponsors_df <- data.frame("leg_id" = factor(),
                          "type" = factor(),
                          "name" = character(),
                          "committee_id" = factor(),
                          "bill_id" = factor() )
for (id in bills$bill_id) {
  
  # create URL string
  url <- paste("https://openstates.org/api/v1/bills/tx/85/",id,"?apikey=880451ec-4611-405c-b206-f4e4947e61e3", sep = "")
  
  #get file
  bdx <- fromJSON(url)
  
  #clean NULL values which cause DF conversion to fail
  action_dates <- bdx$action_dates
  for (i in 1:length(action_dates)) {
    if (is.null(action_dates[[i]])) {
      action_dates[[i]] <- 0
    }
  }
  
  #extract Action Dates / Sponsors vector as a data frame
  action_dates_one_df <- as.data.frame(action_dates)
  sponsors_one_df <- as.data.frame(bdx$sponsors)
  
  #add bill_id
  action_dates_one_df$bill_id <- id
  sponsors_one_df$bill_id <- id
  
  if (nrow(action_dates_df) < 1) {
    action_dates_df <- action_dates_one_df
  } else {
    action_dates_df <- rbind.fill(action_dates_df, action_dates_one_df)
  }
  
  if (nrow(sponsors_df) < 1) {
    sponsors_df <- sponsors_one_df
  } else {
    sponsors_df <- rbind.fill(sponsors_df, sponsors_one_df)
  }
  print(id)
}

write.csv(action_dates_df, file = "TX_85_action_dates.csv")
write.csv(sponsors_df, file = "TX_85_sponsors.csv")

# Columns Subject and type are lists -- converted to character for export
billsx <- bills
billsx$type <- as.character(billsx$type)
billsx$subject <- as.character(billsx$subject)

cols <- c(1,2,3,4,5,6,7,8,10)   #note no 9 - subjects
write.csv(billsx[cols], file = "TX_85_bills.csv")


