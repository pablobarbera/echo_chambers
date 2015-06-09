#==============================================================================
# 07-create-initial-matrix.r
# Purpose: create adjacency matrix indicating what users follow each pol. account
# Author: Pablo Barbera
#==============================================================================

#==============================================================================
# CENSUS: M
#==============================================================================

outfolder <- 'temp/followers_lists/'
fls <- list.files(outfolder, full.names=TRUE)
census <- gsub(".*/(.*).rdata", fls, repl="\\1")
m <- length(census) # 406 accounts

#==============================================================================
# USERS: N
#==============================================================================

# loading entire user list
load("temp/user_list_final.Rdata")
users <- (users$id_str)
n <- length(users) # 5,307,833 users included here

#==============================================================================
# CREATING COMPLETE MATRIX
#==============================================================================

# preparing adjacency matrix
m <- length(fls)
rows <- list()
columns <- list()

pb <- txtProgressBar(min=1,max=m, style=3)
for (j in 1:m){
	cat(fls[j])
    load(fls[j])
    to_add <- which(users %in% followers)
    rows[[j]] <- to_add
    columns[[j]] <- rep(j, length(to_add))
    setTxtProgressBar(pb, j)
}

rows <- unlist(rows)
columns <- unlist(columns)

# preparing sparse Matrix
library(Matrix)
y <- sparseMatrix(i=rows, j=columns)
rownames(y) <- users[1:dim(y)[1]]
colnames(y) <- census

save(y, file="temp/sparse_matrix.Rdata")

