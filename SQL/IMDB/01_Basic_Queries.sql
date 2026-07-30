-- =====================================================
-- IMDB SQL Practice
-- Segment 1
-- Dataset: IMDB
-- =====================================================

-- 
-- =====================================================
-- Q1. Find the total number of rows in each table of the schema.
-- =====================================================

SELECT 'movie' AS table_name, COUNT(*) AS total_rows FROM movie
UNION ALL
SELECT 'genre', COUNT(*) FROM genre
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'names', COUNT(*) FROM names
UNION ALL
SELECT 'director_mapping', COUNT(*) FROM director_mapping
UNION ALL
SELECT 'role_mapping', COUNT(*) FROM role_mapping;


-- =====================================================
-- Q2. Which columns in the movie table have NULL values?
-- =====================================================

SELECT 'id' AS column_name FROM movie WHERE id IS NULL
UNION
SELECT 'title' FROM movie WHERE title IS NULL
UNION
SELECT 'year' FROM movie WHERE year IS NULL
UNION
SELECT 'date_published' FROM movie WHERE date_published IS NULL
UNION
SELECT 'duration' FROM movie WHERE duration IS NULL
UNION
SELECT 'country' FROM movie WHERE country IS NULL
UNION
SELECT 'worlwide_gross_income' FROM movie WHERE worlwide_gross_income IS NULL
UNION
SELECT 'languages' FROM movie WHERE languages IS NULL
UNION
SELECT 'production_company' FROM movie WHERE production_company IS NULL;


SELECT
    SUM(country IS NULL) AS country_nulls,
    SUM(worlwide_gross_income IS NULL) AS gross_income_nulls,
    SUM(languages IS NULL) AS language_nulls,
    SUM(production_company IS NULL) AS production_company_nulls
FROM movie;


-- =====================================================
-- Q3. Find the total number of movies released each year.
-- =====================================================
SELECT year, COUNT(*) AS number_of_movies
FROM movie
GROUP BY year ORDER BY year;

-- Find the month-wise trend.
SELECT MONTH(date_published) AS month_num,
COUNT(*) AS number_of_movies FROM movie
GROUP BY MONTH(date_published) ORDER BY month_num;


-- =====================================================
-- Q4. How many movies were produced in the USA or India in the year 2019?
-- =====================================================

SELECT COUNT(*) AS number_of_movies
FROM movie
WHERE year = 2019
AND (country LIKE '%USA%' OR country LIKE '%India%');



-- =====================================================
-- Q5. Find the unique list of genres present in the dataset.
-- =====================================================

SELECT DISTINCT genre FROM genre ORDER BY genre;