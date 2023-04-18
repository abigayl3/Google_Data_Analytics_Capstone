# Google Data Analytics Capstone Project
*Case study: How does a Bike-share Navigate Speedy Success?*

![Screenshot (1316)](https://user-images.githubusercontent.com/126913055/231244501-de44f4bf-2165-458c-ae26-e7f73b165bfb.png)

As part of my pursuit to obtain the Google Data Analytics Certificate, I have completed this case study to showcase my demonstrated proficiency in data cleaning and analysis using various tools such as Excel, MYSQL, and Tableau.

## Scenario

In this case study, I will be acting as a junior data analyst working on the marketing analyst team for the company, Cyclistic. Cyclistic is a fictitious company that offers a bike-share program across the city of Chicago. The program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of over 600 stations across the city. To broaden their consumer segments, they've offered flexible pricing plans, whereby customers could purchase annual memberships, full-day passes, or single-ride passes. Customers who purchase annual memberships are considered members, while customers who purchase full-day or single passes are referred to as casual riders.

## Purpose
The purpose of this study is to gain insights from historical data about the behavior of members & casual riders. As it is believed that Cyclistic's future is dependent on the maximization of annual memberships, my job is to answer these business questions:

1. How do casual riders and members differ?

2. Why might casual riders make the switch to becoming members?

3. How can Cyclistic use digital media to influence casual riders to become members?

## Task
Using insights from the data, develop a new marketing strategy to increase the conversion rate of casual riders to members. 


## Tools
Excel, MYSQL, Tableau

[SQL Cleaning Script](https://github.com/abigayl3/Google_Data_Analytics_Capstone/blob/main/GDA_Capstone_Cleaning.sql)

[SQL Analysis Script](https://github.com/abigayl3/Google_Data_Analytics_Capstone/blob/main/GDA_Capstone_Analysis.sql)

[Tableau Dashboard](https://public.tableau.com/app/profile/aj4668/viz/GDA_Capstone_1/Dashboard1)

[Raw Data](https://divvy-tripdata.s3.amazonaws.com/index.html)

## Process
### Pre-cleaning with Excel

To begin the data cleaning process, I started with familiarizing myself with the most recent year of data available. The data was separated individually by each month of 2022 in CSV files. Each file had the following information: Ride id, bike type, start time, end time, start station id, start station name, start latitude, start longitude, end station id, end station name, end latitude, end longitude and user type. 

![Screenshot (8)](https://user-images.githubusercontent.com/126913055/232804948-2fabd097-f5fa-43e2-aad5-29782ecf6fe1.png)


In each of those files, I added two columns as per the case instructions: Ride_length & day_of_week. Ride_length was calculated by subtracting the given end times by start times and changing the data type to time. The day_of_week column was created with the WEEKDAY function. Lastly, I renamed each of the csv files for simplicity.


### Data Cleaning with SQL

I chose MYSQL to clean the data. I was able to apply my knowledge of the aggregate functions, GROUP BY, HAVING, ORDER BY, CTE's, subqueries, unions and joins.

- To aggregate the 12 months of data, I created a new table called `2022` by using unions to combine all 12 months and created aliases for some columns
- Added some indexes on columns I knew I would be querying a lot with to ensure that queries ran faster
- Checked data types. Due to data truncation errors while importing the csv files into MYSQL, I had to change some data types. After further investigating the errors, I found values that were too large for certain columns
  - Specifically for the ride length column, I checked where ride times would be considered invalid. ie. deleted invalid rows where ended_at  times aren't actually after started_at times or  any negative values
  - Modified columns to ensure proper DATETIME & TIME data types
- Checked the primary key column (ride_id) for duplicates. Oddly enough there were 35 duplicates, so I removed them from the data set.
- Checked the valid string values for bike_type: electric_bike, classic_bike, or docked_bike. Assuming “docked_bike” is an error as “docked” implies that it’s not in use/at a station, I replaced any entries with “docked bike” to “classic bike” based on the assumption that classic bikes get docked while electric bikes can be left anywhere.
- Checked for missing values
  - Start_station had 833,033 missing values
  - End_station had 892,527 missing values
  - End_lat and end_lng had 8 missing values
- Both start and end stations had missing values that represented 30% of the dataset. I further investigated the missing values by checking which bike types related to the missing station names. 99% of missing values were related to electric bikes, so I continued the assumption that electric bikes are not required to start or end at a station, while classic bikes on the other hand have to. Therefore, I replaced the blank values with the string “Locked”. The 1% that related to classic bikes could then be considered errors, so they were removed from the dataset. I also removed the 8 entries for missing coordinates.
- Looked at station names, and removed certain strings from stations and removed certain maintenance stations from the data set. Additionally, I trimmed the start_station and end_station columns to remove any leading/ trailing spaces.
- Ensured the user_type had only two possible values of “member” or “casual”
- Lastly, I added relevant columns to the final table for analysis such as distance, minutes(from ride_length), month names, day of the week and time of day. I also chose to exclude irrelevant columns such as start_station_id and end_station_id.

## Analyze/Share
### Data Analysis with SQL & Tableau

 I wanted to use these measures to compare members vs. casual riders:
- Bike preferences
- Average, max and min of ride lengths
- Average, max and min of ride distances
- Ride frequency per time of day
- Ride frequency per month
- Ride frequency per day of week
- Top starting and ending stations


Here is a snapshot of the [Tableau Dashboard:](https://public.tableau.com/app/profile/aj4668/viz/GDA_Capstone_1/Dashboard1)
![Screenshot (4)](https://user-images.githubusercontent.com/126913055/232807411-7a6d7488-b017-4e52-a9bd-e33719c2aa25.png)
![Screenshot (5)](https://user-images.githubusercontent.com/126913055/232807483-c23d97d9-3b7c-436d-8195-6e0a02b23ff7.png)
![Screenshot (21)](https://user-images.githubusercontent.com/126913055/232808711-7e8f05ab-305f-4e9f-8ec8-efc672cb43e0.png)
![Screenshot (22) (1)](https://user-images.githubusercontent.com/126913055/232813539-e7a92169-0dc7-494f-a32c-408ebf8c118c.png)
![Screenshot (7)](https://user-images.githubusercontent.com/126913055/232809553-8be83b58-22c9-490d-a5f8-804b06e17467.png)



### Insights Summarized
- Casual riders slightly prefer electric bikes more, while members use both bike types relatively the same.
- The total ride frequency per month peaks in the summer season. Members ride the most in August, while casual riders ride the most in July.
- Members generally ride during the weekdays (Monday - Friday) and causal riders ride more on weekends. 
- Based on ride frequency throughout the day, members have two peak times of 8 am and 5 pm, while casual riders gradually increase in ride frequency throughout the day and peak at 5 pm. This may suggest that members typically use the services for commuting while casual riders ride more recreationally.
- The busiest weekday is Thursday for members and Saturday for casual riders.
- The busiest time of day for both members and casual riders is the evening which ranges from 5pm - 8 pm
- Casual riders on average take longer rides and travel further distances than members
- Casual riders have a larger range for average ride lengths throughout the day 
- The top stations for casual riders are distributed along the shore line, possibly suggesting casual riders participate in more tourist activities. The top stations for members are more evenly distributed within the city.
- The top start and end stations for casual riders is the same station: Streeter Dr & Grand Ave

## Recommendations

#### Strategy 1: “Experience Chicago with Cyclistic”
By capitalizing on the observations that their busiest season is the summer, casual riders use the service for more recreational purposes and the knowledge of their most popular stations, Cyclistic can offer exclusive deals to members from May to August, in partnership with nearby popular destinations. For example, the most popular station used amongst casual riders is Streeter Dr & Grand Ave, and they can partner with near by restaurants/activties. This strategy would not only promote specific bike paths/routes and activities to explore the city of Chicago, but also create a mutually beneficial relationship between Cyclistic and its partners. Both parties would be able to advertise the partnership to their respective customer bases, while Cyclistic members receive discounts at these establishments.

This approach aligns with Cyclistic’s objective of appealing to the behaviors of casual riders while incentivizing them to use their services throughout the whole week, justifying the need for membership. Through targeted marketing campaigns on social media channels, Cyclistic can highlight these exclusive deals as a unique opportunity to support local businesses while enjoying the benefits of membership.


#### Strategy 2: Benefits
Cyclistic can create targeted advertisements promoting the benefits of becoming a member based on the behavior of casual riders in the spring & summer seasons. Cyclistics can leverage digital media such as social media channels for these advertisements and possibly use SMS and email marketing. However, it should be noted that specific marketing channels should be used based on the effectiveness of previous marketing campaigns.

The targeted advertisements can highlight the convenience and availability of electric bikes throughout the whole week, including peak times in the evening, the ease of accessing Cyclistic’s services without payment for each ride, & unlimited rides and ride time without additional fees for longer rides. These benefits would appeal to the behaviour of casual riders, incentivizing them to become members and further promoting customer retention. 

#### Bonus Strategy: Understand rider values
To gain further insight into customer values and factors that influence their decisions, Cyclistic can offer a free ride pass or a chance to win a free month of rides to casual riders who complete a survey pertaining to their experience with the service. This would not only provide valuable data to improve the user experience but also incentivize casual riders to become more engaged with the service and consider the option for membership in the future. The survey could be advertised at the end of each ride purchase receipt all year round. This data would be most useful when promoting the benefits as part of strategy 2 to push which factors have the most influence.

With focusing on targeted promotions and partnerships, Cyclistic can aim towards increasing the conversion rate to annual memberships and drive business growth.
