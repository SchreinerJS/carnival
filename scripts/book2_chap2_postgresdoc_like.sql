--Retrieve customers who have a first name like 'Jen'
SELECT
	first_name,
    last_name
FROM
	customer
WHERE
	first_name LIKE 'Jen%';

--Retrieve customers who have a first name with 'er'
SELECT
	first_name,
        last_name
FROM
	customer
WHERE
	first_name LIKE '%er%'
ORDER BY 
        first_name;

--Retrieve customers who have a first name that begins with any single character
--followed by 'her', and ending with any number of charactesr
SELECT
	first_name,
	last_name
FROM
	customer
WHERE
	first_name LIKE '_her%'
ORDER BY 
        first_name;
        
--Select customers whose first names do not begin with 'Jen'
SELECT
	first_name,
	last_name
FROM
	customer
WHERE
	first_name NOT LIKE 'Jen%'
ORDER BY 
        first_name
        
--Select customers whose first names begin with 'Bar'
SELECT
	first_name,
	last_name
FROM
	customer
WHERE
	first_name ILIKE 'BAR%';
	
