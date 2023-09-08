/*Stored Procedures Practice
Carnival would like to use stored procedures to process valuable business logic surrounding their business. Since they understand that procedures can hold many SQL statements related to a specific task they think it will work perfectly for their current problem.

Inventory Management
1. Selling a Vehicle
Carnival would like to create a stored procedure that handles the case of updating their vehicle inventory when a sale occurs. 
They plan to do this by flagging the vehicle as is_sold which is a field on the Vehicles table. 
When set to True this flag will indicate that the vehicle is no longer available in the inventory. 
Why not delete this vehicle? We don't want to delete it because it is attached to a sales record.

Goals
Use the story above and extract the requirements.
Build two stored procedures for Selling a car and Returning a car. 
Be ready to share with your class or instructor your result.*/

/* Q. Are we including leases in this process or purchased vehicles only?  
 A. For this one, focus on all sales (1 & 2)
 
--Q. It seems like this q. would be a perfect example of when a trigger might be needed?  Without one, all we can do
Is update the vehicles table to ensure that all vehicles with a sale_id are marked is_sold = TRUE.
Otherwise, we would need a trigger to recognize when a new sale is added.

SELECT * 
FROM sales;

REQUIREMENTS:
1. for every vehicle_id in the sales table, match to the vehicle_id in the vehicles table
2. mark that record is_sold = TRUE

IF THERE NEEDS TO BE A TRIGGER :
1. recognize when a new row/sale_id is added to the sales table
2. for each new sale_id, grab the vehicle_id in the vehicle table that matches to the vehicle_id in the sales_table
3. check the status of IS_SOLD for that vehicle (is this necessary?) 
		-- are there used vehicles marked as is_sold in vehicles but do not have a sale_id in the sales table?
4. if is_sold = FALSE, mark it as TRUE; (is IF needed?)
5. if is_sold = TRUE, leave it. (may not be needed)

WOULD THERE ALSO NEED TO BE A TRANSACTION?

--STORED PROCEDURE - Selling a vehicle

FROM Jessalynn:
Q. why no "IN" or "INOUT" on the parameter?

--Updating on vehicle_id ONLY*/
CREATE OR REPLACE PROCEDURE remove_inventory(p_vehicle_id int) -- Name the procedure and define inputs and outputs
LANGUAGE plpgsql  -- define language
AS $$
BEGIN -- start logic
	UPDATE vehicles
	SET is_sold = TRUE 
	WHERE vehicle_id = p_vehicle_id;

	COMMIT;

END -- Stop of logic
$$;

CALL remove_inventory(1);


--Updating on sale_id to get vehicle_id
CREATE OR REPLACE PROCEDURE update_inventory_after_sale(p_sales_id INT) -- Define input
LANGUAGE plpgsql  -- Define language
AS $$
DECLARE
    p_vehicle_id INT;
BEGIN -- Start logic
    -- Select vehicle_id from sales where sales_id equals the given sales_id
   SELECT vehicle_id INTO p_vehicle_id 
   FROM sales 
   WHERE sale_id = p_sales_id;

    -- Update vehicles to set is_sold to true where vehicle_id equals the selected vehicle_id
    UPDATE vehicles 
    SET is_sold = TRUE 
    WHERE vehicle_id = p_vehicle_id;
    
    COMMIT;
END; -- End of logic
$$;

CALL remove_inventory_after_sale(1);

/*2. Returning a Vehicle
Carnival would also like to handle the case for when a car gets returned by a customer. When this occurs they must add the car back to the inventory and mark the original sales record as sale_returned = TRUE.

Carnival staff are required to do an oil change on the returned car before putting it back on the sales floor. In our stored procedure, we must also log the oil change within the OilChangeLogs table. */

/* 1. mark sale_returned = TRUE
 2. mark is_sold = FALSE
 
--Demin's code--

--Updating on sale_id to get vehicle_id*/
CREATE OR REPLACE PROCEDURE update_inventory_after_return(p_sales_id INT) -- Define input
LANGUAGE plpgsql  -- Define language
AS $$
DECLARE
    p_vehicle_id INT;
BEGIN -- Start logic
    -- Select vehicle_id from sales where sales_id equals the given sales_id
    SELECT vehicle_id INTO p_vehicle_id FROM sales WHERE sale_id = p_sales_id;

    -- Update vehicles to set is_sold to false where vehicle_id equals the selected vehicle_id
    UPDATE vehicles 
    SET is_sold = FALSE 
    WHERE vehicle_id = p_vehicle_id; 
    
   -- Update vehicles to set is_sold to true where vehicle_id equals the selected vehicle_id
    UPDATE vehicles 
    SET is_sold = TRUE
    WHERE vehicle_id = p_vehicle_id;
    
COMMIT;

END; -- End of logic
$$;

CALL remove_inventory_after_sale(1);
____________________

