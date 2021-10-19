import sys
from DbConnector import DbConnector
import itertools
import datetime
from haversine import haversine
import pymongo
from math import isclose

connection = DbConnector()
client = connection.client
db = connection.db

NUM_USERS = 182


def sort_dict_desc_by_value(inDict):
    return {k: v for k, v in sorted(
        inDict.items(), key=lambda item: item[1], reverse=True)}


def sub1() -> None:
    """
        Gets the count of the different collections.
    """
    print(f'Number of users:\n\t{db["user"].count()}')
    print(f'Number of activities:\n\t{db["activity"].count()}')
    print(f'Number of trackpoints:\n\t{db["trackpoint"].count()}')


def sub2() -> None:
    """
        Min, avg and max activites across all users.
    """
    activities = list(db["activity"].find())
    num_acts_per_user = {}
    for act in activities:
        if act["user_id"] in num_acts_per_user:
            num_acts_per_user[act["user_id"]] += 1
        else:
            num_acts_per_user[act["user_id"]] = 1
    counts_as_list = [val for _, val in num_acts_per_user.items()]
    print(f'Min activities:\n\t{min(counts_as_list)}.')
    print(f'Avg activities:\n\t{sum(counts_as_list)/len(counts_as_list)}.')
    print(f'Max activities:\n\t{max(counts_as_list)}.')


def sub3() -> None:
    """
        Top 10 users with the most activities.
    """
    activities = list(db["activity"].find())
    num_acts_per_user = {}
    for act in activities:
        if act["user_id"] in num_acts_per_user:
            num_acts_per_user[act["user_id"]] += 1
        else:
            num_acts_per_user[act["user_id"]] = 1
    sorted_by_num_activities = sort_dict_desc_by_value(num_acts_per_user)
    print('Top 10 users with most amount of activities:')
    for k, v in itertools.islice(sorted_by_num_activities.items(), 10):
        print(f'\tUser {k} has {v} activities.')


def sub4() -> None:
    """
        Number of users that have at least one activity
        that starts on one day, and ends on another.
    """
    def same_day(act) -> bool:
        start_date_time = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S')
        end_date_time = datetime.datetime.strptime(
            act["end_date_time"], '%Y/%m/%d %H:%M:%S')
        return start_date_time.day == end_date_time.day
    activities = list(db["activity"].find())
    users_with_diff_day = []
    for act in activities:
        if not same_day(act) and act["user_id"] not in users_with_diff_day:
            users_with_diff_day.append(act["user_id"])
    print(
        f'Number of users with activities that span different days:\n\t{len(users_with_diff_day)}')


def sub5() -> None:
    """
        Number of duplicate activities.
    """
    activities = list(db["activity"].find())
    activities_as_set = set([act["_id"] for act in activities])
    print(
        f'Number of activities:\n\t{len(activities)}.\nNumber of activities after removing dupes:\n\t{len(activities_as_set)}.')
    print(f'\tThere are {len(activities)-len(activities_as_set)} duplicates.')


def sub6() -> None:
    """
        User_id's of people who have been closer than 100m
        of point (39.97548, 116.33031) within 60 seconds of
        2008-08-24 15:38:00.
    """
    infection_point = (39.97548, 116.33031)
    time_of_infection = datetime.datetime.strptime(
        "2008-08-24 15:38:00", '%Y-%m-%d %H:%M:%S')
    one_min_timedelta = datetime.timedelta(minutes=1)

    def infection_within_activity(act) -> bool:
        start_date_time = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S') - one_min_timedelta
        end_date_time = datetime.datetime.strptime(
            act["end_date_time"], '%Y/%m/%d %H:%M:%S') + one_min_timedelta
        return start_date_time <= time_of_infection <= end_date_time

    activities = list(db["activity"].find())

    time_matched_activities = list(
        filter(infection_within_activity, activities))

    print('Infected users:')
    for act in time_matched_activities:
        trackpoints = list(db["trackpoint"].find({"activity_id": act["_id"]}))
        for trackpoint in trackpoints:
            trackpoint_point = (
                float(trackpoint["lat"]), float(trackpoint["lon"]))
            distance_km = haversine(trackpoint_point, infection_point)
            if distance_km < 0.1:
                print(
                    f'\tUser {act["user_id"]} was within 100 meters ({distance_km * 1000} meters) of infection point at {trackpoint["date_time"]}.')
                break


