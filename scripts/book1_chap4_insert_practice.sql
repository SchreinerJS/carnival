--Create test table

DROP TABLE IF EXISTS links;

CREATE TABLE links (
	id SERIAL PRIMARY KEY,
	url VARCHAR(255) NOT NULL,
	name VARCHAR(255) NOT NULL,
	description VARCHAR (255),
    last_update DATE
);

--Insert row and show contents of links table
INSERT INTO links (url, name)
VALUES('https://www.postgresqltutorial.com','PostgreSQL Tutorial');

SELECT *
FROM links;

--Insert row with ' in string
INSERT INTO links (url, name)
VALUES('http://www.oreilly.com','O''Reilly Media');

SELECT *
FROM links;

-- Insert row with date
INSERT INTO links (url, name, last_update)
VALUES('https://www.google.com','Google','2013-06-01');

SELECT *
FROM links;

-- Insert row & return the last insert id
INSERT INTO links (url, name)
VALUES('http://www.postgresql.org','PostgreSQL') 
RETURNING id;

SELECT *
FROM links;

-- Insert multiple rows to links
INSERT INTO 
    links (url, name)
VALUES
    ('https://www.google.com','Google'),
    ('https://www.yahoo.com','Yahoo'),
    ('https://www.bing.com','Bing');
   
SELECT *
FROM links;

--Insert multiple rows and return inserted ROWS
INSERT INTO 
    links(url,name, description)
VALUES
    ('https://duckduckgo.com/','DuckDuckGo','Privacy & Simplified Search Engine'),
    ('https://swisscows.com/','Swisscows','Privacy safe WEB-search')
RETURNING *;

SELECT *
FROM links;




