/*

COVERAGE GAPS ANALYSIS — OUTLINE

Tier 1: Content composition

Stories per 100k by outlet type and population band
Local + original share by outlet type and population band
Underserved flagging: below median local + original stories per 100k within band

Tier 2: CIN coverage (local + original only)

CIN stories per 100k by CIN category, cut by population band
Underserved flagging: below median stories per 100k within band, by CIN category

Consistent definitions throughout:

Population bands from existing CASE statement
Underserved = below band median
Local + original filter for all CIN work

Population band CASE statement:

  CASE 
    WHEN population < 30000 THEN '1 - Under 30,000'
    WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
    WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
    ELSE '4 - 100,000 to 300,000'
  END AS population_band

*/

-- ============================================================
-- Section 1: Exploratory - Raw Story Counts
-- ============================================================

SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state
FROM stories s
JOIN outlets o ON s.outlet_id = o.outlet_id
RIGHT JOIN communities c ON o.community_id = c.community_id
GROUP BY city, state
ORDER BY total_stories DESC;

SELECT COUNT(s.story_id) AS total_stories, outlet_type
FROM stories s
JOIN outlets o ON s.outlet_id = o.outlet_id
GROUP BY outlet_type
ORDER BY total_stories DESC;

-- ============================================================
-- Section 2: Exploratory - Raw Story Counts Summary Stats
-- ============================================================

WITH story_count_community AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    GROUP BY city, state
)
SELECT MIN(total_stories), MAX(total_stories), ROUND(AVG(total_stories), 2)
FROM story_count_community;

WITH story_count_type AS (
    SELECT COUNT(s.story_id) AS total_stories, outlet_type
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    GROUP BY outlet_type
)
SELECT MIN(total_stories) AS min_stories, MAX(total_stories) AS max_stories, ROUND(AVG(total_stories), 2) AS avg_stories
FROM story_count_type;

-- ============================================================
-- Section 3: Exploratory - Total Stories by Population Band
-- ============================================================

SELECT COUNT(s.story_id) AS total_stories, 
    CASE 
        WHEN population < 30000 THEN '1 - Under 30,000'
        WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
        WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
        ELSE '4 - 100,000 to 300,000'
    END AS population_band
FROM stories s
JOIN outlets o ON s.outlet_id = o.outlet_id
RIGHT JOIN communities c ON o.community_id = c.community_id
GROUP BY population_band 
ORDER BY population_band;

-- ============================================================
-- Section 4: Exploratory - Total Stories by Population Band Summary Stats
-- ============================================================

WITH story_count_pop AS (
    SELECT COUNT(s.story_id) AS total_stories, 
        CASE 
            WHEN population < 30000 THEN '1 - Under 30,000'
            WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    GROUP BY population_band
)
SELECT MIN(total_stories), MAX(total_stories), ROUND(AVG(total_stories), 2)
FROM story_count_pop;

-- ============================================================
-- Section 5: Exploratory - Stories per 100k
-- ============================================================

WITH story_count_community AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state, c.population
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    GROUP BY city, state, population
)
SELECT (total_stories::decimal/population) * 100000 AS stories_per_100k, city, state
FROM story_count_community
ORDER BY stories_per_100k DESC;

-- ============================================================
-- Section 6: Exploratory - Stories per 100k Summary Stats
-- ============================================================

WITH story_count_community AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state, c.population
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    GROUP BY city, state, population
),
stories_per_100k AS (
    SELECT (total_stories::decimal/population) * 100000 AS stories_per_100k, city, state
    FROM story_count_community
)
SELECT MIN(stories_per_100k), ROUND(MAX(stories_per_100k), 2), ROUND(AVG(stories_per_100k), 2)
FROM stories_per_100k;

-- ============================================================
-- Section 7: Analysis - Stories per 100k by Outlet Type
-- ============================================================

WITH story_count_type AS (
    SELECT 
        COUNT(s.story_id) AS total_stories, 
        o.outlet_type AS outlet_type, 
        o.community_id AS community_id
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    GROUP BY outlet_type, community_id
)
SELECT 
    outlet_type, 
    ROUND((SUM(total_stories)::decimal / SUM(c.population)) * 100000, 2) AS stories_per_100k
FROM story_count_type st
RIGHT JOIN communities c ON st.community_id = c.community_id
GROUP BY outlet_type
ORDER BY stories_per_100k DESC;

