#==============================================================================
# 10-create-final-matrix.r
# Purpose: create final adjacency matrix
# Author: Pablo Barbera
#==============================================================================

#==============================================================================
# CENSUS: M
#==============================================================================

fls <- list.files(c('temp/followers_lists', 'temp/more-followers'), full.names=TRUE)
census <- gsub(".*/(.*).rdata", fls, repl="\\1")
m <- length(census) # 1187 accounts

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

save(y, file="temp/sparse-matrix-final.Rdata")

table(rowSums(y)>0)

### FINAL SAMPLE SIZE:
#   FALSE    TRUE 
# 1575962 3,731,798 
