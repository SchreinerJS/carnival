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

SELECT *
FROM employees

SELECT *
FROM dealershipemployees

--Practice
--Help out HR fast track turnover by providing the following:
Create employee
, get the id of the employee
Get id of two dealerships
2 writes to dealership table

/*Create a stored procedure with a transaction to handle hiring a new employee. 
Add a new record for the employee in the Employees table and add a record to the Dealershipemployees table
for the two dealerships the new employee will start at.


--
tranaction insert employee data into the employee table
then insert the appropriate data into the dealership employee twice, one for each dealership

FROM KEATON LAW:
CREATE OR REPLACE PROCEDURE hire_new_employee(
    p_first_name TEXT,
    p_last_name TEXT,
    p_email_address TEXT,
    p_phone TEXT,
    p_employee_type_id INT,
    p_dealership_id1 INT,
    p_dealership_id2 INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_employee_id INT;
BEGIN
        -- Insert the new employee and retrieve their ID
        INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
        VALUES (p_first_name, p_last_name, p_email_address, p_phone, p_employee_type_id)
        RETURNING employee_id INTO v_new_employee_id;
        -- Insert records for the new employee in the dealershipemployees table for both dealerships
        INSERT INTO dealershipemployees (dealership_id, employee_id)
        VALUES (p_dealership_id1, v_new_employee_id),
               (p_dealership_id2, v_new_employee_id);
EXCEPTION
    WHEN OTHERS THEN
        --  rollback the transaction if it donked up
        ROLLBACK;
        RAISE;
END;
$$;
CALL hire_new_employee('Bean', 'Beanson', 'beanz@bean.beans', '000-000-0000', 5, 15, 16)
--select statement to see if everything went smoothly
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email_address,
    e.phone,
    d.business_name,
    d.phone AS dealership_phone,
    d.state,
    d.website
FROM
    employees e
JOIN
    dealershipemployees de ON e.employee_id = de.employee_id
JOIN
    dealerships d ON de.dealership_id = d.dealership_id
WHERE
    e.email_address = 'beanz@bean.beans';

-- start a transaction*/
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



--William's team's solutions:

/*
Creating Carnival Reports
As Carnival grows, we have been asked to help solve two issues:
​
It has become more and more difficult for the accounting department to keep track of the all the records in the sales table and how much money came in from each sale.
​
HR currently has an overflowing filing cabinet with files on each employee. There's additional files for each dealership. Sorting through all these files when new employees join Carnival and current employees leave is a process that needs to be streamlined. All employees that start at Carnival are required to work shifts at at least two dealerships.
​
Goals
Using CREATE to add new tables
Using triggers
Using stored procedures
Using transactions
Practice
*/
​
​
/*Provide a way for the accounting team to track all financial transactions by creating a new table called Accounts Receivable. The table should have the following columns: credit_amount, debit_amount, date_received as well as a PK and a FK to associate a sale with each transaction.*/
​
CREATE TABLE accounts_receivable (
    ar_id SERIAL PRIMARY KEY,
    credit_amount NUMERIC(15,2),
    debit_amount NUMERIC(15,2),
    date_received DATE DEFAULT CURRENT_DATE,
    sale_id INT,
	FOREIGN KEY(sale_id) REFERENCES sales(sale_id)
);
​
/*Set up a trigger on the Sales table. When a new row is added, add a new record to the Accounts Receivable table with the deposit as credit_amount, the timestamp as date_received and the appropriate sale_id.*/
​
CREATE OR REPLACE FUNCTION new_sale()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
	
	INSERT INTO accounts_receivable (credit_amount, sale_id)
	VALUES (NEW.deposit, NEW.sale_id)
	; 
​
	RETURN NEW;
END
$$
;
​
CREATE OR REPLACE TRIGGER new_sale_update_ar
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE PROCEDURE new_sale()
;
​
-- Testing --
​
INSERT INTO sales (sales_type_id, 
				   vehicle_id, 
				   employee_id, 
				   customer_id,
				   dealership_id, 
				   price, 
				   deposit, 
				   purchase_date, 
				   pickup_date, 
				   invoice_number, 
				   payment_method, 
				   sale_returned)
VALUES (
	2, 69, 34, 44, 4, 23442, 3224, current_date, current_date , '2232323233', 'mastercard', false);
