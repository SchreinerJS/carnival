--Using WHERE clause with = operator:
SELECT	last_name,
		first_name
FROM customer
WHERE first_name = 'Jamie';

--Using WHERE clause with AND operator:
SELECT	last_name,
		first_name
FROM
		customer
WHERE	first_name = 'Jamie' AND
		last_name = 'Rice';
	
--Using WHERE clause with OR operator:
SELECT
	first_name,
	last_name
FROM
	customer
WHERE
	last_name = 'Rodriguez' OR 
	first_name = 'Adam';

--Using WHERE clause with IN operator:
SELECT
	first_name,
	last_name
FROM
	customer
WHERE 
	first_name IN ('Ann','Anne','Annie');
	
--Using WHERE clause with LIKE operator;
--'%' percent symbol is wildcard to match any string
--'_' underscore symbol matches any single character in a string

SELECT
	first_name,
	last_name
FROM
	customer
WHERE 
	first_name LIKE 'Ann%'
	
--Using WHERE clause with BETWEEN operator;
SELECT
	first_name,
	LENGTH(first_name) name_length
FROM
	customer
WHERE 
	first_name LIKE 'A%' AND
	LENGTH(first_name) BETWEEN 3 AND 5
ORDER BY
	name_length;

--Using WHERE clause not equal <> operator;
SELECT 
	first_name,
	last_name
FROM
	customer
WHERE
	first_name LIKE 'Bra%' AND
	last_name <> 'Motley';


	
