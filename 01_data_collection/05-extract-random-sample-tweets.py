#==============================================================================
# 05-extract-random-sample-tweets.py
# Purpose: extracts a random sample of 2M tweets from each collection. [This
# will be used in the Supplementary Materials. Note that we apply activity filters 
# when extracting the tweets to make the process more efficient.]
# Author: Pablo Barbera
#==============================================================================

import json, sys, re, time
import pymongo, sys
from pymongo import Connection
from datetime import datetime, timedelta

## Export a random sample of 2M tweets, with user ID and
## whether tweet was retweeted, with the following format:
## "temp/tweets/COLLECTION_rs.csv"
k = 2000000 # size of random sample

# connecting to MongoDB
connection = Connection('localhost', 27011)

collections = ["BostonBombing", "GunControl", "MinimumWage", 
	"USElection", "superbowl", "MarriageEquality", "Budget", "Syria", 
	"GovernmentShutdown", "oscars", "SOTU",	"olympics"]

for col in collections:
	## STEP 1: extract all tweets matching conditions from DB
	db = connection[col]
	sp = db.tweets
	data = sp.find({},
		 ['timestamp', 'retweeted_status.user.id_str', 'user.id_str'])
	i = 0
	out = open('temp/tweets/' + col + '.csv', 'a')  
	for t in data:
		i += 1
		user_id = t['user']['id_str']
		if i % 10000 == 0:
			print str(i)
			print t['timestamp'].date()
		is_retweeted = 'retweeted_status' in t.keys()
		if is_retweeted:
			user_id = t['retweeted_status']['user']['id_str']
		out.write("{0},{1},{2}\n".format(
			user_id, is_retweeted, t['timestamp'].date()))
	out.close()
	## STEP 2: take random sample of size K
	infile = open('temp/tweets/' + col + '_rs.csv', 'r')  
	lines = infile.readlines()
	random.shuffle(lines)
	outfile = open('temp/tweets/' + col + '_rs.csv', 'w')  
	for line in lines[:k]:
		outfile.write("{0}".format(line))
	infile.close()
	outfile.close()

# There's probably more efficient ways of doing this, though...