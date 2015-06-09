Replication materials: _Is Online Political Communication More Than an Echo Chamber?_
--------------

This github repository contains the replication code for the paper "Tweeting from Left to Right: Is Online Political Communication More Than an Echo Chamber?", forthcoming in _Psychological Science_, authored by [Pablo Barbera](http://www.pablobarbera.com), [John T. Jost](http://psych.nyu.edu/jost/), [Jonathan Nagler](http://politics.as.nyu.edu/object/JonathanNagler), [Joshua Tucker](https://files.nyu.edu/jat7/public/), and [Richard Bonneau](http://bonneaulab.bio.nyu.edu/), all members of the [Social Media and Political Participation (SMaPP) Lab](http://smapp.nyu.edu/) at NYU.

> __Abstract:__
> We estimated ideological preferences of 3.8 million Twitter users and, using a dataset of 150 million tweets concerning 12 political and non-political issues, explored whether online communication resembles an "echo chamber" due to selective exposure and ideological segregation or a "national conversation." We observed that information was exchanged primarily among individuals with similar ideological preferences for political issues (e.g., presidential election, government shutdown) but not for many other current events (e.g., Boston marathon bombing, Super Bowl). Discussion of the Newtown shootings in 2012 reflected a dynamic process, beginning as a "national conversation" before being transformed into a polarized exchange. With respect to political and non-political issues, liberals were more likely than conservatives to engage in cross-ideological dissemination, highlighting an important asymmetry with respect to the structure of communication that is consistent with psychological theory and research. We conclude that previous work may have overestimated the degree of ideological segregation in social media usage.

This README files provides an overview of the replications materials for the article. The [Data](#https://github.com/pablobarbera/echo_chambers#data) section describes the datasets required for the analysis, as well as those generated after the estimation. Note that the data files are not in this repository; they are only available in [Dataverse](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/F9ICHH). The [Code](#https://github.com/pablobarbera/echo_chambers#code) section summarizes the purpose of each R or python script. The [Figures](#https://github.com/pablobarbera/echo_chambers#figures) specifies which specific script generates the tables and figures in the paper.

## Data

Our datasets are divided in four different folders (zipped in Dataverse):

- `tweet-collections/` contains the list of tweet IDs of the nearly 150 million tweets we use in our analysis. In compliance with Twitter's Terms of Service, we cannot share the full text of the tweets, but we provide the code in `01_data_collection/01-collect-tweets.r` shows how to re-generate this dataset directly from the Twitter API (it may take a while, though).
- `input/` contains datasets that we generated prior to the analysis, such as the list of political accounts we consider (`elites-data.csv`), the ideal point estimates for members of Congress based on roll-call votes and estimated by Simon Jackman (`house.csv` and `senate.csv`), and the matches of Twitter IDs with the voter registration files in five different states (`voter-matches.csv`).
- `temp/` contains datasets generated during the analysis, which we also provide here to facilitate replication of the figures in our analysis. We refer to the code for more information about these.
- `output/` contains datasets with the raw results of our estimation model, and the ideology scores for political accounts and users in our sample (`estimates.rdata`).

__Note__: All files containing personal information about individual users have been anonymized for privacy reasons, and the original User IDs have been replaced by randomly-generated ID numbers. The complete version of all datasets is available upon request.

## Code

We provide all the code necessary to collect, process, and analyze the data, and to generate all the tables and figures in the text of the article. To facilitate replication, we have also divided the code in three different folders (zipped in Dataverse):

- `01_data_collection/`: here we indicate the R packages necessary to run the rest of the code (`00-install-packages.r`), how we collected the tweets and how our collections could be re-built (`01-collect-tweets.r`) and the process we followed to extract the user-level data from our collections (`02-aggregate-user-data.py`) and to apply the spam, location, and activity filters (`03-spam-location-activity-filter.r`). We also include the scripts we used to reorganize our datasets to make it easier to work with data at the retweet level (`04-extract-retweets.py`), and at the tweet level using a random sample of tweets (`05-extract-random-sample-tweets.py`). Finally, here we also illustrate how to collect followers lists, which we will use in our analysis to estimate political ideology (`06-collect-followers.r`).

- `02_estimation/`: the scripts in this folder run the analysis that is explained in more detail in Section 1 of the Supplementary Materials. First, we construct the adjacency matrix indicating what users follow our list of political accounts (`07-create-initial-matrix.r`), then we run the first stage of our method (`08-first-stage.r`), after which we add additional data (`09-collect-additional-followers.r`) and construct the full adjacency matrix (`10-create-final-matrix.r`), which is then used in the final stage of the method (`11-second-stage.r`).

- `03_analysis/`: here we provide the code that replicates the figures in the paper:
	* `12-validation.r` generates Figures 1a (comparing statewide averages of ideology with survey-based measures of ideology), 1b (comparing our estimates for Members of Congress with ideology estimates from roll-call votes), and 1c (comparing our estimates with party registration files in 5 states).
	* `13-heatmaps.r` generates Figures 3a and 3b, visualizing ideological polarization in retweeting behavior.
	* `14-network-visualization.r` produces the files necessary to generate the network visualization in Figures 3a and 3b using Gephi (see the script for more details).
	* `15-polarization-estimation.r` generates Figures 3c and 3d (aggregate ideological polarization by collection and day).
	* `16-asymmetric-polarization.r` generates Figure 4 (liberal-conservative asymmetries in cross-ideological retweeting for twelve different communication topics)











