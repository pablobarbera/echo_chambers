#==============================================================================
# 03-spam-location-activity-filter.r
# Purpose: here we apply the rest of the filters to our sample; we keep
# only those tweeting in English, who have also tweeted in at least two
# of cour collections. In addition, we take a random sample of 200,000
# users and use different location extraction information to identify 
# the state in which they live.
# Author: Pablo Barbera
#==============================================================================

### ADDITIONAL FILTERS

users <- read.csv("temp/user_list_full.csv", stringsAsFactors=F)

## deleting errors in data
users <- users[users$id_str!="",]
todelete <- which(is.na(as.numeric(users$id_str)))
users <- users[-todelete,]

## deleting users with language other than Spanish
users <- users[users$lang=="en",]

## deleting users who haven't participated in at 
## least two collections
active <- apply(users[,lists], 1, function(x) length(which(!is.na(x))))
users <- users[active>1,] ## a total of 5.3 million users

## saving to disk
write.csv(users, file="temp/user_list_full_v2.csv", row.names=F)


### LOCATION INFORMATION FOR A RANDOM SAMPLE OF USERS

# new variables to be filled
users$lat <- NA
users$lng <- NA
users$country <- NA
users$state <- NA

# random sample of 200,000 users with non-empty location field
set.seed(12345)
rs <- sample(1:nrow(users), 200000)
j <- 1

for (i in rs){

    Sys.sleep(.2)
	location <- users$location[i]
	cat(j, location, "-- ")
	error <- tryCatch(geo <- getGeo(location), error=function(e) e)
    if (inherits(error, 'error')) {
        cat("Error! On to the next one...\n")
        Sys.sleep(5)
        next
    }

    if (length(geo)==0 | is.null(geo$state)){
        cat("No state location found!!\n")
        next
    }
    cat(geo$lat, "-- ", geo$lng, "--", geo$state, "\n")

    # adding new information
    users$lat[i] <- geo$lat
    users$lng[i] <- geo$lng
    users$country[i] <- geo$country
    users$state[i] <- geo$state

    j <- j + 1

}

## saving to disk
write.csv(users, file="temp/user_list_final.csv", row.names=F)
save(users, file="temp/user_list_final.rdata")



