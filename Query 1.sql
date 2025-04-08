use md_water_services;
select * from employee ;
-- TO UPDATE EMAIL YOU MUST SET SAFE MODE = 0
set SQL_SAFE_UPDATES =0 ;
-- UPDATEING EMAIL
update employee
set email = concat(lower(replace(employee_name, '' , '.' )),'@ndogowater.gov') ;
select * from employee;
SELECT 
	position,
    province_name,
    count(assigned_employee_id) as num_of_people
from employee 
group by province_name , position ;

update employee 
set phone_number = trim(phone_number);

select phone_number,
length(phone_number)
from employee ;
    
    
select 
town_name ,
count(*) as num_of_emp_per_town
 from employee 
 group by town_name
 order by count(*) desc;
 
-- visits table 
select 
v.assigned_employee_id,
e.employee_name,
count(*) as num_of_vis
from visits v
left join employee e
on v.assigned_employee_id = e.assigned_employee_id 
group by assigned_employee_id
order by count(*) desc
limit 3 ;
-- location table 
select 
location_type ,
province_name,
town_name,
count(*) as num_per_type
from location 
group by location_type ,province_name,
town_name
order by count(*) desc;
-- with this query we can Determine the the percentage of types from a
select 
type_of_water_source,
sum(number_of_people_served) as total_per_type ,
concat(round(sum(number_of_people_served) / 27000000 * 100,2),'%') as percentage
from water_source
group by type_of_water_source
order by  sum(number_of_people_served)  desc 
;

-- Determine the priority of people who need engineers immediatley
with mm as (select 
type_of_water_source,
number_of_people_served,
row_number()over(partition by type_of_water_source order by number_of_people_served desc) as priority_rank 
from water_source
where type_of_water_source in ('shared_tap' , 'well' ,'river'))

select type_of_water_source,
number_of_people_served, 
priority_rank
from mm
order by type_of_water_source ;

-- Determine the time of waiting : 

SELECT 
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END), 0) AS Sunday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END), 0) AS Monday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END), 0) AS Tuesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END), 0) AS Wednesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END), 0) AS Thursday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END), 0) AS Friday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday
FROM visits
WHERE time_in_queue != 0
GROUP BY hour_of_day
ORDER BY hour_of_day;














