/*Practice: Carnival

1. Write a transaction to:
Add a new role for employees called Automotive Mechanic
Add five new mechanics, their data is up to you
Each new mechanic will be working at all three of these dealerships: 
Meeler Autos of San Diego, Meadley Autos of California and Major Autos of Florida*/

SELECT *
FROM employeetypes;

SELECT *
FROM employees
ORDER BY employee_id DESC;

SELECT * 
FROM dealershipemployees
ORDER BY dealership_employee_id DESC
;

SELECT *
FROM dealerships
WHERE business_name IN ('Meeler Autos of San Diego', 'Meadley Autos of California', 'Major Autos of Florida');
--50, 36, 20
-----------------------

DO $$ -- 'DO' will commit automatically if nothing fails
DECLARE
  new_employee_type_id integer;
  new_employee_id integer;

BEGIN -- add new role

INSERT INTO employeetypes
	(
	employee_type_name
	)
VALUES (
	'Automotive Mechanic'
)RETURNING employee_type_id INTO new_employee_type_id;--variable for the dealerships table

-- insert 5 new mechanics

INSERT INTO
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id
	)

VALUES
	(
		'Glenn',
		'McBrayer',
		'glenn.mcbrayer@tdn.com',
		'123-321-1111',
		new_employee_type_id
	) RETURNING employee_id into new_employee_id;

--Insert new employee into dealershipemployees
INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
	values
		(36, new_employee_id),--add to 'Meeler Autos of San Diego'
		(50, new_employee_id),--add to 'Meadley Autos of California'
		(20, new_employee_id);--add to 'Major Autos of Florida'
		
INSERT INTO
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id		
	)	
	
VALUES
	(
		'Gregory',
		'Richter',
		'gregory.richter@tdn.com',
		'123-321-2222', 
		new_employee_type_id
	) RETURNING employee_id into new_employee_id;

INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
VALUES
		(36, new_employee_id),--add to 'Meeler Autos of San Diego'
		(50, new_employee_id),--add to 'Meadley Autos of California'
		(20, new_employee_id);--add to 'Major Autos of Florida'
		
INSERT INTO
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id		
	)	
	
VALUES
	(
		'Kyle',
		'Roberts',
		'kyle.roberts@tdn.com',
		'123-321-3333',
		new_employee_type_id
	) RETURNING employee_id into new_employee_id;

INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
VALUES
		(36, new_employee_id),--add to 'Meeler Autos of San Diego'
		(50, new_employee_id),--add to 'Meadley Autos of California'
		(20, new_employee_id);--add to 'Major Autos of Florida'

INSERT INTO
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id
	)	
VALUES
	(
		'Hershell',
		'Koechner',
		'hershell.koechner@tdn.com',
		'123-321-4444',
		new_employee_type_id
	) RETURNING employee_id into new_employee_id;

INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
	values
		(36, new_employee_id),--add to 'Meeler Autos of San Diego'
		(50, new_employee_id),--add to 'Meadley Autos of California'
		(20, new_employee_id);--add to 'Major Autos of Florida'
		
INSERT INTO
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id
	)
	
VALUES		
	(
	'Susan',
	'Adams',
	'susan.adams@tdn.com',
	'123-321-5555',
	new_employee_type_id
) RETURNING employee_id into new_employee_id;		

INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
	values
		(36, new_employee_id),--add to 'Meeler Autos of San Diego'
		(50, new_employee_id),--add to 'Meadley Autos of California'
		(20, new_employee_id);--add to 'Major Autos of Florida'

EXCEPTION
	 WHEN others THEN
	 	ROLLBACK
  		RAISE INFO ‘Transaction failed:%’, SQLERRM;

END; 

$$ LANGUAGE plpgsql;

--ROLLBACK;
--COMMIT;
-------------------
--refactored transacation from Odie

--Procedure for adding new employeetype
CREATE OR REPLACE PROCEDURE spr_addEmployeeType(IN new_employee_type_name VARCHAR(50))
LANGUAGE plpgsql
AS $$
BEGIN
	
	INSERT INTO employeetypes
	(employee_type_name)
	VALUES 
	(new_employee_type_name);
END
$$;







--Procedure for adding new employees and dealershipemployees
CREATE OR REPLACE PROCEDURE spr_addEmployeeAndDealershipEmployee
(
IN employee_first_name VARCHAR(50), 
IN employee_last_name VARCHAR(50),
IN employee_email VARCHAR(50),
IN employee_phone VARCHAR(50),
IN first_dealership INT,
IN second_dealership INT,
IN third_dealership INT
)
LANGUAGE plpgsql
AS $$

