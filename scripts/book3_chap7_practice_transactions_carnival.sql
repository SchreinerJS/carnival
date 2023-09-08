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

--[Should exception handling be applied]?

-- start transaction
BEGIN;

SAVEPOINT et1;

-- insert a new row into the sales type table
INSERT INTO employeetypes(employee_type_name)
VALUES('Automotive Mechanic');
--[RETURNING (declare variable for 2nd section)
--[RETURNING (declare variable for 3rd section)]

SAVEPOINT et2;

-- insert a new row into the employees table
INSERT INTO employees(first_name, last_name, email_address, phone, employee_type_id)
VALUES
('Glenn', 'McBrayer', 'glenn.mcbrayer@tdn.com', '123-321-1111',   DECLARE variable and then SELECT that variable, 18)
('Gregory', 'Richter', 'gregory.richter@tdn.com', '123-321-2222', 18),
('Kyle', 'Roberts', 'kyle.roberts@tdn.com', '123-321-3333', 18),
('Hershell', 'Koechner', 'hershell.koechner@tdn.com', '123-321-4444', 18),
('Susan', 'Adams', 'susan.adams@tdn.com', '123-321-5555', 18);

SAVEPOINT et3;

INSERT INTO dealershipemployees(dealership_id, employee_id)
VALUES
(20, 1002),
(36, 1002), 
(50, 1002),
(20, 1003),
(36, 1003), 
(50, 1003),
(20, 1004),
(36, 1004), 
(50, 1004),
(20, 1005),
(36, 1005), 
(50, 1005),
(20, 1006),
(36, 1006), 
(50, 1006);

--rollback the transaction
ROLLBACK;

-- commit the transaction
COMMIT;

--ROLLBACK TO SAVEPOINT et1;

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