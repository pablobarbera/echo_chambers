#==============================================================================
# 01-collect-tweets.R
# Purpose: illustrate how tweets were collected, and provide code to re-download
# tweets using tweet IDs (provided)
# Author: Pablo Barbera
#==============================================================================

# The following code illustrates how one of our collections was created.
# However, note that tweets can only be created in real time. Given Twitter's
# Terms of Service, we cannot share the entire dataset, but instead we provide
# code that shows how each of the collections can be recreated.

library(ROAuth)
library(streamR)
keywords <- c("obama", "romney")

# this script will be run once every hour, and tweets are stored in different
# files, whose name indicate when they were created.
current.time <- format(Sys.time(), "%Y_%m_%d_%H_%M")
f <- paste0("Election_", current.time, '.json')

# loading OAuth token
load("~/credentials/twitter/my_oauth")

# open connection to Twitter's Streaming API
filterStream(file.name = f, track = keywords, timeout = 60*60, oauth = my_oauth)

#####################################################
#### REPLICATION: TABLE 1
#####################################################

# Since we cannot share the full tweets datasets, instead we provide the list
# of tweet IDs, which can be used to (a) replicate Table 1 of the paper;
# and (2) if desired, reconstruct the dataset of tweets.

# Replication of Table 1
system("wc -l tweet-collections/*")

 # 60452831 2012Election.txt
 # 14339848 Boston.txt
 # 7755625 Budget.txt
 # 12421627 GovtShutdown.txt
 # 5089809 GunControl.txt
 #  252935 MinimumWage.txt
 # 7739938 Olympics.txt
 # 10644644 Oscars.txt
 # 2750638 SOTU.txt
 # 5052005 SuperBowl.txt
 # 8241896 SupremeCourt.txt
 # 7711780 Syria.txt
 # 142453576 total

# How to recover tweets by ID
library(smappR)

## Example: reading first 100 tweets
ids <- scan("tweet-collections/MinimumWage.txt", n=100, what="character")

## downloading statuses
getStatuses(ids=ids, filename='minimum-wage-tweets.json',
    oauth_folder = "~/credentials/twitter")

## reading tweets in R
library(streamR)
tweets <- parseTweets("minimum-wage-tweets.json")

# (total of tweets will be lower because of deleted tweets, deactivated
# accounts, etc.)

# The rest of the code assumes tweets are hosted in a MongoDB database.
# Here we show how one can dump tweets into this format.
# (We assume mongoDB is installed and running)
library(smappR)
tweetsToMongo(file.name="minimum-wage-tweets.json",
	ns="tweets.minimum_wage")
# NOTE: this function adds two additional fields to the data required
# for the rest of the analysis: 1) timestamp (datetime in ISO format)
# and 2) random_number (a random float, from 0 to 1)

# See https://github.com/SMAPPNYU/smappR for more examples of how
# to work with tweets in MongoDB format. Eg:
mongo <- mongo.create(db="tweets")
count.tweets("tweets.minimum_wage")





