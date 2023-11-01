--CREATING A FUNCTION -- sample (Odie)
CREATE OR REPLACE FUNCTION func_totalSalesRecords()
RETURNS integer
language plpgsql
AS $$

DECLARE
	totalSales integer; --holds result

BEGIN
	SELECT COUNT(*) INTO totalSales FROM sales;

	RETURN totalSales;
END
$$;

SELECT func_totalSalesRecords(); -- call the function

--FUNCTION that returns two columns (Odie)
--Which model of vehicle has the highest current inventory?
SELECT v2.model, COUNT(v.vehicle_id) AS number_sold 
FROM vehicles v
JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
WHERE v.is_sold = FALSE
GROUP BY v2.model
ORDER BY number_sold DESC
LIMIT 1; 

CREATE OR REPLACE FUNCTION func_vehicleModel_highest_inventory()
RETURNS TABLE
(
	model VARCHAR(50), --hover over the column of the original query to get the data type
		number_sold bigint
)
language plpgsql
AS $$

BEGIN
	RETURN QUERY
	SELECT v2.model, COUNT(v.vehicle_id) AS number_sold FROM vehicles v
	JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
	WHERE v.is_sold = FALSE
	GROUP BY v2.model
	ORDER BY number_sold DESC
	LIMIT 1; 
END
$$; 

--BONUS QUESTIONS 
-- Create a function that returns the most popular vehicle make in terms of number of sales?
SELECT model, number_sold
FROM func_vehicleModel_highest_inventory()

--
SELECT 	vt.make AS most_popular_make,
		COUNT(s.sale_id) AS total_sales
FROM sales s
	INNER JOIN vehicles v ON s.vehicle_id = v.vehicle_id
	INNER JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.make
ORDER BY total_sales DESC
LIMIT 1;


CREATE OR REPLACE FUNCTION func_vehicleMake_most_sales()
RETURNS TABLE
(
	model VARCHAR(50), --hover over the column of the original query to get the data type
		number_sold bigint
)
language plpgsql
AS $$

BEGIN
	RETURN QUERY
	SELECT v2.make, COUNT(v.vehicle_id) AS number_sold
	FROM vehicles v
	JOIN vehicletypes v2 ON v.vehicle_type_id = v2.vehicle_type_id
	WHERE v.is_sold = FALSE
	GROUP BY v2.model
	ORDER BY number_sold DESC
	LIMIT 1; 
END
$$; 

SELECT model, number_sold
FROM func_vehicleModel_highest_inventory();



-- Create a function that returns the employee type sold the most of that make?
-- Create a function that returns the top 5 US states with the most customers who have purchased a vehicle from a dealership participating in the Carnival platform?
-- Create a function that returns the top 5 US zipcodes with the most customers who have purchased a vehicle from a dealership participating in the Carnival platform?
-- For all used cars, create a function that returns which states sold the most? The least?
-- Create a stored procedure that adds a new record to the vehicletypes table
-- Create a stored procedure that adds a new record in the sales table
-- Create a stored procedure that removes a record from the sales table
-- Create a stored procedure that adds a mew record to the carrepairtypelogs table 