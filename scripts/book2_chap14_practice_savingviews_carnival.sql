--Converting Your Practice Queries into Views
--It's time to convert some of your report queries into views so that other database developers
-- and application developers can quickly gain access to useful reports without having to write their own SQL.

--Review all of the queries that you wrote for chapters 9, 10, 11 & 12.
--Determine which of those views you feel would be most useful over time.
--Consider the view itself, or how it could be integrated into another query and/or view.

--1. Sales Income by Dealership
CREATE VIEW total_dealership_sales_income_purchases AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
WHERE s.sales_type_id = 1
GROUP BY d.dealership_id
ORDER BY dealership;

CREATE VIEW total_dealership_sales_income_leases AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
WHERE s.sales_type_id = 2
GROUP BY d.dealership_id
ORDER BY dealership;

CREATE VIEW dealership_sales_income AS
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY dealership;

--If there were several software applications written that access this database 
--(e.g. HR applications, sales/tax applications, online purchasing applications, etc.)
-- which, if any, of your queries should be converted into views that multiple applications would like use?

--Be prepared to discuss, and defend your choices in the next class.