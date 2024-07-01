create database Test 
use Test
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);


-- Section 1: 1 mark each
-- Write a query to calculate the price of 'Starry Night' plus 10% tax.
select 
      price=price*1.10
 from 
     artworks
where 
     title='Starry Night'

-- Write a query to display the artist names in uppercase.
select
     UPPER(name)
from 
    artists

-- Write a query to extract the year from the sale date of 'Guernica'.
SELECT
     YEAR(sale_date)
from 
    artworks as a
JOIN
    sales as s on a.artwork_id=s.artwork_id
where 
     title ='Guernica'
-- Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
SELECT
      total_amount
from 
    artworks as a 
JOIN
    sales as s on a.artwork_id=s.sale_id
where 
     title='Mona Lisa'


-- Section 2: 2 marks each
-- Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
 with cte as(
 select 
      artist_id,avg(price) as avgprice
from 
    artworks
group by artist_id
 )
select *
from 
    cte
where 
     avgprice < (select price from artworks )


-- Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
 SELECT
      name ,birth_year
 from 
     artists
where 
     birth_year <(select avg(birth_year) from artists)
    
 

-- Write a query to create a non-clustered index on the sales table to improve query performance for queries filtering by artwork_id.
  create NONCLUSTERED index IX_Fliteringaetwork_id;
 on artworks[artwork_id];


-- Write a query to display artists who have artworks in multiple genres.
   SELECT
         i.name,o.artist_id,count(genre) as number
   from 
       artworks as o 
    join 
        artists as i on o.artist_id=i.artist_id
    group by 
            o.artist_id,i.name
    having
         count(genre) >1

-- Write a query to rank artists by their total sales amount and display the top 3 artists.
    SELECT
         top(3) total_amount,i.name
    from 
        sales as s 
    JOIN
        artworks as o on s.artwork_id=o.artwork_id
    JOIN
        artists as i on o.artist_id=i.artist_id
    order BY
            total_amount desc
    

-- Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
   SELECT
        o.artist_id,i.name
   from 
        artworks as o 
    join 
        artists as i on o.artist_id=i.artist_id
     where 
          genre ='Cubism'

    INTERSECT

    SELECT
        o.artist_id,i.name
   from 
        artworks as o 
    join 
        artists as i on o.artist_id=i.artist_id
     where 
          genre ='Surrealism'


-- Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
  
   SELECT
        top(2) a.price,a.artist_id
        ,sum(quantity) as totalQuantity

    from  
        sales as s 
    JOIN
        artworks as a on s.artwork_id=a.artwork_id
   
     group by artist_id ,price
     order by 
             price DESC
    
    
   

-- Write a query to find the average price of artworks for each artist.
   select 
        i.artist_id,o.artwork_id,i.name, avg(price) as averageprice
   from 
       artworks as o
    join 
        artists as i on o.artist_id=i.artist_id
    GROUP BY
           o.artwork_id,i.artist_id,i.name

-- Write a query to find the artworks that have the highest sale total for each genre.
    SELECT
       title,distinct artist_id,DENSE_RANK() over (partition by genre order by total_amount) as rank
    from 
        sales as s 
    join 
        artworks as a on s.artwork_id=s.artwork_id


-- Write a query to find the artworks that have been sold in both January and February 2024.
  with cte as(
   SELECT
         a.artwork_id,a.title
         , format(sale_date,'MMMMyyyy') as dateofsales
    from 
        sales as s
    JOIN
        artworks as a on s.artwork_id=a.artwork_id
    group by  
            format(sale_date,'MMMMyyyy'), a.artwork_id,a.title)

    SELECT
         *
    from 
        cte
    WHERE
         dateofsales='January2024'
        INTERSECT
     SELECT
         *
    from 
        cte
    WHERE
         dateofsales='February2024'


-- Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.



-- Section 3: 3 Marks Questions
-- Write a query to create a view that shows artists who have created artworks in multiple genres.
   GO
   create view multiplegenres
   as
   select 
         i.name,o.artist_id,count(genre) as numberofgenre
   from 
        artworks as o
    join 
        artists as i on o.artist_id=i.artist_id
     group BY
           i.name,o.artist_id
    HAVING 
          count(genre) >1
    go
-- Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
    with cte as (
   select 
       artist_id,avg(price) over (partition by artwork_id order by artist_id) as avgprice,artwork_id
    from 
       artworks
     
              )
    select *
    from 
        cte as o
    where 
         avgprice <(select price from artworks as i where i.artist_id=o.artist_id)
    
    

-- Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
  with cte as (
   select 
       i.name,o.artist_id,avg(price) as avgprice
    from 
       artworks as o
    join 
        artists as i on o.artist_id=i.artist_id
    group by 
            o.artist_id,i.name
     
              )
    select *
    from 
        cte as o
    where 
         avgprice >(select avg(price)from artworks )
            

-- Section 4: 4 Marks Questions
-- Write a query to export the artists and their artworks into XML format.

-- Write a query to convert the artists and their artworks into JSON format.
SELECT
    a.artist_id,
    a.name AS author_name,
    a.country,
    a.birth_year,
    JSON_QUERY((
        SELECT
            b.artwork_id,
            b.title,
            b.genre,
            b.price
        FROM
            artworks b
        WHERE
            b.artist_id = a.artist_id
        FOR JSON PATH
    )) AS books
FROM
    artists as a
FOR JSON PATH, ROOT('artist');

-- Section 5: 5 Marks Questions
-- Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.
go
create function dbo.Totalquantity()
RETURNS @totalquantity table(genre varchar(30),Quantity int)
AS
BEGIN
    insert into @totalquantity
     SELECT 
           a.genre, sum(quantity) as TotalQuantity
     FROM
         sales as s 
    join 
        artworks as a on s.artwork_id=a.artwork_id
    group BY
          a.genre
    RETURN
          
END
go



-- Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
 GO
  create function dbo.avgfunction(@genre varchar(30))
  RETURNS decimal(10,2)
  BEGIN
       DECLARE @avgsales decimal(10,2)
       SELECT
             @avgsales=avg(total_amount) over(partition by genre)
       from 
            sales as s 
        JOIN
            artworks as a on s.artwork_id=s.artwork_id
        return @avgsales
  END
GO

-- Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
   with cte as (select  
         artist_id,total_amount,NTILE(4) over(order by total_amount) as newrank
   from 
       sales as s
    join 
        artworks as a on s.artwork_id=a.artwork_id)

    select 
         *,case newrank
         WHEN 1 then 'top'
         when  2 then 'second'
         when 3 then 'third'
         when 4 then 'forth'
         end 
    from cte 
    
    

-- Create a trigger to log changes to the artworks table into an artworks_log table, capturing the artwork_id, title, and a change description.
   

-- Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
  GO
  create procedure addsalesupdatetotalsales

  AS
  BEGIN
       begin TRY
       begin TRANSACTION;
         


       commit transaction
       end TRY
       begin CATCH


       
       end CATCH
   end