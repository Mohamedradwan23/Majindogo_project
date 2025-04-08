-- Using Incorrect Records
use md_water_services ;
select type_of_water_source
,count(*) as number_of_pple_wz_no_score
 from auditor_report
 where true_water_source_score = 0
 group by type_of_water_source; 			-- people who drinking from river is 172

select type_of_water_source
,count(*) as number_of_pple_wz_incorrect_score
 from auditor_report
 where true_water_source_score <= 10
 group by type_of_water_source;
 
 
 
 select * from auditor_report;
 select * from water_quality ;
 
 
 
 SELECT 
	e.employee_name,
    e.position,
    e.province_name,
    v.assigned_employee_id,
    a.type_of_water_source,
    COUNT(a.true_water_source_score) AS countt
FROM visits v
left JOIN auditor_report a ON a.location_id = v.location_id
left join employee e on v.assigned_employee_id = e.assigned_employee_id
GROUP BY v.assigned_employee_id, a.type_of_water_source
having COUNT(a.true_water_source_score) != 0
ORDER BY countt DESC;					-- each assigned employee id with his mistakes
 
 
 select * from water_quality ;
 select * from employee ;
 select * from visits ;
 




 select 
	 e.assigned_employee_id,
     e.employee_name,
	 e.province_name,
	 a.type_of_water_source,
	 a.true_water_source_score  as auditor_score,
	 w.subjective_quality_score as employee_score,
case
	when a.true_water_source_score != w.subjective_quality_score  then 'Not match'
else 'Match'
end as correct_or_not
 from visits v
 inner join auditor_report a on v.location_id = a.location_id
 left join water_quality w  on  v.record_id = w.record_id
 left join employee e       on v.assigned_employee_id = e.assigned_employee_id;



 
 
 
 WITH mismatched_scores AS (
    SELECT 
        e.assigned_employee_id,
        e.employee_name,
        e.province_name,
        a.type_of_water_source,
        a.true_water_source_score AS auditor_score,
        w.subjective_quality_score AS employee_score,
        CASE
            WHEN a.true_water_source_score != w.subjective_quality_score THEN 'Not match'
            ELSE 'Match'
        END AS correct_or_not
    FROM visits v
    INNER JOIN auditor_report a ON v.location_id = a.location_id
    LEFT JOIN water_quality w ON v.record_id = w.record_id
    LEFT JOIN employee e ON v.assigned_employee_id = e.assigned_employee_id
)
SELECT * FROM mismatched_scores
WHERE correct_or_not = 'Not match';
 
 
 
 
 WITH mismatched_scores AS (
    SELECT 
        e.employee_name,
        CASE
            WHEN a.true_water_source_score != w.subjective_quality_score THEN 'Not match'
            ELSE 'Match'
        END AS correct_or_not
    FROM visits v
    INNER JOIN auditor_report a ON v.location_id = a.location_id
    LEFT JOIN water_quality w ON v.record_id = w.record_id
    LEFT JOIN employee e ON v.assigned_employee_id = e.assigned_employee_id
    where v.visit_count = 1
)
SELECT 
    employee_name,
    COUNT(*) AS number_of_mismatches
FROM mismatched_scores
WHERE correct_or_not = 'Not match'
GROUP BY employee_name
ORDER BY number_of_mismatches DESC;  
 
select *  from water_source ;
select * from location ;
select * from visits;
-- Determine the number of people served per province and type of water source
with num_per_type as (
SELECT 
	e.province_name,
    ws.type_of_water_source,
    loc.location_id,
    SUM(ws.number_of_people_served) AS total_people_served,
    v.visit_count
FROM visits v 
JOIN water_source ws ON v.source_id = ws.source_id
JOIN location loc ON v.location_id = loc.location_id
JOIN  employee e on v.assigned_employee_id = e.assigned_employee_id
where v.visit_count = 1
GROUP BY ws.type_of_water_source, loc.location_id,province_name
),
num_per_prov as (
select  province_name,
		sum(total_people_served) as total_per_province
from num_per_type
group by province_name) ,

province_totals AS (
    -- Total people served per province
    SELECT 
        loc.province_name,
        SUM(ws.number_of_people_served) AS total_people_in_province
    FROM visits v 
    JOIN water_source ws ON v.source_id = ws.source_id
    JOIN location loc ON v.location_id = loc.location_id
    GROUP BY loc.province_name
),

water_source_province AS (
    -- People served per water source type per province
    SELECT 
        loc.province_name,
        ws.type_of_water_source,
        SUM(ws.number_of_people_served) AS people_served_per_type
    FROM visits v 
    JOIN water_source ws ON v.source_id = ws.source_id
    JOIN location loc ON v.location_id = loc.location_id
    GROUP BY loc.province_name, ws.type_of_water_source
)

-- Calculate percentage for each water source type in columns
SELECT 
    p.province_name,
    p.total_people_in_province,
    ROUND(SUM(CASE WHEN w.type_of_water_source = 'river' THEN w.people_served_per_type ELSE 0 END) * 100.0 / p.total_people_in_province, 2) AS river_percentage,
    ROUND(SUM(CASE WHEN w.type_of_water_source = 'shared_tap' THEN w.people_served_per_type ELSE 0 END) * 100.0 / p.total_people_in_province, 2) AS shared_tap_percentage,
    ROUND(SUM(CASE WHEN w.type_of_water_source = 'well' THEN w.people_served_per_type ELSE 0 END) * 100.0 / p.total_people_in_province, 2) AS well_percentage,
    ROUND(SUM(CASE WHEN w.type_of_water_source = 'tap_in_home' THEN w.people_served_per_type ELSE 0 END) * 100.0 / p.total_people_in_province, 2) AS tap_in_home_percentage,
    ROUND(SUM(CASE WHEN w.type_of_water_source = 'tap_in_home_broken' THEN w.people_served_per_type ELSE 0 END) * 100.0 / p.total_people_in_province, 2) AS tap_in_home_broken_percentage,
    -- Additional columns for actual numbers served
    SUM(CASE WHEN w.type_of_water_source = 'river' THEN w.people_served_per_type ELSE 0 END) AS river_people_served,
    SUM(CASE WHEN w.type_of_water_source = 'shared_tap' THEN w.people_served_per_type ELSE 0 END) AS shared_tap_people_served,
    SUM(CASE WHEN w.type_of_water_source = 'well' THEN w.people_served_per_type ELSE 0 END) AS well_people_served,
    SUM(CASE WHEN w.type_of_water_source = 'tap_in_home' THEN w.people_served_per_type ELSE 0 END) AS tap_in_home_people_served,
    SUM(CASE WHEN w.type_of_water_source = 'tap_in_home_broken' THEN w.people_served_per_type ELSE 0 END) AS tap_in_home_broken_people_served
FROM province_totals p
LEFT JOIN water_source_province w ON p.province_name = w.province_name
GROUP BY p.province_name, p.total_people_in_province
ORDER BY p.province_name;
    
    
CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;



WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;











 
 
 
 
 
 
 
 
 
