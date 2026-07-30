/*
=========================================================
Project  : IMDB SQL Practice
File     : 02_Filtering_and_Aggregation.sql
Author   : Yogesh Attri
Purpose  : Practice SQL Filtering & Aggregation
=========================================================

Topics Covered
--------------
1. GROUP BY
2. HAVING
3. COUNT()
4. AVG()
5. MIN()
6. MAX()
7. Ranking
8. Aggregate Functions

Dataset : IMDB
Database: imdb
=========================================================
*/

USE imdb;

-- =====================================================
-- Q6. Which genre has the highest number of movies?
-- =====================================================

SELECT genre, COUNT(*) AS number_of_movies
FROM genre
GROUP BY genre ORDER BY number_of_movies 
DESC LIMIT 1;

-- =====================================================
-- Q7. How many movies belong to only one genre?
-- =====================================================

SELECT COUNT(*) AS movies_with_one_genre
FROM (
    SELECT movie_id FROM genre
    GROUP BY movie_id HAVING COUNT(genre) = 1
) AS t;

-- =====================================================
-- Q8. What is the average duration of movies in each genre?
-- =====================================================
SELECT g.genre, AVG(m.duration) AS avg_duration
FROM genre g
JOIN movie m ON g.movie_id = m.id
GROUP BY g.genre ORDER BY avg_duration DESC;


-- =====================================================
-- Q9. Rank the genres based on the number of movies.

SELECT *
FROM (
    SELECT genre, COUNT(*) AS movie_count,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
    FROM genre GROUP BY genre
) t;

-- Determine the rank of the 'Thriller' genre.
-- =====================================================
SELECT * FROM (
    SELECT genre, COUNT(*) AS movie_count,
	RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
    FROM genre GROUP BY genre
) t 
WHERE genre = 'Thriller';


-- =====================================================
-- Q10. Find the minimum and maximum values for each column
-- in the ratings table.
-- =====================================================

SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;