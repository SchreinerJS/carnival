--FILTERING PRACTICE: CARNIVAL

-- Get a list of sales records where the sale was a lease.
-- 2 = lease
-- no JOINS yet
-- to return entire record
SELECT *
FROM sales s
WHERE s.sales_type_id = 2;
--400 leased sales
	
--Get a list of sales where the purchase date is within the last five years.

SELECT MIN(purchase_date)
FROM sales
--2005-05-06

SELECT MAX(purchase_date)
FROM sales
--2020-07-29

--Returning purchase dates between five years from today:
SELECT *
FROM sales s
WHERE s.purchase_date >= current_date - interval '5 years'
ORDER BY s.purchase_date DESC;
--642 sales

--Returning the last five years of sales in the database
SELECT *
FROM sales s
WHERE s.purchase_date BETWEEN
	(SELECT MAX(purchase_date) - interval '5 years' FROM sales)
	AND 
	(SELECT MAX(purchase_date) FROM sales)
ORDER BY s.purchase_date DESC;
--1665 sales

--Get a list of sales where the deposit was above 5000 or the customer payed with American Express.
SELECT *
FROM sales s
WHERE deposit > 5000 OR s.payment_method LIKE 'am%'
ORDER BY deposit;
--3742 sales

--Get a list of employees whose first names start with "M" or ends with "d".
SELECT *
FROM employees e
WHERE first_name ILIKE 'm%' AND first_name LIKE '%d';
--2 employees

--Get a list of employees whose phone numbers have the 604 area code.
SELECT *
FROM employees e
WHERE phone LIKE '604%';
--3 employees