DECLARE 
	new_employee_id integer;
	new_employee_type_id integer;

BEGIN
	
	--INSERT into employees table
	INSERT INTO
	employees 
	(
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id
	)
	VALUES
	(
		employee_first_name,
		employee_last_name,
		employee_email,
		employee_phone,
		(SELECT employee_type_id FROM employeetypes ORDER BY employee_type_id DESC LIMIT 1)
	) RETURNING employee_id INTO new_employee_id;

	/*CALL spr_addemployee
	(
	employee_first_name, employee_last_name, employee_email, employee_phone, new_employee_type_id, new_employee_id
	);*/


	--INSERT into dealershipemployees table (uses new_employee_id variable)
	INSERT INTO
	dealershipemployees (
		dealership_id,
		employee_id
	)
	values
		(first_dealership, new_employee_id),--add to 'Meeler Autos of San Diego'
		(second_dealership, new_employee_id),--add to 'Meadley Autos of California'
		(third_dealership, new_employee_id);--add to 'Major Autos of Florida'
	
END
$$;


--If I just want a procedure that adds Employees
CREATE OR REPLACE PROCEDURE spr_addEmployee
(
IN employee_first_name VARCHAR(50), 
IN employee_last_name VARCHAR(50),
IN employee_email VARCHAR(50),
IN employee_phone VARCHAR(50),
IN new_employee_type_id INT,
OUT new_employee_id INT
)
LANGUAGE plpgsql
AS $$

BEGIN
	
	--INSERT into employees table
	INSERT INTO
	employees 
	(
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id
	)
	VALUES
	(
		employee_first_name,
		employee_last_name,
		employee_email,
		employee_phone,
		new_employee_type_id
	) RETURNING employee_id INTO new_employee_id;
	
END
$$;

--test
-- Odie's refactor to Jennifer's solution

SELECT * FROM employeetypes e 
ORDER BY e.employee_type_id DESC;

SELECT * FROM employees e 
ORDER BY e.employee_id DESC;

SELECT * FROM dealershipemployees d 
ORDER BY d.dealership_employee_id DESC;


DO $$
BEGIN; -- add new role

	
	CALL spr_addemployeetype('Actor'); 
	
	CALL spr_addemployeeanddealershipemployee
	(
		'Keanu',
	 	'Reeves',
	 	'keanu.reeves@actors.com',
	 	'555-222-1234',
	 	36,
	 	50,
	 	20
	);
	
	CALL spr_addemployeeanddealershipemployee
	(
		'Ryan',
	 	'Reynolds',
	 	'ryan.reynolds@actors.com',
	 	'555-333-3412',
	 	36,
	 	50,
	 	20
	);
	
	CALL spr_addemployeeanddealershipemployee
	(
		'Scarlett',
	 	'Johansson',
	 	'scarlett.johansson@actors.com',
	 	'555-843-8576',
	 	36,
	 	50,
	 	20
	);
	
	CALL spr_addemployeeanddealershipemployee
	(
		'Hugh',
	 	'Jackman',
	 	'hugh.jackman@actors.com',
	 	'555-376-1010',
	 	36,
	 	50,
	 	20
	);
	
	CALL spr_addemployeeanddealershipemployee
	(
		'Robert',
	 	'Downey Jr.',
	 	'robert.downeyjr@actors.com',
	 	'555-222-3333',
	 	36,
	 	50,
	 	20
	);

	EXCEPTION 
		WHEN others THEN
  			ROLLBACK;
  			RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
  	
END; 

$$ LANGUAGE plpgsql;


--SAMPLE TRANSACTIONS & EXCEPTION HANDLING FROM LESSON

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





/*2. Create a transaction for:
Creating a new dealership in Washington, D.C. called Felphun Automotive
Hire 3 new employees for the new dealership: Sales Manager, General Manager and Customer Service.
All employees that currently work at Nelsen Autos of Illinois 
will now start working at Cain Autos of Missouri instead.*/


SELECT *
FROM dealerships

BEGIN;

SAVEPOINT et4;

-- insert a new row into the sales type table
INSERT INTO dealerships(business_name, phone, city, state, website, tax_id)
VALUES('Automotive Mechanic');

SAVEPOINT et2;