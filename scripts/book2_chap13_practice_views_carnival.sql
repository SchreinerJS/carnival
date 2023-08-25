--Chapter 13 - Virtual Tables with Views

--Example view from lesson:  
--Create a view for employees and the dealerships they work at:

CREATE OR REPLACE VIEW employee_dealership_names AS
SELECT 
    e.employee_id,--added employee_id for future joins
    e.first_name,
    e.last_name,
    d.business_name AS dealership, -- renamed
    d.dealership_id--added FOR future joins
FROM employees e
	INNER JOIN dealershipemployees de ON e.employee_id = de.employee_id
 	INNER JOIN dealerships d ON d.dealership_id = de.dealership_id;
  
SELECT *
FROM employee_dealership_names;

SELECT 	first_name || ' ' || last_name AS ee_name, dealership
FROM employee_dealership_names
ORDER BY ee_name;

--CHECKS--29 employees are working at more than one dealership
SELECT * 
FROM employee_dealership_names en
WHERE 
	(SELECT COUNT(*) 
	FROM employee_dealership_names en1
	WHERE en.employee_id = en1.employee_id) > 1


--Practice: Carnival

--Create a view that lists all vehicle body types, makes and models.
-- Should this be all vehicles (vehicle_id) along with their respective body_type, make, and model?)
-- added VIN which could be more meaningful for a dealership than vehicle_id;

CREATE VIEW vWvehicletypes AS
SELECT v.vehicle_id, vin, body_type, make, model
FROM vehicles v
	LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id;

SELECT *
FROM vWvehicletypes;

--Create a view that shows the total number of employees for each employee type.
CREATE VIEW vWTotalEmployeesByType AS
SELECT DISTINCT employee_type_name AS employee_type, COUNT(employee_id)
FROM employees e
	LEFT JOIN employeetypes et ON e.employee_type_id = et.employee_type_id
GROUP BY employee_type_name;

SELECT *
FROM vWTotalEmployeesByType;

--Create a view that lists all customers without exposing their emails, phone numbers and street address.
CREATE VIEW vWCustomersPublic AS
SELECT c.customer_id,
	c.last_name,
	c.first_name,
	company_name,
	c.state,
	c.zipcode
FROM customers c; 

SELECT *
FROM vWCustomersPublic;

--Create a view named sales2018 that shows the total number of sales for each sales type for the year 2018.
--1st approach: 
SELECT DISTINCT st.sales_type_name AS sales_type,
	COUNT(sale_id) AS total_sales
FROM sales s
	LEFT JOIN salestypes st ON s.sales_type_id = st.sales_type_id
WHERE purchase_date BETWEEN '2018-01-01' AND '2018-12-31'
GROUP BY st.sales_type_name;

--2nd approach: 
SELECT DISTINCT st.sales_type_name AS sales_type,
	COUNT(sale_id) AS total_sales
FROM sales s
	LEFT JOIN salestypes st ON s.sales_type_id = st.sales_type_id
WHERE EXTRACT(YEAR FROM purchase_date) = 2018
GROUP BY st.sales_type_name;

CREATE VIEW sales2018 AS
SELECT DISTINCT st.sales_type_name AS sales_type,
	COUNT(sale_id) AS total_sales
FROM sales s
	LEFT JOIN salestypes st ON s.sales_type_id = st.sales_type_id
WHERE EXTRACT(YEAR FROM purchase_date) = 2018
GROUP BY st.sales_type_name;

SELECT *
FROM sales2018;

CREATE VIEW vwsales2018 AS
SELECT DISTINCT st.sales_type_name AS sales_type,
	COUNT(sale_id) AS total_sales,
	SUM(price) AS total_sales_amount
FROM sales s
	LEFT JOIN salestypes st ON s.sales_type_id = st.sales_type_id
WHERE EXTRACT(YEAR FROM purchase_date) = 2018
GROUP BY st.sales_type_name;

SELECT *
FROM vwsales2018;

--Create a view that shows the employee at each dealership with the most number of sales.

SELECT *
FROM sales

--Q. in sales table, is dealership_id the dealership the sale was made at or where the vehicle was located?
--We have employees who can work at more than one dealership, 3 at most according to prior analysis
--in Chap 11 Employee Recognition.  
--Sales database shows an employee_id attached to sales from up to five different dealerships
--Is there a way to determine employee sales by dealership, or only employee sales across all dealerships?

SELECT COUNT(*)
FROM sales -- 5003 sales

SELECT COUNT(DISTINCT employee_id)
FROM sales -- 990 employee_ids in sales

SELECT DISTINCT employee_id, COUNT(*) AS employee_sales
FROM sales
GROUP BY employee_id
ORDER BY employee_sales DESC -- when not grouped by dealership, up to 12 sales per employee_id 

SELECT DISTINCT employee_id, COUNT(sale_id) AS employee_sales
FROM sales
GROUP BY employee_id
ORDER BY employee_sales DESC--same as above

SELECT 	dealership_id,
		employee_id,		
		COUNT(*) AS ee_sales
FROM sales s
GROUP BY employee_id, dealership_id
ORDER BY dealership_id, ee_sales DESC, employee_id -- when grouped by ee_id & dealership, up to 3 sales per employee

SELECT employee_id, dealership_id
FROM sales
WHERE dealership_id IS NULL -- No NULL dealership_ids

--so how can an employee have 12 sales, if only up to 3 sales per ee_id & dealership_id,
--and employees work at 3 dealerships at most?

SELECT dealership_id, 
			employee_id, 
			COUNT(sale_id) AS total_sales
FROM sales
GROUP BY dealership_id, employee_id
ORDER BY dealership_id, total_sales DESC--this query shows employee_ids in sales database are connected
										--to dealership_ids they do not work at;
										--dealership_id in sales database may be dealership where vehicle is located

--So then, for employees working at more than one dealership, how to determine which dealership to attribute
--the employee's sale to?

--ANSWER BELOW--may not be sales by "dealership" due to lack of clarity re: dealership_id in sales database

CREATE VIEW vWTopEmployeeCountofSalesByDealership AS

WITH dealership_employees AS 
(
	SELECT dealership,
			employee_id,
			first_name,
			last_name
	FROM employee_dealership_names
),

	employee_rank AS 
(
		SELECT dealership,
			first_name,
			last_name, 
			SUM(s.price) AS total_sales,
			RANK() OVER (PARTITION BY dealership ORDER BY SUM(s.price) DESC) AS sales_rank			
		FROM dealership_employees de
			INNER JOIN sales s ON de.employee_id = s.employee_id
		GROUP BY dealership, first_name, last_name
)

SELECT dealership,
	first_name || ' ' || last_name AS employee_name,
	total_sales AS top_ranked_sales
FROM employee_rank
WHERE sales_rank = 1
ORDER BY dealership

SELECT *
FROM vWTopEmployeeCountofSalesByDealership

