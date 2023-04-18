-- Data Aggregation & Cleaning

-- Combing 12 months of data into one table for 2022 and creating aliases
CREATE TABLE `2022` AS
  SELECT 
   ride_id,
  	rideable_type AS bike_type,
  	started_at, 
  	ended_at,
  	ride_length,
  	day_of_week,
  	start_station_name AS start_station,
  	start_station_id,
  	end_station_name AS end_station,
  	end_station_id,
  	start_lat,
  	start_lng,
  	end_lat,
  	end_lng,
  	member_casual AS user_type
  FROM (
    SELECT * FROM `JAN`
	UNION ALL
	SELECT * FROM `FEB`     
	UNION ALL
	SELECT * FROM `MAR` 
	UNION ALL
	SELECT * FROM `APR` 
	UNION ALL
	SELECT * FROM `may` 
	UNION ALL
	SELECT * FROM `JUN` 
	UNION ALL
	SELECT * FROM `JUL` 
	UNION ALL
	SELECT * FROM `AUG` 
	UNION ALL
	SELECT * FROM `SEPT` 
	UNION ALL
	SELECT * FROM `OCT` 
	UNION ALL
	SELECT * FROM `NOV` 
	UNION ALL
	SELECT * FROM `DEC` 
) AS combined_data;
   
-- Add indexes to make queries faster
ALTER TABLE `2022` ADD INDEX id_index(ride_id);
ALTER TABLE `2022` ADD INDEX start_station_name_index(start_station);
ALTER TABLE `2022` ADD INDEX end_station_name_index(end_station);


-- Checking data types
/*To import the files correctly, i had to change some of the data types due to data truncation errors, so i have to change them back.
In order to change the data type for ride_length, I needed to check where times would be considered invalid (endtime is lower than start time or values are too big)*/

SELECT *
FROM `2022` 
WHERE ride_length <= '00:00:00' or ride_length >'24:00:00';

DELETE FROM `2022`
WHERE ride_length <= '00:00:00' or ride_length >'24:00:00';

SELECT *
FROM `2022`
WHERE ride_length LIKE '%#%';

DELETE FROM `2022`
WHERE ride_length LIKE '%#%';

-- change datatypes
ALTER TABLE `2022` 
MODIFY COLUMN started_at DATETIME,
MODIFY COLUMN ended_at DATETIME,
MODIFY COLUMN ride_length TIME;

-- Checking for duplicate entries
-- count rows
SELECT COUNT(*)
FROM `2022` ;
-- 5,667,717 rows

-- count unique values for ride_id
SELECT COUNT(DISTINCT ride_id)
FROM `2022` ;
-- 5,667,680 rows

-- To see duplicate ride_id's to determine if they are actual duplicate entries, or separate entries with the same ride_id
SELECT *
FROM `2022` 
WHERE ride_id IN (
	SELECT ride_id 
	FROM `2022` 
	GROUP BY ride_id 
	HAVING COUNT(*) >1
	ORDER BY ride_id ASC); 
-- Found 72 entries 

-- Find the number of duplicates
SELECT ride_id, COUNT(*)
FROM `2022`
GROUP BY ride_id
HAVING COUNT(*) >1;
-- 35 results

/* The entries found are not duplicate rows, just rows that have the same ride id. These entries repesent 0.00127% of the entire dataset.
I will just delete them instead of changing the primary key id's*/

WITH atable(ride_id, 
    duplicatecount)
AS (SELECT ride_id,  
           ROW_NUMBER () OVER(PARTITION BY ride_id
           ORDER BY Ride_id) AS DuplicateCount
    FROM `2022`)
DELETE FROM `2022` USING `2022` JOIN atable ON `2022`.ride_id = atable.ride_id
WHERE atable.DuplicateCount >1;
-- updated 72 entries

-- Investigate bike types
-- count of all bike types
select bike_type,count(*)
from `2022`
group by bike_type;
-- 2,888,598 electric, 2,601,048 classic, 177,468 docked_bike

-- assuming docked_bike is an error in the name since docked_bike ride lengths are valid and 'docked' implies that it's not in use
update `2022`
set bike_type = 'classic_bike'
where bike_type = 'docked_bike';

-- checking missing values
-- missing values are denoted by '' rather than NULL
 SELECT
  SUM(start_station = '') AS start_station_count,
  SUM(end_station = '') AS end_station_count,
  SUM(start_lat = '') AS start_lat_count,
  SUM(start_lng = '') AS start_lng_count,
  SUM(end_lat = '') AS end_lat_count,
  SUM(end_lng = '') AS end_lng_count,
  SUM(user_type = '') AS user_type_count
FROM `2022`;
/*start_station missing values =833,033
end_station missing values =892,527
end_lat and end_lng missing values = 8
1,725,560/5667114 = station missing values which represent 30% of dataset.*/

