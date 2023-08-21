--JOINING Practice: Carnival
--Get a list of the sales that were made for each sales type.
SELECT
	s.sale_id,
	st.sales_type_name,
	s.purchase_date,
	s.price
FROM salestypes AS st
LEFT JOIN sales AS s ON st.sales_type_id = s.sales_type_id
ORDER BY st.sales_type_name, s.purchase_date DESC;

--Get a list of sales with the VIN of the vehicle, the first name and last name of the customer,
--first name and last name of the employee who made the sale and the name, city and state of the dealership.

SELECT 
	purchase_date,
	price,
	vin,
	c.first_name AS customer_first_name,
	c.last_name AS customer_last_name,
	e.first_name AS employee_first_name,
	e.last_name AS employee_last_name,
	business_name,
	d.city,
	d.state
FROM sales s
	LEFT JOIN customers c ON s.customer_id = c.customer_id
	LEFT JOIN vehicles v ON s.vehicle_id = v.vehicle_id
	LEFT JOIN dealerships d ON s.dealership_id = d.dealership_id
	LEFT JOIN employees e ON s.employee_id = e.employee_id
ORDER BY s.purchase_date DESC;

--Get a list of all the dealerships and the employees, if any, working at each one.
SELECT 
	DISTINCT d.business_name AS dealership_name,
	e.last_name AS employee_last_name,
	e.first_name AS employee_first_name
FROM dealerships d
	LEFT JOIN dealershipemployees de ON d.dealership_id = de.dealership_id
	LEFT JOIN employees e ON de.employee_id = e.employee_id
ORDER BY dealership_name, employee_last_name, employee_first_name;

--Get a list of vehicles with the names of the body type, make, model and color.
SELECT 	vin,
		body_type,
		make,
		model,
		interior_color,
		exterior_color
FROM vehicles v
	LEFT JOIN vehicletypes vt 
	ON v.vehicle_type_id = vt.vehicle_type_id;