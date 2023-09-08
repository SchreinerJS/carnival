--Creating Carnival Reports
--As Carnival grows, we have been asked to help solve two issues:
--
--It has become more and more difficult for the accounting department to keep track of the all the records in the sales table and how much money came in from each sale.
--
--HR currently has an overflowing filing cabinet with files on each employee. There's additional files for each dealership. Sorting through all these files when new employees join Carnival and current employees leave is a process that needs to be streamlined. All employees that start at Carnival are required to work shifts at at least two dealerships.
--
--Goals
--Using CREATE to add new tables
--Using triggers
--Using stored procedures
--Using transactions


--Practice
--A. Provide a way for the accounting team to track all financial transactions by creating a new table called Accounts Receivable. The table should have the following columns: credit_amount, debit_amount, date_received as well as a PK and a FK to associate a sale with each transaction.

CREATE TABLE accountsreceivable (
ar_id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
credit_amount NUMERIC (8,2),
debit_amount NUMERIC (8,2),
date_received DATE,
sale_id INT, 
FOREIGN KEY(sale_id)REFERENCES sales(sale_id)
);

SELECT *
FROM accountsreceivable;

--DROP TABLE accountsreceivable

--1. Set up a trigger on the Sales table. When a new row is added, add a new record to the Accounts Receivable table with the deposit as credit_amount, the timestamp as date_received and the appropriate sale_id.

SELECT *
FROM accountsreceivable

--create trigger for adding a record to the accountsreceivable table
CREATE OR REPLACE FUNCTION add_record_ar() 
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN

--trigger function logic
	INSERT INTO accountsreceivable(credit_amount, date_received, sale_id)
	VALUES (NEW.deposit, current_date, NEW.sale_id);

RETURN NULL;
END;
$$

-- trigger
CREATE TRIGGER new_sale
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE PROCEDURE add_record_ar();

--test--
INSERT INTO public.sales(sales_type_id, vehicle_id, employee_id, customer_id, dealership_id, price, deposit, purchase_date, pickup_date, invoice_number, payment_method, sale_returned)
VALUES
(1, 12, 4, 4, 4, 25000, 5000, '09-07-2023', '09-17-2023', '987654321', 'Visa', false);

SELECT *
FROM accountsreceivable;

--2. Set up a trigger on the Sales table for when the sale_returned flag is updated. Add a new row to the Accounts Receivable table with the deposit as debit_amount, the timestamp as date_received, etc.
--create trigger for adding a record to the accountsreceivable table
CREATE OR REPLACE FUNCTION sale_returned_flag()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN

--trigger function logic
	IF NEW.sale_returned = TRUE THEN
		INSERT INTO accountsreceivable(debit_amount, date_received, sale_id)
		VALUES (NEW.deposit, current_date, NEW.sale_id);
	END IF; 
RETURN NULL;
END;
$$ 

-- trigger
CREATE OR REPLACE TRIGGER sale_returned_flag_trigger
AFTER UPDATE OF sale_returned
ON sales
FOR EACH ROW
EXECUTE PROCEDURE sale_returned_flag();

--test
INSERT INTO public.sales(sales_type_id, vehicle_id, employee_id, customer_id, dealership_id, price, deposit, purchase_date, pickup_date, invoice_number, payment_method, sale_returned)
VALUES
(1, 12, 4, 4, 4, 25000, 5000, '09-07-2023', '09-17-2023', '987654322', 'Visa', false);

UPDATE sales
SET sale_returned = TRUE
WHERE sale_id = 5023

SELECT *
FROM sales
ORDER BY sale_id DESC;

--Practice
--Help out HR fast track turnover by providing the following:

--Create a stored procedure with a transaction to handle hiring a new employee. Add a new record for the employee in the Employees table and add a record to the Dealershipemployees table for the two dealerships the new employee will start at.

-- start a transaction
BEGIN;

-- insert a new row into the sales type table

SELECT *
FROM employees
LIMIT 1;
INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
VALUES('Lease to Own');

SAVEPOINT foo;

-- insert a new row into the employees table
INSERT INTO employees(name)
VALUES('Accountant');

-- roll back to the savepoint
ROLLBACK TO SAVEPOINT foo;


--ROLLBACK A TRANSACTION

-- start a transaction
BEGIN;
-- You can also use BEGIN TRANSACTION; or BEGIN WORK;

-- insert a new row into the sales type table
INSERT INTO employeetypes(name)
VALUES('Accountant');

-- roll back the transaction
ROLLBACK;
-- You can also use ROLLBACK TRANSACTION; or ROLLBACK WORK;

--SAVEPOINT

-- start a transaction
BEGIN;
-- You can also use BEGIN TRANSACTION; or BEGIN WORK;

-- insert a new row into the sales type table
INSERT INTO salestypes(name)
VALUES('Lease to Own');

SAVEPOINT foo;

-- insert a new row into the employees table
INSERT INTO employees(name)
VALUES('Accountant');

-- roll back to the savepoint
ROLLBACK TO SAVEPOINT foo;

--TRANSACTIONS & EXCEPTION HANDLING

do $$ 
DECLARE 
  NewCustomerId integer;
  CurrentTS date;

BEGIN

  INSERT INTO
    customers(
      first_name,
      last_name,
      email,
      phone,
      street,
      city,
      state,
      zipcode,
      company_name
    )
  VALUES
    (
      'Roy',
      'Simlet',
      'r.simlet@remves.com',
      '615-876-1237',
      '77 Miner Lane',
      'San Jose',
      'CA',
      '95008',
      'Remves'
    ) RETURNING customer_id INTO NewCustomerId;

  CurrentTS = CURRENT_DATE;

  INSERT INTO
    sales(
      sales_type_id,
      vehicle_id,
      employee_id,
      customer_id,
      dealership_id,
      price,
      deposit,
      purchase_date,
      pickup_date,
      invoice_number,
      payment_method
    )
  VALUES
    (
      1,
      1,
      1,
      NewCustomerId,
      1,
      24333.67,
      6500,
      CurrentTS,
      CurrentTS + interval '7 days',
      1273592747,
      'solo'
    );

EXCEPTION WHEN others THEN 
  -- RAISE INFO 'name:%', SQLERRM;
  ROLLBACK;

END;

$$ language plpgsql;



--Create a stored procedure with a transaction to handle an employee leaving. The employee record is removed and all records associating the employee with dealerships must also be removed.








