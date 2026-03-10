# Maji Ndogo Water Crisis Analytics

## About the Project
As I am currently advancing through the ALX Africa Data Engineering program, I developed this SQL-based analytics project to investigate and propose solutions for a simulated national water crisis in the fictional country of Maji Ndogo. 

This project involves a complete data lifecycle: from initial database exploration and data cleansing to complex aggregations, auditing surveyor integrity, and generating actionable infrastructure improvement plans.

## Technical Stack & Skills Demonstrated
* **Database:** MySQL
* **Techniques:** Common Table Expressions (CTEs), Complex `JOIN` operations, Window Functions, Data Cleansing (string manipulation, updating records), Views, and Subqueries.
* **Core Competencies:** Data Auditing, Fraud Detection, Geospatial Aggregation, and Business Logic Implementation.

* **`Data/`**: Contains the `md_water_services_data.sql` file. This is the raw SQL dump needed to recreate the database and reproduce this analysis locally.
* **`Analysis/`**: Contains the four distinct analytical phases, represented by the SQL scripts:
    * **Entity Relationship Diagram (ERD):** A visual representation of the Maji Ndogo database schema, mapping the relationships between the `employee`, `location`, `visits`, and `water_source` tables.
    * **`1st Analysis.sql` - Database Exploration & Schema Understanding:** Initial queries to understand the architecture of the `employee`, `location`, `visits`, and `water_source` tables. This phase establishes the baseline data types and relationships.
    * **`2nd Analysis.sql` - Data Cleansing & Initial Aggregations:** Focuses on cleaning corrupted email data, calculating the total population served by different water sources (wells, shared taps, rivers), and understanding the macroscopic scale of the water crisis.
    * **`3rd Analysis.sql` - Data Auditing & Fraud Investigation:** Implements an audit pipeline comparing third-party auditor scores against internal surveyor scores. Using CTEs and `JOIN`s, this script identifies corrupt employees manipulating water quality data.
    * **`4th Analysis.sql` - Strategic Planning & Reporting:** Utilizes derived tables and complex aggregations to calculate water access percentages by province and town. It culminates in a `project_progress` View and automated `INSERT` statements that determine specific infrastructure interventions (e.g., UV/RO filters, drilling new wells) based on queue times and contamination types.

## How to Run This Project
1. Clone this repository to your local machine.
2. Import the `md_water_services_data.sql` file located in the `data/` directory into your MySQL instance to build the schema and populate the tables.
3. Navigate to the `analytics/` directory and execute the analysis scripts in sequential order (1st through 4th) to see the progression of data cleansing, auditing, and final strategic planning.