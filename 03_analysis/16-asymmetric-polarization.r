#==============================================================================
# 16-asymmetric-polarization.r
# Purpose: generate files necessary to reproduce Figure 4 of the paper
# Author: Pablo Barbera
#==============================================================================

######################################################################
### preparing data frame
######################################################################

lists <- c("minimum_wage", "obama", "superbowl", "marriageequality", "budget",
  "newtown", "governmentshutdown", "oscars", "sotu", "syria",
  "olympics", "boston")
labels <- c("Minimum Wage", "2012 Election", "Super Bowl", "Marriage Equality",
	"Budget", "Newtown Shooting", "Gov. Shutdown", "Oscars 2014",
	"State of the Union", "Syria", "Winter Olympics", "Boston Marathon")

min <- -3.5
max <- 3.5
breaks <- 0.25

library(reshape)

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

xy <- c()

for (j in 1:length(lists)){

    cat(j, " ")

    ## loading retweet data
    lst <- lists[j]
    load(paste0("temp/retweets_ideology/rt_results_", lst, '.rdata'))

    names(results) <- c("retweeted", "retweeter",
        "ideology_retweeter", "ideology_retweeted")

    ## summarizing
    new.xy <- expand_data(breaks=0.50, min=-3, max=3)
    new.xy$candidate <- labels[j]
    xy <- rbind(xy, new.xy)

}

######################################################################
### computing poisson regressions
######################################################################

xy$librt <- ifelse(xy$x<0 & xy$y>0, 1, 0)
xy$conrt <- ifelse(xy$x>0 & xy$y<0, 1, 0)

coefs <- c()

for (j in 1:length(lists)){

	cat(j, " ")

	reg <- glm(value ~ factor(x) + factor(y) + conrt + librt,
		family="poisson", data=xy[xy$candidate==labels[j],])
	cis <- exp(confint(reg, level=.999))
	coefs <- rbind(coefs,
		data.frame(
			coef = c(exp(coef(reg)["conrt"]),
				exp(coef(reg)["librt"])),
			coef.lo = cis[c("conrt", "librt"),1],
			coef.hi = cis[c("conrt", "librt"),2],
			topic = labels[j],
			group = c("Conservatives", "Liberals")))
}

not.poli.labels <- c("Super Bowl", "Newtown Shooting", "Oscars 2014", "Syria",
    "Winter Olympics", "Boston Marathon")
poli.labels <- c("Minimum Wage", "Marriage Equality", "Budget",
    "Gov. Shutdown", "State of the Union", "2012 Election")
			
coefs$topic <- factor(coefs$topic, levels=c(not.poli.labels, poli.labels))
coefs$group <- factor(coefs$group, levels=c("Liberals", "Conservatives"))


library(ggplot2)
library(scales)
library(ggthemes)

p <- ggplot(coefs, aes(y=coef, x=topic))
pq <- p + geom_point(aes(color=group, shape=group), size=2) +
    scale_color_manual(values=c("darkblue", "red1")) +
    geom_linerange(aes(ymin=coef.lo, ymax=coef.hi, color=group), size=.8) + 
    scale_shape_manual(values=c(16, 15)) +
    scale_y_continuous("Estimated Rate of Cross-Ideological Retweeting\n(Exponentiated Coefficient from Poisson Regression)",
        limits=c(0, 1)) +
    theme_bw() +
    coord_flip() +
    theme(axis.ticks.y=element_blank(), axis.title.y=element_blank(),
        legend.title=element_blank()) +
    geom_hline(yintercept=1, linetype=5, color="grey50") +
    geom_vline(xintercept=6.5, color="grey50")
pq

ggsave(pq, file="plots/figure4.pdf", height=4, width=8)





