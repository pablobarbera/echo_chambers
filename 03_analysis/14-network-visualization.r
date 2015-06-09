#==============================================================================
# 14-network-visualization.r
# Purpose: generate files necessary to reproduce Figures 3a and 3b of the paper
# Author: Pablo Barbera
#==============================================================================

# load user estimates and merge with user data
load("output/estimates.Rdata")
load("temp/user_list_final.Rdata")
names(users)[1] <- 'id'

##########################################
# computing weights
##########################################

## 1) compute t_ic / n_ic [ratio of tweet activity]
for (var in names(users)[5:16]){
    cat(var, " ")
    users[var] <- users[var] / sum(users[var], na.rm=TRUE)
}
users$tweets <- apply(users[,5:16], 1, sum)

estimates <- merge(estimates[,c("id", "ideology")], 
	users[,c("id", "screen_name", "followers_count", "tweets")])

## 2) compute follower weight
weights.f <- log(estimates$followers_count)
prob.f <- weights.f / sum(weights.f)

## 3) compute tweets weight
weight.t <- log((estimates$tweets * 10000)+ 1)
prob.t <- weight.t / sum(weight.t, na.rm=TRUE)

## 4) putting it all together and taking random sample of 300K
probs <- 0.5 * prob.f + 0.5 * prob.t
probs[is.na(probs)] <- 0

set.seed(12345)
unifs <- runif(length(probs))
chosen <- (unifs/500000) < probs
chosen <- which(chosen)
ids <- estimates$id[sample(chosen, 300000)]

# saving to disk
sbs <- estimates[estimates$id %in% ids,]
save(sbs, file='temp/random-sample-for-network.rdata')

##########################################
# generating nodelist and edgelist for Gephi
##########################################

lists <- c("minimum_wage", "superbowl", "marriageequality", "budget",
  "newtown", "governmentshutdown", "oscars", "sotu", "syria",
  "olympics", "boston", "obama")

for (j in 1:length(lists)){

    ## loading retweet data
    lst <- lists[j]
    cat(lst, " ")
    load(paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

    ## subsetting edges whose nodes are in the 300K random sample
    results <- results[results$retweeted %in% sbs$id &
    				results$retweeter %in% sbs$id,]

    rs <- results[,c("retweeted", "retweeter")]
    names(rs) <- c("Source", "Target")
    write.csv(rs, file=paste0('temp/gephi/edgelist_', lst, '.csv'), row.names=F)

    ids <- data.frame(id=unique(c(rs$Source, rs$Target)), stringsAsFactors=F)
    ids <- merge(ids, sbs, all.x=TRUE)
    names(ids) <- c("Id", "Ideology", "Indegree", "Outdegree")
    write.csv(ids, file=paste0('temp/gephi/nodelist_', lst, '.csv'), row.names=F)
}


##########################################
# instructions to generate graphs in Gephi
##########################################

# Data Lab --> import spreadsheet

# a) Nodelist, with ideology as float, indegree as integer
# b) edgelist

# Visualization

# Partition --> ranking, palette, default red/blue, invert; Spline = ___|^^^^.
# Size --> Indegree, from 12 to 50, spline /^

# Run connected components, undirected. Delete nodes outside giant component

# Layout: openord with default settings

# Preview black
# * border width = 0.01, border color = white, opacity = 80
# - show labels = False
# - Edges thickness = 0.30, opacity = 50












