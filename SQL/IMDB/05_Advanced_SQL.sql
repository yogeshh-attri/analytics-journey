/*
=========================================================
Project  : IMDB SQL Practice
File     : 05_Advanced_SQL.sql
Author   : Yogesh Attri
Purpose  : Practice Advanced SQL Analytics
=========================================================

Topics Covered
--------------
1. Running Totals
2. Moving Average
3. Window Aggregates
4. CTEs
5. Advanced Ranking
6. Business Case Problems

Dataset : IMDB
Database: imdb
=========================================================
*/

USE imdb;

-- =====================================================
-- Q25. Find the genre-wise running total and moving
-- average of average movie duration.
-- =====================================================
SELECT genre, avg_duration, SUM(avg_duration) OVER (ORDER BY genre) AS running_total_duration,
    AVG(avg_duration) OVER (
        ORDER BY genre 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_duration

FROM (
    SELECT 
        g.genre,
        AVG(m.duration) AS avg_duration
    FROM movie m
    JOIN genre g 
        ON g.movie_id = m.id
    GROUP BY g.genre
) t;


-- =====================================================
-- Q26. Find the five highest-grossing movies of each
-- year belonging to the top three genres.
-- =====================================================

WITH top_genres AS (
    SELECT genre
    FROM (
        SELECT 
            g.genre,
            COUNT(*) AS movie_count,
            DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
        FROM genre g
        GROUP BY g.genre
    ) t
    WHERE genre_rank <= 3
),

movie_ranked AS (
    SELECT 
        g.genre,
        m.year,
        m.title AS movie_name,
        m.worlwide_gross_income,
        DENSE_RANK() OVER (
            PARTITION BY g.genre, m.year
            ORDER BY m.worlwide_gross_income DESC
        ) AS movie_rank
    FROM movie m
    JOIN genre g 
        ON g.movie_id = m.id
    WHERE g.genre IN (SELECT genre FROM top_genres)
)
SELECT *
FROM movie_ranked
WHERE movie_rank <= 5
ORDER BY year, genre, movie_rank;

-- =====================================================
-- Q27. Find the top two production houses that have
-- produced the highest number of multilingual movies
-- with a median rating of at least 8.
-- =====================================================

SELECT *
FROM (
    SELECT
        m.production_company,
        COUNT(*) AS movie_count,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_comp_rank
    FROM movie m
    JOIN ratings r
        ON m.id = r.movie_id
    WHERE r.median_rating >= 8
      AND POSITION(',' IN m.languages) > 0
      AND m.production_company IS NOT NULL
    GROUP BY m.production_company
) t
WHERE prod_comp_rank <= 2;

-- =====================================================
-- Q28. Who are the top 3 actresses based on the number of Super Hit movies 
--(Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: 
--  Consider only superhit movies to calculate the actress average ratings.
--  (Hint: You should use the weighted average based on votes. If the ratings clash, 
--  then the total number of votes
--  should act as the tie breaker. If number of votes are same,sort alphabetically by actress name.)
-- =====================================================

WITH superhit_movies AS (
    SELECT 
        m.id,
        r.avg_rating,
        r.total_votes
    FROM movie m
    JOIN ratings r ON m.id = r.movie_id
    JOIN genre g ON g.movie_id = m.id
    WHERE 
        r.avg_rating > 8
        AND g.genre = 'Drama'
),

actress_stats AS (
    SELECT 
        n.name AS actress_name,
        SUM(sh.total_votes) AS total_votes,
        COUNT(DISTINCT sh.id) AS movie_count,
        SUM(sh.avg_rating * sh.total_votes) / SUM(sh.total_votes * 1.0) AS actress_avg_rating
    FROM role_mapping rm
    JOIN names n ON rm.name_id = n.id
    JOIN superhit_movies sh ON rm.movie_id = sh.id
    WHERE rm.category = 'actress'
    GROUP BY n.name
),

ranked AS (
    SELECT *,
        DENSE_RANK() OVER (
            ORDER BY 
                actress_avg_rating DESC,
                total_votes DESC,
                actress_name ASC
        ) AS actress_rank
    FROM actress_stats
)

SELECT *
FROM ranked
WHERE actress_rank <= 3;

-- =====================================================
-- Q29. Find the top nine directors based on:
--
-- • Director ID
-- • Director Name
-- • Number of Movies
-- • Average Inter-Movie Duration Days
-- • Average Movie Rating
-- • Total Votes
-- • Minimum Rating
-- • Maximum Rating
-- • Total Duration
-- =====================================================


WITH director_movies AS (
    SELECT 
        n.id AS director_id,
        n.name AS director_name,
        m.id AS movie_id,
        m.date_published,
        m.duration,
        r.avg_rating,
        r.total_votes
    FROM director_mapping dm
    JOIN names n ON dm.name_id = n.id
    JOIN movie m ON dm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
),

inter_movie_gap AS (
    SELECT 
        a.director_id,
        a.director_name,
        DATEDIFF(b.date_published, a.date_published) AS gap_days
    FROM director_movies a
    JOIN director_movies b 
        ON a.director_id = b.director_id
        AND b.date_published > a.date_published
    WHERE NOT EXISTS (
        SELECT 1
        FROM director_movies c
        WHERE c.director_id = a.director_id
          AND c.date_published > a.date_published
          AND c.date_published < b.date_published
    )
),

director_summary AS (
    SELECT 
        dm.director_id,
        dm.director_name,
        COUNT(dm.movie_id) AS number_of_movies,
        AVG(img.gap_days) AS avg_inter_movie_days,
        AVG(dm.avg_rating) AS avg_rating,
        SUM(dm.total_votes) AS total_votes,
        MIN(dm.avg_rating) AS min_rating,
        MAX(dm.avg_rating) AS max_rating,
        SUM(dm.duration) AS total_duration
    FROM director_movies dm
    LEFT JOIN inter_movie_gap img 
        ON dm.director_id = img.director_id
    GROUP BY dm.director_id, dm.director_name
),

ranked_directors AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY number_of_movies DESC) AS rnk
    FROM director_summary
)

