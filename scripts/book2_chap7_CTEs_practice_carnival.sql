--PRACTICE CTESs

--Top 5 Dealerships

--1A. For the top 5 dealerships, which employees made the most sales?

--solution_i
WITH DealershipRank AS (
		SELECT 
			dealership_id,
			business_name,
			total_dealership_sales,
			RANK() OVER(ORDER BY total_dealership_sales DESC) AS dealership_rank
		FROM 
			(
				SELECT d.dealership_id,
					d.business_name,
					SUM(s.price) AS total_dealership_sales
				FROM
					sales s
					INNER JOIN employees e USING (employee_id)
					INNER JOIN dealerships d USING (dealership_id)
				GROUP BY d.dealership_id
			) AS dealership_sales -- calculate dealership rank by total sales
),

EmployeeRank AS (
		SELECT 
			employee_id,
			dealership_id,
			ee_sales_by_dealership,
			RANK() OVER(PARTITION BY dealership_id ORDER BY ee_sales_by_dealership DESC) AS employee_rank
		FROM 
			(
				SELECT s.employee_id,
					s.dealership_id,
					SUM(s.price) AS ee_sales_by_dealership
				FROM
					sales s
					INNER JOIN employees e USING (employee_id)
					INNER JOIN dealerships d USING (dealership_id)
				GROUP BY s.dealership_id, s.employee_id
			) AS employee_sales -- calculate employee rank by sales per dealership
)

SELECT business_name AS top_dealerships,
		total_dealership_sales,
		e.first_name || ' ' || e.last_name AS top_employee,
		ee_sales_by_dealership
FROM DealershipRank
	LEFT JOIN EmployeeRank USING(dealership_id)
	LEFT JOIN employees e USING(employee_id)
WHERE dealership_rank BETWEEN 1 AND 5
	AND employee_rank = 1
ORDER BY total_dealership_sales DESC; --select the top 5 dealerships in sales 
									  --and the top employee for each those dealerships in sales

--top_dealerships				total_dealership_sales	top_employees	ee_sales_by_dealership
--Junes Autos of Texas			7748707.79			Harwilll Pawlyn		177971.11
--Gladman Autos of New York		6942027.97			Sondra Brigg		163472.82
--Gorgen Autos of Pennsylvania	6935597.41			Tonya Cuesta		155791.86
--Meeler Autos of San Diego		6864260.07			Latrina Robertelli	145847.17
--Mertgen Autos of Alabama		6731101.33			Tracee Mengo		149292.24

--NOTE: Could I use UNBOUNDED PRECEDING and RANGE to select the top 5 and top 1 in the CTEs,
--rather than the WHERE filter in the outer query?

--solution_ii

--a. Calculate total sales for each employee
--b. Rank employees within each dealership based on their total sales
--c. Select the top employee in each dealership
--d. Rank dealerships based on their total sales
--e. Select the top five dealerships

WITH EmployeeSales AS (
	SELECT  e.employee_id, 
		e.first_name,
		e.last_name,
		d.dealership_id,
		SUM(s.price) AS employee_sales
		FROM sales s
			INNER JOIN employees e USING (employee_id)
			INNER JOIN dealerships d USING (dealership_id)
	GROUP BY e.employee_id, d.dealership_id--total sales by employee
),

RankedEmployees AS (
	SELECT
		employee_id,
		first_name,
		last_name,
		employee_sales,
		dealership_id,
		RANK() OVER (PARTITION BY dealership_id ORDER BY employee_sales DESC NULLS LAST)
    FROM EmployeeSales--rank employees within each dealership based on their total sales
),

TopEmployeeByDealership AS (
	SELECT
		employee_id,
		first_name,
		last_name,
		employee_sales,
		dealership_id
	FROM RankedEmployees
	WHERE rank = 1--select the top employee in each dealership
),

DealershipTotalSales AS (
    SELECT
        d.dealership_id,
        d.business_name,
        SUM(s.price) AS dealership_sales
    FROM
        dealerships d
    JOIN
        sales s USING(dealership_id)
    GROUP BY
        d.dealership_id, d.business_name
    ORDER BY
        dealership_sales DESC --rank dealerships based on their total sales

)

