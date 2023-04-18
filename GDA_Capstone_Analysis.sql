-- Analysis

-- Bike preferences
SELECT 
    user_type, 
    bike_type, 
    COUNT(*) AS COUNT,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY user_type) * 100, 2) AS percentage
FROM final_2022
GROUP BY user_type, bike_type;
-- members prefer both bike types, classic & electric, around the same( 51.09% vs. 48.91%), while casual riders slighlty prefer electric bikes more( 54.09% vs. 45.91%)


-- average, max, & min of ride_length per user_type
SELECT user_type, SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(ride_length)))) AS avg_ride_length, max(ride_length) AS max_length, min(ride_length) AS min_length
FROM final_2022 f 
GROUP BY user_type;
-- casual riders on average ride longer than members


-- average ride length per user_type and time_of_day
SELECT SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(ride_length)))) AS avg_ride_length, user_type, time_of_day
FROM final_2022 
GROUP BY user_type,time_of_day
ORDER BY FIELD(time_of_day,'Morning','Afternoon','Evening','Night'), user_type;
-- casual riders on average ride longest in the afternoon(out of all times of the day for casual riders), members on average ride the longest during the evening(out of all the times of day for members) 


-- average distance in miles per user type
SELECT ROUND(AVG(distance_in_miles),3) AS avg_distance, user_type
FROM final_2022 
GROUP BY user_type;
-- casual =4.303 miles, member= 3.39 miles, casual riders cover a distance that is about 27% further than members on average


-- Ride Frequency/time of day per user type
SELECT COUNT(*), time_of_day, user_type
FROM final_2022  
WHERE user_type = 'casual'
GROUP BY user_type, time_of_day
UNION ALL
SELECT COUNT(*), time_of_day, user_type
FROM final_2022  
WHERE user_type = 'member'
GROUP BY user_type, time_of_day
ORDER BY user_type, time_of_day;
-- most rides occur in the afternoon for both user types


-- Ride Frequency/month per user type 
SELECT count(*) AS total_rides, MONTH, user_type
FROM final_2022 f 
GROUP BY MONTH, user_type 
ORDER BY total_rides DESC;
-- The most rides for members occurs in August while the most rides for casual riders occurs in July

-- Ride Frequency/week per member type
SELECT COUNT(*) AS total_rides, day_of_week, user_type
FROM final_2022  
GROUP BY day_of_week, user_type
ORDER BY total_rides DESC;
-- The busiest weekday for members is thursday and the busiest weekday for casual riders is saturday

-- avg ride distance/day of week per user type type
SELECT round(avg(distance_in_miles),3) AS avg_distance,day_of_week, user_type
FROM final_2022 
GROUP BY day_of_week, user_type
ORDER BY avg_distance DESC;
-- Both user's travel the farthest distance on average on the weekends

-- trip frequency based on top starting stations for each user type
(SELECT 
	start_station,
	user_type,
	COUNT(*) as count,
	RANK () OVER (PARTITION BY user_type ORDER BY COUNT(*) DESC) AS station_rank
FROM final_2022
WHERE user_type = 'casual'
GROUP BY start_station, user_type 
LIMIT 10)
UNION ALL
(SELECT 
	start_station,
	user_type,
	COUNT(*) AS count,
	RANK () OVER (PARTITION BY user_type ORDER BY COUNT(*) DESC) AS station_rank
FROM final_2022
WHERE user_type = 'member'
GROUP BY start_station, user_type 
LIMIT 10);

-- trip frequency based on top ending stations for each user type
(SELECT 
	end_station,
	user_type,
	COUNT(*) as count,
	RANK () OVER (PARTITION BY user_type ORDER BY COUNT(*) DESC) AS station_rank
FROM final_2022
WHERE user_type = 'casual'
GROUP BY end_station, user_type 
LIMIT 10)
UNION ALL
(SELECT 
	end_station,
	user_type,
	COUNT(*) AS count,
	RANK () OVER (PARTITION BY user_type ORDER BY COUNT(*) DESC) AS station_rank
FROM final_2022
WHERE user_type = 'member'
GROUP BY end_station, user_type 
LIMIT 10);
