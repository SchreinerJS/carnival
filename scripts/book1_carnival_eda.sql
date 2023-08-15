SELECT *
FROM carrepairtypelogs;
--no values, only fields
-- PRIMARY KEY: car_repair_type_log_id 
	--FOREIGN KEY: possibly vehicle_id, referencing same in vehicles
	--FOREIGN KEY: possibly repair_type_id, referencing same in repairtypes

--4 columns or fields
	--car_repair_type_log_id, numeric
	--date_occurred, datetime
	--vehicle_id, numeric
	--repair_type_id, numeric
	
SELECT *
FROM customers;

--PRIMARY KEY: customer_id
--1,100 rows or UNIQUE customers
--phone field is null -- drop?
--11 columns or fields
	--customer_id, numeric
	--first_name - same field name as in employee_id, different values
	--last_name -- same field name as in employee_id, different values
	--email - string, check for syntax errors?
	--phone (NULL)
	--street, string, no abbreviations
	--city, string
	--state, string
	--zipcode, string
	--company_name, string, contains commas, hyphens
	--phone_number, string, formatted consistently with hyphens

SELECT *
FROM dealershipemployees;

--PRIMARY KEY: dealership_employee_id, 1028 UNIQUE values
	--FOREIGN KEYS: dealership_id - 1-50, (references "dealership_id" in dealerships)
	--				employee_id 1-1000, (references "employee_id" in employees)
--bridge table?
--1,028 rows, records, or observations
--3 columns or fields
	--dealership_employee_id, numeric
	--dealership_id, numeric
	--employee_id, numeric

SELECT *
FROM dealerships;
--PRIMARY KEY: dealership_id, 50 UNIQUE values
--50 rows, records, or observations [added 1]
--7 columns or fields
	--dealership_id - numeric
	--business_name - string
	--phone - string
	--city -string 
	--state - string
	--website - string
	--tax_id - ALSO A UNIQUE IDENTIFIER, string, includes hyphens 

SELECT COUNT(DISTINCT dealership_id) AS dealerships
FROM dealerships;
	--51, same as dealership_location_id in vehicles

SELECT dealership_id
FROM dealerships;

SELECT *
FROM employees;
--PRIMARY KEY: employee_id, 1000 UNIQUE values
	-- FOREIGN KEY: employee_type_id - numeric (references employee_type_id in employeetypes)
--1000 rows, records, or observations
--6 columns or fields
	--employee_id - numeric
	--first_name - string, - same field name as in customer_id, but different values
	--last_name - string - same field name as in customer_id, but different values
	--email_address - check for syntax errors?
	--phone - string, hyphenated consistently
	--employee_type_id - numeric, but won't be calculated

SELECT COUNT (DISTINCT employee_id)
FROM employees;
	-- 1000

SELECT COUNT (DISTINCT employee_type_id)
FROM employees;
--7 distinct employeee_type_ids-- see employeetypes tables for the string values of the types

SELECT *
FROM employeetypes;
--PRIMARY KEY: employee_type_id, 7 UNIQUE values
--7 rows, records, or observations
--2 columns or fields
	--employee_type_id - numeric
	--employee_type_name 
		-- Sales
		-- Finance Manager
		-- Sales Manager
		-- Customer Service
		-- Business Development
		-- General Manager
		-- Porter

SELECT *
FROM oilchangelogs;
--no values, only fields - is this in error?
-- PRIMARY KEY: oil_change_log_id 
	--FOREIGN KEY: possibly vehicle_id, referencing same in vehicles
	
--3 columns or fields
	--oil_change_log_id, numeric
	--date_occurred,  datetime
	--vehicle_id, numeric

SELECT *
FROM repairtypes;

--PRIMARY KEY: repair_type_id, 20 UNIQUE values
--20 rows, records, or observations
--2 columns or fields
	--repair_type_id - numeric
	--repair_type_name - SOME CASE INCONSISTENCY
		-- Computer Diagnostics
		-- Oil Change
		-- Air filter Change
		-- Radiator Flush & Fill Service
		--Transmission Fluid Service
		--A/C Recharge
		--Timing Belt Replacement
		--Tire Rotation and Balance
		--Battery replacement
		--Anti-Lock system
		--Axle Work Bearings/Seals
		--Shock and Strut Replacement
		--Starter
		--Suspension System Service
		--Alignments
		--Anti-Lock System Diagnosis
		--Emission Test Tune-Up
		--Alternator
		--Heater Core
		--Tire Replacement

SELECT *
FROM sales
--PRIMARY KEY: sale_id - unique identifier per sale
--PRIMARY KEY/UNIQUE IDENTIFIER: invoice_number - (each sale has a separate invoice?)
	-- FOREIGN KEY - sales_type_id (references same in salestypes)
	-- FOREIGN KEY - vehicle_id (references same in vehicles)
	-- FOREIGN KEY - employee_id (references same in employees)
	-- FOREIGN KEY - customer_id (references same in customers)
--11 columns or fields
	--sale_id, numeric
	--sales_type_id, numeric
	--vehicle_id, numeric
	--employee_id, numeric
	--customer_id, numeric
	--dealership_id, numeric
	--price, numeric (currency)
	--deposit, numeric (currency)
	--purchase_date, YYYY-MM-DD, datetime
	--pickup_date, YYYY-MM-DD, datetime
	--invoice_number, string
	--payment_method, string
	--sale_returned, boolean 
	
