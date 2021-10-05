-- Oppgave 1
select count(*) as 'Number of users' from geolife_db.user;
select count(*) as 'Number of activities' from geolife_db.activity;
select count(*) as 'Number of trackpoints' from geolife_db.trackpoint;

-- Oppgave 2
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

-- Oppgave 3
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

-- Oppgave 4
select count(distinct user_id) as 'Num users with activities with different start date and end date' from geolife_db.activity a where datediff(start_date_time, end_date_time) <> 0;

-- Oppgave 5
select id from geolife_db.activity where id in (select id from geolife_db.activity group by id having count(*) > 1);
-- OR
SELECT start_date_time, end_date_time, COUNT(*)
FROM geolife_db.activity
GROUP BY start_date_time, end_date_time
HAVING COUNT(*) > 1;
-- Empty set nonetheless

-- Oppgave 6
SELECT  
    a1.id as act_id_1,
    a2.id as act_id_2
FROM
    geolife_db.activity a1,
    geolife_db.activity a2
WHERE   
    (
    a2.start_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute) OR
    a2.end_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute)
    ) and
    a1.id <> a2.id and -- 35924 med bare denne
    a1.user_id <> a2.user_id; -- 34654 med denne og

-- | 20120412235005 | 20120413005853 |

--geolife_db.geo_distance_km(tp1.lat, tp1.lon, tp2.lat, tp2.lon),
    --timestampdiff(SECOND, tp1.date_time, tp2.date_time)
SELECT distinct
    st.id,
    a1.user_id,
    a2.user_id
from
    geolife_db.trackpoint tp1,
    geolife_db.trackpoint tp2,
    geolife_db.sup_table st,
    geolife_db.activity a1,
    geolife_db.activity a2
where
    a1.id = tp1.activity_id and
    a2.id = tp2.activity_id and
    a1.user_id <> a2.user_id and
    tp1.activity_id = st.act_id_1 and
    tp2.activity_id = st.act_id_2 and
    geolife_db.geo_distance_km(tp1.lat, tp1.lon, tp2.lat, tp2.lon) < 0.1 and
    (timestampdiff(SECOND, tp1.date_time, tp2.date_time) < 60 and timestampdiff(SECOND, tp1.date_time, tp2.date_time) > -60)
limit 1000;

select * from geolife_db.trackpoint where id in (3979913, 5002663);


-- Oppgave 7
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

-- Oppgave 8
select transportation_mode as 'Transportation mode', count(distinct user_id) as 'Distinct users' from geolife_db.activity where transportation_mode != 'NULL' and transportation_mode != 'None' group by transportation_mode;

-- Oppgave 9a
select year(start_date_time) as 'Year', month(start_date_time) as 'Month', count(1) as 'Number of activities' from geolife_db.activity group by year(start_date_time), month(start_date_time) order by count(1) desc limit 1;


-- Oppgave 9b
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

-- Oppgave 10
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

-- Oppgave 11
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



-- Oppgave 12
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

