SHOW TABLES; #TO SHOW TABLES WE HAVE

#A LOOK AT OUR TABLES
SELECT * FROM location LIMIT 5; 
SELECT * FROM visits LIMIT 5; 
SELECT * FROM water_source LIMIT 5; 

#UNIQUE TYPES OF WATER SOURCES
SELECT DISTINCT type_of_water_source FROM water_source;

#RETRIEVING TIME_IN_QUEUE FOR WATER
SELECT * FROM visits WHERE time_in_queue > 500;

#SEARCHING FOR AkKi00881224, SoRu37635224, SoRu36096224 source
SELECT * FROM  water_source WHERE source_id IN ('AkKi00881224', 'SoRu37635224', 'SoRu36096224');

#FIND IF SURVERYS VISITED SOURCES WITH HIGH QUALITY A 2ND TIME OR NOT
SELECT * FROM water_quality WHERE subjective_quality_score = 10 AND visit_count > 1;

#CHECK POLLUTION TABLE
SELECT * FROM well_pollution LIMIT 10;

#CHCK IF THERE ANY ERRORS IN THE DATA
SELECT * FROM well_pollution WHERE results = 'Clean' AND biological > 0.01;

#CHECK DESCRIPITIONS WHERE IT HAS CLEAN
SELECT * FROM well_pollution WHERE description LIKE 'Clean %';

#FIX THIS DESCRIPITIONS
UPDATE well_pollution SET description = "Bacteria: Giardia Lamblia" WHERE description = 'Clean Bacteria: Giardia Lamblia';
UPDATE well_pollution SET description = "Bacteria: E. coli" WHERE description = 'Clean Bacteria: E. coli';

#FIX RESULTS
UPDATE well_pollution SET results = 'Contaminated: Biological' WHERE biological > 0.01 AND results = 'Clean';


#=========================================================#
#Exam answers
#=========================================================#

#1ST QUESTION
SELECT * FROM employee WHERE employee_name = 'Bello Azibo';

#2ND QUESTION 
SELECT * FROM employee WHERE position = 'Micro biologist';

#3RD QUESTION
SELECT * FROM water_source ORDER BY number_of_people_served DESC;

#4TH QUESTION
SELECT * FROM global_water_access WHERE name = 'Maji Ndogo';

#6TH QUESTION
SELECT * FROM employee
WHERE (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
AND (employee_name LIKE '% A%' OR employee_name LIKE '% M%') AND position = 'Field Surveyor';

#7TH QUESTION
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

#10TH QUESTION
SELECT * 
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);