############
# A script to process Bills and Bills Details data for analysis
# Proect: Texas Bipartisanship by Mark Clayton Hand
# Script Author: Igor Holas 
# Date: 06-20-2017
###########

# use sponsors csv
# -- import repub value from people_small
# -- calculate mean repub score per bill_id

# use create bill_facts table 
# -- bill id, signed, mean_repub

# libs
library(jsonlite)
library(plyr)

#set wd
setwd('~/tx_lege')

# merge sponsors and people_small
# sponsors.csv and action_dates.csv come from get_bills.R
# people_small.csv comes from get_people.R
sponsors <- read.csv("data/TX_85_sponsors.csv")
action_dates <- read.csv("data/TX_85_action_dates.csv")
people_sall <- read.csv("data/TX_85_people_small.csv")
spons_repub <- merge(sponsors, people_small, by='leg_id')

bill_facts <- as.data.frame(as.list(aggregate(spons_repub[, c('repub')], list(spons_repub$bill_id), FUN=function(x) c(mn = mean(x), n = length(x) ) ) ) )
#cleaning up - setting the corret bill_id column name
names(bill_facts)[names(bill_facts)=="Group.1"] <- "bill_id"
names(bill_facts)[names(bill_facts)=="x.mn"] <- "pct_repub"
names(bill_facts)[names(bill_facts)=="x.n"] <- "num_sponsors"

#adding signed flag
bill_facts2 <- merge (bill_facts,action_dates, by='bill_id')
bill_facts2$signed <- ifelse(bill_facts2$signed !=0, 1, 0)

#export csv
write.csv(bill_facts2[c('bill_id','pct_repub','num_sponsors','signed')], file = "data/TX_85_bill_facts.csv")
