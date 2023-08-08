--Query the rental information of customer id 1 and 2:
SELECT 
	customer_id,
	rental_id,
	return_date
FROM
	rental
WHERE
	customer_id IN (1, 2)
ORDER BY
	return_date DESC;
	
--Query the same using = & OR operators (same result)
SELECT
	rental_id,
	customer_id,
	return_date
FROM
	rental
WHERE
	customer_id = 1 OR customer_id = 2
ORDER BY
	return_date DESC;

--Query all rentals where the customer id is not 1 or 2

SELECT
	customer_id,
	rental_id,
	return_date
FROM
	rental
WHERE
	customer_id NOT IN (1, 2);

--Query same using <> and AND operators (same result)

SELECT
	customer_id,
	rental_id,
	return_date
FROM
	rental
WHERE
	customer_id <> 1
AND customer_id <> 2;

--Retrieve customer ids from rental table with return date of 2005-05-27
SELECT customer_id
FROM rental
WHERE CAST (return_date AS DATE) = '2005-05-27'
ORDER BY customer_id;

--Use above as a subquery to retrieve above along with customer first & last name
SELECT
	customer_id,
	first_name,
	last_name
FROM
	customer
WHERE
	customer_id IN (
		SELECT customer_id
		FROM rental
		WHERE CAST (return_date AS DATE) = '2005-05-27'
		ORDER BY customer_id
	)
ORDER BY customer_id;