-- ============================================================
-- Section 8: Analysis - Stories per 100k by Outlet Type Summary Stats
-- ============================================================

WITH story_count_type AS (
    SELECT 
        COUNT(s.story_id) AS total_stories, 
        o.outlet_type AS outlet_type, 
        o.community_id AS community_id
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    GROUP BY outlet_type, community_id
),
stories_per_100k_type AS (
    SELECT 
        outlet_type, 
        ROUND((AVG(total_stories)::decimal / AVG(c.population)) * 100000, 2) AS stories_per_100k
    FROM story_count_type st
    RIGHT JOIN communities c ON st.community_id = c.community_id
    GROUP BY outlet_type
)
SELECT MIN(stories_per_100k), MAX(stories_per_100k), ROUND(AVG(stories_per_100k), 2)
FROM stories_per_100k_type;

-- ============================================================
-- Section 9: Analysis - Stories per 100k by Population Band
-- ============================================================

WITH stories_count AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state, c.population AS population,
        CASE 
            WHEN c.population < 30000 THEN '1 - Under 30,000'
            WHEN c.population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN c.population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON c.community_id = o.community_id
    GROUP BY city, state, population, population_band
),
stories_per_100k AS (
    SELECT (total_stories::decimal/population) * 100000 AS stories_per_100k, city, state, population_band
    FROM stories_count
    GROUP BY city, state, population, total_stories, population_band
)
SELECT ROUND(AVG(stories_per_100k), 2) AS avg_stories_per_100k, population_band
FROM stories_per_100k
GROUP BY population_band
ORDER BY population_band;

-- ============================================================
-- Section 10: Analysis - Underserved Communities (Count by Band)
-- ============================================================

WITH stories_count AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state, c.population AS population,
        CASE 
            WHEN c.population < 30000 THEN '1 - Under 30,000'
            WHEN c.population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN c.population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON c.community_id = o.community_id
    GROUP BY city, state, population, population_band
),
stories_per_100k AS (
    SELECT (total_stories::decimal/population) * 100000 AS stories_per_100k, city, state, population_band
    FROM stories_count
    GROUP BY city, state, population, total_stories, population_band
),
median_stories_per_100k AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY stories_per_100k) AS median_stories_per_100k, population_band
    FROM stories_per_100k
    GROUP BY population_band
),
underserved_communities AS (
    SELECT 
        s.city,
        s.state,
        s.population_band,
        s.stories_per_100k,
        m.median_stories_per_100k,
        CASE 
            WHEN s.stories_per_100k < m.median_stories_per_100k THEN 'Underserved'
            ELSE 'At or above median'
        END AS status
    FROM stories_per_100k s
    JOIN median_stories_per_100k m ON s.population_band = m.population_band
    WHERE s.stories_per_100k < m.median_stories_per_100k
)
SELECT COUNT(city), population_band
FROM underserved_communities 
GROUP BY population_band
ORDER BY population_band;

-- ============================================================
-- Section 11: Analysis - Underserved Communities Full List
-- ============================================================

WITH stories_count AS (
    SELECT COUNT(s.story_id) AS total_stories, c.city AS city, c.state AS state, c.population AS population,
        CASE 
            WHEN c.population < 30000 THEN '1 - Under 30,000'
            WHEN c.population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN c.population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON c.community_id = o.community_id
    GROUP BY city, state, population, population_band
),
stories_per_100k AS (
    SELECT (total_stories::decimal/population) * 100000 AS stories_per_100k, city, state, population_band
    FROM stories_count
    GROUP BY city, state, population, total_stories, population_band
),
median_stories_per_100k AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY stories_per_100k) AS median_stories_per_100k, population_band
    FROM stories_per_100k
    GROUP BY population_band
)
SELECT 
    s.city,
    s.state,
    s.population_band,
    s.stories_per_100k,
    m.median_stories_per_100k,
    CASE 
        WHEN s.stories_per_100k < m.median_stories_per_100k THEN 'Underserved'
        ELSE 'At or above median'
    END AS status
FROM stories_per_100k s
JOIN median_stories_per_100k m ON s.population_band = m.population_band
WHERE s.stories_per_100k < m.median_stories_per_100k
ORDER BY stories_per_100k;

-- ============================================================
-- Section 12: Exploratory - Critical Information Needs Stories
-- ============================================================

