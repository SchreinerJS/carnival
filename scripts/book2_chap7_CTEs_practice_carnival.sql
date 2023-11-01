--PRACTICE -- CTES -- CHAP 7

--Top 5 Dealerships

--1A. For the top 5 dealerships, which employees made the most sales?
--Q. What makes a dealership "top" in sales -- the sales amount, or the total number of sales?
	--could be either way
--Q. Are leases considered "sales", or rather, part of total revenue?  
	--for this exercise, unless purchase/lease specified, counting purchases and leases as sales

--Solution 1
--top 5 dealerships in total sales (amount)
--and the top employee at each of those dealerships,
--by their total sales at that dealership

WITH DealershipRank AS (
		SELECT dealership_id, business_name, total_dealership_sales,
			RANK() OVER(ORDER BY total_dealership_sales DESC) AS dealership_rank
		FROM 
			(
				SELECT d.dealership_id,
					d.business_name,
					SUM(s.price) AS total_dealership_sales
				FROM
					sales s
					JOIN dealerships d ON (s.dealership_id = d.dealership_id)
				GROUP BY d.dealership_id
			) AS dealership_sales -- calculate dealership rank by total sales
),

EmployeeRank AS (
		SELECT employee_id, dealership_id, ee_sales_by_dealership,
			RANK() OVER(PARTITION BY dealership_id ORDER BY ee_sales_by_dealership DESC) AS employee_rank
		FROM 
			(
				SELECT s.employee_id,
					s.dealership_id,
					SUM(s.price) AS ee_sales_by_dealership
				FROM
					sales s
					INNER JOIN employees e ON (s.employee_id = e.employee_id)
					INNER JOIN dealerships d ON (s.dealership_id = d.dealership_id)
				GROUP BY s.dealership_id, s.employee_id
			) AS employee_sales -- calculate employee rank by sales per dealership
)

SELECT business_name AS top_dealerships,
		total_dealership_sales,
		e.first_name || ' ' || e.last_name AS top_employee,
		ee_sales_by_dealership
FROM DealershipRank AS dr
	LEFT JOIN EmployeeRank AS er ON (dr.dealership_id = er.dealership_id)
	LEFT JOIN employees e USING(employee_id)
WHERE dealership_rank BETWEEN 1 AND 5
	AND employee_rank = 1
ORDER BY total_dealership_sales DESC; -- selecting top 5 dealerships ranked by total sales, top employee at each dealership, and the total sales amounts for each

--APPROACH #2 - top dealerships and employees by number of sales.
--Employee sales by employee_id only, not grouped by dealership
--NOTE: duplicates due to ranking ties and employees working at more than one dealership
--revise from Odie's solution 

WITH dealership_count_sales AS

(
	SELECT DISTINCT d.business_name AS dealership,
	d.dealership_id,
	COUNT(*) OVER(PARTITION BY d.dealership_id) AS dealership_sales_count
	FROM sales s
	INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
	ORDER BY dealership_sales_count DESC
	LIMIT 5
),

employee_count_sales AS 
(
	SELECT DISTINCT	s.employee_id, 
					e.first_name || ' ' || e.last_name AS employee_name,
					COUNT(*) OVER(PARTITION BY e.employee_id) AS employee_sales_count,
					de.dealership_id					
	FROM sales s
	JOIN dealershipemployees de ON s.employee_id = de.employee_id
	INNER JOIN employees e ON de.employee_id = e.employee_id
	ORDER BY dealership_id, employee_sales_count DESC
),

top_employee_by_dealership AS
(
	SELECT
	dcs.dealership_id,
	dcs.dealership,
	ecs.employee_id,
	ecs.employee_name,
	ecs.employee_sales_count,
	RANK() OVER(PARTITION BY dcs.dealership_id 
				ORDER BY ecs.employee_sales_count DESC) AS e_rank
	FROM dealership_count_sales dcs
	JOIN employee_count_sales ecs ON dcs.dealership_id = ecs.dealership_id
)

SELECT te.dealership, 
	te.employee_name,
	te.employee_id,
	te.employee_sales_count
	FROM top_employee_by_dealership te
		INNER JOIN dealership_count_sales dcs ON te.dealership_id = dcs.dealership_id
	WHERE e_rank = 1
	ORDER BY dcs.dealership_sales_count DESC;
    
