/*BOOK 2 CHAP 2 DELETING DATA
Let's delete an existing sales record from the Sales table*/

-- DELETE statement to delete one specific record:
DELETE FROM sales WHERE sales.sale_id = 100;

-- DELETE statement to delete specific records by id:
DELETE FROM sales
WHERE sales.sale_id IN (100, 200, 300);

SELECT *
FROM sales
WHERE sale_id IN (100, 200, 300);

-- DELETE statement to delete a specific vehicle record by year of car:
DELETE FROM vehicles
WHERE year_of_car <= '2017';

-- this last delete produces an error b/c vehicle record has a foreign key
-- in the Sales table.  Since we don't want to remove a constraint, we instead
-- specify how that constraint should behave upon a DELETE.

--ON DELETE CASCADE will help to delete both parent and child records.
--ON DELETE CASCADE is set with CREATE or ALTER TABLE.


/*PRACTICE -- Employees
1. A sales employee at carnival creates a new sales record for a sale they are trying to close.
The customer, last minute decided not to purchase the vehicle. 
Help delete the Sales record with an invoice number of '2436217483'.
Actually, how was the sale record generated?  Shouldn't it have been generated automatically upon payment?  
And if so, then should it just be a case of updating "sale_returned" as TRUE?

If we were to delete:*/
SELECT * FROM sales
WHERE sales.invoice_number = '2436217483' 

DELETE FROM sales
WHERE sales.invoice_number = '2436217483'
RETURNING *;

SELECT * FROM sales
WHERE sales.invoice_number = '2436217483' 

/*2. An employee was recently fired so we must delete them from our database.
Delete the employee with employee_id of 35. 

What problems might you run into when deleting? 

ANSWER -- the employee_id pk has fk's in sales & dealershipemployees tables
--Sales should remain in the database and not be deleted.
--Employees might also need to remain in the database for tax purposes
--Constraints should be reviewed to see if ON DELETE CASCADE is already set 
 	
How would you recommend fixing it?
ANSWER:
--Check constraints
--Suggest to stakeholders to instead create an "Active" boolean column to deactivate employees who no longer work at a dealership