SELECT
    t1.business_name AS top_dealerships,
    t1.dealership_sales AS dealership_total_sales,
    t2.first_name || ' ' || t2.last_name AS top_employee_name,
    t2.employee_sales AS employee_total_sales    
FROM
    TopEmployeeByDealership t2
JOIN
    DealershipTotalSales t1 ON t2.dealership_id = t1.dealership_id
ORDER BY
    dealership_total_sales DESC
LIMIT 5;--Select the top selling employee at each of the five top selling dealerships

--top_dealerships		dealership_total_sales	top_employee_name	employee_sales_by_dealership
--Junes Autos of Texas			7748707.79			Harwilll Pawlyn		177971.11
--Gladman Autos of New York		6942027.97			Sondra Brigg		163472.82
--Gorgen Autos of Pennsylvania	6935597.41			Tonya Cuesta		155791.86
--Meeler Autos of San Diego		6864260.07			Latrina Robertelli	145847.17
--Mertgen Autos of Alabama		6731101.33			Tracee Mengo		149292.24



--1B. For the top 5 dealerships, which vehicle models were the most popular in sales?
--NOTE: revise this code based on new ranked solution for top 5 dealerships
   
WITH DealershipTotalSales AS (
    SELECT
        d.dealership_id,
        d.business_name,
        SUM(s.price) AS dealership_sales
    FROM
        dealerships d
    JOIN
        sales s USING(dealership_id)
    GROUP BY
        d.dealership_id, d.business_name
    ORDER BY
        dealership_sales DESC
    LIMIT 5--top 5 dealerships based on their total sales
),

ModelSales AS (
	SELECT  vt.model,
			d.dealership_id,
			d.business_name,
			SUM(s.price) AS model_sales
			FROM sales s
				JOIN vehicles v USING(vehicle_id)
				JOIN vehicletypes vt USING (vehicle_type_id)
				JOIN dealerships d ON (v.dealership_location_id = d.dealership_id)
		GROUP BY vt.model, d.dealership_id--sum of sales by model and dealership
),

RankedModels AS (
	SELECT
		model,
		model_sales,
		dealership_id,
		business_name,
		RANK() OVER (PARTITION BY dealership_id ORDER BY model_sales DESC NULLS LAST)
    FROM ModelSales--rank top selling models at each dealership
),

TopModelByDealership AS (
	SELECT
		dealership_id,
		business_name,
		model,
		model_sales
	FROM RankedModels
	WHERE rank = 1--select the top employee in each dealership
)

--checks: 544 rows; dealerships 51 x 16 models = 816, but not all models will exist at all dealerships
	
SELECT
    t1.business_name AS top_dealerships,
    t1.dealership_sales AS total_sales,
    t2.model AS top_model_name,
    t2.model_sales AS dealership_model_sales    
FROM
    TopModelByDealership t2
JOIN
    DealershipTotalSales t1 ON t2.dealership_id = t1.dealership_id
ORDER BY
    total_sales DESC
LIMIT 5;--Select the top selling models for the top 5 dealerships in sales


--For the top 5 dealerships, were there more sales or leases?
WITH DealershipTotalSales AS (
    SELECT
        d.dealership_id,
        d.business_name,
        SUM(s.price) AS dealership_sales
    FROM
        dealerships d
    JOIN
        sales s USING(dealership_id)
    GROUP BY
        d.dealership_id, d.business_name
    ORDER BY
        dealership_sales DESC
    LIMIT 5
),

DealershipSalesTypes AS (
	SELECT 
		d.dealership_id,
		d.business_name AS dealership,
		SUM(CASE WHEN st.sales_type_id = 1 THEN price ELSE 0 END) AS purchase,
		SUM(CASE WHEN st.sales_type_id = 2 THEN price ELSE 0 END) AS lease
	FROM dealerships d
	LEFT JOIN sales s ON s.dealership_id = d.dealership_id
	INNER JOIN salestypes st USING(sales_type_id)
	GROUP BY d.dealership_id
	ORDER BY dealership
)

SELECT 
	t1.business_name AS top_dealerships,
	t1.dealership_sales AS total_sales,
	t2.purchase,
	t2.lease,
	CASE WHEN t2.purchase > t2.lease THEN 'purchase' ELSE 'lease' END AS most_sales
FROM
    DealershipSalesTypes t2
