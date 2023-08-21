--Chapter 13 - Virtual Tables with Views

--Example view from lesson:  

CREATE VIEW employee_dealership_names AS
  SELECT 
    e.first_name,
    e.last_name,
    d.business_name
  FROM employees e
  INNER JOIN dealershipemployees de ON e.employee_id = de.employee_id
  INNER JOIN dealerships d ON d.dealership_id = de.dealership_id;
  
 --Using a view from lesson: 
SELECT
	*
FROM
	employee_dealership_names;
	
--Practice: Carnival
--Create a view that lists all vehicle body types, makes and models.
--Create a view that shows the total number of employees for each employee type.
--Create a view that lists all customers without exposing their emails, phone numbers and street address.
--Create a view named sales2018 that shows the total number of sales for each sales type for the year 2018.
--Create a view that shows the employee at each dealership with the most number of sales.