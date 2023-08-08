-- INSERT statement to add a new sales type:
INSERT INTO public.salestypes(sales_type_name) VALUES ('Rent');

-- INSERT statement to add a new sale:
INSERT INTO public.sales(sales_type_id, vehicle_id, employee_id, dealership_id, price, invoice_number)
VALUES (3, 21, 12, 7, 55999, 123477289);

SELECT *
FROM salestypes;

SELECT *
FROM sales;

-- INSERT statement to add 3 new sales:
INSERT INTO 
public.sales(sales_type_id, vehicle_id, employee_id, dealership_id, price, invoice_number)
VALUES 
(3, 21, 12, 7, 55999, 123477289),
(3, 14, 3, 7, 19999, 232727349),
(3, 6, 75, 7, 39500, 8635482010);

SELECT *
FROM sales;

-- DELETE duplicate row from examples:
DELETE FROM sales
WHERE sale_id = 5002;

SELECT *
FROM sales;

SELECT *
FROM customers;

--Pick two friends or family, write a single INSERT statement to add both to the Customers table
INSERT INTO
public.customers(first_name, last_name, email, street, city, state, zipcode, company_name, phone_number)
VALUES 
('Pam', 'Butler', 'knitter.pam@gmail.com', '228 Springhouse Circle', 'Franklin', 'TN', '37067', 'Vanderbilt University Medical Center', '615-579-9546'),
('Lydia', 'Kennedy', 'lydiakennedy2@gmail.com', '2011 Richard Jones Road Apt H-5', 'Nashville', 'TN', '37215', 'HCA Healthcare', '615-429-0999');

SELECT *
FROM customers;

--Add your dream car to the Vehicles table (you might need to add data to the VehicleTypes table first).
--Order the statements and execute all your INSERT statements together.

-- Add a new vehicle type:
INSERT INTO public.vehicletypes(body_type, make, model)
	VALUES ('SUV', 'Porsche', 'Macan S');

--Add a new dealership
INSERT INTO public.dealerships(business_name, phone, city, state, website, tax_id)
	VALUES ('Porsche of Nashville', '855-574-8042', 'Brentwood', 'Tennessee', 'https://www.porscheofnashville.com', 'aa-111-aa-11a1');

-- Add dream vehicle:
INSERT INTO
public.vehicles(vin, engine_type, vehicle_type_id, exterior_color, interior_color, floor_price, msr_price, miles_count, year_of_car, is_sold, is_new, dealership_location_id)
VALUES
('WP1S2295ZPSB01234', 'V6', 35, 'orange', 'black', 78480, 37067, 116, 2023, false, true, 56);

SELECT *
FROM vehicles;

--Add a new employee who works shifts at the first three dealerships listed in Dealerships table:
INSERT INTO
public.employees(first_name, last_name, email_address, phone, employee_type_id)
VALUES
('Kennie', 'Maharg','kmaharge@com.com', '598-678-4885', 4);
--NOTE: are there typos in the email address?

INSERT INTO
public.dealershipemployees(dealership_id, employee_id)
VALUES
(1, 1001),
(2, 1001),
(3, 1001);

SELECT *
FROM dealershipemployees;