--1B OR 2. For the top 5 dealerships, which vehicle models were the most popular in sales?
WITH TopFiveDealerships AS 
(
	SELECT dealership_id, business_name, count_dealership_sales,
			RANK() OVER(ORDER BY count_dealership_sales DESC) AS dealership_rank
	FROM 
	(
		SELECT d.dealership_id,d.business_name, 
				COUNT(*) AS count_dealership_sales
		FROM sales s
		INNER JOIN dealerships d ON (s.dealership_id = d.dealership_id)
		GROUP BY d.dealership_id
		) AS dealership_sales
	LIMIT 5-- calculate top 5 ranked dealerships by total sales
),

RankedModelSales AS
(
	SELECT dealership_id, model, total_sales,
	RANK() OVER(PARTITION BY dealership_id ORDER BY total_sales DESC) AS model_rank
	FROM 
	(
		SELECT s.dealership_id, vt.model, COUNT(*) AS total_sales
		FROM sales s
		INNER JOIN vehicles v ON s.vehicle_id = v.vehicle_id
		LEFT JOIN vehicletypes vt ON (v.vehicle_type_id = vt.vehicle_type_id)
		GROUP BY s.dealership_id, vt.model
		ORDER BY s.dealership_id, total_sales DESC ) AS sales_by_model
)

SELECT t5.business_name AS top_five_dealerships, rms.model, rms.total_sales
FROM TopFiveDealerships AS t5
	INNER JOIN RankedModelSales rms ON(t5.dealership_id = rms.dealership_id)
WHERE t5.dealership_rank BETWEEN 1 AND 5 AND rms.model_rank = 1
ORDER BY t5.dealership_rank


--1C or 3.  For the top 5 dealerships, were there more sales or leases?

WITH DealershipTotalSales AS (
    SELECT 
    d.dealership_id,
    d.business_name,
    COUNT(*) AS dealership_sales
    FROM dealerships d
    JOIN sales s ON (d.dealership_id = s.dealership_id)
    GROUP BY d.dealership_id, d.business_name
    ORDER BY dealership_sales DESC
    LIMIT 5
),

DealershipSalesTypes AS (
	SELECT d.dealership_id,
		d.business_name AS dealership,
		SUM(CASE WHEN s.sales_type_id = 1 THEN 1 ELSE 0 END) AS purchase,
		SUM(CASE WHEN s.sales_type_id = 2 THEN 1 ELSE 0 END) AS lease
	FROM dealerships d
	LEFT JOIN sales s ON s.dealership_id = d.dealership_id
	GROUP BY d.dealership_id
	ORDER BY dealership
)

SELECT 
	t1.business_name AS top_dealerships,
	t1.dealership_sales AS total_sales,
	t2.purchase,
	t2.lease,
	CASE WHEN t2.purchase > t2.lease THEN 'purchase' ELSE 'lease' END AS most_sales
FROM DealershipSalesTypes t2
JOIN DealershipTotalSales t1 ON t2.dealership_id = t1.dealership_id
ORDER BY total_sales DESC;

--Used Cars

--For all used cars, which states sold the most? The least?
--Q. Are we looking at car body type only (WHERE vt.body_type LIKE 'Car'), or does "cars" actually mean "vehicles"  
--Q. ('is_sold' = TRUE) will produce different results than just counting sale_ids, so does this mean 
		--not all vehicles with a sales_id are marked as "is_sold"?

--most
WITH UsedCarsSoldByState AS
(
	SELECT
	d.state,
	COUNT(*) AS total_used_cars_sold
	FROM sales s
	INNER JOIN vehicles v on s.vehicle_id = v.vehicle_id
	INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
	WHERE v.is_new = FALSE
	GROUP BY d.state
	ORDER BY total_used_cars_sold DESC
),

StateRank AS
(
	SELECT 
	uc.state,
	uc.total_used_cars_sold,
	RANK() OVER(ORDER BY total_used_cars_sold DESC) AS rank
	FROM UsedCarsSoldByState AS uc
)

SELECT
sr.state,
sr.total_used_cars_sold AS most_used_cars_sold,
sr.rank
FROM StateRank sr

--if wanting to just show the result add this:

WHERE rank = 1;  -- most used cars sold
--California w/69 vehicles sold; or with 40 vehicles sold if filtered also by "is_sold = TRUE"