-- Dealing with missing station names
-- checking which bike type relates to the missing stations
SELECT 
    bike_type,
    start_station,
    end_station,
    COUNT(*) AS count
FROM `2022`
WHERE start_station = '' OR end_station = ''
GROUP BY bike_type, start_station,end_station;
/*electric bike, start station missing = 833,033
 classic bike, start station missing = 0
 electric bike, end station missing = 886,124
 classic bike, end station missing = 6403*/

/*since majority of the missing values for stations are related to electric bikes, I will continue the analysis under the assumption that 
electric bikes don't necessarily have to be at a station and can be left anywhere in the city. Under this assumption, missing station names 
can be replaced with 'locked' instead. However, this represents a larger issue with their data tracking and in a real life situation, 
it would be best to ask the company before making a significant assumption */

/* Entries with missing end stations and classic bikes represents 0.11% of the whole data-set. Continuing the assumption above, classic bikes would have to 
have a start docking station and end docking station unlike electric bikes, therefore these entries are deemed as errors.*/

DELETE FROM `2022`
WHERE bike_type = 'classic_bike' AND end_station ='';

UPDATE `2022`
SET end_station = IF(end_station = '', 'Locked', end_station),
    start_station = IF(start_station = '', 'Locked', start_station);
   
-- dealing with missing coordinates
-- 8 values are missing for end_lat and end_lng. Having blank ending coordinates is an error and cant be used for analysis as all rides have to have a value for coordinates
DELETE FROM `2022`
WHERE end_lat = '' AND end_lng = '';

-- clean station names
-- After looking at station names, I realized there were a lot of unnecessary characters in the them.
-- Need to remove substrings 'temp', '*','charging', 'public rack'
update `2022`
SET start_station = REPLACE(REPLACE(REPLACE(REPLACE(start_station, ' (Temp)', ''), '*', ''), ' - Charging', ''), 'Public Rack - ','')
WHERE start_station LIKE '%(temp)%' 
	OR start_station LIKE '%*%' 
	OR start_station LIKE '%charging%' 
	OR start_station LIKE '%public rack%'

update `2022`
SET end_station = REPLACE(REPLACE(REPLACE(REPLACE(end_station, ' (Temp)', ''), '*', ''), ' - Charging', ''), 'Public Rack - ','')
WHERE end_station LIKE '%(temp)%' 
	OR end_station LIKE '%*%' 
	OR end_station LIKE '%charging%' 
	OR end_station LIKE '%public rack%';

-- remove trailing/leading spaces
UPDATE `2022`
SET start_station = TRIM(start_station)
SET end_station = TRIM(end_station);

-- remove trips that include 'repair', 'test'
DELETE FROM `2022`
WHERE start_station LIKE '%test%' 
	OR start_station LIKE '%repair%' 
	OR end_station LIKE '%test%' 
	OR end_station LIKE '%repair%';

-- create points to join to final table to calculate distance
CREATE TABLE coor AS
SELECT 
	ride_id,
	POINT(start_lng,start_lat) AS start_point,
	POINT(end_lng,end_lat) AS end_point
FROM `2022`;

-- Create final table that will be used for analysis, calculate distance using the coor table(also could have been done through cte or a subquery), and add other relevant columns
CREATE TABLE final_2022 AS
SELECT
	a.ride_id,
	a.user_type,
	a.bike_type,
  	a.started_at, 
  	a.ended_at,
  	a.ride_length,
  	MINUTE(a.ride_length) AS mins,
  	ROUND(st_distance_sphere(b.start_point, b.end_point)* 0.000621371,4) AS Distance_in_miles,
  	MONTHNAME(a.started_at) AS 'month',
  	a.day_of_week,
  	CASE
         WHEN HOUR(started_at) BETWEEN 0 AND 4 THEN 'Night'
         WHEN HOUR(started_at) BETWEEN 5 AND 11 THEN 'Morning'
         WHEN HOUR(started_at) BETWEEN 12 AND 16 THEN 'Afternoon'
         WHEN HOUR(started_at) BETWEEN 17 AND 20 THEN 'Evening'
         ELSE 'Night'
       END AS time_of_day,
  	a.start_station,
  	a.end_station,
  	a.start_lat AS  s_lat,
  	a.start_lng AS s_lng,
  	a.end_lat AS e_lat,
  	a.end_lng  AS e_lng
FROM `2022` a
JOIN coor b
ON a.ride_id = b.ride_id;

/* Note: Entries that have a distance of 0 are valid since distance is measured by the lat and lng coordinates versus tracked distance on the bike.
 * Distance of 0 would account for riders that started and stopped at the same coordinates. The validity of entries is already determined by ride_length*/
