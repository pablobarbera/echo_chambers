#==============================================================================
# 06-collect-followers.r
# Purpose: download list of Twitter followers of politicians from Twitter API
# Author: Pablo Barbera
#==============================================================================

# setup
library(smappR)
outfolder <- 'temp/followers_lists/'
oauth_folder <- '~/credentials/twitter'

# open list of accounts in first stage (Members of Congress + other political accounts)
elites <- read.csv("input/elites-twitter-data.csv", stringsAsFactors=F)
elites <- elites[elites$followersCount>=5000,] # keeping only those w/5K+ followers

# removing those that we already did (downloaded to "data/followers_lists/")
accounts.done <- gsub(".rdata", "", outfolder)
accounts.left <- elites$twittername[
		tolower(elites$twittername) %in% tolower(accounts.done) == FALSE]

# loop over each account
while (length(accounts.left) > 0){

    # sample randomly one account to get followers
    new.user <- sample(accounts.left, 1)
    cat(new.user, " -- ", length(accounts.left), " accounts left!\n")   
    
    # download followers (with some exception handling...) 
    error <- tryCatch(followers <- getFollowers(screen_name=new.user,
        oauth_folder=oauth_folder, sleep=0.5, verbose=FALSE), error=function(e) e)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...")
        next
    }
    
    # save to file and remove from lists of "accounts.left"
    file.name <- paste0(outfolder, new.user, ".rdata")
    save(followers, file=file.name)
    accounts.left <- accounts.left[-which(accounts.left %in% new.user)]

}