--least
WITH UsedCarsSoldByState AS
(
	SELECT
	d.state,
	COUNT(*) AS total_used_cars_sold
	FROM sales s
	INNER JOIN vehicles v on s.vehicle_id = v.vehicle_id
	INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
	WHERE v.is_new = FALSE
	GROUP BY d.state
	ORDER BY total_used_cars_sold
),

StateRank AS
(
	SELECT 
	uc.state,
	uc.total_used_cars_sold,
	RANK() OVER(ORDER BY total_used_cars_sold) AS rank
	FROM UsedCarsSoldByState AS uc
)

SELECT sr.state, sr.total_used_cars_sold AS most_used_cars_sold
FROM StateRank sr
WHERE rank = 1;  -- least used cars sold

--For all used cars, which model is greatest in the inventory?

--Q For just body_type = 'Car', or all used vehicles?
--Q Filter on 'is_sold = false' as well?
--If a vehicle has been sold, should it be moved to the sales database, or marked as "is_sold"?
--Has this been done consistently with a transaction, or manually/individually?

--Solution #1
WITH used_car_models_inv AS
(
	SELECT
	vt.model AS used_car_model,
	COUNT (*) AS total_in_inv
	FROM vehicles v
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE vt.body_type LIKE 'Car' 
		AND v.is_new = FALSE
		AND v.is_sold = FALSE
	GROUP BY vt.model--select used cars in inventory
	ORDER BY total_in_inv DESC
)

SELECT m1.used_car_model, m1.total_in_inv AS most_in_inventory
FROM used_car_models_inv AS m1
WHERE total_in_inv = (SELECT MAX(total_in_inv) FROM used_car_models_inv);
--ANSWER: if looking for body_type = 'Car', Corvette, with 12 in inventory

--Solution #2
WITH used_car_models_inv AS
(
	SELECT
	vt.model AS used_car_model,
	COUNT (*) AS total_in_inv
	FROM vehicles v
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE v.is_new = FALSE AND v.is_sold = FALSE
	GROUP BY vt.model--select used cars in inventory
	ORDER BY total_in_inv DESC
)

SELECT m1.used_car_model, m1.total_in_inv AS most_in_inventory
FROM used_car_models_inv AS m1
WHERE total_in_inv = (SELECT MAX(total_in_inv) FROM used_car_models_inv);
--ANSWER: if looking all used vehicles, Titan, with 15 in inventory

--Which make is greatest inventory?

--Solution #1
WITH used_car_makes_inv AS
(
	SELECT
	vt.make AS used_car_make,
	COUNT (*) AS total_in_inv
	FROM vehicles v
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE vt.body_type LIKE 'Car' 
		AND v.is_new = FALSE
		AND v.is_sold = FALSE
	GROUP BY vt.make--select used cars in inventory
	ORDER BY total_in_inv DESC
)

SELECT m2.used_car_make, m2.total_in_inv AS most_in_inventory
FROM used_car_makes_inv AS m2
WHERE m2.total_in_inv = (SELECT MAX(total_in_inv) FROM used_car_makes_inv);
--ANSWER for body_type = car: Nissan, with 19 in inventory

--Solution #2
WITH used_car_makes_inv AS
(
	SELECT
	vt.make AS used_car_make,
	COUNT (*) AS total_in_inv
	FROM vehicles v
	JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
	WHERE v.is_new = FALSE AND is_sold = FALSE --select used cars in inventory
	GROUP BY vt.make
	ORDER BY total_in_inv DESC 
)

SELECT m2.used_car_make, m2.total_in_inv AS most_in_inventory
FROM used_car_makes_inv AS m2
WHERE m2.total_in_inv = (SELECT MAX(total_in_inv) FROM used_car_makes_inv);

--Practice

--Talk with your teammates and think of another scenario
--where you can use a CTE to answer multiple business questions
--about employees, inventory, sales, deealerships or customers.

--CHATGPT GENERATED questions:
--Customer Loyalty Assessment:
--Identify customers who have made more than one purchase 
--and list their contact information along with the count of purchases they've made.

WITH customer_total_purchases AS 
	(
		SELECT customer_id, COUNT(*) AS total_purchases
		FROM sales s
		WHERE s.sales_type_id = 1
		GROUP BY s.customer_id
	)

SELECT tp.total_purchases, c.last_name, c.first_name, c.email, c.phone_number 
FROM customer_total_purchases tp
JOIN customers c USING(customer_id)
WHERE total_purchases > 1
ORDER BY total_purchases DESC, c.last_name;

