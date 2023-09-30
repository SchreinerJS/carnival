/*Use the Carnival ERD to identify the tables that are still missing in your database.

Which tables need to be created after reviewing the ERD?
What levels of normalization will these new tables be supporting?
Do any of these tables have a foreign key in another table? What is the child table that would hold the foreign key(s).
Consider
What needs to be created or modified? Don't just consider tables, but foriegn keys and other table modifications as well.
What data needs needs to change or move? See note on Data Migration below
What needs to be deleted?
Does order matter? What order should tasks be completed in?

SELECT DISTINCT body_type FROM vehicletypes v
SELECT DISTINCT make FROM vehicletypes v
SELECT DISTINCT model FROM vehicletypes v

SELECT * FROM vehicletypes v

DO $$
DECLARE
	body_type_id INTEGER;
	model_id INTEGER;
	make_id INTEGER;

BEGIN
	--create new tables
	CREATE TABLE vehiclebodytypes(
		vehicle_body_type_id SERIAL PRIMARY KEY,
		body_type VARCHAR NOT NULL
	);
	
	CREATE TABLE vehiclemodels(
		vehicle_model_id SERIAL PRIMARY KEY,
		model VARCHAR NOT NULL
	);
	
	CREATE TABLE vehiclemakes(
		vehicle_make_id SERIAL PRIMARY KEY,
		make VARCHAR NOT NULL

--migration
	INSERT INTO vehiclebodytypes (body_type)
		SELECT DISTINCT body_type FROM vehicletypes;
	
	INSERT INTO vehiclemodels (model)
		SELECT DISTINCT model FROM vehicletypes	

	INSERT INTO vehiclemakes (make)
		SELECT DISTINCT make FROM vehicletypes	
		
	ALTER TABLE vehicletypes
	ADD COLUMN vehicle_body_type_id int
	REFERENCES vehiclebodytypes(vehicle_body_type_id);
	
	ALTER TABLE vehicletypes
	ADD COLUMN vehicle_model_id int
	REFERENCES vehiclebodytypes(vehicle_model_id);

	UPDATE vehicletypes vt
	SET vt.vehicle_body_type_id = vbt.vehicle_body_type_id
	FROM vehiclebodytypes vbt
	WHERE vt.body_type = vbt.body_type
	
	UPDATE vehicletypes vt
	SET make = vehicle_make_id
	FROM vehiclemakes vm1
	WHERE vt.make = vm1.make;
	
	UPDATE vehicletypes vt
	SET model = vehicle_model_id
	FROM vehiclemodels vm2
	WHERE vt.model = vm2.model;
	
	ALTER TABLE vehicletypes
	ALTER COLUMN body-type
	SET DATA TYPE integer
	USING body_type::integer
	
	
	ADD CONTRAINT vehcilestypes_vehiclebodytypes
	FOREIGN KEY (vehicle_body_type_id)
	REFERENCES vehiclebodytypes (vehicle_body_type_id);
	
	
	INSERT INTO vehiclebodytypes (body_type)
	VALUES (
		SEELCT DISTINCT body_type FROM vehicletypes
	
EXCEPTION WHEN OTHERS THEN
RAISE INFO 'error:%', SQLERRM;
ROLLBACK;

END $$;
_________________
	RETURNING vehicle_body_type_id INTO body_type_id;
	RETURNING vehicle_model_id INTO model_id;
	RETURNING vehicle_make_id INTO make_id;

	-- verify migration		

			
					SELECT COUNT(DISTINCT body_type) AS orig_count FROM vehicletypes;
	SELECT COUNT(*) AS newbody_count FROM vehicletypes;
	IF orig_count <> newbody_count THEN
		ROLLBACK;
	END IF;

	SELECT COUNT(DISTINCT body_type) AS orig_count FROM vehicletypes v
	SELECT COUNT(*) AS newbody_count
	
	
	CREATE TABLE vehiclemakes(
		vehicle_make_id SERIAL PRIMARY KEY,
		make VARCHAR NOT NULL
		
-- verify migration		
SELECT COUNT(DISTINCT body_type) AS orig_count FROM vehicletypes;
SELECT COUNT(*) AS newbody_count FROM vehicletypes;
IF orig_count <> newbody_count THEN
	ROLLBACK;
END IF;

-- ALTER TABLE vehicletypes??
--Lauren
ALTER TABLE table_name
ALTER COLUMN table_name SET DATA TYPE IN
--or CREATE OR REPLACE TABLE vehicletypes??

EXCEPTION WHEN OTHERS THEN
RAISE INFO 'error:%', SQLERRM;
ROLLBACK;

END $$;



--
END;

