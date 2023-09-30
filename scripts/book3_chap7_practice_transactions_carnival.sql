/*Practice: Carnival

1. Write a transaction to:
Add a new role for employees called Automotive Mechanic
Add five new mechanics, their data is up to you
Each new mechanic will be working at all three of these dealerships: 
Meeler Autos of San Diego, Meadley Autos of California and Major Autos of Florida*/

SELECT *
FROM employeetypes;

SELECT *
FROM employees;

SELECT * 
FROM dealershipemployees;

SELECT *
FROM dealerships
WHERE business_name IN ('Meeler Autos of San Diego', 'Meadley Autos of California', 'Major Autos of Florida');
--50, 36, 20

--GROUP CODE  - Jennifer Schreiner, Lauren Hanson, Demin Zawity
do $$
declare
  NewEmployeeTypeId integer;
  NewEmployeeId1 integer;
  NewEmployeeId2 integer;
  NewEmployeeId3 integer;
  NewEmployeeId4 integer;
  NewEmployeeId5 integer;
begin
-- add new role
insert into employeetypes (employee_type_name)
values (‘Automotive Mechanic’)
returning employee_type_id into NewEmployeeTypeId;
-- 5 new mechanics
insert into
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id)
		
values
	(‘George’, ‘Hanson’, ‘george@george.com’, ‘516-934-4829’, NewEmployeeTypeId)
			returning employee_id into NewEmployeeId1;
		
insert into
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id)
values
	(‘Nigel’, ‘Hussung’, ‘nigel@nigel.com’, ‘412-398-6283’, NewEmployeeTypeId)
			returning employee_id into NewEmployeeId2;
		
insert into
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id)
values
	(‘Anastasia’, ‘Thomas’, ‘anastasia@anastasia.com’, ‘689-321-4938’, NewEmployeeTypeId)
			returning employee_id into NewEmployeeId3;
		
insert into
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id)
values
	(‘Gio’, ‘Roggenbuck’, ‘gio@gio.com’, ‘513-284-5693’, NewEmployeeTypeId)
			returning employee_id into NewEmployeeId4;
	
insert into
	employees (
		first_name,
		last_name,
		email_address,
		phone,
		employee_type_id)
	values
	(‘Poppy’, ‘Nelson’, ‘poppy@poppy.com’, ‘378-276-3948’, NewEmployeeTypeId)
		returning employee_id into NewEmployeeId5;
/* WITHOUT FOREACH LOOP*/
insert into
	dealershipemployees (
		dealership_id,
		employee_id
	)
	values
		(36, NewEmployeeId1),
		(50, NewEmployeeId1),
		(20, NewEmployeeId1),
		
		(36, NewEmployeeId2),
		(50, NewEmployeeId2),
		(20, NewEmployeeId2),
		
		(36, NewEmployeeId3),
		(50, NewEmployeeId3),
		(20, NewEmployeeId3),
		
		(36, NewEmployeeId4),
		(50, NewEmployeeId4),
		(20, NewEmployeeId4),
		
		(36, NewEmployeeId5),
		(50, NewEmployeeId5),
		(20, NewEmployeeId5);
commit;
exception when others then
  RAISE INFO ‘Error:%’, SQLERRM;
  rollback;
end;
$$ language plpgsql;



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