--Inventory Analysis:
--For each vehicle type, find the average and maximum price of vehicles. 
--Present the results along with the vehicle type details.

--NOTE, in this database there are duplicate body_types.  This query will act on the understanding that vehicle type is
--a make/model combination
--NOTE, there is a large price discrepancy between new & used, so it might be good to determine if we want to see both.

SELECT * FROM vwvehicletypes vwvt

CREATE OR REPLACE VIEW public.vwvehicletypes
AS SELECT v.vehicle_id,
    v.vin,
    vt.body_type,
    vt.make,
    vt.model,
    vt.vehicle_type_id
   FROM vehicles v
     LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id;--revise view to include vehicle_type_id

WITH vehicle_price AS 
(
	SELECT
	s.vehicle_id,
	s.price,
	vwvt.vehicle_type_id,
	vwvt.make ||' '|| vwvt.model AS vehicle_type,
	vwvt.body_type 
	FROM sales s
	JOIN vwvehicletypes vwvt ON s.vehicle_id = vwvt.vehicle_id -- CTE to pull price for every vehicle with its vehicle_type & body_type
)

SELECT vp.vehicle_type, vp.body_type, ROUND(AVG(vp.price),2) AS average_price, MAX(vp.price) AS max_price
FROM vehicle_price vp
GROUP BY vp.vehicle_type, vp.body_type
ORDER BY vehicle_type

--for each vehicle, show the average sale price & max sale price, along with the vehicle type details & sale price

WITH vehicle_price AS
(
  SELECT 
  s.sale_id,
  s.vehicle_id,
  s.price,
  vwt.vehicle_type_id,
  vwt.make ||' '|| vwt.model AS vehicle_type,
  vwt.body_type 
  FROM sales s 
  JOIN vwvehicletypes vwt ON s.vehicle_id = vwt.vehicle_id
)
SELECT  
	vp.sale_id,
	vp.vehicle_id,
	vp.vehicle_type,
	vp.body_type,
	vp.price,
    ROUND(AVG(price) OVER (PARTITION BY vehicle_type), 2) AS average_price,
    MAX(price) OVER (PARTITION BY vehicle_type) AS max_price
FROM vehicle_price vp
ORDER BY vp.vehicle_id, vp.price

--Employee Performance Tier:
--Categorize employees into performance tiers based on their average sales price. 
--Use a CTE to calculate the average sales price for each employee
--and assign them to "High," "Medium," or "Low" performance tiers.

--find the overall average of all employee sales
SELECT ROUND(AVG(s.price), 2) AS avg_sale_price
FROM sales s 
JOIN employees e USING (employee_id)
ORDER BY avg_sale_price DESC
--58,517.66

--find the MAX and MIN of AVG employee sales
WITH avg_employee_sales AS
(
	SELECT e.employee_id, e.last_name || ', ' || e.first_name AS employee_name, ROUND(AVG(s.price), 2) AS avg_sale_price
	FROM sales s 
	JOIN employees e USING (employee_id)
	GROUP BY e.employee_id
	ORDER BY avg_sale_price DESC
)

SELECT MAX(avg_sale_price)
FROM avg_employee_sales
--97,349.64

WITH avg_employee_sales AS
(
	SELECT e.employee_id, e.last_name || ', ' || e.first_name AS employee_name, ROUND(AVG(s.price), 2) AS avg_sale_price
	FROM sales s 
	JOIN employees e USING (employee_id)
	GROUP BY e.employee_id
	ORDER BY avg_sale_price DESC
)
SELECT MIN(avg_sale_price)
FROM avg_employee_sales
--18,020.12



--Sales Mix Analysis:
--Determine the percentage of sales attributed to each sales type (purchase or lease). 
--Present a breakdown of sales types along with their respective percentages.

--Geographic Dealership Distribution:
--How many dealerships are located in each city? 
--Utilize a CTE to aggregate the count of dealerships per city and present the results.

--My question:
--What is the most popular year of each model sold?
SELECT *
FROM vwvehicletypes

SELECT *
FROM vehicles


--The "sales-per-employee" ratio is annual sales divided by total employees.
--Key sales metrics to track: https://blog.hubspot.com/sales/sales-metrics
	--Total revenue = quantity of products and services sold x price of the product or service
	--Revenue by product or service = income generated per product or service
	--Market penetration = total customer base compared with total market potential