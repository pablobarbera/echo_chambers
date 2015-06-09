#==============================================================================
# 11-second-stage.r
# Purpose: second stage of estimation method
# Author: Pablo Barbera
#==============================================================================

# setup
library(Matrix)
load("output/ca-first-stage.Rdata")
load("temp/sparse-matrix-final.Rdata")

## STEP 2: projecting columns
# deleting rows not in first stage
y <- y[dimnames(y)[[1]] %in% res$rownames,]
# deleting columns in first stage (we keep only new columns)
points <- y[,tolower(dimnames(y)[[2]]) %in% tolower(res$colnames)==FALSE]

# principal coordinates for rows
Psi <- res$rowcoord
# new points
h <- matrix(points, ncol=dim(points)[2])
h.sum <- apply(h, 2, sum)
hs <- h/matrix(h.sum, nrow=nrow(h), ncol=ncol(h), byrow=TRUE)
# singular values
svgam <- matrix(res$sv[1:3], nrow=ncol(h), ncol=3, byrow=TRUE)
# projecting and normalizing
g <- (t(hs) %*% Psi) / svgam

col.df <- data.frame(
	colname = c(
		res$colnames, 
		dimnames(y)[[2]][tolower(dimnames(y)[[2]]) %in% tolower(res$colnames)==FALSE]),
	coord1 = c(res$colcoord[,1], g[,1]),
	coord2 = c(res$colcoord[,2], g[,2]),
	coord3 = c(res$colcoord[,3], g[,3]),
	stringsAsFactors=F)

col.df[order(col.df$coord1),]

save(col.df, file='output/col_coord.Rdata')


## STEP 3: projecting rows
load("temp/sparse-matrix-final.Rdata")
load("output/col_coord.Rdata")

y <- y[rowSums(y)>0,]

dim(y)
# > dim(y)
# [1] 3,731,798    1187

col.df <- col.df[match(dimnames(y)[[2]], col.df$colname),]
colmasses <- colSums(y) / sum(y)
colcoords <- matrix(as.matrix(col.df[,2:4]), ncol=3)

supplementary_rows <- function(res, points){
	svphi <- matrix(res$sv[1:3], nrow = nrow(points), ncol = res$nd, 
            byrow = TRUE)
	## adapted from CA package
	cs <- colmasses
	gam.00 <- colcoords
	SR <- as.matrix(points)*1
	rs.sum <- rowSums(points)
	base2 <- t(SR/matrix(rs.sum, nrow = nrow(SR), ncol = ncol(SR)))
    cs.0 <- matrix(cs, nrow = nrow(base2), ncol = ncol(base2))
    base2 <- base2 - cs.0
    phi2 <- (t(as.matrix(base2)) %*% gam.00)/svphi
	return(phi2)
}

# sanity check
res$rownames[2]
points <- y[dimnames(y)[[1]] == res$rownames[2],] *1
res$rowcoord[2,]
supplementary_rows(res, t(as.matrix(points)))

# now all users, split in groups of 100,000

groups <- as.numeric(cut(1:nrow(y), c(seq(0, nrow(y), 100000), nrow(y))))
n.groups <- length(unique(groups))
results <- list()
for (i in 1:n.groups){
	cat(i, "/", n.groups, "\n")
	results[[i]] <- supplementary_rows(res, y[which(groups==i),])
}

row.df <- do.call(rbind, results)

row.df <- data.frame(
	rowname = dimnames(y)[[1]][1:nrow(row.df)],
	coord1 = row.df[,1],
	coord2 = row.df[,2],
	coord3 = row.df[,3],
	sum = rowSums(y),
	stringsAsFactors=F)

save(row.df, file='output/row_coord.Rdata')


## STEP 4: STANDARDIZING ALL ESTIMATES TO N(0,1)

load("output/row_coord.Rdata")

## keeping only relevant variables
users <- row.df
names(users)[c(1,2)] <- c("id", "ideology")
users <- users[,c("id", "ideology", "sum")]
users$type <- "Ordinary\nusers"
users$party <- ""

## rescaling to N(0,1)
users <- users[order(users$ideology + rnorm(length(users$ideology), 0, 0.05)),]
p <- rnorm(nrow(users), 0, 1)
p <- sort(p)
users$ideology <- p

users <- users[,c("id", "ideology", "type", "party", "sum")]

## now the same with column coordinates
load("output/col_coord.Rdata")

## putting together dataset
## a) original data
elite <- read.csv("input/elites-data.csv", stringsAsFactors=F)
elite <- elite[,c("twitter_id", "twitter_name", "type", "party")]
names(elite) <- c("id", "screenName", "type", "party")
## b) new accounts added in step 2
more.elite <- read.csv("temp/new-accounts.csv", stringsAsFactors=F)
more.elite <- more.elite[,c("id", "screenName")]
more.elite$type <- NA
more.elite$party <- NA
## merging and deleting duplicates
elite <- rbind(elite, more.elite)
elite <- elite[!duplicated(elite$id),]
elite <- elite[!is.na(elite$id),]
elite$merge <- tolower(elite$screenName)
col.df$merge <- tolower(col.df$colname)
col.df <- merge(col.df, elite)
col.df$id <- as.character(col.df$id)
col.df$ideology <- col.df$coord1
col.df$sum <- 0
elites <- col.df[,c("id", "ideology", "type", "party", "sum")]
## rescale so that both distributions have sd=1
ratio <- sd(res$colcoord[,1]) / sd(res$rowcoord[,1])
elites$ideology <- elites$ideology / ratio


## putting it all together and saving
estimates <- rbind(elites, users)
estimates <- estimates[!duplicated(estimates$id),]

save(estimates, file="output/estimates.rdata")





