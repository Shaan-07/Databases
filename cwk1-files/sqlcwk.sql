/*
@author - Shaan Shaikh

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 musicstore.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vNoCustomerEmployee; 
DROP VIEW IF EXISTS v10MostSoldMusicGenres; 
DROP VIEW IF EXISTS vTopAlbumEachGenre; 
DROP VIEW IF EXISTS v20TopSellingArtists; 
DROP VIEW IF EXISTS vTopCustomerEachGenre; 

/*
============================================================================
Task 1: Complete the query for vNoCustomerEmployee.
DO NOT REMOVE THE STATEMENT "CREATE VIEW vNoCustomerEmployee AS"
============================================================================
*/
.mode column
.header on
CREATE VIEW vNoCustomerEmployee AS
SELECT EmployeeId, FirstName, LastName, Title FROM employees WHERE EmployeeId NOT IN (SELECT SupportRepId FROM customers);
SELECT * from vNoCustomerEmployee;

/*
============================================================================
Task 2: Complete the query for v10MostSoldMusicGenres
DO NOT REMOVE THE STATEMENT "CREATE VIEW v10MostSoldMusicGenres AS"
============================================================================
*/
CREATE VIEW v10MostSoldMusicGenres AS
SELECT g.Name AS Genre, SUM(ii.Quantity) AS Sales FROM genres g JOIN tracks t ON g.GenreId = t.GenreId JOIN invoice_items ii ON t.TrackId = ii.TrackId GROUP BY g.Name ORDER BY Sales DESC LIMIT 10;
SELECT * from v10MostSoldMusicGenres;


/*
============================================================================
Task 3: Complete the query for vTopAlbumEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopAlbumEachGenre AS"
============================================================================
*/
CREATE VIEW vTopAlbumEachGenre AS
SELECT Genre, Album, Artist, Sales
FROM (
    SELECT g.Name AS Genre, a.Title AS Album, ar.Name AS Artist, SUM(ii.Quantity) AS Sales,
           ROW_NUMBER() OVER(PARTITION BY g.Name ORDER BY SUM(ii.Quantity) DESC) AS RowNumber
    FROM genres g, tracks t, albums a, artists ar, invoice_items ii
    WHERE g.GenreId = t.GenreId
    AND t.AlbumId = a.AlbumId
    AND a.ArtistId = ar.ArtistId
    AND t.TrackId = ii.TrackId
    GROUP BY g.Name, a.Title, ar.Name
) AS RankedData
WHERE RowNumber = 1;

SELECT * from vTopAlbumEachGenre;


/*
============================================================================
Task 4: Complete the query for v20TopSellingArtists
DO NOT REMOVE THE STATEMENT "CREATE VIEW v20TopSellingArtists AS"
============================================================================
*/

CREATE VIEW v20TopSellingArtists AS
SELECT ar.Name AS Artist, 
       COUNT(DISTINCT a.AlbumId) AS TotalAlbum, 
       SUM(ii.Quantity) AS TrackSold
FROM artists ar, albums a, tracks t, invoice_items ii
WHERE ar.ArtistId = a.ArtistId
AND a.AlbumId = t.AlbumId
AND t.TrackId = ii.TrackId
GROUP BY ar.Name
ORDER BY TrackSold DESC, ar.ArtistID DESC
LIMIT 20;

SELECT * FROM v20TopSellingArtists;



/*
============================================================================
Task 5: Complete the query for vTopCustomerEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
SELECT Genre, TopSpender, MAX(TotalSpending) AS TotalSpending FROM
(SELECT g.Name AS Genre, 
       c.FirstName || ' ' || c.LastName AS TopSpender, 
       ROUND(SUM(ii.Quantity * ii.UnitPrice), 2) AS TotalSpending
FROM genres g
JOIN tracks t ON g.GenreId = t.GenreId
JOIN invoice_items ii ON t.TrackId = ii.TrackId
JOIN invoices i ON ii.InvoiceId = i.InvoiceId
JOIN customers c ON i.CustomerId = c.CustomerId
GROUP BY g.Name, c.CustomerId)
GROUP BY Genre;
SELECT * FROM vTopCustomerEachGenre;

