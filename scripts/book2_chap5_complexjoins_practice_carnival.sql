--Chap 5 COMPLEX JOINS Practice: 
--Sales Type by Dealership

--1. Produce a report that lists every dealership, the number of purchases done by each, 
--and the number of leases done by each.

SELECT 
	d.business_name AS dealership,
	SUM(CASE WHEN st.sales_type_id = 1 THEN 1 ELSE 0 END) AS purchase,
	SUM(CASE WHEN st.sales_type_id = 2 THEN 1 ELSE 0 END) AS lease
FROM dealerships d
	LEFT JOIN sales s ON s.dealership_id = d.dealership_id
	INNER JOIN salestypes st ON s.sales_type_id = st.sales_type_id
GROUP BY d.dealership_id
ORDER BY dealership; --code corrected afer review with CHATGPT AND team

--Practice: Leased Types

--2. Produce a report that determines the most popular vehicle model that is leased.
SELECT vt.model AS most_popular_model, 
	COUNT(s.sales_type_id) AS total_leased
FROM sales s 
	JOIN vehicles v ON s.vehicle_id = v.vehicle_id
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
WHERE s.sales_type_id = 2
GROUP BY vt.model
ORDER BY total_leased DESC
LIMIT 1;
--The most popular leased vehicle is the Maxima, with 294 leases

--Practice: Who Sold What

--What is the most popular vehicle make in terms of number of sales?
--NOTE: If "sales" includes both purchases and leases:
SELECT 	vt.make AS most_popular_make,
		COUNT(*) AS total_sales
FROM sales s
	JOIN vehicles v ON s.vehicle_id = v.vehicle_id
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.make
ORDER BY total_sales DESC
LIMIT 1;
--Nissan is the most popular vehicle with 1360 total sales

--2. Which employee type sold the most of that make?
SELECT  et.employee_type_name,
		COUNT(s.sale_id) AS total_nissan_sales
FROM
	employeetypes et
INNER JOIN employees e ON et.employee_type_id = e.employee_type_id
INNER JOIN sales s ON e.employee_id = s.employee_id
LEFT JOIN vehicles v ON s.vehicle_id = v.vehicle_id
INNER JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
WHERE vt.make LIKE 'Nissan'
GROUP BY et.employee_type_name
ORDER BY total_nissan_sales DESC
LIMIT 1;	--Customer Service employee type also sold the most Nissans (507) if sales include purchase & leases

SELECT  et.employee_type_name,
		COUNT(s.sale_id) AS total_nissan_sales
FROM
	employeetypes et
	INNER JOIN employees e ON et.employee_type_id = e.employee_type_id
	INNER JOIN sales s ON e.employee_id = s.employee_id
	LEFT JOIN vehicles v ON s.vehicle_id = v.vehicle_id
	INNER JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
WHERE vt.make LIKE 'Nissan' AND s.sales_type_id = 1
GROUP BY et.employee_type_name
ORDER BY total_nissan_sales DESC
LIMIT 1;	--Customer Service employee type sold the most Nissans (117) where sales are puchase only

--MORE practice questions FROM CHATGPT:
--1. Employee Performance Evaluation:
--What is the average sales price for each employee in the Sales table? 

--Dealer Performance Comparison:
--Which dealership has the highest total sales revenue? 
