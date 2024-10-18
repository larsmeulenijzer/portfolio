/*
Exoplanets data exploration
*/


SELECT *
FROM SQLPortfolio.exoplanets;


-- Replace empty strings with NULL for stars that do not have a HD index

UPDATE exoplanets
SET hd_id = NULL
WHERE hd_id = '';


-- Count the number of unique planets and stars in the table

SELECT COUNT(DISTINCT name) AS number_of_planets,
COUNT(DISTINCT hostname) AS number_of_stars
FROM exoplanets;


-- Find the planets that have appeared the most in published papers

WITH popularity AS (
    SELECT name, COUNT(name) AS number_of_papers
    FROM exoplanets
    GROUP BY name
)
SELECT name, number_of_papers
FROM popularity
WHERE number_of_papers = (
    SELECT MAX(number_of_papers)
    FROM popularity
);


-- For the planets from the output of the previous query, list the papers in which they appear

SELECT DISTINCT planet_ref
FROM exoplanets
WHERE name IN (
    WITH popularity AS (
        SELECT name, COUNT(name) AS number_of_papers
        FROM exoplanets
        GROUP BY name
    )
    SELECT name
    FROM popularity
    WHERE number_of_papers = (
        SELECT MAX(number_of_papers)
        FROM popularity
    )
);


-- Find the discovery facilities that have found the most new exoplanets

WITH discoveries_per_facility AS (
    WITH distinct_discoveries AS (
        SELECT disc_facility
        FROM exoplanets
        GROUP BY name, disc_facility
    )
    SELECT disc_facility, COUNT(disc_facility) AS number_of_discoveries
    FROM distinct_discoveries
    GROUP BY disc_facility
)
SELECT disc_facility, number_of_discoveries
FROM discoveries_per_facility
WHERE number_of_discoveries = (
    SELECT MAX(number_of_discoveries)
    FROM discoveries_per_facility
);


-- Divide the distinct star systems into groups based on how many stars they countain and find the group sizes

WITH stars AS (
    SELECT DISTINCT hostname, star_num
    FROM exoplanets
)
SELECT star_num, COUNT(star_num) AS number_of_entries
FROM stars
GROUP BY star_num
ORDER BY star_num;


-- Repeat the above query but only for the star systems that have a HD index

WITH stars AS (
    SELECT DISTINCT hostname, star_num
    FROM exoplanets
    WHERE hd_id IS NOT NULL
)
SELECT star_num, COUNT(star_num) AS number_of_entries
FROM stars
GROUP BY star_num
ORDER BY star_num;


-- Find how many exoplanets were discovered in each year

WITH exoplanets_distinct AS (
    SELECT DISTINCT name, disc_year
    FROM exoplanets
)
SELECT disc_year, COUNT(disc_year)
FROM exoplanets_distinct
GROUP BY disc_year
ORDER BY disc_year;


-- Rank the discovery methods by how many discoveries were made with it in 2023

WITH exoplanets_distinct AS (
    SELECT DISTINCT name, disc_method
    FROM exoplanets
    WHERE disc_year = 2023
)
SELECT disc_method, COUNT(disc_method) AS number_of_discoveries
FROM exoplanets_distinct
GROUP BY disc_method
ORDER BY number_of_discoveries DESC;


-- Add a column to the table specifying the year in which each discovery facility made their first discovery

SELECT *,
MIN(disc_year)
OVER(PARTITION BY disc_facility) AS first_discovery
FROM exoplanets;


-- Using the above query, find how many discoveries each facility made in their first year

WITH facility_info AS (
    SELECT DISTINCT name, disc_year, disc_facility, 
    MIN(disc_year)
    OVER(PARTITION BY disc_facility) AS first_discovery
    FROM exoplanets
)
SELECT disc_facility, COUNT(disc_facility) AS number_of_discoveries_first_year
FROM facility_info
WHERE disc_year = first_discovery
GROUP BY disc_facility
ORDER BY number_of_discoveries_first_year DESC;


-- Reset table

UPDATE exoplanets
SET hd_id = ''
WHERE hd_id IS NULL;