--|      25 |              714 |                263 |
--|       4 |              344 |                219 |
--|      41 |              399 |                201 |
--|      39 |              198 |                147 |
--|     128 |              518 |                138 |
--|      62 |              406 |                133 |
--|      17 |              265 |                129 |
--|      14 |              236 |                118 |
--|      30 |              210 |                112 |
--|       0 |              155 |                101 |
--|      37 |              129 |                100 |
--|       2 |              146 |                 98 |
--|       3 |              148 |                 98 |
--|      34 |              180 |                 88 |
--|     140 |              345 |                 86 |
--|      38 |               72 |                 58 |
--|      22 |               82 |                 55 |
--|      42 |              110 |                 54 |
--|     142 |              138 |                 52 |
--|      15 |               60 |                 46 |
--|       1 |               57 |                 45 |
--|       5 |               73 |                 44 |
--|      12 |               69 |                 43 |
--|      28 |               53 |                 36 |
--|      51 |               50 |                 36 |
--|      36 |               44 |                 34 |
--|      11 |              201 |                 32 |
--|       9 |               37 |                 31 |
--|      19 |               79 |                 31 |
--|      44 |               61 |                 31 |
--|     134 |               75 |                 31 |
--|       7 |               40 |                 30 |
--|     155 |               40 |                 30 |
--|      13 |              119 |                 29 |
--|      18 |               44 |                 27 |
--|      24 |               49 |                 27 |
--|      71 |               66 |                 27 |
--|     115 |               81 |                 26 |
--|      29 |               42 |                 25 |
--|     103 |               47 |                 24 |
--|      35 |               24 |                 23 |
--|     119 |               32 |                 22 |
--|      43 |               32 |                 21 |
--|      16 |               36 |                 20 |
--|      74 |               85 |                 19 |
--|     168 |               83 |                 19 |
--|      26 |               21 |                 18 |
--|       6 |               24 |                 17 |
--|      40 |               20 |                 17 |
--|       8 |               23 |                 16 |
--|      57 |               22 |                 16 |
--|      55 |               19 |                 15 |
--|      83 |               31 |                 15 |
--|     181 |               15 |                 14 |
--|      46 |               31 |                 13 |
--|      61 |               20 |                 12 |
--|      20 |               94 |                 11 |
--|      23 |               16 |                 11 |
--|      85 |               34 |                 11 |
--|      99 |               16 |                 11 |
--|     112 |               71 |                 10 |
--|     131 |               15 |                 10 |
--|     157 |               13 |                  9 |
--|     158 |               14 |                  9 |
--|     162 |               11 |                  9 |
--|     169 |               33 |                  9 |
--|     172 |               18 |                  9 |
--|      50 |               12 |                  8 |
--|      63 |               14 |                  8 |
--|     130 |               14 |                  8 |
--|     176 |                8 |                  8 |
--|      45 |                8 |                  7 |
--|     146 |               10 |                  7 |
--|      47 |               12 |                  6 |
--|      66 |                8 |                  6 |
--|      73 |               53 |                  6 |
--|     122 |                6 |                  6 |
--|     164 |                7 |                  6 |
--|      65 |               16 |                  5 |
--|      78 |               39 |                  5 |
--|     135 |                8 |                  5 |
--|     145 |                5 |                  5 |
--|     159 |                7 |                  5 |
--|     173 |                6 |                  5 |
--|      32 |                4 |                  4 |
--|      84 |               12 |                  4 |
--|      89 |                8 |                  4 |
--|      93 |               22 |                  4 |
--|      95 |               33 |                  4 |
--|     121 |                5 |                  4 |
--|     133 |                4 |                  4 |
--|     163 |               32 |                  4 |
--|      31 |                4 |                  3 |
--|      77 |                3 |                  3 |
--|      90 |                8 |                  3 |
--|     109 |                4 |                  3 |
--|     123 |                4 |                  3 |
--|     126 |               22 |                  3 |
--|     132 |                3 |                  3 |
--|     167 |               21 |                  3 |
--|     171 |                5 |                  3 |
--|      27 |                3 |                  2 |
--|      33 |                4 |                  2 |
--|      54 |                2 |                  2 |
--|      58 |                6 |                  2 |
--|      72 |                2 |                  2 |
--|      76 |                3 |                  2 |
--|      79 |               23 |                  2 |
--|      81 |                7 |                  2 |
--|      86 |                3 |                  2 |
--|      97 |                9 |                  2 |
--|     108 |                3 |                  2 |
--|     152 |                3 |                  2 |
--|     153 |                5 |                  2 |
--|     165 |               15 |                  2 |
--|     166 |                8 |                  2 |
--|     180 |                4 |                  2 |
--|      21 |                1 |                  1 |
--|      48 |                1 |                  1 |
--|      56 |               15 |                  1 |
--|      60 |                1 |                  1 |
--|      67 |                1 |                  1 |
--|      69 |                1 |                  1 |
--|      80 |                2 |                  1 |
--|      87 |                5 |                  1 |
--|      92 |                2 |                  1 |
--|     111 |                3 |                  1 |
--|     113 |               31 |                  1 |
--|     144 |                1 |                  1 |
--|     151 |                1 |                  1 |
--|     175 |                1 |                  1 |