--CHAP 10 Carnival Inventory

--In this chapter, you will be writing queries to produce reports about the inventory of vehicles
--at dealerships on the Carnival platform.

--A. Available Models
--A1. Which model of vehicle has the lowest current inventory?  
--This will help dealerships know which models the purchase from manufacturers.

--Q. What does "current" mean?  
		--a. WHERE is_sold = FALSE?
		--b. Should pickup_date, purchase_date, or sale_returned fields impact current inventory counts?
--Q. How might flags on used cars impact current inventory?
		--c. Will "sold" be marked as TRUE for a used car currently in inventory?
--Q. Produce all models for ties for lowest inventory?
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
--A1.a --select the lowest inventory at each dealership along with its corresponding model
	--using a windows function
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(v.vehicle_id)) AS inventory_rank
    FROM vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE is_sold = FALSE
    GROUP BY business_name, model--get ranked list of lowest model inventories at each dealership
)

SELECT 
    dealership,
    model,
    inventory_total AS lowest_inventory
FROM dealership_inventory
WHERE inventory_rank = 1
ORDER BY dealership;--select the lowest inventory at each dealership along with its corresponding model
 
--A1.b using CTEs and subqueries:
   
WITH dealership_inventory AS (
    SELECT 
        d.business_name AS dealership, 
        vt.model,
        COUNT(v.vehicle_id) AS inventory_total
    FROM vehicles v
        JOIN vehicletypes vt USING(vehicle_type_id)
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE is_sold = FALSE
    GROUP BY business_name, model
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
    GROUP BY dealership
	) AS min_inv ON di.dealership = min_inv.dealership 
					 AND di.inventory_total = min_inv.min_inventory
ORDER BY di.dealership;
   
--2. Which model of vehicle has the highest current inventory? 
--This will help dealerships know which models are, perhaps, not selling.
   
--A2.a using a windows function
WITH dealership_inventory AS (
    SELECT 
        business_name AS dealership, 
        model,
        COUNT(v.vehicle_id) AS inventory_total,
        RANK() OVER(PARTITION BY d.business_name ORDER BY COUNT(v.vehicle_id) DESC) AS inventory_rank
    FROM vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE is_sold = FALSE
    GROUP BY business_name, model --get ranked list of highest model inventories at each dealership 
)
SELECT 
    dealership,
    model,
    inventory_total AS highest_inventory
FROM dealership_inventory
WHERE inventory_rank = 1
ORDER BY dealership;--select the highest inventory at each dealership along with its corresponding model

--A2.b 2 using CTEs and subqueries:
   
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
FROM dealership_inventory di
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
ORDER BY di.dealership;

--B - Diverse Dealerships
   
--B1. Which dealerships are currently selling the least number of vehicle models? 
--This will let dealerships market vehicle models more effectively per region.
 
--Q. How does "per region" impact the question being asked?  
--a) count of models by dealerships or
-- b) count of models by dealerships grouped by region, like by state?
   
--Q. Should the report show:
-- a) how many of each vehicle model is currently being offered i) for sale (in inventory, or is_sold = false?
--  or ii) have been sold recently (is_sold=true, or filtered by a date range?)
--OR
-- b) a count of unique vehicle models i) which have been sold, or ii) are being offered for sale currently?
--Q. Should the results be filtered for a) the model(s)  with the least sales by a ranking 
--b) the 3 least sold models, c) the MIN model sold by dealerships? (edited) 

--EDA--
SELECT COUNT(vehicle_id) AS vehicles_sold
FROM vehicles
	JOIN sales s USING (vehicle_id)
WHERE is_sold = TRUE
--vehicles marked as sold = 2481

SELECT COUNT(vehicle_id) AS vehicles_sold
FROM vehicles
	JOIN sales s USING (vehicle_id)
WHERE is_sold = TRUE AND sale_id IS NOT NULL
--vehicles marked as sold where sale_id IS NOT NULL = 2481
--NOTE: can use is_sold = TRUE for vehicles_sold

--B1.a. Least sold models at each dealership
WITH model_sales AS (
    SELECT 
        business_name AS dealership, 
        model,
        COUNT(v.vehicle_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY business_name ORDER BY COUNT(v.vehicle_id)) AS model_rank
    FROM vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE is_sold = TRUE
    GROUP BY business_name, model
)
SELECT 
    dealership,
    model,
    vehicles_sold
