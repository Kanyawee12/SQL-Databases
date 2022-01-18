--My first query
SELECT 
	firstname,
    LOWER(firstname) || '@chinook.com' AS email
FROM customers;

--Filter Table
SELECT firstname, company, country FROM customers
WHERE UPPER(country) = 'USA' 
	or UPPER(country) = 'FRANCE' 
    OR UPPER(country) = 'BRAZIL'; 
------------------------------------------------------------------------
SELECT firstname, company, country FROM customers
WHERE UPPER(country) IN ('USA', 'FRANCE', 'BRAZIL'); --tuple

SELECT firstname, company, country FROM customers
WHERE UPPER(country) NOT IN ('USA', 'FRANCE', 'BRAZIL'); --tuple // not this 3 country

SELECT firstname, company, country FROM customers 
where company is not NULL;

--Transform Column
SELECT 
	name,
    --composer,
    bytes,
    ROUND(milliseconds / 60000.0, 2) As minute,
    ROUND(bytes / (1024*1024.0), 4) as megabyte
from tracks

--Work with Date
SELECT datetime ('now');
-- format datetime to show element we want
SELECT 
	invoicedate,
    STRFTIME('%Y', invoicedate) as 'InvoicesYear', --camelcase: InvioicesYear
    STRFTIME('%m', invoicedate) as 'InvoicesMonth',
    STRFTIME('%d', invoicedate) as 'InvoicesDay'
FROM invoices
WHERE InvoicesMonth = '09' and InvoicesYear = '2010';

--CASE Example
SELECT country,
	case 
    	when country in ('USA', 'Canada') 				  THEN 'America Region'
        WHEN country in ('France', 'Belgium', 'Germany') THEN 'European Region'
        else 'Other Region'
    end as region
from customers;


-- intermediate WHERE
-- intermediate where clause
-- filter table befor select course
SELECT firstname, lastname FROM customers
where customerid BETWEEN 1 AND 5; -- where ustomerid >= 1 AND ustomerid <= 5

SELECT customerid, firstname, lastname FROM customers
where customerid <> 5; -- id 5 sript 

--like ==> pattern matching
SELECT name FROM tracks
where name like '%love%'; -- % wildcard -- case insensitive 

SELECT email FROM customers
where email like '%@yahoo%' 

SELECT name from tracks
WHERE name GLOB '[LM]*'; --GLOB is case sensitive

-- WHERE name NOT GLOB '[LM]*';

SELECT firstname, postalcode FROM customers
where postalcode GLOB '[0-9]*';
-- หรือ where postalcode NOT GLOB '[A-Z -]*';

--Aggregate
SELECT 
	AVG(milliseconds) as avg_mil,
    SUM(milliseconds) as sum_mil,
    MIN(milliseconds) as min_mil,
    MAX(milliseconds) as max_mil,
    COUNT(milliseconds) as count_mil,
    COUNT(*) -- count all records in a table
FROM tracks; --aggregate function ignore NULL

SELECT COUNT(*), COUNT(firstname), COUNT(company), count(postalcode) FROM customers;

--Aggregate + GROUP by
SELECT
	country,
	COUNT(*) as n
FROM customers
GROUP by country
HAVING n >= 4  -- having function do before group by 
ORDER By n DESC; -- order by last function
--ascending order น้อย - มาก

--Chart SQLite
--DROP TABLE count_cutomers_by_country;
CREATE TABLE count_cutomers_by_country AS
    SELECT
        country,
        COUNT(*) as n
    FROM customers
    GROUP by 1 -- country
    ORDER by 2 DESC;

--Chart
BAR-SELECT country as label, n as y FROM count_cutomers_by_country;

LINE-SELECT country as label, n as y FROM count_cutomers_by_country;

AREA-SELECT country as label, n as y FROM count_cutomers_by_country;

PIE-SELECT country as label, n as y FROM count_cutomers_by_country;


--CREATE VIEW
-- VIEW: virtual table
CREATE VIEW view_usa_customers as 
    SELECT * FROM customers
    WHERE country = 'USA';

SELECT * FROM view_usa_customers;

-- inner join
/*SELECT * from artists 
INNER JOIN albums on artists.artistid = albums.artistid --PK = FK
INNER JOIN tracks ON albums.albumid = tracks.albumid
INNER JOIN genres on genres.genreid = tracks.genreid;*/
DROP VIEW summary_table;

CREATE VIEW summary_table as
    SELECT 
        t1.artistid,
        t1.name as artist_name, 
        t2.Title, 
        t3.bytes,
        t3.name as track_name, 
        t4.Name as genre_name 
    from artists t1
    INNER JOIN albums t2 on t1.artistid = t2.artistid --PK = FK
    INNER JOIN tracks t3 ON t2.albumid = t3.albumid
    INNER JOIN genres t4 on t3.genreid = t4.genreid;


-- analyze data from our new view
SELECT 
	genre_name,
    COUNT(*) as n,
    AVG(bytes) as avg_byte,
    SUM(bytes) as sum_byte,
    MIN(bytes) as min_byte,
    MAX(bytes) as max_byte
FROM summary_table
where track_name like '%love%'
GROUP by 1
ORDER by 2 DESC;

--Subqueries
SELECT * FROM (
  SELECT firstname, lastname, country FROM (
      SELECT * FROM customers
  )
)
where country = 'Canada';

--SELECT max(bytes) FROM tracks : 1059546140
SELECT name, composer, bytes FROM tracks
where bytes = (SELECT max(bytes) FROM tracks);

SELECT name, composer, bytes FROM tracks
where bytes < (SELECT max(bytes) FROM tracks);


---- window functions (Analytics Function)
-- OVER() course = window functions -->create new column
-- run inner query (Subqueries) before outer query
SELECT * FROM (
		SELECT 
		firstname, 
	    country,
	    ROW_NUMBER() OVER(PARTITION BY country ORDER BY firstname) AS rowNum --window functions
		FROM customers
)
WHERE rowNum = 1 AND country IN ('Germany','USA');