#==============================================================================
# 09-collect-additional-followers.r
# Purpose: after identifying ideological subspace, find popular accounts among
# liberals and conservatives, and download those followers lists
# Author: Pablo Barbera
#==============================================================================

# setup
library(smappR)
oauth_folder <- '~/credentials/twitter'

#################################################################################
### STEP 1: TAKE RANDOM SAMPLE OF 1000 INDIVIDUALS ON THE EXTREMES OF THE DISTRIBUTION
### AND DOWNLOAD THE LISTS OF ACCOUNTS THEY FOLLOW
#################################################################################

# load results for individuals
load("output/ca-first-stage.Rdata")

new <- data.frame(id = res$rownames,
    svd.theta1 = res$rowcoord[,1], dist = res$rowdist,
    svd.theta2 = res$rowcoord[,2], svd.theta3 = res$rowcoord[,3],
    inertia = res$rowinertia, 
    stringsAsFactors=F)

# we identify the extremes of the distribution as the top and bottom 20%
left.cutoff <- quantile(new$svd.theta1, 0.20, na.rm=TRUE)
middle <- quantile(new$svd.theta1, c(0.40, 0.60), na.rm=TRUE)
right.cutoff <- quantile(new$svd.theta1, 0.80, na.rm=TRUE)

## adding accounts on the left
set.seed(12345)
left.accounts <- sample(new$id[new$svd.theta1 < left.cutoff], 500)
accounts.done <- gsub(".rdata", "", list.files("temp/liberal"))
accounts.left <- left.accounts[left.accounts %in% accounts.done==FALSE]

# loop over each account
while (length(accounts.left) > 0){

    # sample randomly one account to get friends
    new.user <- sample(accounts.left, 1)
    cat(new.user, " -- ", length(accounts.left), " accounts left!\n")   
    
    # download friends (with some exception handling...) 
    error <- tryCatch(friends <- getFriends(screen_name=NULL, user_id=new.user,
        oauth_folder=oauth_folder), error=function(e) e)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...")
        next
    }
    
    # save to file and remove from lists of "accounts.left"
    file.name <- paste0("temp/liberal/", new.user, ".rdata")
    save(friends, file=file.name)
    accounts.left <- accounts.left[-which(accounts.left %in% new.user)]
}

## adding accounts on the right
right.accounts <- sample(new$id[new$svd.theta1 > right.cutoff], 500)
accounts.done <- gsub(".rdata", "", list.files("temp/conservative"))
accounts.left <- right.accounts[right.accounts %in% accounts.done==FALSE]

# loop over each account
while (length(accounts.left) > 0){

    # sample randomly one account to get friends
    new.user <- sample(accounts.left, 1)
    cat(new.user, " -- ", length(accounts.left), " accounts left!\n")   
    
    # download friends (with some exception handling...) 
    error <- tryCatch(friends <- getFriends(screen_name=NULL, user_id=new.user,
        oauth_folder=oauth_folder, error=function(e) e)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...")
        next
    }
    
    # save to file and remove from lists of "accounts.left"
    file.name <- paste0("temp/conservative/", new.user, ".rdata")
    save(friends, file=file.name)
    accounts.left <- accounts.left[-which(accounts.left %in% new.user)]
}

#################################################################################
### STEP 2: FIND MOST COMMON ACCOUNTS AND COMPUTE AN INDEX OF RELATIVE
### POPULARITY IN LEFT AND RIGHT
#################################################################################

# find most common accounts on left
fls <- list.files("temp/liberal", full.names=TRUE)
ids <- list()
i = 1
for (fl in fls){
	load(fl)
	ids[[i]] <- friends
	i = i + 1
}
ids <- unlist(ids)
libtab <- table(ids)
liberals <- data.frame(id = names(libtab), 
    libcount = as.numeric(libtab),
    stringsAsFactors=F)

# find most common accounts on right
fls <- list.files("temp/conservative", full.names=TRUE)
ids <- list()
i = 1
for (fl in fls){
	load(fl)
	ids[[i]] <- friends
	i = i + 1
}
ids <- unlist(ids)
contab <- table(ids)
conservatives <- data.frame(id = names(contab), 
    concount = as.numeric(contab),
    stringsAsFactors=F)

# putting it together
add <- merge(liberals, conservatives, all=TRUE)
add$libcount[is.na(add$libcount)] <- 0
add$concount[is.na(add$concount)] <- 0
add$diff <- add$libcount - add$concount

# deleting elites
elite <- read.csv("input/elites-twitter-data.csv", stringsAsFactors=F)
add <- add[add$id %in% elite$id == FALSE,]

# top people
add <- add[order(add$diff),]

new.accounts <- data.frame(id = c(tail(add$id, n=400), head(add$id, n=400)), 
	type=rep(c("liberal", "conservative"), each=400), stringsAsFactors=F)

## finding twitter data
user.data <- getUsersBatch()

library(twitteR)
load("~/credentials/twitter/my_oauth") # loading OAuth Twitter token
registerTwitterOAuth(my_oauth)
user.data <- lookupUsers(new.accounts$id)
user.data <- twListToDF(user.data)
user.data <- merge(new.accounts, user.data, sort=FALSE)

write.csv(user.data, "temp/new-accounts.csv", row.names=F)

#################################################################################
### STEP 3: DOWNLOAD FOLLOWERS OF 800 NEW ACCOUNTS
#################################################################################

d <- read.csv("temp/new-accounts.csv", stringsAsFactors=F)

# we exclude those with 10M+ followers (lists are too large to be downloaded)
d <- d[d$followersCount<1000000,]

# removing those already downloaded
accounts.done <- gsub(".rdata", "", list.files("temp/more-followers"))
accounts.left <- d$screenName[tolower(d$screenName) %in% tolower(accounts.done) == FALSE]
accounts.left <- accounts.left[!is.na(accounts.left)]

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
    file.name <- paste0("temp/more-followers", new.user, ".rdata")
    save(followers, file=file.name)
    accounts.left <- accounts.left[-which(accounts.left %in% new.user)]

}

## note: a few of these account were inactive/deleted at the time we downloaded them





