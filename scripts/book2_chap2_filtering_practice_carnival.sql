--FILTERING PRACTICE: CARNIVAL

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
