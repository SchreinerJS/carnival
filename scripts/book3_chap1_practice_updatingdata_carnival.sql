--Let's see an example of updating an email address for a customer.

SELECT * FROM customers
WHERE customer_id = 67;

-- UPDATE statement to change a customer
UPDATE  public.customers
SET email = 'juliasmith@gmail.com'
WHERE customer_id = 67;

--PRACTICE
--1. Employees
--Kristopher Blumfield an employee of Carnival has asked to be transferred to a different dealership location.
--She is currently at dealership 9.
--She would like to work at dealership 20. Update her record to reflect her transfer.
SELECT * FROM employees
WHERE first_name LIKE 'Kristopher' AND last_name LIKE 'Blumfield';
--employee_id = 9

SELECT * FROM dealershipemployees
WHERE employee_id = 9;

UPDATE public.dealershipemployees
SET dealership_id = 20
WHERE employee_id = 9
RETURNING *;
-- Does dealership_employee_id also need to change? Don't think so.

--OR

UPDATE public.dealershipemployees
SET dealership_id = 20
WHERE first_name LIKE 'Kristopher' AND last_name LIKE 'Blumfield'
RETURNING *;

--2. Sales
--A Sales associate needs to update a sales record because her customer want to pay with a Mastercard instead of JCB. 
--Update Customer, Ernestus Abeau Sales record which has an invoice number of 9086714242.

SELECT * FROM sales
WHERE invoice_number LIKE '9086714242';

UPDATE public.sales
SET payment_method = 'mastercard'
WHERE invoice_number = '9086714242'
RETURNING *;
