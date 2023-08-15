--Purchase Income by Dealership


--Write a query that shows the total purchase sales income per dealership.
--salestype 1=Purchase 2=Lease

--solution_i
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 1
GROUP BY d.dealership_id
ORDER BY dealership;

--Write a query that shows the purchase sales income per dealership for July of 2020.

SELECT d.business_name AS dealership,
	SUM(s.price) AS purchase_sales_july_2020
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 1 AND
		s.purchase_date BETWEEN '07-01-2020' AND '07-31-2020'
GROUP BY d.business_name
ORDER BY d.business_name;


--Write a query that shows the purchase sales income per dealership for all of 2020.
SELECT d.business_name AS dealership,
	SUM(s.price) AS purchase_sales_july_2020
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 1 AND
		s.purchase_date BETWEEN '01-01-2020' AND '12-31-2020'
GROUP BY d.business_name
ORDER BY d.business_name;


--Lease Income by Dealership
--Write a query that shows the total lease income per dealership.
SELECT 	d.business_name AS dealership,
		SUM(s.price) AS total_purchase_sales
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 2
GROUP BY d.dealership_id
ORDER BY dealership;

--Write a query that shows the lease income per dealership for Jan of 2020.
SELECT d.business_name AS dealership,
	SUM(s.price) AS purchase_sales_july_2020
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 2 AND
		s.purchase_date BETWEEN '01-01-2020' AND '01-31-2020'
GROUP BY d.business_name
ORDER BY d.business_name;

--Write a query that shows the lease income per dealership for all of 2019.
SELECT d.business_name AS dealership,
	SUM(s.price) AS purchase_sales_july_2020
FROM
	sales s
		INNER JOIN salestypes st USING (sales_type_id)
		INNER JOIN dealerships d USING (dealership_id)
WHERE st.sales_type_id = 2 AND
		s.purchase_date BETWEEN '01-01-2019' AND '12-31-2019'
GROUP BY d.business_name
ORDER BY d.business_name;

--Total Income by Employee

--Write a query that shows the total income (purchase and lease) per employee.
WITH SalesIncomeByEmployee AS (
		SELECT 
			s.employee_id,
			e.first_name,
			e.last_name,
			SUM(s.price) AS total_income
		FROM
			sales s
				LEFT JOIN salestypes st USING(sales_type_id)
				INNER JOIN employees e USING (employee_id)
		WHERE st.sales_type_id IN (1,2)
		GROUP BY s.employee_id, e.first_name, e.last_name
)

SELECT 	first_name || ' ' || last_name AS employee_name,
	total_income
FROM SalesIncomeByEmployee
ORDER BY total_income DESC;

-- calculate employee rank by sales per dealersh
--*NOTE TO SELF: Try with windows functions

--Practice questions FROM CHATGPT:
--2.--Sales Trend Analysis:
--How have monthly sales totals fluctuated over the past year? 
