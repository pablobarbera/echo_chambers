#==============================================================================
# 02-aggregagate-user-data.py
# Purpose: takes tweets collections and aggregates user data (e.g. followers;
# number of tweets in each collection, etc), necessary to prepare list of 
# users that will be included in the analysis. Note that here we're already
# applying the spam and activity filters.
# Author: Pablo Barbera
#==============================================================================

import json, sys, re, time
import pymongo, sys
from pymongo import Connection
from datetime import datetime, timedelta

## Export user data from a collection, aggregated at the user
## level (note that for users with more than one tweets, only
## their most recent user data is kept)
## Data will be stored in separate files for each collection,
## with the format "temp/user_list_COLLECTION_NAME"

def export_userlist(collection_name):
    data = sp.find({'user.followers_count':{'$gte':25},
        'user.statuses_count':{'$gte':100},
        'user.friends_count':{'$gte':100} },
        ['user.id_str', 'user.followers_count', 'user.lang', 'user.location'])
    print "Counting tweets..."    
    tw = data.count()   
    i = 0
    user_list = {}
    user_data = {}
    print "Extracting data..."  
    for t in data:
        i += 1
        if i % 1000 == 0:
            print(str(i) + '/' + str(tw))
        try:
            user_id = t['user']['id_str']
        except:
            continue
        user_list[user_id] = 1 + user_list.get(user_id,0)
        user_data[user_id] = "{0},{1},{2},{3},{4}".format(
            t['user']['id_str'],
            t['user']['followers_count'],
            t['user']['lang'],
            t['user']['location'].replace(",", "").replace("\n","").encode("utf-8"),
            user_list[user_id]) 
    outhandle = open('temp/user_list_' + collection_name +'.csv', "w")
    file_key = "id_str,followers_count,lang,location,tweets"
    outhandle.write("{0}\n".format(file_key))
    for user, user_string in user_data.items():
        outhandle.write("{0}\n".format(user_string))
### Now we apply the function to all our collections

connection = Connection('localhost', 27011)

collections = ["BostonBombing", "GunControl", "MinimumWage", 
	"USElection", "superbowl", "MarriageEquality", "Budget", "Syria", 
	"GovernmentShutdown", "oscars", "SOTU",	"olympics"]

for col in collections:
	db = connection[col]
	sp = db.tweets
	export_userlist(col)

### The final step is to aggregate all the user-level datasets into
### a single dataset

users = {}
tweets = {}

for col in collections:
	print col
	tweets[col] = {}
	d = open('temp/user_list_' + col + '.csv', 'r')
	d.readline()
	for line in d:
		try:
			w = line.rstrip().split(",")
		except:
			continue
		try:
			if w[2] == 'en':
				users[w[0]] = ",".join(w[1:4])
				tweets[col][w[0]] = w[4]
		except:
			continue

outhandle = open('temp/user_list_full.csv', 'w')
ulist = users.keys()
file_key = 'id_str,followers_count,lang,location,' + ",".join(lists)
outhandle.write(file_key + "\n")
for u in ulist:
	tw = []
	for l in lists:
		tw.append(tweets[l].get(u, '0'))
	if tw.count('0') == 11:
		continue
	lw = u + "," + users[u] + ","
	lw = lw + ",".join(tw)
	outhandle.write(lw + "\n")

outhandle.close()






