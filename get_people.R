############
# A script to read in People (Legislators) from Open State API 
# Project: Texas Bipartisanship by Mark Clayton Hand
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

# Progress notes 
# 6-19-17 CURRENTLY IMPLEMENTED FOR TEXAS ONLY
# --- [] implement per-state 
# 6-20-17 4 files are created here: bills, people, action dates, and sponsors for key question
# --- [] the code should be cleaned up and a script should read just one file 
# --- [] the bill-detail takes forever, but currently most data is discraded - fix 
# --- [] in bills, column subjects is a list and cannot be exported - clean up
# --- [] in people all_id and offices are lists and cannot be exported - clean up
# 6-20-2017 Set up project structure
# [] bill detail scraping as a function 
# [] bills + bill details scraping as a script - with bill detail craping commented out
# [] bills cleanup + bill characteristics - passes , partisanship
# 
setwd("~/tx_lege")

#getting list of legislators - see API docs
people <- fromJSON("https://openstates.org/api/v1/legislators/?state=tx&active=true&apikey=880451ec-4611-405c-b206-f4e4947e61e3")

#export raw file  for archiving
# - 21, 11 (offices and all_ids) are lists - cannot be exported
cols_people<- c(1,2,3,4,5,6,7,8,9,10,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28,29)
write.csv(people[cols_people], file = "TX_85_people_raw.csv")

# calculating numeric republican 1 = yes variable 
people$repub <- ifelse (people$party == "Republican", 1, 0)
#cleaning missing party affiliation for Dan Patrick
people$repub <- ifelse (is.na(people$repub), 1, people$repub)


# 6-20-2017 Keeping only lege_id, and 
small_cols <- c('leg_id', 'repub')
people_small <- people[small_cols]

write.csv(people_small, file = "data/TX_85_people_small.csv")
