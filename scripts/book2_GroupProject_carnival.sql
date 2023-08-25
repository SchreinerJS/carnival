--Creating Carnival Reports
--Carnival would like to harness the full power of reporting. 
--Let's begin to look further at querying the data in our tables. 
--Carnival would like to understand more about thier business and needs you to help them build some reports.

--Goal
--Below are some desired reports that Carnival would like to see. 
--Use your query knowledge to find the following metrics.

--Employee Reports
--Best Sellers

--Who are the top 5 employees for generating sales income?

WITH SalesByEmployee AS (
	SELECT s.employee_id,
			first_name,
			last_name,
			SUM(s.price) AS total_ee_sales
	FROM sales s
	JOIN employees e ON (s.employee_id = e.employee_id)
	GROUP BY s.employee_id, first_name, last_name--aggregate sales by employee
),

EmployeeRank AS (
	SELECT 	employee_id,
			last_name,
			first_name,
			total_ee_sales,
			RANK() OVER(ORDER BY total_sales DESC) AS employee_rank
	FROM SalesByEmployee--rank employees by total_sales
)			
SELECT employee_id, first_name || ' ' || last_name AS employee_name, total_sales, employee_rank
FROM EmployeeRank
WHERE employee_rank BETWEEN 1 AND 5--select the top 5 employees by sales income generated

--Who are the top 5 dealership for generating sales income?

SELECT d.business_name AS dealership,
	SUM(s.price) AS total_ds_sales
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY total_ds_sales DESC
LIMIT 5;--select top 5 dealerships by total sales income generated

--dealership_sales_income VIEW
CREATE OR REPLACE VIEW dealership_sales_income AS
SELECT d.business_name AS dealership,
    	SUM(s.price) AS total_ds_sales
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY total_ds_sales DESC;
 
 
SELECT *
FROM dealership_sales_income
ORDER BY total_ds_sales DESC
LIMIT 5;--select top 5 dealerships by total sales income generated using a view

--Which vehicle model generated the most sales income?

SELECT vt.model AS top_model,
	SUM(s.price) AS total_model_sales
FROM sales s
JOIN vehicles v ON s.vehicle_id = v.vehicle_id
LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.model
ORDER BY total_model_sales DESC
LIMIT 1;

--Top Performance
--Which employees generate the most income per dealership?

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
ORDER BY dealership--

--BELOW IS THE employee_dealership_names view
CREATE OR REPLACE VIEW vwEmployeeDealershipNames AS
SELECT e.employee_id,
    e.first_name,
    e.last_name,
    first_name || ' ' || last_name AS employee_name,
    d.business_name AS dealership,
    d.dealership_id,
    de.dealership_employee_id
   FROM employees e
     JOIN dealershipemployees de ON e.employee_id = de.employee_id
     JOIN dealerships d ON d.dealership_id = de.dealership_id;

--working query--    
SELECT edn.dealership, edn.employee_name, 
FROM vwEmployeeDealershipNames edn
	JOIN sales s ON edn.employee_id = s.employee.id
GROUP BY ORDER BY employee_name

--Jessalynn's code--
WITH sales_rank AS (
    SELECT 
    	de.dealership_id,
        e.employee_id, 
        e.first_name || ' ' || e.last_name AS employee_name,
        SUM(s.price) AS total_sales_by_price,
        RANK() OVER (PARTITION BY de.dealership_id ORDER BY SUM(s.price) DESC) AS sales_rank
    FROM employees e 
    JOIN sales s ON e.employee_id = s.employee_id 
    JOIN dealershipemployees de ON de.employee_id = e.employee_id
    GROUP BY e.employee_id, e.first_name, e.last_name, de.dealership_id
)
SELECT
    d.dealership_id,
    d.business_name,
    sr.employee_id, 
    sr.employee_name,
    sr.total_sales_by_price
FROM
    sales_rank sr
JOIN
    dealerships d ON d.dealership_id = sr.dealership_id
WHERE
    sr.sales_rank = 1;

--Vehicle Reports
--Inventory
--In our Vehicle inventory, show the count of each Model that is in stock.
--In our Vehicle inventory, show the count of each Make that is in stock.
--In our Vehicle inventory, show the count of each BodyType that is in stock.

--Purchasing Power
--Which US state's customers have the highest average purchase price for a vehicle?
--Now using the data determined above, which 5 states have the customers with the highest average purchase price for a vehicle?