def sub7() -> None:
    """
        Users that have never taken a taxi.
    """
    def activity_is_taxi(act) -> bool:
        return act["transportation_mode"] == "taxi\n"

    activities = list(db["activity"].find())

    unique_taxi_users = set([act["user_id"]
                             for act in list(filter(activity_is_taxi, activities))])
    print('For the sake of brevity, we list users who have taken a taxi.')
    print(
        f'There are {NUM_USERS - len(unique_taxi_users)} users who have never taken a taxi.')
    print('Users who have taken taxi:')
    for uid in unique_taxi_users:
        print(f'\t{uid}')


def sub8() -> None:
    """
        List of transportation modes, and how many distinct
        users they have.
    """
    transportation_modes_with_count = {}
    activities = list(db["activity"].find())
    for act in activities:
        if act["transportation_mode"] is None:
            continue
        if act["transportation_mode"].strip() in transportation_modes_with_count:
            transportation_modes_with_count[act["transportation_mode"].strip()].append(
                act["user_id"])
        else:
            transportation_modes_with_count[act["transportation_mode"].strip()] = [
                act["user_id"]]
    print('Distinct transportation modes with count:')
    for k, v in transportation_modes_with_count.items():
        print(f'\t{k} has been used by {len(set(v))} users.')


def sub9a() -> None:
    """
        Year and month with the most activities
    """
    monthyear_with_count = {}
    activities = list(db["activity"].find())
    for act in activities:
        current_date = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S')
        current_yearmonth = f'{current_date.year}/{current_date.month}'
        if current_yearmonth in monthyear_with_count:
            monthyear_with_count[current_yearmonth] += 1
        else:
            monthyear_with_count[current_yearmonth] = 1

    sorted_by_num_activities = sort_dict_desc_by_value(monthyear_with_count)

    print(
        f'{list(sorted_by_num_activities.keys())[0]} has the most activities with {list(sorted_by_num_activities.values())[0]}.')


def sub9b() -> None:
    """
        User with the most activities in the month and year
        given by 9a (2008/11).
    """
    def is_2008_11(act):
        act_date = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S')
        return act_date.year == 2008 and act_date.month == 11

    users_with_activity_count = {}
    users_with_hours_registered = {}
    activities = list(db["activity"].find())

    valid_activities = filter(is_2008_11, activities)

    for act in valid_activities:
        start_date_time = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S')
        end_date_time = datetime.datetime.strptime(
            act["end_date_time"], '%Y/%m/%d %H:%M:%S')
        if act["user_id"] in users_with_activity_count:
            users_with_activity_count[act["user_id"]] += 1
            users_with_hours_registered[act["user_id"]
                                        ] += end_date_time - start_date_time
        else:
            users_with_activity_count[act["user_id"]] = 1
            users_with_hours_registered[act["user_id"]
                                        ] = end_date_time - start_date_time

    sorted_by_act_count = sort_dict_desc_by_value(users_with_activity_count)
    print(f'User ID\t\tActivities\tTime registered (days, H:M:S)')
    for k, v in sorted_by_act_count.items():
        users_with_hours_registered
        print(f'{k}\t\t{v}\t\t{users_with_hours_registered[k]}')


def sub10() -> None:
    """
        Total distance walked us 2008 by user_id 112.
    """
    def is_2008(act):
        start_date_time = datetime.datetime.strptime(
            act["start_date_time"], '%Y/%m/%d %H:%M:%S')
        return start_date_time.year == 2008

    km_walked_by_112 = 0
    acts_with_trackpoints = {}
    activities = list(db["activity"].find({"user_id": "112"}))
    filtered_activities = list(filter(is_2008, activities))
    print(
        f'Fetching trackpoints from {len(filtered_activities)} activities (this may take some time).')
    for act in filtered_activities:
        acts_with_trackpoints[act["_id"]] = list(
            db["trackpoint"].find({"activity_id": act["_id"]}).sort("date_days", pymongo.ASCENDING))
    print('Done fetching all batches.')
    for act_id, trackpoints in acts_with_trackpoints.items():
        km_walked_by_112 += sum([haversine((float(trackpoints[i]["lat"]), float(trackpoints[i]["lon"])), (float(trackpoints[i+1]["lat"]), float(trackpoints[i+1]["lon"])))
                                 for i in range(len(trackpoints) - 1)])

    print(f'Length walked by 112:\n\t{km_walked_by_112}km')


