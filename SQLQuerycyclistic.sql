SELECT *
INTO [whole_2020_trips_cyclistic]
FROM
(
    SELECT * FROM [capstone].[dbo].[Divvy_Trips_2020_Q1$] AS Q1
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202004-divvy-tripdata$'] AS April
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202005-divvy-tripdata$'] AS May
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202006-divvy-tripdata$'] AS June
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202008-divvy-tripdata$'] AS Aug
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202009-divvy-tripdata$'] AS Sep
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202010-divvy-tripdata$'] AS Oct 
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202011-divvy-tripdata$'] AS Nov
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202012-divvy-tripdata$'] AS Dece
	UNION ALL
    SELECT * FROM [capstone].[dbo].['202007-divvy-tripdata$'] AS Jul
) AS QueryAlias;


SELECT *
INTO [H1_2020_trips_cyclistic]
FROM
(
    SELECT * FROM [capstone].[dbo].[Divvy_Trips_2020_Q1$] AS Q1
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202004-divvy-tripdata$'] AS April
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202005-divvy-tripdata$'] AS May
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202006-divvy-tripdata$'] AS June

) AS QueryAlias;


-- Combining tables into one for first half of 2020
SELECT *
INTO [H1_2020_trips_cyclistic]
FROM
(
    SELECT * FROM [capstone].[dbo].[Divvy_Trips_2020_Q1$] AS Q1
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202004-divvy-tripdata$'] AS April
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202005-divvy-tripdata$'] AS May
    UNION ALL
    SELECT * FROM [capstone].[dbo].['202006-divvy-tripdata$'] AS June

) AS QueryAlias;

-- basic exploration 
SELECT * FROM [H1_2020_trips_cyclistic]

SELECT COUNT(*) AS TOTAL FROM  [H1_2020_trips_cyclistic];
SELECT COUNT(*) AS MEMBERS 
FROM  [H1_2020_trips_cyclistic]
WHERE [member_casual] ='member'
;

SELECT DISTINCT([rideable_type])
FROM
[H1_2020_trips_cyclistic]


--looking for any null values (data on where rides are ending is missing)
SELECT COUNT(*) - COUNT(rideable_type) AS NULL_ride_ids,
	COUNT(*) - COUNT(rideable_type) AS NULL_rideable_type,
	COUNT(*) - COUNT(started_at) AS NULL_started_at,
	COUNT(*) - COUNT(start_station_name) AS null_start_station_name,
	COUNT(*) - COUNT(end_station_name) AS null_end_station_name,
	COUNT(*) - COUNT(start_station_id) AS null_start_station_id,
	COUNT(*) - COUNT(end_station_id) AS null_end_station_id,
	COUNT(*) - COUNT(start_lat) AS null_start_lat,
	COUNT(*) - COUNT(start_lng) AS null_start_lng,
	COUNT(*) - COUNT(end_lng) AS null_end_lat,
	COUNT(*) - COUNT(end_lat) AS null_end_lng,
	COUNT(*) - COUNT(member_casual) AS null_member_casual
	FROM [H1_2020_trips_cyclistic]

