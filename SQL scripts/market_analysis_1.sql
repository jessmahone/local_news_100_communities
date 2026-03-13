-- ============================================================
-- Section 1: Exploratory - Population Band Distribution
-- ============================================================

SELECT
  CASE
    WHEN population < 50000 THEN '1 - Under 50,000'
    WHEN population >= 50000 AND population < 100000 THEN '2 - 50,000 to 100,000'
    WHEN population >= 100000 AND population < 150000 THEN '3 - 100,000 to 150,000'
    ELSE '4 - 150,000 to 300,000'
  end as population_band,
  COUNT(*) AS count
FROM communities
GROUP BY population_band
ORDER BY population_band;

select count(*) as cities
from communities
where population < 35000;

SELECT
  case 
	when population < 30000 then '1 - Under 30,000'
	when population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band,
  COUNT(*) AS count
FROM communities
GROUP BY population_band
order by population_band;

-- ============================================================
-- Section 2: Exploratory - Raw Outlet Counts
-- ============================================================

select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state
order by total_outlets DESC;

with community_raw_count as (
select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state)
select MIN(total_outlets), MAX(total_outlets), ROUND(AVG(total_outlets), 2)
from community_raw_count;

-- ============================================================
-- Section 3: Exploratory - Outlets Per 100k Summary Stats
-- ============================================================

with community_raw_count as (
select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state, c.population as population
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state, population),
outlets_per_100k AS(
select (total_outlets::decimal/population) * 100000 as outlets_per_100k, city, state
from community_raw_count
group by city, state, population, total_outlets)
select MIN(outlets_per_100k), MAX(outlets_per_100k) , ROUND(AVG(outlets_per_100k), 2) as average
from outlets_per_100k;

-- ============================================================
-- Section 4: Analysis - Avg Outlets Per 100k by Population Band
-- ============================================================

with community_raw_count as (
select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state, c.population as population,
case 
	when c.population < 30000 then '1 - Under 30,000'
	when c.population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when c.population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state, population, population_band),
outlets_per_100k AS(
select (total_outlets::decimal/population) * 100000 as outlets_per_100k, city, state, population_band
from community_raw_count
group by city, state, population, total_outlets, population_band)
select round(AVG(outlets_per_100k), 2) as avg_outlets_per_100k, population_band
from outlets_per_100k
group by population_band
order by population_band;


select count(o.outlet_id), o.outlet_type,
case 
	when c.population < 30000 then '1 - Under 30,000'
	when c.population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when c.population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band
from outlets o
right join communities c on c.community_id  = o.community_id
group by population_band,  outlet_type
order by population_band;

-- ============================================================
-- Section 5: Analysis - Outlet Type Mix by Population Band
-- ============================================================

select 
	case 
	when c.population < 30000 then '1 - Under 30,000'
	when c.population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when c.population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band,
count (case when outlet_type = 'Newspaper/Magazine' then o.outlet_id end) as newspapers,
	count(case when outlet_type = 'TV Station' then o.outlet_id end) as tv_stations,
	count(case when outlet_type = 'Radio Station' then o.outlet_id end) as radio_stations,
	count(case when outlet_type = 'Online Only' then o.outlet_id end) as digital_natives
from outlets o
right join communities c on c.community_id = o.community_id
group by population_band
order by population_band;

-- ============================================================
-- Section 6: Analysis - Underserved Communities (Full List)
-- ============================================================

with community_raw_count as (
select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state, c.population as population,
case 
	when c.population < 30000 then '1 - Under 30,000'
	when c.population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when c.population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state, population, population_band),
outlets_per_100k AS(
select (total_outlets::decimal/population) * 100000 as outlets_per_100k, city, state, population_band
from community_raw_count
group by city, state, population, total_outlets, population_band),
median_outlets_per_100k as (
select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER by outlets_per_100k) as median_outlets_per_100k, population_band
from outlets_per_100k
group by population_band)
SELECT 
  o.city,
  o.state,
  o.population_band,
  o.outlets_per_100k,
  m.median_outlets_per_100k,
  CASE 
    WHEN o.outlets_per_100k < m.median_outlets_per_100k THEN 'Underserved'
    ELSE 'At or above median'
  END AS status
FROM outlets_per_100k o
JOIN median_outlets_per_100k m ON o.population_band = m.population_band
WHERE o.outlets_per_100k < m.median_outlets_per_100k
ORDER BY o.population_band, o.outlets_per_100k;

-- ============================================================
-- Section 7: Analysis - Underserved Communities (Count by Band)
-- ============================================================

with community_raw_count as (
select COUNT(o.outlet_id) as total_outlets, c.city as city, c.state as state, c.population as population,
case 
	when c.population < 30000 then '1 - Under 30,000'
	when c.population between 30000 and 50000 then '2 - 30,000 to 50,000'
	when c.population between 50000 and 100000 then '3 - 50,000 to 100,000'
	else '4 - 100,000 to 300,000'
end as population_band
from outlets o
right join communities c on c.community_id = o.community_id
group by city, state, population, population_band),
outlets_per_100k AS(
select (total_outlets::decimal/population) * 100000 as outlets_per_100k, city, state, population_band
from community_raw_count
group by city, state, population, total_outlets, population_band),
median_outlets_per_100k as (
select PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER by outlets_per_100k) as median_outlets_per_100k, population_band
from outlets_per_100k
group by population_band),
underserved_communities as (
SELECT 
  o.city,
  o.state,
  o.population_band,
  o.outlets_per_100k,
  m.median_outlets_per_100k,
  CASE 
    WHEN o.outlets_per_100k < m.median_outlets_per_100k THEN 'Underserved'
    ELSE 'At or above median'
  END AS status
FROM outlets_per_100k o
JOIN median_outlets_per_100k m ON o.population_band = m.population_band
WHERE o.outlets_per_100k < m.median_outlets_per_100k)
select COUNT(city), population_band
from underserved_communities 
group by population_band
order by population_band;

