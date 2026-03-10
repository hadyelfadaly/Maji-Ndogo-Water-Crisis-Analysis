USE md_water_services;

#Table we gonna use in the rest of the analysis
CREATE OR REPLACE VIEW combined_analysis_table AS
SELECT l.province_name, l.town_name, s.type_of_water_source AS source_type, l.location_type ,
 s.number_of_people_served AS people_served, v.time_in_queue, p.results
FROM location AS l 
INNER JOIN visits AS v ON l.location_id = v.location_id
INNER JOIN water_source AS s ON s.source_id = v.source_id
LEFT JOIN well_pollution AS p ON p.source_id = v.source_id
WHERE v.visit_count = 1;

#pivot table for water sources per province
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT province_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name
)
SELECT ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

#pivot table for water sources per province, then town (province first to avoid duplicate town names), using temporary table to 
#avoid calculating this complex query each time,
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each province
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name, town_name
)
SELECT ct.province_name, ct.town_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM combined_analysis_table ct
JOIN town_totals pt ON ct.province_name = pt.province_name AND ct.town_name = pt.town_name
GROUP BY ct.province_name, ct.town_name
ORDER BY ct.town_name;

#check which town has the highest ratio of people who have taps, but have no running water?
SELECT province_name, town_name, ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM town_aggregated_water_access;


CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future.
*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity.
*/
Address VARCHAR(50), # Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), # What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, # Engineers will add this the day the source has been upgraded.
Comments TEXT # Engineers can leave comments. We use a TEXT type that has no limit on char length
);


#Project_progress_query, will save into a view to use
CREATE OR REPLACE VIEW progressQuery AS
SELECT location.address, location.town_name, location.province_name, water_source.source_id, water_source.type_of_water_source,
well_pollution.results, visits.time_in_queue
FROM water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
WHERE visits.visit_count =  1 AND
(
well_pollution.results != 'Clean' OR
(water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30) OR
water_source.type_of_water_source IN ('river', 'tap_in_home_broken')
);

#improvements needed for wells and shared taps
INSERT INTO project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT pq.source_id, pq.address, pq.town_name, pq.province_name, pq.type_of_water_source, 
CASE 
WHEN pq.type_of_water_source = 'well' AND pq.results = 'Contaminated: Biological' THEN 'Install UV filter' 
WHEN pq.type_of_water_source = 'well' AND pq.results = 'Contaminated: Chemical' THEN 'Install RO filter' 
WHEN pq.type_of_water_source = 'shared_tap' THEN CONCAT("Install ", FLOOR(pq.time_in_queue/30), " taps nearby")
WHEN pq.type_of_water_source = 'river' THEN 'Drill well'
WHEN pq.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
ELSE NULL 
END
FROM progressQuery AS pq;

#=========================================================#
#Exam answers
#=========================================================#

#1ST QUESTION
SELECT COUNT(*) FROM project_progress WHERE Improvement LIKE '%UV';

#5TH QUESTION
SELECT * FROM town_aggregated_water_access;

#8TH QUESTION
SELECT province_name
FROM town_aggregated_water_access
GROUP BY province_name
HAVING MAX(tap_in_home + tap_in_home_broken) < 50;

#10TH QUESTION
SELECT project_progress.Project_id, project_progress.Town, project_progress.Province, 
project_progress.Source_type, project_progress.Improvement, Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;