--analyzing time reason for 12 case statemnt is the problem in data set column conversion where 00 is written as 12. 
-- time will also be calculated again using sql query if deemed neccecassry.
SELECT 
	[day] AS DAY_OF_WEEK,
	[member_casual], DATEPART(MONTH, [started_at]) AS ride_month,
	CASE 
        WHEN DATEPART(HOUR, [Length ]) != 12 
        THEN DATEPART(HOUR, [Length ]) * 60 + DATEPART(MINUTE, [Length ])
        ELSE DATEPART(MINUTE, [Length ])
    END AS extracted_minutes
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
	GROUP BY DATEPART(MONTH, [started_at]), day , member_casual, [Length ];


 --FINDING AVERAGE LENGTH FOR MEMBERS AND CASUALS SEPRATERLY GROUPING BY MONTH AND DAYS OF WEEK TO FIND A TREND
 SELECT 
    DATEPART(MONTH, [started_at]) AS ride_month,
    [day] AS DAY_OF_WEEK,
    [member_casual] AS MEM,
    AVG(
        CASE 
            WHEN DATEPART(HOUR, [Length]) != 12 
            THEN DATEPART(HOUR, [Length]) * 60 + DATEPART(MINUTE, [Length])
            ELSE DATEPART(MINUTE, [Length])
        END
    ) AS average_minutes_members
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
WHERE [member_casual] = 'member'
GROUP BY DATEPART(MONTH, [started_at]), [day], [member_casual]
ORDER BY ride_month, DAY_OF_WEEK;
-- avg length for casuals 
 SELECT 
    DATEPART(MONTH, [started_at]) AS ride_month,
    [day] AS DAY_OF_WEEK,
    [member_casual] AS MEM,
    AVG(
        CASE 
            WHEN DATEPART(HOUR, [Length]) != 12 
            THEN DATEPART(HOUR, [Length]) * 60 + DATEPART(MINUTE, [Length])
            ELSE DATEPART(MINUTE, [Length])
        END
    ) AS average_minutes_casual
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
WHERE [member_casual] = 'casual'
GROUP BY DATEPART(MONTH, [started_at]), [day], [member_casual]
ORDER BY ride_month, DAY_OF_WEEK;

-- number of rides for each day of week for each month for members and casuals 
SELECT DATEPART(MONTH, [started_at]) AS ride_month, [day] AS day_of_week, COUNT(ride_id) AS num_of_rides_members
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
WHERE [member_casual] = 'member'
GROUP BY DATEPART(MONTH, [started_at]), [day], [member_casual]
ORDER BY ride_month, day_of_week;
-- member/casual count of rides for days of week and months 
SELECT DATEPART(MONTH, [started_at]) AS ride_month, [day] AS day_of_week,
COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_count,
COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_count
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
GROUP BY DATEPART(MONTH, [started_at]), [day]
ORDER BY ride_month, day_of_week;


-- sum of memeber and casual count for each day of week 
SELECT
[day] as day_of_week,
COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_count,
COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_count
FROM
[H1_2020_trips_cyclistic]
GROUP BY
[day]
ORDER BY
[day];


--basic exploration of names and counts of start and end stations
SELECT DISTINCT([start_station_name]), COUNT(*) AS start_station_count, [member_casual]
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
WHERE [member_casual] = 'member' 
GROUP BY start_station_name,[member_casual] ;

SELECT DISTINCT([end_station_name]), COUNT(*) AS end_station_count 
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
GROUP BY end_station_name;

--POPULARITY OF START/END STATIONS AMONG USERS 
SELECT 
    [start_station_name],
    COUNT(CASE WHEN [member_casual] = 'member' THEN 1 END) AS member_count,
    COUNT(CASE WHEN [member_casual] = 'casual' THEN 1 END) AS casual_count
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
GROUP BY [start_station_name]
ORDER BY member_count DESC, casual_count DESC;
-- top 15 stations with focus on casuals
SELECT TOP 15
    [start_station_name],
	COUNT(CASE WHEN [member_casual] = 'casual' THEN 1 END) AS casual_count,
    COUNT(CASE WHEN [member_casual] = 'member' THEN 1 END) AS member_count
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
GROUP BY [start_station_name]
ORDER BY casual_count DESC, member_count DESC
;



SELECT TOP 15
    [end_station_name],
	COUNT(CASE WHEN [member_casual] = 'casual' THEN 1 END) AS casual_count,
    COUNT(CASE WHEN [member_casual] = 'member' THEN 1 END) AS member_count
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
GROUP BY [end_station_name]
ORDER BY casual_count DESC, member_count DESC
;

--since our aim is to target non members/casuals lets focus only on popularity among non members 
SELECT 
	[start_station_name], 
	COUNT(CASE WHEN [member_casual]='casual' THEN 1 END) AS Casual_start_station,
	[end_station_name], 
	COUNT(CASE WHEN [member_casual]='casual' THEN 1 END) AS Casual_end_station
FROM [capstone].[dbo].[H1_2020_trips_cyclistic]
WHERE [member_casual] = 'casual' 
GROUP BY [start_station_name],[end_station_name]
ORDER BY Casual_start_station DESC;
-- PROBLEM FACED to be confirmed later; start station and end station count for casual riders is exaclty the same 