SELECT *
FROM ranked_directors
WHERE rnk <= 9;

--- only top 9 directors.

WITH director_movies AS (
    SELECT 
        n.id AS director_id,
        n.name AS director_name,
        m.id AS movie_id,
        m.date_published,
        m.duration,
        r.avg_rating,
        r.total_votes
    FROM director_mapping dm
    JOIN names n ON dm.name_id = n.id
    JOIN movie m ON dm.movie_id = m.id
    JOIN ratings r ON m.id = r.movie_id
),

inter_movie_gap AS (
    SELECT 
        a.director_id,
        DATEDIFF(b.date_published, a.date_published) AS gap_days
    FROM director_movies a
    JOIN director_movies b 
        ON a.director_id = b.director_id
        AND b.date_published > a.date_published
    WHERE NOT EXISTS (
        SELECT 1
        FROM director_movies c
        WHERE c.director_id = a.director_id
          AND c.date_published > a.date_published
          AND c.date_published < b.date_published
    )
),

director_summary AS (
    SELECT 
        dm.director_id,
        dm.director_name,
        COUNT(dm.movie_id) AS number_of_movies,
        AVG(img.gap_days) AS avg_inter_movie_days,
        AVG(dm.avg_rating) AS avg_rating,
        SUM(dm.total_votes) AS total_votes,
        MIN(dm.avg_rating) AS min_rating,
        MAX(dm.avg_rating) AS max_rating,
        SUM(dm.duration) AS total_duration
    FROM director_movies dm
    LEFT JOIN inter_movie_gap img 
        ON dm.director_id = img.director_id
    GROUP BY dm.director_id, dm.director_name
),

ranked_directors AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY number_of_movies DESC) AS rnk
    FROM director_summary
)

SELECT 
    director_id,
    director_name,
    number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration
FROM ranked_directors
WHERE rnk <= 9;