#==============================================================================
# 13-heatmaps.r
# Purpose: produce Figure 2 in paper
# Author: Pablo Barbera
#==============================================================================

# setup
library(reshape)
load("output/estimates.rdata")
estimates <- estimates[,c("id", "ideology")]

## list abbreviations and names
lists <- c("minimum_wage", "obama", "superbowl", "marriageequality", "budget",
  "newtown", "governmentshutdown", "oscars", "sotu", "syria",
  "olympics", "boston")

not.poli <- c("superbowl", "newtown", "oscars", "syria", "olympics", "boston")
not.poli.labels <- c("Super Bowl", "Newtown Shooting", "Oscars 2014", "Syria",
    "Winter Olympics", "Boston Marathon")
poli <- c("minimum_wage", "marriageequality", "budget", "governmentshutdown",
    "sotu", "obama")
poli.labels <- c("Minimum Wage", "Marriage Equality", "Budget",
    "Gov. Shutdown", "State of the Union", "2012 Election")

## functions to construct heatmaps
min <- -3.5
max <- 3.5
breaks <- 0.25

expand_data <- function(breaks=0.10, min=-4, max=4){
    x <- results$ideology_retweeter
    y <- results$ideology_retweeted
    x <- (round((x - min) / breaks, 0) * breaks) + min
    y <- (round((y - min) / breaks, 0) * breaks) + min
    tab <- table(x, y)
    tab <- melt(tab)
    tab$prop <- tab$value/sum(tab$value)
    return(tab)
}

######################################################################
### PRE-PROCESSING: EXTRACTING RETWEET LISTS AND MERGING WITH ESTIMATES
######################################################################

pol.days <- c() ## we also estimate our polarization index by day

for (j in 1:length(not.poli)){
    
    lst <- not.poli[j]
    cat(lst, "\n")
    fls <- list.files("temp/retweets", full.names=TRUE)
    fls <- fls[grep(lst, fls)]  

    results <- list()   

    for (i in 1:length(fls)){
        retweets <- read.table(fls[i], sep=",", 
        	stringsAsFactors=F, col.names=c("retweeter", "retweeted"), fill=T)
        names(retweets)[1] <- 'id'
        retweets <- merge(retweets, estimates)
        names(retweets)[1] <- "retweeter"
        names(retweets)[3] <- "ideology_retweeter"
        names(retweets)[2] <- 'id'
        retweets <- merge(retweets, estimates)
        names(retweets)[4] <- "ideology_retweeted"
        names(retweets)[1] <- "retweeted"
        results[[i]] <- retweets
        cat(i, " ")
        pol.days <- rbind(pol.days,
            data.frame(collection = not.poli.labels[j], day = i, 
                polar = mean(abs(retweets$ideology_retweeted)),
            stringsAsFactors=F))
    }   

    results <- do.call(rbind, results)  

    ## saving results
    save(results, file=paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

}


for (j in 1:length(poli)){
    
    lst <- not.poli[j]
    cat(lst, "\n")
    fls <- list.files("temp/retweets", full.names=TRUE)
    fls <- fls[grep(lst, fls)]  

    results <- list()   

    for (i in 1:length(fls)){
        retweets <- read.table(fls[i], sep=",", 
        	stringsAsFactors=F, col.names=c("retweeter", "retweeted"), fill=T)
        names(retweets)[1] <- 'id'
        retweets <- merge(retweets, estimates)
        names(retweets)[1] <- "retweeter"
        names(retweets)[3] <- "ideology_retweeter"
        names(retweets)[2] <- 'id'
        retweets <- merge(retweets, estimates)
        names(retweets)[4] <- "ideology_retweeted"
        names(retweets)[1] <- "retweeted"
        results[[i]] <- retweets
        cat(i, " ")
        pol.days <- rbind(pol.days,
            data.frame(collection = not.poli.labels[j], day = i, 
                polar = mean(abs(retweets$ideology_retweeted)),
            stringsAsFactors=F))
    }   

    results <- do.call(rbind, results)  

    ## saving results
    save(results, file=paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

}

save(pol.days, file="temp/polarization-by-day.rdata")

######################################################################
### FIGURE 2(a): political topics
######################################################################

xy.poli <- c()

for (j in 1:length(poli)){

    cat(j, " ")

    ## loading retweet data
    lst <- poli[j]
    cat(lst, " ")
    load(paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

    names(results) <- c("retweeted", "retweeter",
        "ideology_retweeter", "ideology_retweeted")

    ## summarizing
    new.xy <- expand_data(breaks=0.25)
    new.xy$candidate <- poli.labels[j]
    xy.poli <- rbind(xy.poli, new.xy)
}

library(scales)
library(ggplot2)

p <- ggplot(xy.poli, aes(x=y, y=x))
pq <- p + geom_tile(aes(fill=prop), colour="white") + 
        scale_fill_gradient(name="% of\ntweets", 
        low = "white", high = "black", 
        breaks=c(0, .0050, 0.010, 0.015, 0.02), limits=c(0, .021),
        labels=c("0.0%", "0.5%", "1.0%", "1.5%", ">2%")) +
        labs(y="Estimated Ideology of Retweeter", x="Estimated Ideology of Author") + 
        scale_y_continuous(expand=c(0,0), breaks=(-2:2), limits=c(-3, 3)) +
        scale_x_continuous(expand=c(0,0), breaks=(-2:2), limits=c(-3, 3)) +
        facet_wrap( ~ candidate, nrow=2) + 
        theme(panel.border=element_rect(fill=NA), panel.background = element_blank()) +
        coord_equal() 
pq

ggsave(filename="plots/figure2a.pdf", plot=pq, height=5, width=8)


######################################################################
### FIGURE 2(b): non-political topics
######################################################################

xy <- c()

for (j in 1:length(not.poli)){

    cat(j, " ")

    ## loading retweet data
    lst <- not.poli[j]
    cat(lst, " ")
    load(paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

    names(results) <- c("retweeted", "retweeter",
        "ideology_retweeter", "ideology_retweeted")

    ## summarizing
    new.xy <- expand_data(breaks=0.25)
    new.xy$candidate <- not.poli.labels[j]
    xy <- rbind(xy, new.xy)

}


p <- ggplot(xy, aes(x=y, y=x))
pq <- p + geom_tile(aes(fill=prop), colour="white") + 
        scale_fill_gradient(name="% of\ntweets", 
        low = "white", high = "black", 
        breaks=c(0, .0050, 0.010, 0.015, 0.02), limits=c(0, .021),
        labels=c("0.0%", "0.5%", "1.0%", "1.5%", ">2%")) +
        labs(y="Estimated Ideology of Retweeter", x="Estimated Ideology of Author") + 
        scale_y_continuous(expand=c(0,0), breaks=(-2:2), limits=c(-3, 3)) +
        scale_x_continuous(expand=c(0,0), breaks=(-2:2), limits=c(-3, 3)) +
        facet_wrap( ~ candidate, nrow=2) + 
        theme(panel.border=element_rect(fill=NA), panel.background = element_blank()) +
        coord_equal()
pq

ggsave(filename="plots/figure2b.pdf", plot=pq, height=5, width=8)