FROM model_sales
WHERE model_rank = 1
ORDER BY dealership;

--B1.b. Least count of unique models currently selling (being offered/in inventory) by dealership
SELECT 
	business_name AS dealership, 
    COUNT(DISTINCT model) AS unique_models
 FROM vehicles v
 	LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
 	LEFT JOIN dealerships d ON v.dealership_location_id = d.dealership_id
WHERE is_sold = FALSE
GROUP BY business_name
ORDER BY unique_models, business_name;
--most dealerships are selling about the same amount of unique models
--disregarding the add-in Porsche, Camelin Autos of North Dakota has the least models for sale at 13.

--B1.c. Least count of unique models currently selling (has sold) by dealership
SELECT 
	business_name AS dealership, 
    COUNT(DISTINCT model) AS unique_models
 FROM vehicles v
 	LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
 	LEFT JOIN dealerships d ON v.dealership_location_id = d.dealership_id
WHERE is_sold = TRUE
GROUP BY business_name
ORDER BY unique_models, business_name;


--B2.a. Which dealerships are currently selling the highest number of vehicle models?
--This will let dealerships know which regions have either a high population, or less brand loyalty.
WITH model_sales AS (
    SELECT 
        business_name AS dealership, 
        model,
        COUNT(v.vehicle_id) AS vehicles_sold,
        RANK() OVER(PARTITION BY business_name ORDER BY COUNT(v.vehicle_id) DESC) AS model_rank
    FROM vehicles v
        JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
        JOIN dealerships d ON v.dealership_location_id = d.dealership_id
    WHERE is_sold = TRUE
    GROUP BY business_name, model
)
SELECT 
    dealership,
    model,
    vehicles_sold
FROM model_sales
WHERE model_rank = 1
ORDER BY vehicles_sold DESC;
 
--B1.b. Highest count of unique models currently selling (being offered/in inventory) by dealership
SELECT 
	business_name AS dealership, 
    COUNT(DISTINCT model) AS unique_models
 FROM vehicles v
 	LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
 	LEFT JOIN dealerships d ON v.dealership_location_id = d.dealership_id
WHERE is_sold = FALSE
GROUP BY business_name
ORDER BY unique_models DESC, business_name;
--most dealerships are selling about the same amount of unique models
--disregarding the add-in Porsche, Camelin Autos of North Dakota has the least models for sale at 13.

--B1.c. Least count of unique models currently selling (has sold) by dealership
SELECT 
	business_name AS dealership, 
    COUNT(DISTINCT model) AS unique_models
 FROM vehicles v
 	LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
 	LEFT JOIN dealerships d ON v.dealership_location_id = d.dealership_id
WHERE is_sold = TRUE
GROUP BY business_name
ORDER BY unique_models DESC, business_name;
   
--NOTES: CHATGPT on population and brand loyalty:
--Population refers to the total number of people in a specific geographical area or within a certain group.
--It is a measure of the number of individuals that reside within a defined region,
--such as a city, country, or any other designated area.
   
--Brand loyalty, on the other hand, refers to the degree to which consumers consistently choose and prefer
-- a particular brand over others in the market.
-- It reflects the level of attachment, trust, and commitment a consumer has toward a specific brand.
-- Brand loyalty can lead to repeat purchases, positive word-of-mouth, and resistance to switching to competing brands.
   
--The relationship between population and brand loyalty lies in the fact that the population size of a certain area
-- or demographic can influence the potential customer base for a brand. 
--A larger population generally means a larger pool of potential customers, which can provide more opportunities
-- for building and maintaining brand loyalty. 
--However, brand loyalty is not solely determined by population size; it also depends on factors such as
-- the quality of the product or service, customer experience, marketing strategies, and brand reputation.

--In areas with larger populations, brands often have the chance to reach a larger audience, but they also face
-- more competition from other brands vying for consumer attention and loyalty.
-- In contrast, in areas with smaller populations, brands might have a more focused and niche customer base,
-- potentially leading to stronger brand loyalty among a dedicated group of consumers.

--In summary, population and brand loyalty are related in that population size can impact the potential
--customer base for a brand, but brand loyalty itself is influenced by a range of factors beyond just population size.    
