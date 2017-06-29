############
# A script to process Bills and Bills Details for analysis
# Project: Texas Bipartisanship by Mark Clayton Hand
# Script Author: Igor Holas 
# Date: 06-23-2017
# Description - uses local bulk download files from OpenStates.org 
###########

####
# Passed without signage 150 
# about 1000 signed

setwd("~/tx_lege")

# Get bills and subset by session and bill type (bills and constitutional ammendments)
types <- c('bill',"constitutional amendment")
bills85 <- read.csv("data/tx_bills.csv")
bills85 <- subset(bills85, bills85$session == 85 & bills85$type %in% types)

# Get sponsors, subset where session_id == 85 and bill_id matches a bill_in in Bill data frame
sponsors85 <- read.csv("data/tx_bill_sponsors.csv")
sponsors85 <- subset(sponsors85, sponsors85$bill_id %in% bills85$bill_id & sponsors85$session == 85)
# there are missing Leg ID's 812 missing from 18,638
# this will be a problem for merging / counting 
sum(sponsors85$leg_id == "")
sum(sponsors85$leg_id != "")


# Get actions, keep only session 85 and bill_id's in Bills85 data frame 
actions85 <- read.csv("data/tx_bill_actions.csv")
actions85 <- subset(actions85, actions85$session == 85 & actions85$bill_id %in% bills85$bill_id)

# Get Legislator info - keep only those where Leg_id is not missing in sponsors85 data frame
not_na_leg_id_85 <- sponsors85$leg_id[sponsors85$leg_id != ""]
legislators85 <- read.csv("data/tx_legislators.csv")
legislators85 <- subset(legislators85, legislators85$leg_id %in% not_na_leg_id_85)
# table(legislators85$party, useNA = "ifany")
#            Democrat Democratic Republican 
# 2         11         51        113 

#####################
# Cleaning data - Calculating new values
####################

# set Republican flag
legislators85$repub <- ifelse(legislators85$party == "Republican", 1, 0)
# table(legislators85$republican)
# 0   1 
# 64 113 

#drop most of legilators data frame 
small_cols <- c('leg_id', 'repub')
legislators85_small <- legislators85[small_cols]

# sponsors merge with legislators_small
sponsors85_repub <- merge(sponsors85, legislators85_small, by='leg_id')

#aggregate 
bill_facts <- as.data.frame(as.list(aggregate(sponsors85_repub[, c('repub')], list(sponsors85_repub$bill_id), FUN=function(x) c(mn = mean(x), n = length(x) ) ) ) )
#cleaning up - setting the corret bill_id column name
names(bill_facts)[names(bill_facts)=="Group.1"] <- "bill_id"
names(bill_facts)[names(bill_facts)=="x.mn"] <- "pct_repub"
names(bill_facts)[names(bill_facts)=="x.n"] <- "num_sponsors"

# Adding is_law flag
# Scenaria
# 1 Signed 
# 2 filed without signature
# 3 has an effective date

effective <- actions85[grep("Effective", actions85$action),]
effective$effective <- 1

signed <- actions85[grep("Signed by", actions85$action),]
signed$signed <- 1

filed <- actions85[grep("Filed without", actions85$action),]
filed$filed_wo_signature <- 1

passed <- merge (signed[c("bill_id", "signed")],effective[c("bill_id", "effective")], by = 'bill_id', all = TRUE)
passed <- merge (passed,filed[c("bill_id", "filed_wo_signature")], by = 'bill_id', all = TRUE)
passed$is_law <- 1

# merging it all togeher
bill_facts2 <- merge (bill_facts,passed, by='bill_id', all.x = TRUE)
bill_facts2$signed <- ifelse(is.na(bill_facts2$signed),0,1)
bill_facts2$effective <- ifelse(is.na(bill_facts2$effective),0,1)
bill_facts2$filed_wo_signature <- ifelse(is.na(bill_facts2$filed_wo_signature),0,1)
bill_facts2$is_law <- ifelse(is.na(bill_facts2$is_law),0,1)

#export csv
write.csv(bill_facts2[c('bill_id','pct_repub','num_sponsors','signed','effective','filed_wo_signature','is_law')], file = "data/bills_sponsors_passage_85.csv")