SELECT COUNT(sale_id)
FROM sales;
-- 5000 rows total

SELECT COUNT(DISTINCT sale_id)
FROM sales;
-- 5000 rows total
-- likely vehicle sales  
-- only one salestype per sale

SELECT COUNT(DISTINCT invoice_number)
FROM sales;
-- 5000 rows, also a unique identifier
-- one sale per invoice?  since both sale_id and invoice_number = 5000 distinct values?

SELECT COUNT(DISTINCT sales_type_id)
FROM sales;
	-- 2 - should match salestypes of vehicles, lease & purchase

SELECT COUNT(vehicle_id)
FROM sales;
	-- 5003, about 1/2 amount of vehicle_ids in vehicles

SELECT COUNT(DISTINCT vehicle_id)
FROM sales;
	-- 1000, should match vehicles

SELECT COUNT(DISTINCT employee_id)
FROM sales;
	--990, doesn't match employee_id in employees because not all employees have made sales?
	-- doesn't match dealership_employee_ids because not all dealership employees make sales?

SELECT COUNT(DISTINCT customer_id)
FROM sales;
	--1089 
	-- doesn't match UNIQUE customers, maybe because some customers have purchased only services

SELECT MIN(price)
FROM sales;
	--18002.69

SELECT MAX(price)
FROM sales; 
	--99983.29

SELECT MIN(purchase_date)
FROM sales;
	--2005-05-06

SELECT MAX(purchase_date)
FROM sales; 
	--2020-07-29

SELECT payment_method, COUNT(payment_method) AS total_methods
FROM sales
GROUP BY payment_method
ORDER BY total_methods DESC, payment_method; 
	--16 payment_methods

SELECT *
FROM salestypes
--PRIMARY KEY: sales_type_id
	--2 columns, 2 rows [updated to 3 rows]
	--sales_type_id, int
	--sales_type_name, string
	-- 1=Purchase
	-- 2=Lease
	-- 3=Rent
	
SELECT *
FROM vehicles;
--PRIMARY KEY: vehicle_id (1 per each vehicle sold)
--PRIMARY KEY/UNIQUE IDENTIFIER: vin - (each vehicle has its own VIN, no two are alike)
	-- FOREIGN KEY - vehicle_type_id (references same in vehicletypes)
	--NOTE: NO customer info in vehicle info, need to JOIN on 

--11 columns or fields
	--vehicle_id, numeric
	--vin, string
	--engine_type, string (one type per vehicle)
	--vehicle_type_id, numeric
	--exterior_color, string
	--interior_color, string
	--floor_price, numeric (currency)
	--msr_price, numeric (currency)
	--miles_count, numeric
	--year_of_car, numeric 
	--is_sold, boolean, Q. Is [V] for "value", or "true"?
	--is_new, boolean, Q. Is [V] for "value", or "true"?
	--pickup_date, YYYY-MM-DD, datetime
	--dealership_location_id, numeric 

SELECT COUNT(vehicle_id)
FROM vehicles;
	--10,000 vehicles

SELECT COUNT (DISTINCT vehicle_id)
FROM vehicles;
	--10,000 vehicles- Unique identifier in vehicles table, matches # of rows

SELECT COUNT (DISTINCT dealership_location_id)
FROM vehicles;
	--50, but not a state code [51, with updates]

SELECT DISTINCT dealership_location_id
FROM vehicles
ORDER BY dealership_location_id;
	--50 locations [51, with updates]

SELECT COUNT(DISTINCT vehicle_type_id)
FROM vehicles;
	--25 vehicle types

SELECT COUNT(is_new)
FROM vehicles
WHERE is_new = FALSE;
	--102 used vehicles

SELECT *
FROM vehicletypes;
--PRIMARY KEY: vehicle_type_id 
--4 columns or fields
	--vehicle_type_id, numeric
	--body_type, string
	--make, string
	--model, string
--30 DISTINCT vehicle_type_ids & rows, based on body_type, make, and model of vehicle

SELECT vehicle_type_id,
		COUNT(vehicle_id) AS "total_vehicles"
FROM vehicles
GROUP BY vehicle_type_id
ORDER BY vehicle_type_id;
	--25 vehicle types, however note that the description of many values is the same


SELECT COUNT (DISTINCT body_type)
FROM vehicletypes;
	--4 body_types

SELECT body_type, COUNT(vehicle_type_id) AS "total_body_types"
FROM vehicletypes
GROUP BY body_type
ORDER BY body_type;

SELECT COUNT(DISTINCT make)
FROM vehicletypes;
	--5 vehicle types

SELECT make, COUNT(vehicle_type_id) AS "total_body_types"
FROM vehicletypes
GROUP BY make
ORDER BY total_body_types DESC;

SELECT COUNT(DISTINCT model)
FROM vehicletypes;
	--16 model types

SELECT model, COUNT(vehicle_type_id) AS "total_body_types"
FROM vehicletypes
GROUP BY model
ORDER BY total_body_types DESC;
