-- Calculate the average replacement cost of all films:
SELECT
	ROUND( AVG( replacement_cost ), 2 ) avg_replacement_cost
FROM
	film;
	
--Calculate the average replacement cost of the Drama films whose category id is 7
SELECT
	ROUND( AVG( replacement_cost ), 2 ) avg_replacement_cost
FROM
	film
INNER JOIN film_category USING(film_id)
INNER JOIN category USING(category_id)
WHERE
	category_id = 7;
	
-- get the number of films
SELECT 
    COUNT(*) 
FROM 
    film;
    
--get number of drama films
SELECT
	COUNT(*) drama_films
FROM
	film
INNER JOIN film_category USING(film_id)
INNER JOIN category USING(category_id)
WHERE
	category_id = 7;
	
--what is the maximum replacement cost of films?
SELECT 
    MAX(replacement_cost)
FROM 
    film;
    
--get the films that have the maximum replacement cost
SELECT
	film_id,
	title
FROM
	film
WHERE
	replacement_cost =(
		SELECT
			MAX( replacement_cost )
		FROM
			film
	)
ORDER BY
	title;
	
--return the minimum replacement cost of films:

SELECT 
    MIN(replacement_cost)
FROM 
    film;

--get the films which have the minimum replacement cost

SELECT
	film_id,
	title
FROM
	film
WHERE
	replacement_cost =(
		SELECT
			MIN( replacement_cost )
		FROM
			film
	)
ORDER BY
	title;
	
--calculate the total length of films grouped by film’s rating
SELECT
	rating,
	SUM( rental_duration )
FROM
	film
GROUP BY
	rating
ORDER BY
	rating;