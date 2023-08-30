/*Converting Your Practice Queries into Views
It's time to convert some of your report queries into views so that other database developers
 and application developers can quickly gain access to useful reports without having to write their own SQL.

Review all of the queries that you wrote for chapters 9, 10, 11 & 12.
Determine which of those views you feel would be most useful over time.
Consider the view itself, or how it could be integrated into another query and/or view.

*--If there were several software applications written that access this database 
--(e.g. HR applications, sales/tax applications, online purchasing applications, etc.)
-- which, if any, of your queries should be converted into views that multiple applications would like use?

--Be prepared to discuss, and defend your choices in the next class.*/

--1. Sales Income by Dealership
--a.Purchase sales income
CREATE VIEW total_dealership_sales_income_purchases AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
WHERE s.sales_type_id = 1
GROUP BY d.dealership_id
ORDER BY dealership;

--a.Lease sales income
CREATE VIEW total_dealership_sales_income_leases AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
WHERE s.sales_type_id = 2
GROUP BY d.dealership_id
ORDER BY dealership;

--a. All sales income
CREATE VIEW dealership_sales_income AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY dealership;


--All vehicles id, vin, body_type, make, model, color, is_sold, is_new
CREATE VIEW vwVehicleTypesStatus AS
SELECT 	vehicle_id,
		vin,
		body_type,
		make,
		model,
		interior_color,
		exterior_color,
		is_sold,
		is_new
FROM vehicles v
	LEFT JOIN vehicletypes vt 
	ON v.vehicle_type_id = vt.vehicle_type_id;

SELECT *
FROM vehicles

--All customer purchases by state
CREATE OR REPLACE VIEW vwCustomerPurchasesByState AS
SELECT c.customer_id, 
	c.first_name,
	c.last_name,
	c.first_name || ' ' || c.last_name AS customer_fullname,
	c.state AS customer_state,
	s.sale_id,
	s.price AS purchase_price
FROM customers c
	JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sales_type_id = 1
ORDER BY state

