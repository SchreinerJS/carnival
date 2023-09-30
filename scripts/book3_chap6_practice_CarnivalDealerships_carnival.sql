/*BOOK 3 CHAP 6
 CARNIVAL DEALERSHIPS

 1. Because Carnival is a single company, we want to ensure that there is consistency in the data provided to the user. 
 Each dealership has its own website but we want to make sure the website URL are consistent and easy to remember. 
 Therefore, any time a new dealership is added [or an existing dealership is updated], 
 we want to ensure that the website URL has the following format:
 http://www.carnivalcars.com/{name of the dealership with underscores separating words}.

Q. "if an existing dealership is updated" -- when anything for that dealership is updated, or just the business_name and/or website?
METHOD:
	a) use LOWER(REPLACE to update business_name spaces to underscores
	b) CONCAT that with the text provided above

TWO TRIGGERS NEEDED:
1) AFTER INSERT NEW.dealership_id 
2) [AFTER OR BEFORE?] UPDATE on the dealership table*/

CREATE OR REPLACE FUNCTION update_dealership_website_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update website in the trigger function
    NEW.website := 'http://www.carnivalcars.com/' || LOWER(REPLACE(NEW.business_name, ' ', '_'));
    RETURN NEW;
END;
$$ ;

CREATE TRIGGER dealership_website_trigger
BEFORE INSERT ON dealerships
FOR EACH ROW
EXECUTE FUNCTION update_dealership_website_trigger();

CREATE OR REPLACE TRIGGER dealership_update_trigger
BEFORE UPDATE ON dealerships
FOR EACH ROW
EXECUTE FUNCTION update_dealership_website_trigger();

--DROP TRIGGER dealership_insert_website_trigger ON dealerships;

--test insert
INSERT INTO dealerships (business_name, city, state, website, tax_id)
VALUES ('Crest Honda', 'Nashville', 'Tennessee', 'cresthonda.com', 'ab-121-ab-12a2');

--test update
UPDATE dealerships
SET business_name = 'Jepizza H Crest Honda'
WHERE dealership_id = 74

--review 
SELECT dealership_id, business_name, phone, website
FROM dealerships
ORDER BY dealership_id DESC

DELETE FROM dealerships
WHERE dealership_id = 74;

/*2. If a phone number is not provided for a new dealership, set the phone number to the default customer care number 777-111-0305.*/

CREATE OR REPLACE FUNCTION default_phone()
   RETURNS TRIGGER 
   LANGUAGE plpgsql
AS $$
BEGIN
	
	IF NEW.phone IS NULL THEN
		
		UPDATE dealerships
		SET phone = '777-111-0305'
		WHERE dealerships.dealership_id = NEW.dealership_id;
		
	END IF;

	RETURN NULL;

END;
$$;

--how to test above with a SELECT statemetn on the function?

CREATE OR REPLACE TRIGGER insert_default_phone
AFTER INSERT ON dealerships
FOR EACH ROW
EXECUTE PROCEDURE default_phone();

--sample data
INSERT INTO dealerships (business_name, city, state, website, tax_id)
VALUES ('Crest Honda', 'Nashville', 'Tennessee', 'cresthonda.com', 'ab-121-ab-12a2');

--review
SELECT dealership_id, business_name, phone, website
FROM dealerships
ORDER BY dealership_id DESC
--DROP TRIGGER dealership_insert_website_trigger ON dealerships

--delete sample data
DELETE FROM dealerships
WHERE dealership_id = 70;

/* 3. For accounting purposes, the name of the state needs to be part of the dealership's tax id. 
For example, if the tax id provided is bv-832-2h-se8w for a dealership in Virginia, 
then it needs to be put into the database as bv-832-2h-se8w--virginia.*/

--Q. If a state has more than one name, replace spaces with hyphens, underscore, or nothing?
	--DECISION, remove spaces
