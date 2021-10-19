-- Subtask 1
select count(*) as 'Number of users' from geolife_db.user;
select count(*) as 'Number of activities' from geolife_db.activity;
select count(*) as 'Number of trackpoints' from geolife_db.trackpoint;

-- Subtask 2
SELECT 
    min(inner_user_count) as 'Minimum number of activities',
    avg(inner_user_count) as 'Average number of activities',
    max(inner_user_count) as 'Maximum number of activities'
FROM 
    (
        SELECT
            user_id as inner_user_id,
            COUNT(user_id) as inner_user_count
        FROM
            geolife_db.activity 
        GROUP BY 
            user_id
    ) as T;

-- Subtask 3
SELECT 
    inner_user_id as 'User ID', 
    inner_user_count as 'Number of activities' 
FROM 
    (
        SELECT
            user_id as inner_user_id,
            COUNT(user_id) as inner_user_count
        FROM
            geolife_db.activity 
        GROUP BY
            user_id 
        order by
            inner_user_count desc 
        limit 10
    ) as T;

-- Subtask 4
select count(distinct user_id) as 'Num users with activities with different start date and end date' from geolife_db.activity a where datediff(start_date_time, end_date_time) <> 0;

-- Subtask 5
select 
    id 
from
    geolife_db.activity
where
    id in
    (
        select
            id
        from
            geolife_db.activity
        group by
            id
        having
            count(*) > 1
    );
-- OR
SELECT 
    start_date_time, end_date_time, COUNT(*)
FROM
    geolife_db.activity
GROUP BY
    start_date_time, end_date_time
HAVING
    COUNT(*) > 1;
-- Empty set nonetheless

-- Subtask 6
set @row_number = 0;
SELECT distinct
    st.id,
    a1.user_id,
    a2.user_id
from
    geolife_db.trackpoint tp1,
    geolife_db.trackpoint tp2,
    geolife_db.activity a1,
    geolife_db.activity a2,
    (SELECT
        (@row_number:=@row_number + 1) AS id,
        a1.id as act_id_1,
        a2.id as act_id_2
    FROM
        geolife_db.activity a1
    inner join
        geolife_db.activity a2
    on
        a1.id <> a2.id
    WHERE   
        (
        a2.start_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute) OR
        a2.end_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute)
        ) and
        a1.user_id <> a2.user_id
    group by
        a1.id, a2.id) as st
where
    a1.id = tp1.activity_id and
    a2.id = tp2.activity_id and
    a1.user_id <> a2.user_id and
    tp1.activity_id = st.act_id_1 and
    tp2.activity_id = st.act_id_2 and
    geolife_db.geo_distance_km(tp1.lat, tp1.lon, tp2.lat, tp2.lon) < 0.1 and
    (timestampdiff(SECOND, tp1.date_time, tp2.date_time) < 60 and timestampdiff(SECOND, tp1.date_time, tp2.date_time) > -60);

-- Subtask 7
select 
    distinct id
from
    geolife_db.user 
where
    id not in 
        (
            select
                user_id
            from
                geolife_db.activity
            where
                transportation_mode = 'taxi'
        );

-- Subtask 8
select
    transportation_mode as 'Transportation mode',
    count(distinct user_id) as 'Distinct users' 
from
    geolife_db.activity
where
    transportation_mode != 'NULL' and
    transportation_mode != 'None'
group by
    transportation_mode;

-- Subtask 9a
select 
    year(start_date_time) as 'Year',
    month(start_date_time) as 'Month',
    count(1) as 'Number of activities' 
from
    geolife_db.activity
group by
    year(start_date_time), month(start_date_time)
order by
    count(1) desc
limit 1;


-- Subtask 9b
select
    user_id as 'User ID',
    count(1) as 'Number of activities in November, 2008',
    sum(timestampdiff(SECOND, start_date_time, end_date_time)) / 3600 as 'Hours registered'
from
    geolife_db.activity
where
    year(start_date_time) = 2008 and
    month(start_date_time) = 11
group by
    user_id 
order by
    count(1) desc
limit 10;

-- Subtask 10
select 
    sum(distance) as 'Kilometers walked by user 112 in 2008'
from (
    SELECT
    a.activity_id,
    -- Haversine
    sum(geolife_db.geo_distance_km(a.lat, a.lon, b.lat, b.lon)) as distance
    -- Euclidean
    -- sum(sqrt(POW(a.lat - b.lat, 2) + POW(a.lon - b.lon, 2))) as distance
    FROM
        geolife_db.trackpoint a
    JOIN 
        geolife_db.trackpoint b 
    ON 
        a.id = b.id - 1
    where
        a.activity_id 
    in  (
        select
            a.id
        from
            geolife_db.activity a
        where
            a.user_id = 112 and
            year(a.start_date_time) = 2008 and
            a.transportation_mode = 'walk'
        )
    group by
        a.activity_id
) as T;

-- Subtask 11
select
    act.user_id as 'User ID',
    sum(altitude_gained) * 0.3048 as 'Meters gained'
from (
    SELECT
        a.activity_id as inner_activity_id,
        sum(b.altitude - a.altitude) as altitude_gained
    FROM
        geolife_db.trackpoint a
    JOIN 
        geolife_db.trackpoint b 
    ON 
        a.id = b.id - 1
    where
        b.altitude > a.altitude and
        a.altitude != -777 and
        b.altitude != -777
    group by
        a.activity_id
) as T,
    geolife_db.activity act
where 
    inner_activity_id = act.id
group by
    act.user_id
order by
    sum(altitude_gained) desc
limit 20;



-- Subtask 12
select
    a.user_id as 'User ID',
    count(distinct a2.id) as 'Total activities',
    count(distinct a.id) as 'Invalid activities'
from
    geolife_db.activity a
join
    geolife_db.activity a2
on
    a.user_id = a2.user_id
join
    geolife_db.trackpoint tp1
on
    tp1.activity_id = a.id
join
    geolife_db.trackpoint tp2
on
    tp1.id = tp2.id - 1
where
    tp1.activity_id = tp2.activity_id and
    timestampdiff(SECOND, tp1.date_time, tp2.date_time) > 300
group by
    a.user_id
order by
    count(distinct a.id) desc;