SELECT COUNT(story_id) AS cin_stories, critical_info_need
FROM stories
WHERE local = TRUE 
    AND original = TRUE 
    AND critical_info_need IS NOT NULL 
    AND critical_info_need != 'None'
GROUP BY critical_info_need
ORDER BY cin_stories DESC;

-- ============================================================
-- Section 13: Exploratory - CIN Stories Summary Stats
-- ============================================================

WITH cin_stories AS (
    SELECT COUNT(story_id) AS total_stories, critical_info_need
    FROM stories
    WHERE local = TRUE 
        AND original = TRUE 
        AND critical_info_need IS NOT NULL 
        AND critical_info_need != 'None'
    GROUP BY critical_info_need
) 
SELECT MIN(total_stories), MAX(total_stories), ROUND(AVG(total_stories), 2)
FROM cin_stories;

-- ============================================================
-- Section 14: Exploratory - CIN Stories per 100k
-- ============================================================

WITH cin_stories AS (
    SELECT COUNT(s.story_id) AS cin_stories, critical_info_need, c.city AS city, c.state AS state, c.population
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    WHERE local = TRUE 
        AND original = TRUE 
        AND critical_info_need IS NOT NULL 
        AND critical_info_need != 'None'
    GROUP BY critical_info_need, city, state, population
) 
SELECT (cin_stories::decimal/population) * 100000 AS cin_per_100k, city, state, critical_info_need
FROM cin_stories
ORDER BY cin_per_100k DESC;

-- ============================================================
-- Section 15: Exploratory - CIN Stories per 100k Summary Stats
-- ============================================================

WITH cin_stories AS (
    SELECT COUNT(s.story_id) AS cin_stories, critical_info_need, c.city AS city, c.state AS state, c.population
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON o.community_id = c.community_id
    WHERE local = TRUE 
        AND original = TRUE 
        AND critical_info_need IS NOT NULL 
        AND critical_info_need != 'None'
    GROUP BY critical_info_need, city, state, population
),
cin_per_100k AS (
    SELECT (cin_stories::decimal/population) * 100000 AS cin_per_100k, city, state, critical_info_need
    FROM cin_stories
)
SELECT MIN(cin_per_100k), MAX(cin_per_100k), ROUND(AVG(cin_per_100k), 2)
FROM cin_per_100k;

-- ============================================================
-- Section 16: Analysis - CIN Stories per 100k by CIN Category
-- ============================================================

WITH cin_stories AS (
    SELECT 
        COUNT(s.story_id) AS cin_stories, 
        s.critical_info_need,
        c.community_id,
        c.population
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    JOIN communities c ON o.community_id = c.community_id
    WHERE local = TRUE 
        AND original = TRUE 
        AND critical_info_need IS NOT NULL 
        AND critical_info_need != 'None'
    GROUP BY s.critical_info_need, c.community_id, c.population
)
SELECT 
    critical_info_need,
    ROUND((SUM(cin_stories)::decimal / SUM(population)) * 100000, 2) AS cin_per_100k
FROM cin_stories
GROUP BY critical_info_need
ORDER BY cin_per_100k DESC;

-- ============================================================
-- Section 17: Analysis - CIN Stories per 100k by Population Band
-- ============================================================

WITH cin_stories AS (
    SELECT COUNT(s.story_id) AS cin_stories, c.city AS city, c.state AS state, c.population AS population,
        CASE 
            WHEN c.population < 30000 THEN '1 - Under 30,000'
            WHEN c.population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN c.population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    RIGHT JOIN communities c ON c.community_id = o.community_id
    WHERE local = TRUE 
        AND original = TRUE 
        AND critical_info_need IS NOT NULL 
        AND critical_info_need != 'None'
    GROUP BY city, state, population, population_band
),
cin_per_100k AS (
    SELECT (cin_stories::decimal/population) * 100000 AS cin_per_100k, city, state, population_band
    FROM cin_stories
    GROUP BY city, state, population, cin_stories, population_band
)
SELECT ROUND(AVG(cin_per_100k), 2) AS avg_cin_per_100k, population_band
FROM cin_per_100k
GROUP BY population_band
ORDER BY population_band;

-- ============================================================
-- Section 18: Analysis - Individual CIN Categories per 100k
-- ============================================================

