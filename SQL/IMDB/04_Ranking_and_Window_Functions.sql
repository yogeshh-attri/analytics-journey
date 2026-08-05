/*
=========================================================
Project  : IMDB SQL Practice
File     : 04_Ranking_and_Window_Functions.sql
Author   : Yogesh Attri
Purpose  : Practice Ranking Functions and Window Functions
=========================================================

Topics Covered
--------------
1. RANK()
2. DENSE_RANK()
3. ROW_NUMBER()
4. OVER()
5. PARTITION BY
6. Window Functions

Dataset : IMDB
Database: imdb
=========================================================
*/

USE imdb;

-- =====================================================
-- Q19. Find the top three directors in the top three
-- genres whose movies have an average rating greater
-- than 8.
-- =====================================================
WITH top_genres AS (
SELECT g.genre FROM genre g
    JOIN ratings r ON g.movie_id = r.movie_id
    WHERE r.avg_rating > 8
    GROUP BY g.genre ORDER BY COUNT(*) DESC LIMIT 3
),

director_counts AS (
    SELECT n.name AS director_name, COUNT(*) AS movie_count
    FROM director_mapping d
    JOIN names n ON d.name_id = n.id
    JOIN genre g ON d.movie_id = g.movie_id
    JOIN ratings r ON d.movie_id = r.movie_id
    WHERE r.avg_rating > 8 AND g.genre IN (SELECT genre FROM top_genres)
    GROUP BY n.name
)

SELECT * FROM director_counts
ORDER BY movie_count DESC
LIMIT 3;


-- =====================================================
-- Q20. Find the top two actors whose movies have a
-- median rating greater than or equal to 8.
-- =====================================================
SELECT n.name AS actor_name, COUNT(*) AS movie_count
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE r.median_rating >= 8 AND rm.category = 'actor'
GROUP BY n.name ORDER BY movie_count DESC LIMIT 2;


-- =====================================================
-- Q21. Rank the top three production houses based on
-- the total number of votes received by their movies.
-- =====================================================

SELECT *
FROM (
    SELECT m.production_company, SUM(r.total_votes) AS vote_count,
	DENSE_RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
    FROM movie m JOIN ratings r ON m.id = r.movie_id
    WHERE m.production_company IS NOT NULL
    GROUP BY m.production_company
) t
WHERE prod_comp_rank <= 3;


-- =====================================================
-- Q22. Rank actors who have acted in Indian movies
-- based on their weighted average ratings.
--
-- Conditions:
-- • At least five Indian movies
-- • Use total votes as tie breaker
-- =====================================================
SELECT *
FROM (
    SELECT n.name AS actor_name, SUM(r.total_votes) AS total_votes, COUNT(DISTINCT rm.movie_id) AS movie_count,
	SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actor_avg_rating,
	DENSE_RANK() OVER ( ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC, SUM(r.total_votes) DESC
        ) AS actor_rank
        
    FROM role_mapping rm
    JOIN names n ON rm.name_id = n.id
    JOIN movie m ON rm.movie_id = m.id
    JOIN ratings r ON rm.movie_id = r.movie_id
    WHERE rm.category = 'actor' AND m.country LIKE '%India%'
    GROUP BY n.name HAVING COUNT(DISTINCT rm.movie_id) >= 5
) t;


-- =====================================================
-- Q23. Rank the top five actresses in Hindi movies
-- released in India based on weighted average ratings.
--
-- Conditions:
-- • At least three Hindi movies
-- • Use total votes as tie breaker
-- =====================================================
SELECT *
FROM (
    SELECT n.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(DISTINCT rm.movie_id) AS movie_count,
        SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) AS actress_avg_rating,
        DENSE_RANK() OVER (ORDER BY SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes) DESC,
                SUM(r.total_votes) DESC) AS actress_rank
    FROM role_mapping rm
    JOIN names n ON rm.name_id = n.id
    JOIN movie m ON rm.movie_id = m.id
    JOIN ratings r ON rm.movie_id = r.movie_id
    WHERE rm.category = 'actress' AND m.country LIKE '%India%'
	AND m.languages LIKE '%Hindi%'
    GROUP BY n.name  HAVING COUNT(DISTINCT rm.movie_id) >= 3
) t
WHERE actress_rank <= 5;


-- =====================================================
-- Q24. Classify thriller movies having at least
-- 25,000 votes into:
--
-- • Superhit
-- • Hit
-- • One-time-watch
-- • Flop
-- =====================================================

SELECT
    m.title AS movie_name, 
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch'
        ELSE 'Flop'
    END AS movie_category, r.avg_rating
FROM movie m
JOIN genre g ON g.movie_id = m.id
JOIN ratings r ON r.movie_id = m.id
WHERE g.genre = 'Thriller'
  AND r.total_votes >= 25000
ORDER BY r.avg_rating DESC;