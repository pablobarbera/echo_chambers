#==============================================================================
# 08-first-stage.r
# Purpose: first stage of estimation method
# Author: Pablo Barbera
#==============================================================================

# setup
library(Matrix)
library(ca)

## STEP 1: identifying subspace. Matrix with only politicians, media, think tanks;
## and users who follow 10 or more of these.

# load sparse matrix
load("temp/sparse_matrix.Rdata")
dim(y) # 5307831     406
y <- y[rowSums(y)>9,]
dim(y) # 178704    406
y <- as.matrix(y)
res <- ca(y, nd=3)

## saving
save(res, file="output/ca-first-stage.rdata")

###########
## preliminary validation
###########

# dataset with Twitter ideology estimates
df <- data.frame(screen_name = res$colnames,
    svd.phi = res$colcoord[,1], merge = tolower(res$colnames),
    stringsAsFactors=F)

## dataset with ideology from roll-call votes
elite <- read.csv("input/elites-data.csv", stringsAsFactors=F)

house <- read.csv("input/house.csv", stringsAsFactors=F)
house$chamber <- "house"
senate <- read.csv("input/senate.csv", stringsAsFactors=F)
senate$chamber <- "senate"
cong <- rbind(
    house[,c("nameid", "idealPoint", "party", "chamber")], 
    senate[,c("nameid", "idealPoint", "party", "chamber")])
names(cong)[1] <- "id"
elite <- merge(elite, cong[,c("id", "idealPoint")], all.x=TRUE)
elite$merge <- tolower(elite$twitter_name)


## merging everything
elite <- merge(elite, df)

## correlation plot
d <- elite[!is.na(elite$idealPoint),]
cor(d$svd.phi, d$idealPoint)

## correlations by party/chamber
cor(d$svd.phi[d$party=="R"], d$idealPoint[d$party=="R"]) #  0.442
cor(d$svd.phi[d$party=="D"], d$idealPoint[d$party=="D"]) # 0.647
cor(d$svd.phi[d$chamber=="House"], d$idealPoint[d$chamber=="House"]) # 0.956
cor(d$svd.phi[d$chamber=="Senate"], d$idealPoint[d$chamber=="Senate"]) # 0.944

cor(d$svd.phi[d$chamber=="House" & d$party=="D"], 
    d$idealPoint[d$chamber=="House" & d$party=="D"])
cor(d$svd.phi[d$chamber=="Senate"& d$party=="D"], 
    d$idealPoint[d$chamber=="Senate"& d$party=="D"])

cor(d$svd.phi[d$chamber=="House" & d$party=="R"], 
    d$idealPoint[d$chamber=="House" & d$party=="R"])
cor(d$svd.phi[d$chamber=="Senate"& d$party=="R"], 
    d$idealPoint[d$chamber=="Senate"& d$party=="R"])






