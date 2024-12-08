create database zomato;
use zomato;

-- Creating Tables

CREATE TABLE main (
    `RestaurantID`	INT,
    `RestaurantName`	VARCHAR(512),
    `CountryCode`	VARCHAR(512),
    `City`	VARCHAR(512),
    `Locality`	VARCHAR(512),
    `Longitude`	DOUBLE,
    `Latitude`	DOUBLE,
    `Cuisines`	VARCHAR(512),
    `Currency`	VARCHAR(512),
    `Has_Table_booking`	VARCHAR(512),
    `Has_Online_delivery`	VARCHAR(512),
    `Is_delivering_now`	VARCHAR(512),
    `Switch_to_order_menu`	VARCHAR(512),
    `Price_range`	INT,
    `Votes`	INT,
    `Average_Cost_for_two`	INT,
    `Rating`	VARCHAR(512),
    `Year Opening`	INT,
    `Month Opening`	INT,
    `Day Opening`	INT,
    `Buckets`	VARCHAR(512)
);

select * from main;

Create Table country
(
CountryID varchar(512) primary key,
Countryname Varchar(100)
);

select count(*) from country;

Create Table currency
(Currency VARCHAR(512) primary key,	
`USD Rate` float
);
Select * from currency;

-- DATA Modelling

ALTER TABLE maindata
add constraint  FK_country
foreign key ( `CountryCode`)
references country(countryid);

ALTER TABLE main
add constraint  FK_currency
foreign key (currency)
references currency(currency);

-- Opening_Date column

ALTER TABLE Main
ADD COLUMN Opening_Date DATE;

-- Adding records onto opening key from existing column
UPDATE Main
SET Opening_Date = STR_TO_DATE(CONCAT(`Year Opening`, '-', `Month Opening`, '-', `Day Opening`), '%Y-%m-%d');

-- Add columns for the necessary fields derived from dates

ALTER TABLE Main
ADD COLUMN Year INT,
ADD COLUMN MonthNo INT,
ADD COLUMN MonthFullName VARCHAR(20),
ADD COLUMN Quarter VARCHAR(5),
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN WeekdayNo INT,
ADD COLUMN WeekdayName VARCHAR(20),
ADD COLUMN FinancialMonth VARCHAR(5),
ADD COLUMN FinancialQuarter VARCHAR(5);

select * from main;

-- Insert the relevant date-derived data into the new columns
UPDATE Main
SET Year = YEAR(Opening_Date),
    MonthNo = MONTH(Opening_Date),
    MonthFullName = MONTHNAME(Opening_Date),
    Quarter = CONCAT('Q', QUARTER(Opening_Date)),
    YearMonth = DATE_FORMAT(Opening_Date, '%Y-%b'),
    WeekdayNo = DAYOFWEEK(Opening_Date),
    WeekdayName = DAYNAME(Opening_Date),
    FinancialMonth = CASE
        WHEN MONTH(Opening_Date) >= 4 THEN CONCAT('FM', MONTH(Opening_Date) - 3)
        ELSE CONCAT('FM', MONTH(Opening_Date) + 9)
    END,
    FinancialQuarter = CASE
        WHEN MONTH(Opening_Date) IN (4, 5, 6) THEN 'FQ-1'
        WHEN MONTH(Opening_Date) IN (7, 8, 9) THEN 'FQ-2'
        WHEN MONTH(Opening_Date) IN (10, 11, 12) THEN 'FQ-3'
        ELSE 'FQ-4'
    END;
select * from main;

-- Convert the 'Average cost for 2' column from local currencies into USD

ALTER TABLE main ADD COLUMN average_cost_for_Two_Dollars FLOAT;

ALTER TABLE Main ADD COLUMN average_cost VARCHAR(255) 
AS (CONCAT('$', FORMAT(((Average_Cost_for_two + Price_range) / 2) * 0.012, 2))) STORED;
select * from main;

-- DATA ANALYSIS (QUERIES)

-- 1 .Find the Numbers of Resturants based on City and Country.

select * from country;

SELECT 
	Countryname, 
	city,
    COUNT(*) AS Number_of_Restaurants
FROM Main
JOIN Country ON 
Main.CountryCode = Country.CountryID
GROUP BY 
 Countryname,city
ORDER BY 
    Countryname, City;
    
-- 2 .Numbers of Resturants opening based on Year , Quarter , Month.

select * from maindata;

SELECT Year, COUNT(*) AS Number_of_Restaurants
FROM Main
GROUP BY Year
ORDER BY Year;

SELECT quarter, count(*) as Number_of_restaurants
From Main GROUP BY Quarter
ORDER BY QUARTER;

SELECT Monthno, count(*) as Number_of_restaurants
FROM Main GROUP BY monthno
ORDER BY Monthno;

-- 3. Count of Restaurants based on Average Ratings 

select * from main;
Select Rating ,
	Count(*) as Number_of_restaurants 
    from main 
    group by 1
    order by 1;
    
-- 4.Percentage of Restaurants based on "Has_Table_booking"

SELECT Has_Table_booking,COUNT(*) AS Number_of_Restaurants,
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Main)) AS Percentage
FROM Main
GROUP BY Has_Table_booking;

-- 5. Percentage of Restaurants based on "Has_Online_delivery"

select Has_online_delivery, count(*) as Number_of_restaurants,
(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Main)) AS Percentage
FROM Main
GROUP BY Has_Online_delivery;

-- 6. Average Rating and  number of votes received by restaurants in each country.

SELECT 
    c.countryname,
    round(AVG(m.rating),2) AS avg_rating,
    SUM(m.votes) AS total_votes
FROM 
    main m
JOIN 
    country c ON m.countrycode = c.countryid
GROUP BY 
    c.countryid
ORDER BY 
    avg_rating DESC;

-- 7.Number of Restaurants Offering Both Table Booking and Online Delivery

SELECT 
    COUNT(*) AS both_services_count
FROM 
    main
WHERE 
    has_table_booking = "yes"
    AND has_online_delivery = "yes";

--  8.The Most Popular Cuisine in a Specific Country 

SELECT 
    cuisines,
    COUNT(*) AS cuisine_count FROM main
JOIN 
    country ON main.countrycode = country.countryid
WHERE 
    countryname = 'India'
GROUP BY 
    cuisines
ORDER BY 
    cuisine_count DESC
LIMIT 1;

-- 9. Average Cost for Two in Each Country
select * from main;
SELECT 
   countryname,
    round(AVG(Average_Cost_for_two),2) AS avg_cost_for_two,
    currency
FROM 
    main  
JOIN 
    country ON main.countrycode = country.countryid
GROUP BY 
    countryname, currency
ORDER BY 
    avg_cost_for_two DESC;
    
    
-- 10. Top 5 Cities by Number of Restaurants

SELECT city, COUNT(*) AS total_restaurants
FROM main 
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 5;











