from DbConnector import DbConnector
from pickle import load
from dcs import *

connection = DbConnector()
client = connection.client
db = connection.db

users = []
activities = []

with open('preprocessed/users.pickle', 'rb') as f:
    users = load(f)

with open('preprocessed/activities.pickle', 'rb') as f:
    activities = load(f)

# users_to_be_uploaded = [
#    {"_id": user.id, "has_labels": user.has_labels} for user in users]
#
# db['user'].insert_many(users_to_be_uploaded)
#
# print('done users')
#

# added = []
#
# activities_to_be_inserted = [{
#    "_id": a.id,
#    "user_id": a.user_id,
#    "transportation_mode": a.transportations_mode,
#    "start_date_time": a.start_date_time,
#    "end_date_time": a.end_date_time}
#    for a in activities]
#
# for activity in activities_to_be_inserted:
#    if activity["_id"] in added:
#        continue
#    db['activity'].insert_one(activity)
#    added.append(activity["_id"])

activity_ids = []
for activity in db['activity'].find():
    activity_ids.append([activity["_id"], activity["user_id"]])

finished = 0

for act in activity_ids:
    with open(f'dataset\\dataset\\Data\\{act[1]}\\Trajectory\\{act[0]}.plt') as f:
        print(
            f'Starting with:\tdataset\\dataset\\Data\\{act[1]}\\Trajectory\\{act[0]}.plt')
        trackpoints = f.readlines()[6:]
        if len(trackpoints) > 2500:
            continue
        values = []
        for tp in trackpoints:
            parts = tp.split(',')
            current_tp = {
                "activity_id": act[0],
                "lat": parts[0],
                "lon": parts[1],
                "altitude": parts[3],
                "date_days": parts[4],
                "date_time": parts[5].replace('-', '/').strip() + ' ' + parts[6].strip()
            }
            values.append(current_tp)
        db['trackpoint'].insert_many(values)
    finished += 1
    print(f'Finished {finished} out of {len(activity_ids)} inserts.')