--Q. Should all existing dealership tax ids be updated, as well as any newly inserted dealerhips?
	--DECISION, at this time, only updating newly inserted dealerships

--TRIGGERS QUESTIONS:
--If we need to create a trigger to update all existing ids, would that be statement-level or row-level?
--Is there a way to test to avoid the incremental gaps due to inserting test data which is then deleted after (transactions)?

CREATE OR REPLACE FUNCTION update_dealership_tax_id()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Update website in the trigger function
   NEW.tax_id := NEW.tax_id || '--' || LOWER(REPLACE(NEW.state, ' ', ''));
   RETURN NEW;
END;
$$ ;

CREATE OR REPLACE TRIGGER update_tax_id
BEFORE INSERT ON dealerships
FOR EACH ROW
EXECUTE PROCEDURE update_dealership_tax_id();

--[write trigger if needed to update all existing]

--sample data
INSERT INTO dealerships (business_name, city, state, website, tax_id)
VALUES ('Crest Honda', 'Asheville', 'North Carolina', 'cresthonda.com', 'ab-121-ab-12a2');

SELECT dealership_id, business_name, phone, website, state, tax_id
FROM dealerships
ORDER BY dealership_id DESC

--delete sample data
DELETE FROM dealerships
WHERE dealership_id = 89;
_________________________________
--1st ATTEMPT Q1:  

--CREATE OR REPLACE FUNCTION update_dealership_website(business_name TEXT)
--RETURNS TEXT
--LANGUAGE plpgsql
--AS $$
--DECLARE
--   updated_name TEXT;
--   updated_website TEXT;
--BEGIN
--    -- Replace spaces in NEW.business_name with underscores
--    updated_name := LOWER(REPLACE(business_name, ' ', '_'));
--   
--    -- Update website
--    updated_website := 'http://www.carnivalcars.com/' || updated_name::TEXT;
--
--    RETURN updated_website;
--END;
--$$ ;

--test
--SELECT update_dealership_website('Boomes Autos of Alabama');
--SELECT update_dealership_website('Sample Business Name');

--DROP FUNCTION update_dealership_website(business_name TEXT)

--create trigger function to call the website update function/procedure
--CREATE OR REPLACE FUNCTION update_dealer_website_trigger()
--RETURNS TRIGGER 
--LANGUAGE plpgsql
--AS $$
--BEGIN
--  NEW.website := update_dealership_website(NEW.business_name);
--   RETURN NEW;
--END;
--$$ ;

--SELECT * FROM pg_trigger WHERE tgname = 'dealership_insert_email_trigger';



---------------------------

/*William's code for inserting current date if no date is inserted:
CREATE OR REPLACE FUNCTION SetPurchaseDate()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN

	IF (SELECT purchase_date FROM sales WHERE sales.sale_id = NEW.sale_id) IS NULL THEN 
  		UPDATE sales
  		SET purchase_date = CURRENT_DATE
  		WHERE sales.sale_id = NEW.sale_id;
    END IF;
	
	UPDATE sales
	SET pickup_date = NEW.purchase_date + integer '3'
	WHERE sales.sale_id = NEW.sale_id;
	
	RETURN NULL;
	
END
$$
;

CREATE OR REPLACE TRIGGER new_sale
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE PROCEDURE SetPurchaseDate()
; 
 */


--Ex.
--CREATE FUNCTION set_net_price() 
--  RETURNS TRIGGER 
--  LANGUAGE PlPGSQL
--AS $$
--BEGIN
--  -- trigger function logic
--	UPDATE product 
--	SET net_price = price - price * discount  
--	FROM product_segment  
--	WHERE product.segment_id = product_segment.id;  
--
--  
--  RETURN NULL;
--END;
--$$
--
---- then we create the trigger
--CREATE TRIGGER new_net_price
--  AFTER INSERT
--  ON product
--  FOR EACH ROW
--  EXECUTE PROCEDURE set_net_price();
	
   -- trigger logic


