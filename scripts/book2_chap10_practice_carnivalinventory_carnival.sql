--Carnival Inventory
--In this chapter, you will be writing queries to produce reports about the inventory of vehicles
--at dealerships on the Carnival platform.

--Available Models
--1. Which model of vehicle has the lowest current inventory?  
--This will help dealerships know which models the purchase from manufacturers.

--Q. What does "current" mean?  
		--a. WHERE is_sold = FALSE?
		--b. Should pickup_date, purchase_date, or sale_returned fields
			-- impact current inventory counts?
--Q. How might flags on used cars impact current inventory?
		--c. Will "sold" be marked as TRUE for a used car currently in inventory?
--Q. Produce all models should there be ties for lowest inventory?
----------------------------------------------------------------------
--EDA
--Q. What are the max pickup & purchase dates?
SELECT MAX(pickup_date)
FROM sales;
--MAX pickup date is 2020-08-22

SELECT MAX(purchase_date)
FROM sales;
--MAX purchase date is 2020-07-29

--Q. Should sale_returned impact current inventory?
SELECT COUNT(sale_returned) AS returned_sales
FROM sales
WHERE sale_returned = TRUE;
--30

SELECT COUNT(is_sold)
FROM vehicles v
WHERE is_sold = FALSE;
--5061 vehicles are not marked as sold

SELECT COUNT(is_sold)
FROM vehicles v
	JOIN sales s USING (vehicle_id)
WHERE is_sold = FALSE AND pickup_date IS NULL;
--2 sold vehicles do not have a pickup date
----------------------------------------------------------------------
--ANSWER 1 using a windows function
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(v.vehicle_id)) AS inventory_rank
    FROM 
        vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = FALSE
    GROUP BY 
        d.business_name, vt.model--get ranked list of lowest model inventories at each dealership
)
SELECT 
    dealership,
    model,
    inventory_total AS lowest_inventory
FROM 
    dealership_inventory
WHERE 
    inventory_rank = 1
ORDER BY 
    dealership;--select the lowest inventory at each dealership along with its corresponding model

--ANSWER 2 using CTEs and subqueries:
   
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total
    FROM 
        vehicles v
        JOIN vehicletypes vt USING(vehicle_type_id)
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = FALSE
    GROUP BY 
        d.business_name, vt.model
)
SELECT 
    di.dealership,
    di.model,
    di.inventory_total AS lowest_inventory
FROM 
    dealership_inventory di
JOIN (
    SELECT 
        dealership,
        MIN(inventory_total) AS min_inventory
    FROM 
        dealership_inventory
    GROUP BY 
        dealership
) min_inv ON di.dealership = min_inv.dealership 
							  AND di.inventory_total = min_inv.min_inventory
ORDER BY 
    di.dealership;

--2. Which model of vehicle has the highest current inventory? 
--This will help dealerships know which models are, perhaps, not selling.
   
--ANSWER 1 using a windows function
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(v.vehicle_id) DESC) AS inventory_rank
    FROM 
        vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = FALSE
    GROUP BY 
        d.business_name, vt.model --get ranked list of highest model inventories at each dealership 
)
SELECT 
    dealership,
    model,
    inventory_total AS most_inventory
FROM 
    dealership_inventory
WHERE 
    inventory_rank = 1
ORDER BY 
    dealership;--select the lowest inventory at each dealership along with its corresponding model

--ANSWER 2 using CTEs and subqueries:
   
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total
    FROM 
        vehicles v
        JOIN vehicletypes vt USING(vehicle_type_id)
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = FALSE
    GROUP BY 
        d.business_name, vt.model
     )
SELECT 
    di.dealership,
    di.model,
    di.inventory_total AS most_inventory
FROM 
    dealership_inventory di
JOIN (
    SELECT 
        dealership,
        MAX(inventory_total) AS most_inventory
    FROM 
        dealership_inventory
    GROUP BY 
        dealership
) most_inv ON di.dealership = most_inv.dealership 
							  AND di.inventory_total = most_inv.most_inventory
ORDER BY 
    di.dealership;

--Diverse Dealerships
--3. Which dealerships are currently selling the least number of vehicle models? 
--This will let dealerships market vehicle models more effectively per region.

--EDA--
SELECT COUNT(vehicle_id) AS vehicles_sold
FROM vehicles
	JOIN sales s USING (vehicle_id)
WHERE is_sold = TRUE
--vehicles marked as sold = 4940

SELECT COUNT(vehicle_id) AS vehicles_sold
FROM vehicles
	JOIN sales s USING (vehicle_id)
WHERE is_sold = TRUE AND sale_id IS NOT NULL
--vehicles marked as sold where sale_id IS NOT NULL = 2481

--models with sale_id, marked as sold, by sale_id
WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.sale_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.sale_id)) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = TRUE--should this field be included, or just go by sale_id?
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;

--models with sale_id, by sale_id  (produces more numbers than 1st query)
WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.sale_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.sale_id)) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;

--models by vehicle id, marked as sold (produces same numbers as 1st query)
WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.vehicle_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.vehicle_id)) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = TRUE--should this field be included, or just go by sale_id?
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;   
   
   
--4. Which dealerships are currently selling the highest number of vehicle models?
--This will let dealerships know which regions have either a high population, or less brand loyalty.
   WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.sale_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.sale_id) DESC) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = TRUE--should this field be included, or just go by sale_id?
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;

--models with sale_id, by sale_id  (produces more numbers than 1st query)
WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.sale_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.sale_id) DESC) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;

--models by vehicle id, marked as sold (produces same numbers as 1st query)
WITH model_sales AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(s.vehicle_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(s.vehicle_id) DESC) AS model_rank
    FROM 
        sales s
        JOIN vehicles v ON s.vehicle_id = v.vehicle_id
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE 
        v.is_sold = TRUE--should this field be included, or just go by sale_id?
    GROUP BY 
        d.business_name, vt.model
        
    )
SELECT 
    dealership,
    model,
    vehicles_sold
FROM 
    model_sales
WHERE 
    model_rank = 1
ORDER BY 
    dealership;   