select * from album
select * from employee
select * from CUSTOMER
select * from INVOICE_LINE
select * from genre
select * from track
SELECT * FROM INVOICE
SELECT * FROM PLAYLIST
SELECT * FROM PLAYLIST_TRACK
SELECT * FROM MEDIA_TYPE 
SELECT * FROM ARTIST
--EASY QUERY
--Q1: Who is the senior most employee based on job title?
SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC LIMIT 1;

--Q2: Which countries have the most Invoices?
SELECT COUNT(*) AS INVOICE, BILLING_COUNTRY  AS COUNTRY
FROM INVOICE
GROUP BY 2
ORDER BY 1 DESC;

--Q3: What are top 3 values of total invoice?
SELECT INVOICE_ID, TOTAL
FROM INVOICE
ORDER BY 2 DESC LIMIT 3;

/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/
SELECT SUM(TOTAL) AS NVOICE_TOTAL, BILLING_CITY
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY 1 DESC;

/*Question 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, SUM(I.TOTAL) AS TOTAL_SPEND
FROM CUSTOMER C
JOIN
INVOICE I
ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL_SPEND DESC LIMIT 1;

--MODERATE QUERY
/*Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A*/
--1ST METHOD
SELECT DISTINCT C.EMAIL, C.FIRST_NAME, C.LAST_NAME
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE IL.TRACK_ID IN (
       SELECT T.TRACK_ID FROM TRACK T
	   JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
	   WHERE G.NAME ILIKE 'ROCK'
)
	   ORDER BY C.EMAIL;

--2ND METHOD
SELECT DISTINCT
    c.email,
    c.first_name,
    c.last_name
    
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
 
ORDER BY c.email;

/*Q2: Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10 rock bands*/
--METHOD 1
SELECT
	A.ARTIST_ID,
	A.NAME,
	COUNT(A.ARTIST_ID) AS TOTAL_SONG
FROM
	ARTIST A
	JOIN ALBUM AL ON A.ARTIST_ID = AL.ARTIST_ID
	JOIN TRACK T ON AL.ALBUM_ID = T.ALBUM_ID
	JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
WHERE
	G.NAME ILIKE 'ROCK'
GROUP BY
	A.ARTIST_ID
ORDER BY
	TOTAL_SONG DESC
LIMIT
	10;


/*Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest
songs listed first.*/
SELECT
	NAME,
	MILLISECONDS AS MS
FROM
	TRACK
WHERE
	MILLISECONDS > (
		SELECT
			AVG(MILLISECONDS) AS AVG_MS
		FROM
			TRACK
	)
ORDER BY
	MS DESC;

--ADVANCE QUERY
--Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

/*Steps to Solve: First, find which artist has earned the most according to the InvoiceLines.Now use this artist to find which customer spent the most on this artist.
For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables. 
Note, this one is tricky because the Total spent in the Invoice table might not be on a single product,
so you need to use the InvoiceLine table to find out how many of each product was purchased,
and then multiply this by the price for each artist.*/
WITH BEST_SELLING_ARTIST AS(
	SELECT A.ARTIST_ID, A.NAME AS ARTIST_NAME, 
	SUM(IL.UNIT_PRICE*IL.QUANTITY) AS TOTAL_SALE
	FROM INVOICE_LINE IL
	JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
	JOIN ALBUM AL ON AL.ALBUM_ID = T.ALBUM_ID
	JOIN ARTIST A ON A.ARTIST_ID = AL.ARTIST_ID
	GROUP BY 1
	ORDER BY TOTAL_SALE DESC
	LIMIT 1
)

SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, BSA.ARTIST_NAME,
	SUM(IL.UNIT_PRICE*IL.QUANTITY) AS AMOUNT_SPEND
	FROM INVOICE I
	JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
	JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
	JOIN ALBUM AL ON AL.ALBUM_ID = T.ALBUM_ID
	JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID = AL.ARTIST_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/*Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre.For countries where the maximum number of purchases is
shared return all Genres.*/

--Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. 
WITH POPULAR_GENRE AS
(
	SELECT COUNT(IL.QUANTITY) AS PURCHASES, C.COUNTRY, G.NAME, G.GENRE_ID,
	ROW_NUMBER() OVER(PARTITION BY C.COUNTRY ORDER BY COUNT(IL.QUANTITY) DESC)
	AS ROW_NO
	FROM INVOICE_LINE IL
	JOIN INVOICE I ON IL.INVOICE_ID = I.INVOICE_ID
	JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
	JOIN GENRE G ON G.GENRE_ID = T.GENRE_ID
	GROUP BY 2,3,4
	ORDER BY 1 DESC
)
SELECT * FROM POPULAR_GENRE WHERE ROW_NO <= 1



/*Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount*/


/*Steps to Solve:  Similar to the above question. There are two parts in question- first find the most spent 
on music for each country and second filter the data for respective customers.*/
WITH RECURSIVE COUNTRY_WITH_CUSTOMER AS (
          SELECT C.CUSTOMER_ID,FIRST_NAME,LAST_NAME, I.BILLING_COUNTRY, SUM(I.TOTAL) AS TOTAL_SPENDING
		  FROM INVOICE I
		  JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
		  GROUP BY 1,2,3,4
		  ORDER BY 5 DESC),


COUNTRY_MAX_SPENDING AS (
          SELECT BILLING_COUNTRY, MAX(TOTAL_SPENDING) AS MAX_SPENDING
		  FROM COUNTRY_WITH_CUSTOMER
		  GROUP BY BILLING_COUNTRY
		 )
SELECT CC.BILLING_COUNTRY, CC.TOTAL_SPENDING, CC.FIRST_NAME, CC.LAST_NAME, CC.CUSTOMER_ID
FROM COUNTRY_WITH_CUSTOMER CC
JOIN COUNTRY_MAX_SPENDING MS
ON CC.BILLING_COUNTRY = MS.BILLING_COUNTRY
WHERE CC.TOTAL_SPENDING = MS.MAX_SPENDING
ORDER BY 1;









