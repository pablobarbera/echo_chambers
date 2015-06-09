#==============================================================================
# 15-polarization-estimation.r
# Purpose: generate files necessary to reproduce Figures 3c and 3d of the paper
# Author: Pablo Barbera
#==============================================================================

######################################################################
### FIGURE 3(c): polarization by tweet collection
######################################################################

## list abbreviations and names
lists <- c("minimum_wage", "obama", "superbowl", "marriageequality", "budget",
  "newtown", "governmentshutdown", "oscars", "sotu", "syria",
  "olympics", "boston")
labels <- c("Minimum Wage", "2012 Election", "Super Bowl", "Marriage Equality",
	"Budget", "Newtown Shooting", "Govt. Shutdown", "Oscars 2014",
	"State of the Union", "Syria", "Winter Olympics", "Boston Marathon")
polarization <- c()

for (j in 1:length(lists)){

    cat(j, " ")

    ## loading retweet data
    lst <- lists[j]
    cat(lst, " ")
    load(paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

    names(results) <- c("retweeted", "retweeter",
        "ideology_retweeter", "ideology_retweeted")

    ## polarization values
    polarization <- rbind(polarization, 
        data.frame(collection = labels[j], 
            polar = mean(abs(results$ideology_retweeted)),
            stringsAsFactors=F))

}

polarization <- polarization[order(polarization$polar),]

polarization$collection <- factor(polarization$collection,
    levels=rev(polarization$collection))

library(ggplot2)
library(scales)
library(ggthemes)

p <- ggplot(polarization, aes(x=collection, y=polar, fill=polar, label=collection))
pq <- p + geom_bar(size=3, stat="identity") + theme_bw() + coord_flip() +
    scale_y_continuous("Aggregate Ideological Polarization", expand=c(0,0), limits=c(0, 1.7)) +
    geom_text(hjust=1.05, color="white", size=3) +
    theme(axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "none")
pq

ggsave(filename="plots/figure3c.pdf", plot=pq, height=4, width=3)


######################################################################
### FIGURE 3(d): polarization by day
######################################################################

# loading polarization estimate by day
# (generated in 13-heatmaps.r)
load("temp/polarization-by-day.rdata")

library(ggplot2)
library(RColorBrewer)
library(scales)
library(grid)

plot.data <- pol.days[pol.days$collection %in% c("2012 Election",
    "Marriage Equality", "Newtown Shooting", "Syria", "Boston Marathon"),]
plot.data <- plot.data[plot.data$day<30,]

plot.data$collection <- factor(plot.data$collection, levels=c("2012 Election",
    "Marriage Equality", "Newtown Shooting", "Syria", "Boston Marathon"))

colors <- c(rev(brewer.pal(5, "RdBu"))[1], rev(brewer.pal(5, "RdBu"))[5], "purple", "green", "orange")

p <- ggplot(plot.data, aes(x=day, y=polar, group=collection))
pq <- p + geom_point(aes(color=collection), alpha=1/2, size=1.5) + stat_smooth(aes(color=collection)) +
    scale_x_continuous(name="Days of Twitter Data Collection", limits=c(0,30), expand=c(0,0)) +
      theme_bw() + 
    scale_y_continuous("Polarization", limits=c(0.50,2.00), expand=c(0,0)) +
    theme(axis.line = element_line(colour = "black"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    legend.key.size=unit(0.5, "cm"),
    legend.key.height=unit(2,"line")) +
    scale_color_manual("Collection", breaks=c("2012 Election",
    "Marriage Equality", "Newtown Shooting", "Syria", "Boston Marathon"), 
        labels=c("2012\nElection",
    "Marriage\nEquality", "Newtown\nShooting", "Syria", "Boston\nMarathon"), values=colors)
pq

ggsave(filename="plots/figure3d.pdf", plot=pq, height=3.5, width=6)

