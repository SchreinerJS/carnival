/*Carnival's Next Steps
Monique did a great job with the initial database. 
But we noticed that she didnt normalize her data enough. 
When we take a look at her VehicleType what do you notice?

SELECT *
FROM vehicletypes;

NOTE: there are duplicate entries for models
SELECT model, COUNT(model) 
FROM vehicletypes
GROUP BY model
HAVING COUNT(model) > 1;

Practice: VehicleType Normalization

1. Review Carnival's ERD and identify what you need to do
to normalize the VehicleTypes Table.
	
2. What tables still need to be created?
	--vehiclebodytypes, vehiclemodel, vehiclemakes?
	
3. What are the relationships can you identify?

4. Which should hold the primary key of the other as a foreign key?
	Vehicletypeid should be the primary key for a foreignkey vehiclebodytypeid

*Stop and think:

Why did we add a column to the vehicleTypes table? 
What data will we put in that column?

What data will need to go into the VehicleBodyTypes table?

What data will need to go into the vehicle_bodytype_id column in the vehicletypes table?*/