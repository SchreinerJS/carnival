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

DO $$
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

--EXCEPTION WHEN others THEN
  --RAISE INFO ‘Error:%’, SQLERRM;

--END; 

$$ LANGUAGE plpgsql;

--ROLLBACK;
--COMMIT;


______________
--ODIE'S example code
SELECT * FROM vehicletypes v
WHERE v.vehcile_type_id = 32;

BEGIN;
--Foreign Key
--DELETE FROM vehicles
--WHERE vehicles_type_id = 30;

DELETE FROM vehicletypes v
WHERE v.vehicle_type_id = 32;

--ROLLBACK
--COMMIT  
	--Test the code first before committing; after it's committed, it is final
--END if you use this at the end of the transaction, it will commit


__________________________



__________________________
--	Lauren Hanson
--	do $$
--declare
--  NewEmployeeTypeId integer;
--  NewEmployeeIds integer[];
--  DealershipIds integer[] = array[36, 20, 50];
--  dealer_id integer;
--begin


do $$
DECLARE
	NewEmployeeTypeId integer;
	NewEmployeeIds integer[]
--	NewEmployeeId1 integer;
--	NewEmployeeId2 integer;
--	NewEmployeeId3 integer;
--	NewEmployeeId4 integer;
--	NewEmployeeId5 integer;
	DealershipIds integer[] = array[36, 20, 50]
--	dealer_id integer;

-- start transaction
BEGIN;

--SAVEPOINT et1;

-- insert a new row into the sales type table
INSERT INTO employeetypes(employee_type_name)
VALUES('Automotive Mechanic'
) RETURNING employee_type_id INTO NewEmployeeTypeId;

--SAVEPOINT et2;

-- insert first new employee into the employees table
INSERT INTO employees(
	first_name,
	last_name,
	email_address,
	phone,
	employee_type_id)
	
--	Lauren Hanson
--	VALUES
--		(‘George’, ‘Hanson’, ‘george@george.com’, ‘516-934-4829’, NewEmployeeTypeId),
--		(‘Nigel’, ‘Hussung’, ‘nigel@nigel.com’, ‘412-398-6283’, NewEmployeeTypeId),
--		(‘Anastasia’, ‘Thomas’, ‘anastasia@anastasia.com’, ‘689-321-4938’, NewEmployeeTypeId),
--		(‘Gio’, ‘Roggenbuck’, ‘gio@gio.com’, ‘513-284-5693’, NewEmployeeTypeId),
--		(‘Poppy’, ‘Nelson’, ‘poppy@poppy.com’, ‘378-276-3948’, NewEmployeeTypeId)
--		returning employee_id into NewEmployeeIds;
--		
--foreach dealer_id in array DealershipIds
--loop 	
--	insert into
--	dealershipemployees (
--		dealership_id,
--		employee_id
--	)
--	need to figure out NewEmployeeIds. It is currently an array.
--	values(dealer_id, NewEmployeeIds);
--end loop;
--insert into
--	dealershipemployees (
--		dealership_id,
--		employee_id
--	)
--values (36, NewEmployeeId), (20, NewEmployeeId), (50, NewEmployeeId);
--exception when others then
--  RAISE INFO ‘Error:%’, SQLERRM;
--  rollback;
--end;
--$$ language plpgsql;

/*Jennifer's clunky code
--	VALUES
--	('Glenn', 'McBrayer', 'glenn.mcbrayer@tdn.com', '123-321-1111', NewEmployeeTypeId
--	) RETURNING employee_id into NewEmployeeID_1);
--
---- insert second new employee into the employees table
--INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
--VALUES
--('Gregory', 'Richter', 'gregory.richter@tdn.com', '123-321-2222', NewEmployeeTypeId
--	) RETURNING employee_id into NewEmployeeID_2);
--
---- insert third new employee into the employees table
--INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
--VALUES
--('Kyle', 'Roberts', 'kyle.roberts@tdn.com', '123-321-3333', NewEmployeeTypeId
--	) RETURNING employee_id into NewEmployeeID_3);
--
--INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
--VALUES
--('Hershell', 'Koechner', 'hershell.koechner@tdn.com', '123-321-4444', NewEmployeeTypeId
--	) RETURNING employee_id into NewEmployeeID_4);
--
--INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
--VALUES
--('Susan', 'Adams', 'susan.adams@tdn.com', '123-321-5555', NewEmployeeTypeId
--	) RETURNING employee_id into NewEmployeeID_5);

	--Jennifer's original code without variables

--SAVEPOINT et3;

INSERT INTO dealershipemployees(dealership_id, employee_id)
VALUES
(DealershipIds, NewEmployeeID_1),
(DealershipIds, NewEmployeeID_2),
(DealershipIds, NewEmployeeID_3),
(DealershipIds, NewEmployeeID_4),
(DealershipIds, NewEmployeeID_5);

EXCEPTION WHEN others THEN 
RAISE INFO 'error:%', SQLERRM;
  ROLLBACK;

END;

$$ language plpgsql;

-- commit the transaction
--COMMIT;

--ROLLBACK TO SAVEPOINT et1;

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