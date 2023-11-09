--Creating Carnival Reports
--Carnival would like to harness the full power of reporting. 
--Let's begin to look further at querying the data in our tables. 
--Carnival would like to understand more about thier business and needs you to help them build some reports.

--Goal
--Below are some desired reports that Carnival would like to see. 
--Use your query knowledge to find the following metrics.

--Employee Reports
--Best Sellers

--Who are the top 5 employees for generating sales income?
--OPTION 1, if concerned there might be duplicate totals

WITH SalesByEmployee AS (
	SELECT s.employee_id,
			first_name || ' ' || last_name AS employee_name, -- concat employee_name
			SUM(s.price) AS total_ee_sales -- aggregate sales by employee
	FROM sales s
	JOIN employees e ON (s.employee_id = e.employee_id)
	GROUP BY s.employee_id, first_name, last_name
	ORDER BY total_ee_sales DESC -- sort results by most sales descending
),

EmployeeRank AS (
	SELECT 	employee_id,
			employee_name,
			total_ee_sales,
			RANK() OVER(ORDER BY total_ee_sales DESC) AS employee_rank -- rank the sales in the case of ties
	FROM SalesByEmployee--rank employees by total_sales
)			
SELECT employee_id, employee_name, total_ee_sales, employee_rank
FROM EmployeeRank
WHERE employee_rank BETWEEN 1 AND 5--select the top 5 employees by sales income generated

--OPTION 2, if not concerned there might be duplicate totals

SELECT s.employee_id,
	first_name || ' ' || last_name AS employee_name,
	SUM(s.price) AS total_ee_sales
FROM sales s
JOIN employees e ON (s.employee_id = e.employee_id)
GROUP BY s.employee_id, first_name, last_name
ORDER BY total_ee_sales DESC
LIMIT 5; --aggregate sales by employee and provide top 5 in DESC order

--Who are the top 5 dealership for generating sales income?

SELECT d.business_name AS dealership,
	SUM(s.price) AS total_ds_sales
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY total_ds_sales DESC
LIMIT 5;--select top 5 dealerships by total sales income generated

--dealership_sales_income VIEW
CREATE OR REPLACE VIEW dealership_sales_income AS
SELECT d.business_name AS dealership,
    	SUM(s.price) AS total_ds_sales
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id
ORDER BY total_ds_sales DESC;
 
 
SELECT *
FROM dealership_sales_income
ORDER BY total_ds_sales DESC
LIMIT 5;--select top 5 dealerships by total sales income generated using a view

--Which vehicle model generated the most sales income?

SELECT vt.model AS top_model,
	SUM(s.price) AS total_model_sales
FROM sales s
JOIN vehicles v ON s.vehicle_id = v.vehicle_id
LEFT JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.model
ORDER BY total_model_sales DESC
LIMIT 1;

--Top Performance
--Which employees generate the most income per dealership?

--ANSWER, without using a view
WITH dealership_employees AS 
(
	SELECT dealership,
			employee_id,
			first_name,
			last_name
	FROM employee_dealership_names
),

	employee_rank AS 
(
		SELECT dealership,
			first_name,
			last_name, 
			SUM(s.price) AS total_sales,
			RANK() OVER (PARTITION BY dealership ORDER BY SUM(s.price) DESC) AS sales_rank			
		FROM dealership_employees de
			INNER JOIN sales s ON de.employee_id = s.employee_id
		GROUP BY dealership, first_name, last_name
)

SELECT dealership,
	first_name || ' ' || last_name AS employee_name,
	total_sales AS top_ranked_sales
FROM employee_rank
WHERE sales_rank = 1
ORDER BY dealership--

--ANSWER using employee_dealership_names view
--Rank top employees by total sales
WITH ranked_employee_sales AS (
	SELECT edn.dealership_id,
		edn.dealership,
		s.employee_id,
		edn.employee_name,
		SUM(s.price) AS total_sales,
		RANK() OVER (PARTITION BY edn.dealership ORDER BY SUM(s.price) DESC) AS sales_rank			
	FROM vwEmployeeDealershipNames edn
		JOIN sales s ON edn.employee_id = s.employee_id
	GROUP BY edn.dealership_id, edn.dealership, s.employee_id, edn.employee_name
)
--Select top ranked employee at each dealership
SELECT dealership,
		employee_name,
		total_sales AS top_ranked_sales
FROM ranked_employee_sales
WHERE sales_rank = 1
ORDER BY dealership;

/*Vehicle Reports

--Inventory
--In our Vehicle inventory, show the count of each Model that is in stock.*/

SELECT model, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY model
ORDER BY model;

--In our Vehicle inventory, show the count of each Make that is in stock.
SELECT make, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY make
ORDER BY make;

--In our Vehicle inventory, show the count of each BodyType that is in stock.
SELECT body_type, COUNT(*)
FROM vwVehicleTypesStatus
WHERE is_sold = FALSE
GROUP BY body_type
ORDER BY body_type;

--Purchasing Power
--Which US state's customers have the highest average purchase price for a vehicle?

SELECT customer_state, ROUND(AVG(purchase_price),2) AS avg_purchase_price
FROM vwCustomerPurchasesByState
GROUP BY customer_state
ORDER BY avg_purchase_price DESC
LIMIT 1;

--Now using the data determined above, 
--which 5 states have the customers with the highest average purchase price for a vehicle?
SELECT customer_state, ROUND(AVG(purchase_price),2) AS avg_purchase_price
FROM vwCustomerPurchasesByState
GROUP BY customer_state
ORDER BY avg_purchase_price DESC
LIMIT 5;



