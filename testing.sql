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
-- Empty set

-- Oppgave 6

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
    act.user_id,
    sum(altitude_gained)
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
        b.altitude > a.altitude
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
-- 4,   1173001
-- 41,  920530
-- 30,  603017
-- 128, 547315
-- 39,  528486
-- 25,  491843
-- 3,   484717
-- 0,   427462
-- 2,   414222
-- 140, 370611
-- 37,  367507
-- 34,  325745
-- 62,  323703
-- 17,  272221
-- 42,  243411
-- 22,  217510
-- 14,  214876
-- 7,   206690
-- 13,  200068
-- 28,  182880


-- Oppgave 12

SELECT  
    a1.id,
    a1.start_date_time,
    a1.end_date_time,
    a2.id
FROM    
    geolife_db.activity a1, geolife_db.activity a2
WHERE   
    (
    a2.start_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute) OR
    a2.start_date_time BETWEEN date_add(a1.start_date_time, interval -1 minute) AND date_add(a1.end_date_time, interval 1 minute)
    ) and
    a1.id <> a2.id;

/*
timestampdiff(SECOND, start_date_time, end_date_time)


select distinct
    a.user_id,
    b.user_id
from
    geolife_db.activity a,
    geolife_db.activity b,
    geolife_db.trackpoint tp,
    geolife_db.trackpoint tp2
where
    a.user_id != b.user_id and
    tp.activity_id = a.id and
    tp2.activity_id = b.id and
    timestampdiff(SECOND, tp.date_time, tp2.date_time) <= 60 and
    geolife_db.geo_distance_km(tp.lat, tp.lon, tp2.lat, tp2.lon) < 0.1;


select
    count(distinct tp1.activity_id)
from
    geolife_db.trackpoint tp1
join
    geolife_db.trackpoint tp2
on
    tp1.activity_id <> tp2.activity_id
where
    timestampdiff(SECOND, tp1.date_time, tp2.date_time) <= 60 and
    geolife_db.geo_distance_km(tp1.lat, tp1.lon, tp2.lat, tp2.lon) < 0.1;
*/