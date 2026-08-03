/*
=========================================================
Project  : IMDB SQL Practice
File     : 03_Joins.sql
Author   : Yogesh Attri
Purpose  : Practice SQL Joins
=========================================================

Topics Covered
--------------
1. INNER JOIN
2. LEFT JOIN
3. Multiple Table Joins
4. GROUP BY with JOIN
5. ORDER BY
6. Filtering with JOIN

Dataset : IMDB
Database: imdb
=========================================================
*/

USE imdb;

-- =====================================================
-- Q11. Find the top 10 movies based on average rating.
-- =====================================================
SELECT *
FROM (
    SELECT m.title, r.avg_rating,
	DENSE_RANK() OVER (ORDER BY r.avg_rating DESC) AS movie_rank
    FROM movie m
    JOIN ratings r 
    ON m.id = r.movie_id
) t
WHERE movie_rank <= 10;


-- =====================================================
-- Q12. Summarise the ratings table based on the movie
-- counts by median rating.
-- =====================================================
SELECT 
    median_rating,
    COUNT(*) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating;


-- =====================================================
-- Q13. Which production house has produced the highest
-- number of hit movies (average rating > 8)?
-- =====================================================
SELECT *
FROM (
    SELECT 
        m.production_company,
        COUNT(*) AS movie_count,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_company_rank
    FROM movie m
    JOIN ratings r 
    ON m.id = r.movie_id
    WHERE r.avg_rating > 8
      AND m.production_company IS NOT NULL
    GROUP BY m.production_company
) t
WHERE prod_company_rank = 1;


-- =====================================================
-- Q14. How many movies belonging to each genre were
-- released in March 2017 in the USA with more than
-- 1,000 votes?
-- =====================================================
SELECT g.genre, COUNT(*) AS movie_count
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE YEAR(m.date_published) = 2017
  AND MONTH(m.date_published) = 3
  AND m.country LIKE '%USA%'
  AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;


-- =====================================================
-- Q15. Find movies of each genre that start with
-- the word 'The' and have an average rating > 8.
-- =====================================================

SELECT m.title, r.avg_rating, GROUP_CONCAT(g.genre)
FROM movie m
JOIN genre g ON g.movie_id = m.id
JOIN ratings r ON r.movie_id = m.id
WHERE m.title LIKE 'The%' AND r.avg_rating > 8
GROUP BY m.id, m.title, r.avg_rating 
ORDER BY r.avg_rating DESC;

-- =====================================================
-- Q16. Count the movies released between
-- 1-Apr-2018 and 1-Apr-2019 having a median
-- rating of 8.
-- =====================================================

SELECT COUNT(*) AS movie_count
FROM movie m JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND r.median_rating = 8;

-- =====================================================
-- Q17. Do German movies receive more votes than
-- Italian movies?
-- =====================================================

SELECT 'Germany' AS country, SUM(r.total_votes) AS total_votes
FROM movie m JOIN ratings r ON m.id = r.movie_id
WHERE m.country LIKE '%Germany%'
UNION ALL
SELECT 'Italy' AS country, SUM(r.total_votes) AS total_votes
FROM movie m JOIN ratings r ON m.id = r.movie_id
WHERE m.country LIKE '%Italy%';

-- =====================================================
-- Q18. Find the columns in the names table
-- having NULL values.
-- =====================================================
SELECT 
    SUM(name IS NULL) AS name_nulls,
    SUM(height IS NULL) AS height_nulls,
    SUM(date_of_birth IS NULL) AS date_of_birth_nulls,
    SUM(known_for_movies IS NULL) AS known_for_movies_nulls
FROM names;