--View all vehicles in database
SELECT *
FROM vehicles;

--Get in the habit of immediately using a table alias

SELECT
    v.engine_type,
    v.floor_price,
    v.msr_price
FROM Vehicles v;

OR

SELECT
    v.engine_type,
    v.floor_price,
    v.msr_price
FROM Vehicles AS v;

--Practice: Write a query that returns the business name, city, state, and website for each dealership.
--Use an alias for the Dealerships table.
SELECT d.business_name, d.city, d.state, d.website
FROM dealerships AS d;

--Practice: Write a query that returns the first name, last name, and email address of every customer.
--Use an alias for the Customers table.

SELECT c.first_name, c.last_name, c.email
FROM customers AS c;










