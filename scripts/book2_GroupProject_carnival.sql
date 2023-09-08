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
--OPTION 1, if concerned there might be duplicate totals

WITH SalesByEmployee AS (
	SELECT s.employee_id,
			first_name || ' ' || last_name AS employee_name,
			SUM(s.price) AS total_ee_sales
	FROM sales s
	JOIN employees e ON (s.employee_id = e.employee_id)
	GROUP BY s.employee_id, first_name, last_name
	ORDER BY total_ee_sales DESC--aggregate sales by employee
),

EmployeeRank AS (
	SELECT 	employee_id,
			employee_name,
			total_ee_sales,
			RANK() OVER(ORDER BY total_ee_sales DESC) AS employee_rank
	FROM SalesByEmployee--rank employees by total_sales
)			
SELECT employee_id, employee_name, total_ee_sales, employee_rank
FROM EmployeeRank
WHERE employee_rank BETWEEN 1 AND 5--select the top 5 employees by sales income generated

--OPTION 2, if not concerned there might be duplicate totals

SELECT s.employee_id,
	first_name || ' ' || last_name AS employee_name,
	SUM(s.price) AS total_ee_sales
FROM sales s
JOIN employees e ON (s.employee_id = e.employee_id)
GROUP BY s.employee_id, first_name, last_name
ORDER BY total_ee_sales DESC
LIMIT 5; --aggregate sales by employee and provide top 5 in DESC order

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

--ANSWER, without using a view
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

--ANSWER using employee_dealership_names view
--Rank top employees by total sales
WITH ranked_employee_sales AS (
	SELECT edn.dealership_id,
		edn.dealership,
		s.employee_id,
		edn.employee_name,
		SUM(s.price) AS total_sales,
		RANK() OVER (PARTITION BY edn.dealership ORDER BY SUM(s.price) DESC) AS sales_rank			
	FROM vwEmployeeDealershipNames edn
		JOIN sales s ON edn.employee_id = s.employee_id
	GROUP BY edn.dealership_id, edn.dealership, s.employee_id, edn.employee_name
)
--Select top ranked employee at each dealership
SELECT dealership,
		employee_name,
		total_sales AS top_ranked_sales
FROM ranked_employee_sales
WHERE sales_rank = 1
ORDER BY dealership;

/*Vehicle Reports

--Inventory
--In our Vehicle inventory, show the count of each Model that is in stock.*/

SELECT model, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY model
ORDER BY model;

--In our Vehicle inventory, show the count of each Make that is in stock.
SELECT make, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY make
ORDER BY make;

--In our Vehicle inventory, show the count of each BodyType that is in stock.
SELECT body_type, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY body_type
ORDER BY body_type;

--Purchasing Power
--Which US state's customers have the highest average purchase price for a vehicle?

SELECT customer_state, ROUND(AVG(purchase_price),2) AS avg_purchase_price
FROM vwCustomerPurchasesByState
GROUP BY customer_state
ORDER BY avg_purchase_price DESC
LIMIT 1;

--Now using the data determined above, 
--which 5 states have the customers with the highest average purchase price for a vehicle?
SELECT customer_state, ROUND(AVG(purchase_price),2) AS avg_purchase_price
FROM vwCustomerPurchasesByState
GROUP BY customer_state
ORDER BY avg_purchase_price DESC
LIMIT 5;