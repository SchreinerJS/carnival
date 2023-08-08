--Select payments between 8 and 9 USD
SELECT
	customer_id,
	payment_id,
	amount
FROM
	payment
WHERE
	amount BETWEEN 8 AND 9;
	
--Select payments not between the range of 8 and 9 USD
SELECT
	customer_id,
	payment_id,
	amount
FROM
	payment
WHERE
	amount NOT BETWEEN 8 AND 9;
	
--To check a value against a range of dates, ISO 8601 format
	--i.e. YYYY-MM-DD
--Retrieve payments with a date between 2007-02-07 and 2007-02-15:
SELECT
	customer_id,
	payment_id,
	amount,
 	payment_date
FROM
	payment
WHERE
	payment_date BETWEEN '2007-02-07' AND '2007-02-15';