--William's team's solution for Week 6 Group Project: 

/*
Creating Carnival Reports
As Carnival grows, we have been asked to help solve two issues:

It has become more and more difficult for the accounting department to keep track of the all the records in the sales table and how much money came in from each sale.

HR currently has an overflowing filing cabinet with files on each employee. There's additional files for each dealership. Sorting through all these files when new employees join Carnival and current employees leave is a process that needs to be streamlined. All employees that start at Carnival are required to work shifts at at least two dealerships.

Goals
Using CREATE to add new tables
Using triggers
Using stored procedures
Using transactions
Practice
*/


/*Provide a way for the accounting team to track all financial transactions by creating a new table called Accounts Receivable. The table should have the following columns: credit_amount, debit_amount, date_received as well as a PK and a FK to associate a sale with each transaction.*/

CREATE TABLE accounts_receivable (
    ar_id SERIAL PRIMARY KEY,
    credit_amount NUMERIC(15,2),
    debit_amount NUMERIC(15,2),
    date_received DATE DEFAULT CURRENT_DATE,
    sale_id INT,
	FOREIGN KEY(sale_id) REFERENCES sales(sale_id)
);

/*Set up a trigger on the Sales table. When a new row is added, add a new record to the Accounts Receivable table with the deposit as credit_amount, the timestamp as date_received and the appropriate sale_id.*/

CREATE OR REPLACE FUNCTION new_sale()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
	
	INSERT INTO accounts_receivable (credit_amount, sale_id)
	VALUES (NEW.deposit, NEW.sale_id)
	; 

	RETURN NEW;
END
$$
;

CREATE OR REPLACE TRIGGER new_sale_update_ar
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE PROCEDURE new_sale()
;

-- Testing --

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

SELECT * FROM accounts_receivable;

/*Set up a trigger on the Sales table for when the sale_returned flag is updated. Add a new row to the Accounts Receivable table with the deposit as debit_amount, the timestamp as date_received, etc.*/

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

END
$$
;

CREATE OR REPLACE TRIGGER returning_sale
AFTER UPDATE
ON sales
FOR EACH ROW
EXECUTE PROCEDURE sale_return()
;

-- Testing --

UPDATE sales
SET sale_returned = 'true'
WHERE sale_id = 5029;

SELECT * FROM sales ORDER BY sale_id DESC;

SELECT * FROM accounts_receivable;

/*Create a stored procedure with a transaction to handle hiring a new employee. Add a new record for the employee in the Employees table and add a record to the Dealershipemployees table for the two dealerships the new employee will start at.*/

CREATE OR REPLACE PROCEDURE new_hire(first_name varchar (30), 
									 last_name varchar (30),
									 email_address varchar (50) DEFAULT NULL,
									 phone varchar (12) DEFAULT NULL,
									 employee_type_id integer DEFAULT NULL)
LANGUAGE plpgsql
AS
$$
DECLARE

	employeeId int;
	dealership1 int;
	dealership2 int;
	
BEGIN	

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

		INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
		VALUES (first_name, last_name, email_address, phone, employee_type_id)
		RETURNING employee_id INTO employeeId;
	
		COMMIT;

		INSERT INTO dealershipemployees (dealership_id, employee_id)
		VALUES (dealership1, employeeId), (dealership2, employeeId);
	
		COMMIT;

	END;
END	
$$
;

-- Executing procedure -- 
CALL new_hire('John', 'Doe');

-- Testing --
SELECT * 
FROM employees 
	LEFT JOIN dealershipemployees USING (employee_id)
WHERE first_name = 'John' AND last_name = 'Doe'


-- Group Solution -- 

CREATE OR REPLACE PROCEDURE add_employee_to_dealerships()
LANGUAGE plpgsql
AS $$
DECLARE 
  NewEmployeeId integer;
  
BEGIN
    INSERT INTO employees (first_name, last_name, email_address, phone, employee_type_id)
    VALUES ('John', 'Doe', 'johndoe@example.com', '123-456-7890', 1)
		RETURNING employee_id INTO NewEmployeeId;

COMMIT;

	    INSERT INTO dealershipemployees (dealership_id, employee_id)
    	VALUES (1, NewEmployeeId),
    		   (2, NewEmployeeId);
		
COMMIT;

END;
$$;

-- Testing --

CALL add_employee_to_dealerships();

SELECT * FROM dealershipemployees d ORDER BY dealership_employee_id DESC;
SELECT * FROM employees e ORDER BY e.employee_id DESC;


/*Create a stored procedure with a transaction to handle an employee leaving. The employee record is removed and all records associating the employee with dealerships must also be removed.*/


CREATE OR REPLACE PROCEDURE remove_employee(IN EmployeeId INT)
LANGUAGE plpgsql
AS $$
  
BEGIN
    DELETE FROM dealershipemployees de WHERE de.employee_id = EmployeeId;
   
    DELETE FROM accounts_receivable WHERE sale_id IN (SELECT sale_id FROM sales WHERE employee_id = EmployeeId);

    DELETE FROM sales s WHERE s.employee_id = EmployeeId;
    
    DELETE FROM employees e WHERE e.employee_id = EmployeeId;
    
COMMIT;

END;
$$;

-- Executing Procedure --
CALL remove_employee(1010);

-- Validating --
SELECT * FROM dealershipemployees d ORDER BY dealership_employee_id DESC;
SELECT * FROM employees e ORDER BY e.employee_id DESC;
SELECT * FROM sales s ORDER BY s.sale_id DESC;