WITH cin_stories AS (
    SELECT 
        COUNT(s.story_id) AS cin_stories, 
        s.critical_info_need, 
        c.city, 
        c.state, 
        c.population,
        CASE
            WHEN population < 30000 THEN '1 - Under 30,000'
            WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    JOIN communities c ON o.community_id = c.community_id
    WHERE s.local = TRUE
        AND s.original = TRUE
        AND s.critical_info_need IS NOT NULL
        AND s.critical_info_need != 'None'
    GROUP BY s.critical_info_need, c.city, c.state, c.population
)
SELECT 
    (cin_stories::decimal/population) * 100000 AS cin_per_100k, 
    city, 
    state, 
    critical_info_need,
    population_band
FROM cin_stories
ORDER BY city, critical_info_need;

-- ============================================================
-- Section 19: Analysis - Underserved Cities by CIN Category
-- ============================================================

WITH cin_stories AS (
    SELECT 
        COUNT(s.story_id) AS cin_stories, 
        s.critical_info_need, 
        c.city, 
        c.state, 
        c.population,
        CASE
            WHEN population < 30000 THEN '1 - Under 30,000'
            WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    JOIN communities c ON o.community_id = c.community_id
    WHERE s.local = TRUE
        AND s.original = TRUE
        AND s.critical_info_need IS NOT NULL
        AND s.critical_info_need != 'None'
    GROUP BY s.critical_info_need, c.city, c.state, c.population
),
cin_per_100k AS (
    SELECT 
        (cin_stories::decimal/population) * 100000 AS cin_per_100k, 
        city, 
        state, 
        critical_info_need,
        population_band
    FROM cin_stories
),
median_cin AS (
    SELECT 
        population_band,
        critical_info_need,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cin_per_100k) AS median_cin_per_100k
    FROM cin_per_100k  
    GROUP BY population_band, critical_info_need
)
SELECT 
    c.city,
    c.state,
    c.population_band,
    c.cin_per_100k,
    m.critical_info_need,
    m.median_cin_per_100k,
    CASE 
        WHEN c.cin_per_100k < m.median_cin_per_100k THEN 'Underserved'
        ELSE 'At or above median'
    END AS status
FROM cin_per_100k c
JOIN median_cin m ON c.population_band = m.population_band 
    AND c.critical_info_need = m.critical_info_need
WHERE c.cin_per_100k < m.median_cin_per_100k
ORDER BY c.population_band, c.cin_per_100k;

-- ============================================================
-- Section 20: Analysis - Underserved Cities by CIN Category and Population Band
-- ============================================================

WITH cin_stories AS (
    SELECT 
        COUNT(s.story_id) AS cin_stories, 
        s.critical_info_need, 
        c.city, 
        c.state, 
        c.population,
        CASE
            WHEN population < 30000 THEN '1 - Under 30,000'
            WHEN population BETWEEN 30000 AND 50000 THEN '2 - 30,000 to 50,000'
            WHEN population BETWEEN 50000 AND 100000 THEN '3 - 50,000 to 100,000'
            ELSE '4 - 100,000 to 300,000'
        END AS population_band
    FROM stories s
    JOIN outlets o ON s.outlet_id = o.outlet_id
    JOIN communities c ON o.community_id = c.community_id
    WHERE s.local = TRUE
        AND s.original = TRUE
        AND s.critical_info_need IS NOT NULL
        AND s.critical_info_need != 'None'
    GROUP BY s.critical_info_need, c.city, c.state, c.population
),
cin_per_100k AS (
    SELECT 
        (cin_stories::decimal/population) * 100000 AS cin_per_100k, 
        city, 
        state, 
        critical_info_need,
        population_band
    FROM cin_stories
),
median_cin AS (
    SELECT 
        population_band,
        critical_info_need,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cin_per_100k) AS median_cin_per_100k
    FROM cin_per_100k  
    GROUP BY population_band, critical_info_need
),
underserved_cities AS (
    SELECT 
        c.city,
        c.state,
        c.population_band,
        c.cin_per_100k,
        m.critical_info_need,
        m.median_cin_per_100k,
        CASE 
            WHEN c.cin_per_100k < m.median_cin_per_100k THEN 'Underserved'
            ELSE 'At or above median'
        END AS status
    FROM cin_per_100k c
    JOIN median_cin m ON c.population_band = m.population_band 
        AND c.critical_info_need = m.critical_info_need
    WHERE c.cin_per_100k < m.median_cin_per_100k
)
SELECT COUNT(city), population_band, critical_info_need
FROM underserved_cities
GROUP BY population_band, critical_info_need;