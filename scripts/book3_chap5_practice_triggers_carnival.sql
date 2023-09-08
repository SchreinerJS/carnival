/*Book3: Chap 5
Intro to Triggers

BOOK TRIGGERS BY LYNN SAMUELSON
Create a trigger to set the pickup date of the vehicle to be seven days 
from the date of purchase every time a new row is added to the Sales table.*/

CREATE OR REPLACE FUNCTION set_pickup_date() 
  RETURNS TRIGGER 
  LANGUAGE PlPGSQL
AS $$
BEGIN
  -- trigger function logic
  UPDATE sales
  SET pickup_date = NEW.purchase_date + integer '7'
  WHERE sales.sale_id = NEW.sale_id;
  
  RETURN NULL;
END;
$$

CREATE OR REPLACE TRIGGER new_sale_made
AFTER INSERT
  ON sales
  FOR EACH ROW
  EXECUTE FUNCTION set_pickup_date();
 
INSERT INTO sales (sales_type_id, vehicle_id, employee_id, customer_id, dealership_id, price, deposit, purchase_date, pickup_date, invoice_number, payment_method, sale_returned)
VALUES (1, 9988, 500, 250, 56, 38500, 26400, CURRENT_DATE, CURRENT_DATE, '9989989988', 'visa', false); 

SELECT * FROM sales
ORDER BY sale_id DESC;

/*Practice: Carnival
1. Create a trigger function for when a new Sales record is added,
 set the purchase date to 3 days from the current date.*/

CREATE OR REPLACE FUNCTION set_purchase_date()
  RETURNS TRIGGER 
  LANGUAGE PlPGSQL
AS $$
BEGIN
  -- trigger function logic
  UPDATE sales
  SET purchase_date = CURRENT_DATE + integer '3'
  WHERE sales.sale_id = NEW.sale_id;
  
  RETURN NULL;
END;
$$

--create trigger

CREATE OR REPLACE TRIGGER new_purchase_date
  AFTER INSERT
  ON sales
  FOR EACH ROW
  EXECUTE FUNCTION set_purchase_date();

 --test
INSERT INTO sales (sales_type_id, vehicle_id, employee_id, customer_id, dealership_id, price, deposit, purchase_date, pickup_date, invoice_number, payment_method, sale_returned)
VALUES (1, 9989, 500, 250, 56, 38500, 26400, CURRENT_DATE, CURRENT_DATE, '9989989989', 'visa', false); 

SELECT * FROM sales
ORDER BY sale_id DESC;


/*2.  Create a trigger for updates to the Sales table. 
If the pickup date is on or before the purchase date, set the pickup date to 7 days after the purchase date.
If the pickup date is after the purchase date but less than 7 days out from the purchase date,
add 4 additional days to the pickup date. */

--NOTE: the update to the sales table which should trigger the function is updating the pickup_date

--Together with Jessalynn Whyte:
CREATE OR REPLACE FUNCTION reset_pickup_date() 
  RETURNS TRIGGER 
  LANGUAGE plpgsql
AS $$
BEGIN
	--first condition
	IF NEW.pickup_date <= NEW.purchase_date THEN
	
	--trigger function logic
	NEW.pickup_date := NEW.purchase_date + interval '7 days';
	
	--second condition
	ELSEIF NEW.pickup_date > NEW.purchase_date AND NEW.pickup_date < NEW.purchase_date + interval '7 days' THEN
	
	--trigger function logic
	NEW.pickup_date := NEW.pickup_date + interval '4 days';
	END IF;
	RETURN NEW;
	
END;
$$

CREATE OR REPLACE TRIGGER update_pickup_date
  BEFORE UPDATE
  ON sales
  FOR EACH ROW
  EXECUTE FUNCTION reset_pickup_date();
 
 --review table status
SELECT sale_id, purchase_Date, pickup_date
FROM sales
ORDER BY sale_id DESC;

INSERT INTO sales (sales_type_id, vehicle_id, employee_id, customer_id, dealership_id, price, deposit, purchase_date, invoice_number, payment_method, sale_returned)
VALUES (1, 9006, 500, 250, 56, 38500, 26400, CURRENT_DATE, '9989989996', 'visa', false); 

--tester code for updating pickup_date
UPDATE sales
SET pickup_date = '2023-09-06'
WHERE sale_id = 5022; 

 --review table status
SELECT sale_id, purchase_Date, pickup_date
FROM sales
ORDER BY sale_id DESC;