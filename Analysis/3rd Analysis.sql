USE md_water_services;

#take a look at the table
SELECT * FROM auditor_report;

#Is there a difference in the scores of auditor report and ater quality tables?
SELECT r.location_id, v.record_id, r.true_water_source_score AS auditor_score, w.subjective_quality_score AS surveyor_score
FROM auditor_report AS r 
INNER JOIN visits AS v ON r.location_id = v.location_id 
INNER JOIN water_quality AS w ON v.record_id = w.record_id
WHERE r.true_water_source_score = w.subjective_quality_score AND v.visit_count = 1;
#this query return 1518 row out of the og 1620 row means a 94% of of the records the auditor checked were correct

#lets check the incorrect rows
SELECT r.location_id, v.record_id, r.type_of_water_source AS auditor_source, s.type_of_water_source AS survey_source,
r.true_water_source_score AS auditor_score, w.subjective_quality_score AS surveyor_score
FROM auditor_report AS r 
INNER JOIN visits AS v ON r.location_id = v.location_id 
INNER JOIN water_quality AS w ON v.record_id = w.record_id
INNER JOIN water_source AS s ON v.source_id = s.source_id
WHERE r.true_water_source_score != w.subjective_quality_score AND v.visit_count = 1;

#lets check who employees responsible for this errors
SELECT r.location_id, v.record_id, r.true_water_source_score AS auditor_score, w.subjective_quality_score AS surveyor_score, 
e.employee_name
FROM auditor_report AS r 
INNER JOIN visits AS v ON r.location_id = v.location_id 
INNER JOIN water_quality AS w ON v.record_id = w.record_id
INNER JOIN employee AS e ON e.assigned_employee_id = v.assigned_employee_id
WHERE r.true_water_source_score != w.subjective_quality_score AND v.visit_count = 1;
#save this query as CTE to down the complexity, later converted to a view cuz we will use it a lot
CREATE VIEW Incorrect_records AS
(
SELECT r.location_id, v.record_id, r.true_water_source_score AS auditor_score, w.subjective_quality_score AS surveyor_score, 
e.employee_name, r.statements
FROM auditor_report AS r 
INNER JOIN visits AS v ON r.location_id = v.location_id 
INNER JOIN water_quality AS w ON v.record_id = w.record_id
INNER JOIN employee AS e ON e.assigned_employee_id = v.assigned_employee_id
WHERE r.true_water_source_score != w.subjective_quality_score AND v.visit_count = 1
);
#lets calculate how many mistaked each employee made
WITH error_count AS
(
SELECT employee_name, COUNT(*) AS number_of_mistakes
FROM Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database 
for records where the auditor and employees scores are different*/
GROUP BY employee_name
ORDER BY number_of_mistakes DESC
),
#THERE ARE SOME EMPLOYEES WHO ARE DOING ALOT OF MISTAKES WHILE OTHERS THAT ONLY HAVE VERY FEW, MAYBE SOME ARE CORRUPT?!!!
#lets get the avg mistakes, convert it into a cte to use later
suspect_list AS 
(
SELECT employee_name, number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
#this query results in 4 employees, we will return to the incorrect record view to see their records
SELECT * 
FROM Incorrect_records AS i
INNER JOIN suspect_list AS s ON i.employee_name = s.employee_name
WHERE statements LIKE '%cash%';

#=========================================================#
#Exam answers
#=========================================================#

#QUESTION 10
SELECT
auditorRep.location_id,
visitsTbl.record_id,
auditorRep.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS employee_score,
wq.subjective_quality_score - auditorRep.true_water_source_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
WHERE (wq.subjective_quality_score - auditorRep.true_water_source_score) > 9;

