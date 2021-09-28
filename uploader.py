from DbConnector import DbConnector
from pickle import load
from dcs import *

connection = DbConnector()
db_connection = connection.db_connection
cursor = connection.cursor

users = []
activities = []

with open('preprocessed/users.pickle', 'rb') as f:
    users = load(f)

with open('preprocessed/activities.pickle', 'rb') as f:
    activities = load(f)

# for user in users:
#    query = "INSERT INTO user (id, has_labels) VALUES ('%s','%s')"
#    cursor.execute(
#        query % (user.id, 1 if user.has_labels else 0))
# db_connection.commit()
#
#added = []
#
# for activity in activities:
#    if activity.id in added:
#        continue
#    query = "INSERT INTO activity (id, user_id, transportation_mode, start_date_time, end_date_time) VALUES ('%s','%s','%s','%s','%s')"
#    cursor.execute(
#        query % (activity.id, activity.user_id, activity.transportations_mode, activity.start_date_time, activity.end_date_time))
#    added.append(activity.id)
# db_connection.commit()
#

finished = 0
cursor.execute('SELECT id, user_id FROM activity')
response = cursor.fetchall()

activity_ids = [[act_id[0], act_id[1]] for act_id in response]

for act in activity_ids:
    act[1] = str(act[1])
    while len(act[1]) < 3:
        act[1] = '0' + act[1]


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
            values.append((act[0], parts[0], parts[1], parts[3], parts[4], parts[5].replace(
                '-', '/').strip() + ' ' + parts[6].strip()))
        query = "INSERT INTO trackpoint (activity_id, lat, lon, altitude, date_days, date_time) VALUES (%s,%s,%s,%s,%s,%s)"
        cursor.executemany(query, values)
        # 39.984702,
        # 116.318417,
        # 0,
        # 492,
        # 39744.1201851852,
        # 2008-10-23,
        # 02:53:04
    finished += 1
    db_connection.commit()
    print(f'{finished} out of {len(activity_ids)} inserts.')
