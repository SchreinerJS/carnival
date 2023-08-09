--get data from the payment table and groups the result by customer id.

SELECT
   customer_id
FROM
   payment
GROUP BY
   customer_id;

--get the total amount that each customer has been paid:
SELECT
	customer_id,
	SUM (amount)
FROM
	payment
GROUP BY
	customer_id;
	
--sort the groups:

SELECT
	customer_id,
	SUM (amount)
FROM
	payment
GROUP BY
	customer_id
ORDER BY
	SUM (amount) DESC;
	
--get the total amount paid by each customer:
SELECT
	first_name || ' ' || last_name full_name,
	SUM (amount) amount
FROM
	payment
INNER JOIN customer USING (customer_id)    	
GROUP BY
	full_name
ORDER BY amount DESC;	

--find the number of payment transactions that each staff has processed:
SELECT
	staff_id,
	COUNT (payment_id)
FROM
	payment
GROUP BY
	staff_id;
	
--group by several columns example:
SELECT 
	customer_id, 
	staff_id, 
	SUM(amount) 
FROM 
	payment
GROUP BY 
	staff_id, 
	customer_id
ORDER BY 
    customer_id;
   
--group payments by dates
--use the DATE() function to convert timestamps to dates first
--then group payments by the result date:
SELECT 
	DATE(payment_date) paid_date, 
	SUM(amount) sum
FROM 
	payment
GROUP BY
	DATE(payment_date);