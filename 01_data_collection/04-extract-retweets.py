#==============================================================================
# 04-extract-retweets.py
# Purpose: extracts retweets (retweter and retweeted) from each of the tweet
# collections. [Note that we apply activity filters when extracting the
# retweets to make the process more efficient.]
# Author: Pablo Barbera
#==============================================================================

import json, sys, re, time
import pymongo, sys
from pymongo import Connection
from datetime import datetime, timedelta

## Export retweets as edges, and store them in a different file
## for each collection and day, with the following format:
## "temp/retweets/retweets_list_COLLECTION_DATE.csv"
## Also note that ONLY automatic retweets are included.

# connecting to MongoDB
connection = Connection('localhost', 27011)

collections = ["BostonBombing", "GunControl", "MinimumWage", 
	"USElection", "superbowl", "MarriageEquality", "Budget", "Syria", 
	"GovernmentShutdown", "oscars", "SOTU",	"olympics"]

for col in collections:
	db = connection[col]
	sp = db.tweets
	# query only those tweets coming from users who passed our filter
	data = sp.find({'user.followers_count':{'$gte':25},
		'user.statuses_count':{'$gte':100},
		'user.friends_count':{'$gte':100},
		 'retweeted_status':{'$exists':True} })
	
	retweets = []
	old_date = str('a')
	i = 0
	
	for t in data:
		if i % 1000 == 0:
			print str(i)
			try:
				new_date = t['timestamp'].date()
			except:
				continue
			# when tweet date is new, open new file where tweets will be stored
			# (note that this assumes tweets are in order, which should almost always be the case!)
			if new_date is not old_date:
				print new_date
				outhandle = open('temp/retweets/retweets_list_' + col + '_' + str(new_date) + '.csv', 'a')
				for retweet in retweets:
					outhandle.write("{0},{1}\n".format(retweet[0], retweet[1]))
				outhandle.close()  
				retweets = []          
		try:
			retweeter = t['user']['id_str']
			retweeted = t['retweeted_status']['user']['id_str']
		except:
			continue
		retweets.append([retweeter, retweeted])
		i += 1