def sub11() -> None:
    """
        Top 20 users who have gained the most meters.
    """
    activities = list(db["activity"].find())
    tot_len = len(activities)
    current = 0

    users_with_meters_ascended = {}
    for act in activities:
        current += 1
        ascended = 0
        current_trackpoints = list(db["trackpoint"].find(
            {"activity_id": act["_id"]}).sort("date_days", pymongo.ASCENDING))
        for i in range(len(current_trackpoints) - 1):
            curr_alt = float(current_trackpoints[i]["altitude"])
            next_alt = float(current_trackpoints[i+1]["altitude"])
            if not isclose(curr_alt, -777) and not isclose(next_alt, -777) and next_alt > curr_alt:
                ascended += ((next_alt - curr_alt) * 0.3048)

        if act["user_id"] in users_with_meters_ascended:
            users_with_meters_ascended[act["user_id"]] += ascended
        else:
            users_with_meters_ascended[act["user_id"]] = ascended
        print(f'Finished {current}\tout of {tot_len}')

    sorted_by_meters_gained = sort_dict_desc_by_value(
        users_with_meters_ascended)

    print('User ID\t\tMeters gained')
    STOP_AT = 20
    for_counter = 0
    for k, v in sorted_by_meters_gained.items():
        print(f'{k}\t\t{v}')
        if for_counter >= STOP_AT:
            break
        for_counter += 1


def sub12() -> None:
    """
        Count of invalid activities per user.
    """
    activities = list(db["activity"].find())
    users_with_num_invalid_acts = {}
    tot_len = len(activities)
    current = 0

    for act in activities:
        current += 1
        current_trackpoints = list(db["trackpoint"].find(
            {"activity_id": act["_id"]}).sort("date_days", pymongo.ASCENDING))
        for i in range(len(current_trackpoints) - 1):
            curr_time = datetime.datetime.strptime(
                current_trackpoints[i]["date_time"], '%Y/%m/%d %H:%M:%S')
            next_time = datetime.datetime.strptime(
                current_trackpoints[i+1]["date_time"], '%Y/%m/%d %H:%M:%S')
            if (next_time-curr_time).seconds >= 300:
                if act["user_id"] in users_with_num_invalid_acts:
                    users_with_num_invalid_acts[act["user_id"]] += 1
                else:
                    users_with_num_invalid_acts[act["user_id"]] = 1
                break
        print(f'Finished {current}\tout of {tot_len}')

    sorted_by_invalid_count = sort_dict_desc_by_value(
        users_with_num_invalid_acts)

    print('User ID\t\tInvalid activites')
    for k, v in sorted_by_invalid_count.items():
        print(f'{k}\t\t{v}')


def main():
    funcs = {
        '1': sub1,
        '2': sub2,
        '3': sub3,
        '4': sub4,
        '5': sub5,
        '6': sub6,
        '7': sub7,
        '8': sub8,
        '9a': sub9a,
        '9b': sub9b,
        '10': sub10,
        '11': sub11,
        '12': sub12
    }

    first_run = True

    while 1:
        if first_run:
            print('Please input the task(s) that you want to execute. Valid tasks are:\n')
            for k in funcs.keys():
                print(f'\t{k}')
            first_run = False
            print('Remember that the MongoDB server must be running in order for the application to function normally.')
        else:
            print('Please input the task(s) that you want to execute.\n')

        uinput = input('Select task(s) separated by space, q to quit.\n')
        if uinput.lower() == 'q':
            sys.exit()
        filtered_input = [i for i in uinput.split(" ") if i in funcs.keys()]

        for i in filtered_input:
            print(f'Running subtask {i}.')
            funcs[i]()
            print('______________________________')


if __name__ == '__main__':
    main()