​
SELECT * FROM accounts_receivable;
​
/*Set up a trigger on the Sales table for when the sale_returned flag is updated. Add a new row to the Accounts Receivable table with the deposit as debit_amount, the timestamp as date_received, etc.*/
​
CREATE OR REPLACE FUNCTION sale_return()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
	 
	 UPDATE accounts_receivable
	 SET debit_amount = sales.deposit
	 FROM sales
	 WHERE accounts_receivable.sale_id = sales.sale_id;
	 
	 RETURN NEW;
​
END
$$
;
​
CREATE OR REPLACE TRIGGER returning_sale
AFTER UPDATE
ON sales
FOR EACH ROW
EXECUTE PROCEDURE sale_return()
;
​
-- Testing --
​
UPDATE sales
SET sale_returned = 'true'
WHERE sale_id = 5029;
​
SELECT * FROM sales ORDER BY sale_id DESC;
​
SELECT * FROM accounts_receivable;
​
/*Create a stored procedure with a transaction to handle hiring a new employee. Add a new record for the employee in the Employees table and add a record to the Dealershipemployees table for the two dealerships the new employee will start at.*/
​
CREATE OR REPLACE PROCEDURE new_hire(first_name varchar (30), 
									 last_name varchar (30),
									 email_address varchar (50) DEFAULT NULL,
									 phone varchar (12) DEFAULT NULL,
									 employee_type_id integer DEFAULT NULL)
LANGUAGE plpgsql
AS
$$
DECLARE
​
	employeeId int;
	dealership1 int;
	dealership2 int;
	
BEGIN	
​
	SELECT dealership_id 
	FROM dealerships 
	ORDER BY RANDOM() LIMIT 1 
	INTO dealership1;
	
	SELECT dealership_id 
	FROM dealerships 
	WHERE dealership_id <> dealership1
	ORDER BY RANDOM() LIMIT 1 
	INTO dealership2;
	
	BEGIN	
​
		INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
		VALUES (first_name, last_name, email_address, phone, employee_type_id)
		RETURNING employee_id INTO employeeId;
	
		COMMIT;
​
		INSERT INTO dealershipemployees (dealership_id, employee_id)
		VALUES (dealership1, employeeId), (dealership2, employeeId);
	
		COMMIT;
​
	END;
END	
$$
;
​
-- Executing procedure -- 
CALL new_hire('John', 'Doe');
​
-- Testing --
SELECT * 
FROM employees 
	LEFT JOIN dealershipemployees USING (employee_id)
WHERE first_name = 'John' AND last_name = 'Doe'
​
​
-- Group Solution -- 
​
CREATE OR REPLACE PROCEDURE add_employee_to_dealerships()
LANGUAGE plpgsql
AS $$
DECLARE 
  NewEmployeeId integer;
  
BEGIN
    INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
    VALUES ('John', 'Doe', 'johndoe@example.com', '123-456-7890', 1)
		RETURNING employee_id INTO NewEmployeeId;
​
COMMIT;
​
	    INSERT INTO dealershipemployees (dealership_id, employee_id)
    	VALUES (1, NewEmployeeId),
    		   (2, NewEmployeeId);
		
COMMIT;
​
END;
$$;
​
-- Testing --
​
CALL add_employee_to_dealerships();
​
SELECT * FROM dealershipemployees d ORDER BY dealership_employee_id DESC;
SELECT * FROM employees e ORDER BY e.employee_id DESC;
​
​
/*Create a stored procedure with a transaction to handle an employee leaving. The employee record is removed and all records associating the employee with dealerships must also be removed.*/
​
​
CREATE OR REPLACE PROCEDURE remove_employee(IN EmployeeId INT)
LANGUAGE plpgsql
AS $$
  
BEGIN
    DELETE FROM dealershipemployees de WHERE de.employee_id = EmployeeId;
   
    DELETE FROM accounts_receivable WHERE sale_id IN (SELECT sale_id FROM sales WHERE employee_id = EmployeeId);
​
    DELETE FROM sales s WHERE s.employee_id = EmployeeId;
    
    DELETE FROM employees e WHERE e.employee_id = EmployeeId;
    
COMMIT;
​
END;
$$;
​
-- Executing Procedure --
CALL remove_employee(1010);
​
-- Validating --
SELECT * FROM dealershipemployees d ORDER BY dealership_employee_id DESC;
SELECT * FROM employees e ORDER BY e.employee_id DESC;
SELECT * FROM sales s ORDER BY s.sale_id DESC;




