USE md_water_services;

#filling employee emails
UPDATE employee 
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');

SELECT * FROM employee;

#cleaning phone numbers
UPDATE employee 
SET phone_number = TRIM(phone_number);

SELECT LENGTH(phone_number) FROM employee;

#count how many of our employees live in each town
SELECT town_name ,COUNT(*) AS num_employees 
FROM employee 
GROUP BY town_name;

#look at the number of records each employee collected
SELECT assigned_employee_id, COUNT(visit_count) AS number_of_visits 
FROM visits 
GROUP BY assigned_employee_id
ORDER BY number_of_visits DESC
LIMIT 3;

#get the top 3 employees details
SELECT employee_name, email, phone_number 
FROM employee 
WHERE assigned_employee_id IN (1, 30, 34);

#counts the number of records per town
SELECT COUNT(*) AS records_per_town, town_name
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

#counts the number of records per province
SELECT COUNT(*) AS records_per_province, province_name
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC;

SELECT province_name, town_name, COUNT(*) AS records_per_town
FROM location
GROUP BY town_name, province_name
ORDER BY records_per_town DESC;

#number of records for each location type
SELECT COUNT(*) AS num_sources, location_type
FROM location
GROUP BY location_type;
#60% of our water sources are in rural communities across Maji Ndogo. We need to keep this in mind when we make decisions. 

#How many people did we survey in total?
SELECT SUM(number_of_people_served) AS total_people_surved
FROM water_source;

#How many wells, taps and rivers are there?
SELECT type_of_water_source, COUNT(type_of_water_source) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source;

#What is the average number of people that are served by each water source?
SELECT type_of_water_source, ROUND(AVG(number_of_people_served), 0) AS ave_people_per_source
FROM water_source
GROUP BY type_of_water_source;

#total number of people served by each type of water source in total
SELECT type_of_water_source, ROUND((SUM(number_of_people_served) / 27628140) * 100.0, 0) AS perc_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY perc_people_per_source DESC;

#which sources need to be fixed first
SELECT type_of_water_source, SUM(number_of_people_served) AS total_people_per_source, 
RANK() OVER(ORDER BY SUM(number_of_people_served) DESC) AS ranking
FROM water_source
GROUP BY type_of_water_source;

#rank each source in each type, i will use row number
SELECT source_id, type_of_water_source, number_of_people_served, 
ROW_NUMBER() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM water_source;

#how long the survey took
SELECT DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS surveyPeriod
FROM visits;

#how long people have to queue on average in Maji Ndogo
SELECT AVG(NULLIF(time_in_queue, 0)) AS avgQueueTime
FROM visits;

#queue times aggregated across the different days of the week.
SELECT DAYNAME(time_of_record) AS dayOfWeek, ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS avgQueueTime
FROM visits
GROUP BY DAYNAME(time_of_record);

#what time during the day people collect water.
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hourOfDay, ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS avgQueueTime
FROM visits
GROUP BY TIME_FORMAT(TIME(time_of_record), '%H:00')
ORDER BY avgQueueTime DESC, hourOfDay ASC;

#pivot table fot hour of day per each day
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END),0) AS Sunday,
-- Monday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END),0) AS Monday,
-- Tuesday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END),0) AS Tuesday,
-- Wednesday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END),0) AS wednesday,
-- Thursday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END),0) AS Thursday,
-- Friday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END),0) AS Friday,
-- Saturday
ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END),0) AS Saturday
FROM visits
WHERE time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day;


#=========================================================#
#Exam answers
#=========================================================#


#3RD QUESTION
SELECT assigned_employee_id, COUNT(visit_count) AS sumOfVisits
FROM visits
GROUP BY assigned_employee_id
ORDER BY sumOfVisits
LIMIT 2;

SELECT assigned_employee_id, employee_name
FROM employee
WHERE assigned_employee_id IN (20, 22);

#6TH QUESTION
SELECT COUNT(*) AS countOfemps
FROM employee
WHERE town_name = 'Dahabu';

#7TH QUESTION
SELECT COUNT(*) AS countOfemps
FROM employee
WHERE town_name IN('Harare', 'Kilimani');

