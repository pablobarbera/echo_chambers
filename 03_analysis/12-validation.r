#==============================================================================
# 12-validation.r
# Purpose: validate estimation results
# Author: Pablo Barbera
#==============================================================================

######################################################################
### FIGURE 1(a): comparison with statewide ideology averages
######################################################################

# loading estimation results
load("output/estimates.rdata")

# loading user data
load("temp/user_list_final.rdata")
geo <- users[users$country=="United States" & !is.na(users$country),]
names(geo)[1] <- "id"

# merging
users <- merge(estimates[c("id", "ideology")], geo[,c("id", "state")])
users <- users[users$state %in% state.name,]

# aggregating at the state level
results <- aggregate(users$ideology, by=list(state=users$state), FUN=median)
names(results)[2] <- "twitter"

# reading state-level variables and merging
df <- read.csv("input/state-level-variables.csv", stringsAsFactors=F)
df <- merge(df, results)

# correlations
cor(df$twitter, df$opinion) # -0.871
cor(df$twitter, df$obama) # -0.817

# generating Figure 1a
df$state.abb <- state.abb # adding state abbreviations
df$opinion <- df$opinion/100
set.seed(123)
df$jitter <- df$opinion + runif(length(df$opinion), -.005, .005)
cor(df$twitter, df$jitter) # we add some minor jitter to improve visualization

library(ggplot2)
library(scales)
library(ggthemes)

p <- ggplot(df, aes(x=twitter, y=jitter, label=state.abb))
pq <- p + geom_text(size=1.5) + stat_smooth(se=FALSE, method="lm", color="red") +
    scale_x_continuous("Ideology of Median Twitter User in Each State", limits=c(-.61, 1.5)) +
    scale_y_continuous("Mean Liberal Opinion (Lax and Phillips, 2012)", label=percent) + #, limits=c(0.38, 0.55)) +
    geom_rangeframe(sides="bl", data=data.frame(twitter=c(-0.50, 1.50), jitter=c(0.40, .55), state.abb=NA)) + theme_tufte()
pq

ggsave(filename="plots/figure1a.pdf", plot=pq, height=4, width=4)


######################################################################
### FIGURE 1(b): comparison with roll-call votes ideology estimates
######################################################################

# loading results
load("output/ca-first-stage.rdata")

df <- data.frame(screen_name = res$colnames,
    svd.phi = res$colcoord[,1], merge = tolower(res$colnames),
    stringsAsFactors=F)
df$merge <- tolower(df$screen_name)

## loading elite data and merging with Congress estimates
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

## merging
elite <- merge(elite, df)
d <- elite[!is.na(elite$idealPoint),]

# generating Figure 1b

library(ggplot2)
library(scales)
library(ggthemes)

p <- ggplot(d, aes(y=idealPoint, x=svd.phi, label=party))
pq <- p + geom_text(size=1.5, aes(color=party)) +
        scale_x_continuous("Estimated Twitter Ideal Points", limits=c(-1.7, 1.7), breaks=c(-1.5, 0, 1.5)) +
        scale_y_continuous("Ideology Estimates Based on Roll-Call Votes\n(Clinton et al, 2004)", breaks=c(-2, -1, 0, 1, 2)) +
        scale_color_manual(name="Political Party", values=c("blue", "darkgreen", "red"), guide="none") +
        theme(panel.border=element_rect(fill=NA), panel.background = element_blank(), 
            legend.position="none") 
pq

c1 <- round(cor(d$idealPoint[d$party=="D"], 
    d$svd.phi[d$party=="D"]), 2)
c2 <- round(cor(d$idealPoint[d$party=="R"], 
    d$svd.phi[d$party=="R"]), 2)

a1 <- data.frame(svd.phi = -1.4, idealPoint=-2.5, 
            party=as.character(paste0("rho[D]==", c1)))
a2 <- data.frame(svd.phi = 1.3, idealPoint=2, 
            party=as.character(paste0("rho[R]==", c2)))
a <- rbind(a1, a2)

pq <- pq + geom_text(data=a, size=3, parse=TRUE) +
     geom_rangeframe(sides="bl", data=data.frame(idealPoint=c(-2, 2), svd.phi=c(-1.5, 1.5), party=NA)) + theme_tufte()

pq

ggsave(filename="plots/figure1b.pdf", plot=pq, height=4, width=4)


d$party <- factor(d$party)
levels(d$party) <- c("Democrats", "Independents", "Republicans")

p <- ggplot(d, aes(y=idealPoint, x=svd.phi, shape=party, color=party))
pq <- p + geom_point(size=1.5, aes(shape=party, color=party)) +
        scale_shape_manual(values=c(4, 0, 1)) +
        scale_x_continuous("Estimated Twitter Ideal Points", limits=c(-1.7, 1.7), breaks=c(-1.5, 0, 1.5)) +
        scale_y_continuous("Ideology Estimates Based on Roll-Call Votes\n(Clinton et al, 2004)", breaks=c(-2, -1, 0, 1, 2)) +
        #scale_color_manual(values=c("blue", "darkgreen", "red")) +
        theme(panel.border=element_rect(fill=NA), panel.background = element_blank()) 
pq

a1 <- data.frame(svd.phi = -1.4, idealPoint=-2.5, 
            label=as.character(paste0("rho[D]==", c1)), party="Democrats")
a2 <- data.frame(svd.phi = 1.3, idealPoint=2, 
            label=as.character(paste0("rho[R]==", c2)), party="Republicans")
a <- rbind(a1, a2)

pq <- pq + annotate("text", y=a1$idealPoint, x=a1$svd.phi, label=as.character(a1$label), size=3, parse=TRUE) +
            annotate("text", y=a2$idealPoint, x=a2$svd.phi, label=as.character(a2$label), size=3, parse=TRUE) +
     geom_rangeframe(sides="bl", data=data.frame(idealPoint=c(-2, 2), svd.phi=c(-1.5, 1.5), party=NA), guide="none") + theme_tufte() +
     theme(legend.position=c(0.18, 0.90),  legend.title=element_blank()) +
    guides(colour = guide_legend(override.aes = list(linetype=c(0,0,0), shape=c(4,0,1), size=c(3,3,3))))

pq

ggsave(filename="plots/figure1b_revised.pdf", plot=pq, height=4, width=4)

######################################################################
### FIGURE 1(c): comparison with voting registration records
######################################################################

# reading voter matches
voters <- read.csv("input/voter-matches.csv", stringsAsFactors=F)

# loading estimation results
load("output/estimates.rdata")


# merging with ideology estimates
voters <- merge(voters, estimates[,c("id", "ideology")])

# Generating Figure 1.c
voters$party <- factor(voters$party)
levels(voters$party) <- c("Registered Democrats", "Registered Republicans")

library(ggplot2)
library(scales)
library(ggthemes)

p <- ggplot(voters, aes(x=party, y=ideology))
pq <- p + geom_boxplot(outlier.colour="grey", outlier.size=1) +
    scale_y_continuous("Twitter-Based Ideology Estimates", limits=c(-3, 3)) +
        theme(panel.border=element_rect(fill=NA), 
            panel.background = element_blank(), legend.position="none",
            panel.grid.minor=element_blank()) +
    geom_hline(aes(yintercept=0), linetype=3) + coord_flip() + theme(axis.title.y=element_blank())
pq

# estiamating accuracy
tab <- table(voters$ideology>0.5, voters$party=="Registered Republicans")
sum(tab[1,1], tab[2,2]) / sum(tab) ## 77% accuracy

ggsave(filename="plots/figure1c_revised.pdf", plot=pq, 
        height=2.5, width=8)