JOIN
    DealershipTotalSales t1 ON t2.dealership_id = t1.dealership_id
ORDER BY
    total_sales DESC
LIMIT 5;

--Used Cars

--For all used cars, which states sold the most? The least?

WITH used_car_sales AS (
	SELECT t1.vehicle_id, s.sale_id, s.dealership_id
		FROM (
				SELECT v.vehicle_id
				FROM vehicles v
				JOIN vehicletypes vt USING(vehicle_type_id)
				WHERE vt.body_type LIKE 'Car' AND v.is_new = FALSE) AS t1
		JOIN sales s USING(vehicle_id)--select used cars
),
		
used_cars_by_state AS (
	SELECT d.state, COUNT(sale_id) AS total_used_car_sales
		FROM dealerships d
			JOIN used_car_sales USING(dealership_id)
		GROUP BY d.state
		ORDER BY total_used_car_sales DESC
)

SELECT *
FROM used_cars_by_state;
--Texas has the most, with 32 used cars sold
--Colorado & Indiana are tied with the least, with 3 cars sold each

SELECT state, MAX(total_used_car_sales) AS most_sold
FROM used_cars_by_state
GROUP BY state
ORDER BY most_sold DESC
LIMIT 1;

SELECT state, MIN(total_used_car_sales) AS least_sold
FROM used_cars_by_state
GROUP BY state
ORDER BY least_sold
LIMIT 2;

SELECT COUNT(vehicle_id)
FROM vehicles v
--10,001

SELECT COUNT(vehicle_id)
FROM sales s 
--5003

SELECT COUNT (DISTINCT vehicle_id)
FROM sales s
--1000

--For all used cars, which model is greatest in the inventory? 
WITH used_cars AS (
	SELECT t1.vehicle_id, t1.make, t1.model
		FROM (
				SELECT v.vehicle_id,
						vt.make,
						vt.model
				FROM vehicles v
				JOIN vehicletypes vt USING(vehicle_type_id)
				WHERE vt.body_type LIKE 'Car' AND v.is_new = FALSE) AS t1--select used cars
),
				
used_cars_by_model AS (
	SELECT model, 
			COUNT(vehicle_id) AS total_used_cars
	FROM used_cars
	GROUP BY model
	ORDER BY total_used_cars DESC
)

SELECT *
FROM used_cars_by_model;
--ANSWER: Corvette, with 12 in inventory
--NOTE: should is_sold = FALSE?

--Which make is greatest inventory?

WITH used_cars AS (
	SELECT t1.vehicle_id, t1.make, t1.model
		FROM (
				SELECT v.vehicle_id,
						vt.make,
						vt.model
				FROM vehicles v
				JOIN vehicletypes vt USING(vehicle_type_id)
				WHERE vt.body_type LIKE 'Car' AND v.is_new = FALSE) AS t1--select used cars
),
				
used_cars_by_make AS (
	SELECT make, 
			COUNT(vehicle_id) AS total_used_cars
	FROM used_cars
	GROUP BY make
	ORDER BY total_used_cars DESC
)

SELECT *
FROM used_cars_by_make;
--ANSWER: Nissan, with 19 in inventory
--NOTE: should is_sold = FALSE?


--*NOTE: can I answer both with one query?

--Practice

--Talk with your teammates and think of another scenario where you can use a CTE 
--to answer multiple business questions about employees, inventory, sales, deealerships or customers.

--CHATGPT GENERATED questions:
--Customer Loyalty Assessment:
--Identify customers who have made more than one purchase 
--and list their contact information along with the count of purchases they've made.

----Inventory Analysis:
--For each vehicle type, find the average and maximum price of vehicles. 
--Present the results along with the vehicle type details.

--Employee Performance Tier:
--Categorize employees into performance tiers based on their average sales price. 
--Use a CTE to calculate the average sales price for each employee
--and assign them to "High," "Medium," or "Low" performance tiers.

--Sales Mix Analysis:
--Determine the percentage of sales attributed to each sales type (purchase or lease). 
--Present a breakdown of sales types along with their respective percentages.

--Geographic Dealership Distribution:
--How many dealerships are located in each city? 
--Utilize a CTE to aggregate the count of dealerships per city and present the results.

--My questions:
--What is the most popular year of each model sold?



