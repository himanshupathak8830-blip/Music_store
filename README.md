# 🎵 Music Store Database – Project Description
The Music Store Database Project is a SQL-based data analysis project designed to explore and analyze a digital music store’s transactional data. The database contains information related to artists, albums, tracks, genres, customers, invoices, and employees. The objective of this project is to perform real-world data analysis using SQL queries and generate meaningful business insights such as customer behavior, sales performance, and popular music trends. By working on this project, core SQL concepts like joins, aggregations, grouping, subqueries, and sorting are applied to answer practical business questions that a data analyst would face in a real music retail environment.

## 🎯 Project Objectives
- Understand relational database structure
- Analyze music sales data using SQL
- Identify top-performing customers, cities, and countries
- Find most popular music genres and tracks
- Practice real-life SQL interview questions

## 🗂️ Dataset Overview
- The dataset simulates a real digital music store and includes:
- Customer purchase history
- Track and genre details
- Artist and album information
- Invoice and revenue data
- Employee hierarchy
- All tables are connected using Primary Keys and Foreign Keys, ensuring data consistency and relational integrity.

## 🛠 Skills Demonstrated
- SQL querying & analysis
- Data aggregation and filtering
- Multi-table joins
- Business problem solving
- Database exploration

# 🎵 Music Store SQL Project – Query Explanation
🟢 EASY LEVEL QUESTIONS (Basic Understanding)
## These queries are used to explore the database and answer simple business questions.
### 1️⃣ Who is the senior most employee?
```sql
SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1;

Explanation:
The levels column represents the employee hierarchy. Sorting in descending order brings the highest level employee first. LIMIT 1 returns only the most senior employee.
📌 Business Insight:
Helps identify the top authority in the company.
### 2️⃣ Which countries have the most invoices?
```sql
SELECT COUNT(*) AS invoice, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice DESC;

Explanation:
Counts total invoices for each country.
Groups data country-wise.
Orders results so the country with the highest invoices appears first.
📌 Business Insight:
Identifies countries generating the most sales.

### 3️⃣ What are the top 3 invoice totals?
```sql
SELECT invoice_id, total
FROM invoice
ORDER BY total DESC
LIMIT 3;
Explanation:
Sorts invoices by total amount.
Displays the top 3 highest-value invoices.
📌 Business Insight:
Shows the highest single purchases made.

### 4️⃣ Which city has the best customers?
```sql
SELECT billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC;
Explanation:
Adds up invoice totals city-wise.
The city with highest revenue comes first.
📌 Business Insight:
Best city for promotions or concerts.

### 5️⃣ Who is the best customer?
```sql
SELECT c.customer_id, c.first_name, c.last_name, 
SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;
Explanation:
Joins customers with their invoices.
Calculates total spending per customer.
Returns the highest spender.
📌 Business Insight:
Most valuable customer for loyalty programs.

#🟡 MODERATE LEVEL QUESTIONS (Joins + Filters)
These queries involve multiple tables and deeper analysis.
6️⃣ List all Rock music listeners
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;
Explanation:
Multiple joins connect customers to genres.
Filters only Rock genre listeners.
DISTINCT avoids duplicate customers.
📌 Business Insight:
Target Rock music fans for marketing.
7️⃣ Top 10 artists who wrote the most Rock music
SELECT ar.name, COUNT(*) AS track_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.name
ORDER BY track_count DESC
LIMIT 10;
Explanation:
Links artists → albums → tracks → genres.
Counts Rock tracks per artist.
Returns top 10 Rock artists.
📌 Business Insight:
Most influential Rock artists in the store.
8️⃣ Tracks longer than average length
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
);
Explanation:
Subquery calculates average track length.
Main query returns tracks longer than average.
📌 Business Insight:
Identifies long-duration premium tracks.
🔴 ADVANCED LEVEL QUESTIONS (Subqueries + Business Logic)
These are interview-level / real analyst queries.
9️⃣ How much has each customer spent on artists?
SELECT c.customer_id, c.first_name, c.last_name, ar.name,
SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.name
ORDER BY total_spent DESC;
Explanation:
Calculates spending per customer per artist.
Uses multiple joins and aggregation.
Revenue is calculated using price × quantity.
📌 Business Insight:
Understand customer preferences by artist.
🔟 Most popular music genre for each country
WITH genre_sales AS (
  SELECT i.billing_country, g.name, 
  COUNT(il.quantity) AS purchases
  FROM invoice i
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  JOIN track t ON il.track_id = t.track_id
  JOIN genre g ON t.genre_id = g.genre_id
  GROUP BY i.billing_country, g.name
)
SELECT *
FROM genre_sales gs
WHERE purchases = (
  SELECT MAX(purchases)
  FROM genre_sales
  WHERE billing_country = gs.billing_country
);
Explanation:
CTE calculates genre sales per country.
Subquery finds the highest purchased genre per country.

📌 Business Insight:
- Country-wise music taste analysis.

🏁 Conclusion
- This project demonstrates:
- Strong SQL fundamentals
- Real-world business problem solving
- Ability to work with complex joins and subqueries
- Interview-ready SQL knowledge
