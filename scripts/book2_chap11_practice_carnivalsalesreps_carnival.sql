--CHAP 11 - Carnival Sales Reps
--Employee Reports

SELECT COUNT(*)
FROM employees;
--1001 employees total

--1. How many employees are there for each role?

SELECT et.employee_type_id, employee_type_name, COUNT(*)
FROM employees e 
	JOIN employeetypes et USING(employee_type_id)
GROUP BY et.employee_type_id, employee_type_name;

--NOTE: 144 finance managers total

--2. How many finance managers work at each dealership?
SELECT business_name AS dealership, COUNT(de.employee_id)
FROM employees e 
	JOIN dealershipemployees de ON e.employee_id = de.employee_id
	JOIN dealerships d USING(dealership_id)
WHERE employee_type_id = 2
GROUP BY d.business_name
ORDER BY d.business_name;

--3. Get the names of the top 3 employees who work shifts at the most dealerships?

--EDA--
--Q are there any employees who have more than one role?
SELECT employee_id, first_name, last_name, COUNT(employee_type_id) AS total_roles
FROM employees 
GROUP BY employee_id, last_name, first_name
ORDER BY total_roles DESC
--1001 - one employee is assigned to more than one role

WITH dealership_shifts AS (
	SELECT 	e.employee_id,
			first_name,
			last_name,
			COUNT(de.dealership_id) AS total_dealerships,
			RANK() OVER(ORDER BY COUNT(de.dealership_id) DESC ) AS employee_rank
	FROM employees e
		JOIN dealershipemployees de USING(employee_id)
	GROUP BY e.employee_id, first_name, last_name
	ORDER BY total_dealerships DESC
)
SELECT first_name || ' ' || last_name AS employee_name,
		total_dealerships
FROM dealership_shifts
WHERE employee_rank IN (1,2)
ORDER BY total_dealerships DESC, employee_name;

--There is only 1 top employee working at 3 locations, then a group tied for 2nd

--CHECKS--29 employees are working at more than one dealership, 1 at 3, the rest at 2
SELECT * 
FROM employee_dealership_names en
WHERE 
	(SELECT COUNT(*) 
	FROM employee_dealership_names en1
	WHERE en.employee_id = en1.employee_id) > 1

--4. Get a report on the top two employees who has made the most sales through leasing vehicles.

WITH employee_leasing_sales AS
	(
		SELECT  first_name, 
				last_name,
				SUM(price) AS total_leasing_sales
		FROM sales s
			LEFT JOIN salestypes st USING (sales_type_id)
			JOIN employees e USING(employee_id)
		WHERE st.sales_type_id = 2
		GROUP BY first_name, last_name
		ORDER BY total_leasing_sales DESC
	)

SELECT first_name || ' ' || last_name AS employee_name,
		total_leasing_sales
FROM employee_leasing_sales
LIMIT 2;

--Q. Better to write code using the ids for practice with larger databases?
--Q. When GROUP BY first_name, last_name -- could there be an issue?  
	-- Is it better to join again to employee table at end to bring in the name?
--Q. Better to use rank and select rank vs. LIMIT?
