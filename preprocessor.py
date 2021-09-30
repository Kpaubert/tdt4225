from dataclasses import dataclass
from pickle import dump
from dcs import *
import time
import os

user_ids_with_labels = []
users = []
activities = []

trackpoints_omitted = 0
trackpoints_total = 0

activities_total = 0
activities_omitted_labels = 0
activities_omitted_num_trackpoints = 0

with open('dataset\\dataset\\labeled_ids.txt', 'r') as f:
    user_ids_with_labels = [id.strip() for id in f.readlines()]


# print(user_ids_with_labels)
for root, dirs, files in os.walk("dataset\\dataset\\Data", topdown=False):
    for name in dirs:
        if name != 'Trajectory':
            users.append(User(name, name in user_ids_with_labels))

    for file in [f for f in files if f.endswith('.plt')]:
        activities_total += 1
        current_path = os.path.join(root, file)
        user_id = current_path.split('\\')[3]

        if user_id in user_ids_with_labels:
            with open(current_path, 'r') as f:
                file_content = f.readlines()
                trackpoints_total += int(len(file_content[6:]))
                if len(file_content[6:]) > 2500:
                    trackpoints_omitted += int(len(file_content[6:]))
                    activities_omitted_num_trackpoints += 1
                    continue
                first_tp = file_content[6].split(',')
                start_date_time = first_tp[-2].replace('-', '/').strip() + \
                    ' ' + first_tp[-1].strip()
                last_tp = file_content[-1].split(',')
                end_date_time = last_tp[-2].replace('-',
                                                    '/').strip() + ' ' + last_tp[-1].strip()
                label_file = root.replace('\\Trajectory', '\\labels.txt')
                with open(label_file, 'r') as lf:
                    lf_file_content = lf.readlines()[1:]
                    found_match = False
                    for t in lf_file_content:
                        timeparts = t.split('\t')
                        if start_date_time == timeparts[0] and end_date_time == timeparts[1]:
                            activity_id = file.replace('.plt', '')
                            activity = Activity(activity_id, user_id,
                                                timeparts[2], start_date_time, end_date_time)

                            activities.append(activity)
                            found_match = True
                            break
                    if not found_match:
                        activities_omitted_labels += 1
                        trackpoints_omitted += int(len(file_content[6:]))

        else:
            with open(current_path, 'r') as f:
                file_content = f.readlines()
                trackpoints_total += int(len(file_content[6:]))
                if len(file_content[6:]) > 2500:
                    trackpoints_omitted += int(len(file_content[6:]))
                    activities_omitted_num_trackpoints += 1
                    continue
                first_tp = file_content[6].split(',')
                start_date_time = first_tp[-2].replace('-', '/').strip() + \
                    ' ' + first_tp[-1].strip()
                last_tp = file_content[-1].split(',')
                end_date_time = last_tp[-2].replace('-',
                                                    '/').strip() + ' ' + last_tp[-1].strip()
                activity_id = file.replace('.plt', '')
                activity = Activity(activity_id, user_id,
                                    None, start_date_time, end_date_time)

                activities.append(activity)


print(len(users))

print(f'Trackpoints total: {trackpoints_total}')
print(f'Trackpoints omitted: {trackpoints_omitted}')

print(f'Activities total: {activities_total}')
print(f'Activities omitted due to labels: {activities_omitted_labels}')
print(
    f'Activities omitted due to number of trackpoints: {activities_omitted_num_trackpoints}')

user_ids = [user.id for user in users]
activities_valid_user_id = len(
    [0 for activity in activities if activity.user_id in (user_ids)])

print(
    f'Number of activities without valid user_id: {activities_valid_user_id}')

"""
with open('preprocessed/users.pickle', 'wb+') as f:
    print(f'Dumping {len(users)} users.')
    dump(users, f)

with open('preprocessed/activities.pickle', 'wb+') as f:
    print(f'Dumping {len(activities)} activities.')
    dump(activities, f)
"""
