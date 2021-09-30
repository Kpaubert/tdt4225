-- Oppgave 1
select count(*) as 'Number of users' from geolife_db.user;
-- 182
select count(*) as 'Number of activities' from geolife_db.activity;
-- 7670
select count(*) as 'Number of trackpoints' from geolife_db.trackpoint;
-- 5227362

-- Oppgave 2
SELECT min(inner_user_count), avg(inner_user_count), max(inner_user_count) FROM (SELECT user_id as inner_user_id, COUNT(user_id) as inner_user_count FROM geolife_db.activity GROUP BY user_id) as T;
-- 1, 52.1769, 714 

-- Oppgave 3
SELECT inner_user_id, inner_user_count FROM (SELECT user_id as inner_user_id, COUNT(user_id) as inner_user_count FROM geolife_db.activity GROUP BY user_id order by inner_user_count desc limit 10) as T;
-- 25, 714
-- 128, 518
-- 62, 406
-- 41, 399
-- 140, 345
-- 4, 344
-- 17, 265
-- 14, 236
-- 30, 210
-- 11, 201

-- Oppgave 4
select count(distinct user_id) from geolife_db.activity a where datediff(start_date_time, end_date_time) <> 0;
-- 63
-- select count(distinct user_id) from geolife_db.activity a where (select datediff(min(date_time), max(date_time)) from geolife_db.trackpoint tp where a.id = tp.activity_id) <> 0;
-- select a.user_id, count(a.user_id) from geolife_db.activity a where (select datediff(min(date_time), max(date_time)) from geolife_db.trackpoint tp where a.id = tp.activity_id) <> 0 group by a.user_id;

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
    a1.id <> a2.id;

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
select distinct user_id from geolife_db.activity where user_id not in (select user_id from geolife_db.activity where transportation_mode = 'taxi');
-- 137
-- 0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,11 ,12 ,13 ,14 ,15 ,16 ,17 ,18 ,19 ,20 ,21 ,22 ,23 ,24 ,25 ,26 ,27 ,28 ,29 ,30 ,31 ,32 ,33 ,34 ,35 ,36 ,37 ,38 ,39 ,40 ,41 ,42 ,43 ,44 ,45 ,46 ,47 ,48 ,50 ,51 ,52 ,54 ,55 ,56 ,57 ,60 ,61 ,63 ,64 ,65 ,66 ,67 ,69 ,71 ,72 ,73 ,74 ,76 ,77 ,79 ,81 ,82 ,83 ,84 ,86 ,87 ,89 ,90 ,91 ,92 ,93 ,95 ,97 ,99 ,101 ,102 ,103 ,107 ,108 ,109 ,112 ,113 ,115 ,117 ,119 ,121 ,122 ,123 ,125 ,126 ,130 ,131 ,132 ,133 ,134 ,135 ,136 ,138 ,139 ,140 ,142 ,144 ,145 ,146 ,151 ,152 ,153 ,155 ,157 ,158 ,159 ,161 ,162 ,164 ,165 ,166 ,167 ,168 ,169 ,171 ,172 ,173 ,175 ,176 ,178 ,180 ,181 |

-- Oppgave 8
select transportation_mode, count(distinct user_id) from geolife_db.activity where transportation_mode != 'NULL' group by transportation_mode;
-- airplane,    1
-- bike,        19
-- boat,        1
-- bus,         12
-- car,         8
-- run,         1
-- subway,      4
-- taxi,        10
-- train,       2
-- walk,        31

-- Oppgave 9a
select year(start_date_time), month(start_date_time), count(1) from geolife_db.activity group by year(start_date_time), month(start_date_time) order by count(1) desc limit 1;
-- 2008, november - 766

-- Oppgave 9b
select user_id, count(1), sum(timestampdiff(SECOND, start_date_time, end_date_time)) from geolife_db.activity where year(start_date_time) = 2008 and month(start_date_time) = 11 group by user_id order by count(1) desc;
-- 62,   105,    143203
-- 14,   74,     266018
-- 128,  59,     147492
-- 11,   59,     90229
-- 17,   51,     234114
-- 19,   45,     128316
-- 4,    37,     701488
-- 5,    34,     330691
-- 15,   32,     379168
-- 3,    31,     514935
-- 12,   28,     587550
-- 18,   27,     120086
-- 1,    24,     249019
-- 0,    23,     167486
-- 2,    21,     323063
-- 13,   20,     52195
-- 7,    19,     429359
-- 16,   17,     98033
-- 9,    15,     269928
-- 6,    12,     199433
-- 8,    11,     101384
-- 42,   8,      43695
-- 85,   5,      8027
-- 126,  3,      2054
-- 140,  3,      16000
-- 167,  2,      2007
-- 84,   1,      13510
-- Person med ID 62 hadde flest aktiviteter med 105.
-- Altså feil, personen med nest flest aktiviteter har flere timer enn personen med flest aktiviteter.

-- Oppgave 10
select 
    sum(distance) as Total
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
-- 147.2681198663135 km hvis man bruker haversine
-- Tror man kan gjøre noe med den euclidean distance greia

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