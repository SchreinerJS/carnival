--CHAP 12 - Carnival Customers
--In these exercises, you will be using data from the Customers table. You will need to use the following concepts.

--Sub-queries or CTE
--AVG() function
--COUNT() function
--JOIN
--GROUP BY
--ORDER BY
--LIMIT

--States With Most Customers

--1. What are the top 5 US states with the most customers who have purchased a vehicle
-- from a dealership participating in the Carnival platform?

--EDA-- have customers purchased more than one vehicle?
SELECT c.customer_id, COUNT(sale_id) AS total_sales
FROM sales s
	JOIN salestypes st USING (sales_type_id)
	JOIN customers c USING (customer_id)
WHERE sale_id IS NOT NULL
	AND sales_type_id = 1
GROUP BY c.customer_id
ORDER BY customer_id ;

--EDA -- Are there customers in the sales database who have not made a purchase?
SELECT c.customer_id, COUNT(sale_id) AS total_sales
FROM sales s
	JOIN salestypes st USING (sales_type_id)
	JOIN customers c USING (customer_id)
WHERE sale_id IS NULL
	AND sales_type_id = 1
GROUP BY c.customer_id
ORDER BY customer_id;
--no, there are no null values in sale_id column

SELECT state AS top_five_states, 
	COUNT(DISTINCT s.customer_id) AS total_customers--count DISTINCT customers 
FROM sales s
	JOIN salestypes st USING (sales_type_id)
	JOIN customers c USING (customer_id)
WHERE sales_type_id = 1
GROUP BY state --select customers who purchased AT LEAST one vehicle FROM a dealership
ORDER BY total_customers DESC --limit to the top 5 states
LIMIT 5;

--NOTE: counts like these without percentages based on total populations of states may be misleading.


--2. What are the top 5 US zipcodes with the most customers who have purchased a vehicle 
--from a dealership participating in the Carnival platform?
SELECT zipcode AS top_five_zipcodes,
	COUNT(DISTINCT s.customer_id) AS total_purchasing_customers
FROM sales s
	JOIN salestypes st USING (sales_type_id)
	JOIN customers c USING (customer_id)
WHERE sales_type_id = 1
GROUP BY zipcode 
ORDER BY total_purchasing_customers DESC
LIMIT 11;--counting DISTINCT customers, there is a tie for 4th & 5th place

SELECT zipcode AS top_five_zipcodes,
	COUNT(s.customer_id) AS total_purchasing_customers
FROM sales s
	JOIN salestypes st USING (sales_type_id)
	JOIN customers c USING (customer_id)
WHERE sales_type_id = 1
GROUP BY zipcode 
ORDER BY total_purchasing_customers DESC
LIMIT 11;--not counting DISTINCT customers, there is also a tie for 4th & 5th place

WITH zipcode_rank AS (
		SELECT top_five_zipcodes,
				total_purchasing_customers,
				RANK() OVER(ORDER BY total_purchasing_customers DESC) AS zipcode_rank
		FROM 
			(
				SELECT zipcode AS top_five_zipcodes, 
					COUNT (DISTINCT s.customer_id) AS total_purchasing_customers
				FROM sales s
					JOIN salestypes st USING(sales_type_id)
					JOIN customers c USING(customer_id)
				GROUP BY zipcode 
				) AS zipcode_table
)

SELECT top_five_zipcodes, total_purchasing_customers, zipcode_rank
FROM zipcode_rank
WHERE zipcode_rank BETWEEN 1 AND 5--Solved using RANK and DISTINCT customers

--3. What are the top 5 dealerships with the most customers?
--Q Customers who have at least one sale or customers from the customer database?

SELECT 	business_name AS top_five_dealerships,
	COUNT(DISTINCT s.customer_id) AS total_customers
FROM dealerships d 
	JOIN sales s USING (dealership_id)
GROUP BY dealership_id
ORDER BY total_customers DESC
LIMIT 5;

