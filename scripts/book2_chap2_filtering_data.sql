--Find customers who are from Texas:
SELECT
	last_name, first_name, city, state
FROM
	customers
WHERE
	state = 'TX';

-- Find customers who are from Houston, TX:

SELECT
	c.last_name, c.first_name, c.city, c.state
FROM
	customers c
WHERE
	c.city = 'Houston' AND c.state = 'TX';

-- Find customers who are from Texas or Tennessee:

SELECT
	c.last_name, c.first_name, c.city, c.state
FROM
	customers c
WHERE
	c.state = 'TX' OR c.state = 'TN';

--For providing a list of values in the WHERE clause, use IN.
-- Find customers who are from Texas, Tennessee or California:

SELECT
	c.last_name, c.first_name, c.city, c.state
FROM
	customers c
WHERE
	c.state IN ('TX', 'TN', 'CA');

--For pattern matching, use LIKE. The % is a wildcard that means anything can come after the "C".
-- Find customers who are from states that start with the letter C:

SELECT
	c.last_name, c.first_name, c.city, c.state
FROM
	customers c
WHERE
	c.state LIKE 'C%';

-- Find customers whose last name is greater than 5 characters
-- and first name is less than or equal to 7 characters:

SELECT
	c.last_name, c.first_name
FROM
	customers c
WHERE
	LENGTH(c.last_name) > 5 AND LENGTH(c.first_name) <= 7;

-- If you want to specify a range in the WHERE clause, use BETWEEN.
-- Customers whose company name has between 10 and 20 characters (greater than or equal to 10 and less than or equal to 20):

SELECT
	c.last_name, c.first_name, c.company_name
FROM
	customers c
WHERE
	LENGTH(c.company_name) BETWEEN 10 AND 20;

-- Find customers whose company name is null:
-- Because NULL is not equal to any value (even itself), this will not work.

SELECT
	c.last_name, c.first_name, c.company_name
FROM
	customers c
WHERE
	c.company_name = NULL;

-- Instead, we do the following:

SELECT
	c.last_name, c.first_name, c.company_name
FROM
	customers c
WHERE
	c.company_name IS NULL;

--PRACTICE: CARNIVAL

-- Get a list of sales records where the sale was a lease.
-- 2 = lease
-- no JOINS yet
-- to return entire record
SELECT *
FROM sales s
WHERE s.sales_type_id = 2;
--400 leased sales

-- to return essential columns related to the sale
SELECT  
	s.sales_type_id, s.sale_id
FROM sales s
WHERE s.sales_type_id = 2;
--400 leased sales

-- to show the sale was a lease:
SELECT 
	s.sale_id,
	s.sales_type_id,
	st.sales_type_name
FROM sales s
	INNER JOIN salestypes st 
	ON s.sales_type_id = st.sales_type_id
WHERE s.sales_type_id = 2;
--400 leased sales
	
--Get a list of sales where the purchase date is within the last five years.
--NOTE: database MIN purchase_date = 2005-05-06
--		database MAX purchase_date = 2020-07-29
--understand the question to mean the "last five years" from today
--rather than the last five years of the databse in question

SELECT *
FROM sales s
WHERE s.purchase_date BETWEEN '2019-08-08' AND '2023-08-08'
ORDER BY s.purchase_date DESC;
--327 sales

SELECT *
FROM sales s
WHERE s.purchase_date >= '2019-08-08'
ORDER BY s.purchase_date DESC;
--327 sales

--Get a list of sales where the deposit was above 5000 or the customer payed with American Express.
SELECT
	s.sale_id,
	s.deposit,
	s.payment_method
FROM sales s
WHERE deposit > 5000 OR s.payment_method LIKE 'am%'
ORDER BY deposit;
--3742 sales

--Get a list of employees whose first names start with "M" or ends with "d".
SELECT 
	e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE first_name ILIKE 'm%' AND first_name LIKE '%d';
--2 employees

--Get a list of employees whose phone numbers have the 604 area code.
SELECT 
	e.employee_id, e.first_name, e.last_name, phone
FROM employees e
WHERE phone LIKE '604%';
--3 employees
