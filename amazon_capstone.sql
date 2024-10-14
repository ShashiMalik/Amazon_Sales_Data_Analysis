use amazon_sales;

show columns from amazon;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'amazon' AND table_schema = 'amazon_sales';

SELECT count(*) as Total_no_of_columns
FROM information_schema.columns
WHERE table_name = 'amazon' AND table_schema = 'amazon_sales';

select count(*) as Total_records from amazon;


SELECT `Invoice ID`,Branch,City FROM amazon WHERE 1 IS NULL OR 2 IS NULL OR 3 IS NULL;
SELECT `Customer type`,gender,`Product line` FROM amazon WHERE 4 IS NULL OR 5 IS NULL OR 6 IS NULL;
SELECT `Unit price`,Quantity,`Tax 5%` FROM amazon WHERE 7 IS NULL OR 8 IS NULL OR 9 IS NULL;
SELECT Total ,Date,Time FROM amazon WHERE 10 IS NULL OR 11 IS NULL OR 12 IS NULL;
SELECT Payment,cogs,`gross margin percentage` FROM amazon WHERE 13 IS NULL OR 14 IS NULL OR 15 IS NULL;
SELECT `gross income`,Rating FROM amazon WHERE 16 IS NULL OR 17 IS NULL;

alter table amazon drop monthname;
alter table amazon drop dayname;
alter table amazon drop timeofday;

alter table amazon drop Product_line_Quality;


ALTER TABLE amazon
Add column monthname varchar(20),
Add column dayname varchar(20),
add column timeofday varchar(20);

SET SQL_SAFE_UPDATES = 0;

update amazon
SET timeofday =   CASE
    WHEN TIME(Time) < '12:00:00' THEN 'Morning'
    WHEN TIME(Time) >= '12:00:00' AND TIME(Time) < '18:00:00' THEN 'Afternoon'
    ELSE 'Evening'
  END ;
  
update amazon   
set monthname = monthname(Date) ;

update amazon
set dayname = dayname(Date);

SELECT * , dayname(Date) AS dayname
FROM amazon;


-- Q1. What is the count of distinct cities in the dataset?
select  City, count(*) as count_of_cities 
	from amazon 	
    group by city;

-- Q2 For each branch, what is the corresponding city?
select  Branch, City 
	from amazon 	
    group by Branch , city;

-- Q3 What is the count of distinct product lines in the dataset?
select `Product Line`, count(*) as No_of_ProductLines from amazon 
group by `product line` order by No_of_ProductLines desc;

-- Q4 Which payment method occurs most frequently?
select Payment, count(*) as counts_of_payment_made 
from amazon  
group by Payment 
order by counts_of_payment_made desc 
limit 1 ;


-- Q5 Which product line has the highest sales?
select `Product line`, sum(Total) as Highest_sales_Product_Line 
from amazon  
group by `Product line` 
order by Highest_sales_Product_Line desc 
limit 1 ;

-- Q6 How much revenue is generated each month?
select monthname, sum(Total) as Total_revenue_of_each_month 
from amazon 
group by monthname;

-- Q7 In which month did the cost of goods sold reach its peak?
select monthname, sum(cogs) as cogs_of_each_month 
from amazon 
group by monthname 
order by cogs_of_each_month desc
limit 1;

-- Q8 Which product line generated the highest revenue?
select `Product line`, sum(Total) as Highest_Revenue_Product_Line 
from amazon  
group by `Product line`
order by Highest_Revenue_Product_Line desc 
limit 1 ;

-- Q9 In which city was the highest revenue recorded?
select City, sum(Total) as City_has_Highest_Revenue 
from amazon  
group by City
order by City_has_Highest_Revenue desc 
limit 1 ;

-- Q10 Which product line incurred the highest Value Added Tax?
select `Product line`, sum(`Tax 5%`) as Highest_VAT_Product_Line 
from amazon  
group by `Product line`
order by Highest_VAT_Product_Line desc
limit 1;

-- Q11 For each product line, add a column indicating "Good" if its sales are above average, 
-- otherwise "Bad."
Alter Table amazon 
add column Product_line_Quality varchar(20);

update amazon as main
join
(
    SELECT a1.`product line`, AVG(a1.cogs) AS avg_cogs
    FROM amazon AS a1
    GROUP BY a1.`product line`
) AS a2 ON main.`product line` = a2.`product line`
set main.Product_line_Quality = case
when main.cogs > a2.avg_cogs then 'Good'
else 'Bad'
end;
select city,`product line`, count(Product_line_Quality) from amazon 
where Product_line_Quality = 'Good'
group by city,`product line` order by `Product lIne`,count(Product_line_Quality) desc;

select city,`product line`, count(Product_line_Quality) from amazon 
where Product_line_Quality = 'Bad'
group by city,`product line` order by `Product lIne`,count(Product_line_Quality) desc;

-- Q12 Identify the branch that exceeded the average number of products sold.
SELECT Branch, COUNT(*) AS Products_sold
FROM amazon
GROUP BY Branch
HAVING Products_sold > (
    SELECT AVG(Products_sold)
    FROM (
        SELECT COUNT(*) AS Products_sold
        FROM amazon
        GROUP BY Branch
    ) AS AvgProducts
);



-- Q13 Which product line is most frequently associated with each gender?
WITH Product_Counts_Per_Gender AS (
    SELECT `Product line`, gender, COUNT(*) AS counts_per_gender,
           RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rank_per_gender
    FROM amazon
    GROUP BY `Product line`, gender
)
SELECT `Product line`, gender, counts_per_gender
FROM Product_Counts_Per_Gender
WHERE rank_per_gender = 1;

-- Q14 Calculate the average rating for each product line.
select distinct(`Product line`), 
round(avg(Rating) over(partition by `Product line`),2) as avg_rating_of_each_product_line 
from amazon;

-- Q15 Count the sales occurrences for each time of day on every weekday.
select timeofday, dayname, sum(Total) as Total_sales 
from amazon
group by timeofday, dayname
order by Total_sales desc;

-- Q16 Identify the customer type contributing the highest revenue.
select `customer type` , sum(total) as total_revenue_contribution
	from amazon
    group by `customer type` order by total_revenue_contribution desc
    limit 1;

-- Q 17 Determine the city with the highest VAT percentage.
select city, sum(`tax 5%`) as highest_vat from amazon 
group by city order by highest_vat desc
limit 1 ;

-- Q 18 Identify the customer type with the highest VAT payments.
select `customer type` , sum(`tax 5%`) as highest_vat
	from amazon
    group by `customer type` order by highest_vat desc
    limit 1;

-- Q19 What is the count of distinct customer types in the dataset?
select distinct(`customer type`) from amazon;

-- Q20 What is the count of distinct payment methods in the dataset?
select distinct(payment) from amazon;


-- Q 21 Which customer type occurs most frequently?
select `customer type`, count(*) from amazon 
group by `customer type`
order by count(*) desc
limit 1;

-- Q22 Identify the customer type with the highest purchase frequency.
select `customer type`, count(*) as Purchase_frequency from amazon 
group by `customer type`
order by count(*) desc limit 1;

-- Q23 Determine the predominant gender among customers.
select Gender , count(*) as predominant_gender 
from amazon 
group by Gender
order by predominant_gender desc
limit 1;

-- Q24 Examine the distribution of genders within each branch.
select Gender , branch, count(*) as count_of_gender_wrt_Branch
from amazon 
group by Gender, branch
order by count_of_gender_wrt_Branch desc;

-- Q 25 Identify the time of day when customers provide the most ratings.
select timeofday, count(rating) as counts_of_ratings_by_timeofday from amazon 
group by timeofday
order by counts_of_ratings_by_timeofday desc
limit 1;

-- Q26 Determine the time of day with the highest customer ratings for each branch.
WITH TimeOfDayRatings AS (
    SELECT timeofday, branch, rating,
	RANK() OVER (PARTITION BY branch ORDER BY rating DESC) AS rating_rank
    FROM amazon
)
SELECT timeofday, branch, rating
FROM TimeOfDayRatings
WHERE rating_rank = 1;


-- Q27 Identify the day of the week with the highest average ratings.

SELECT DayName, AVG(Rating) AS Avg_Rating
FROM amazon
GROUP BY DayName 
order by Avg_Rating desc
Limit 1;
    


-- Q28 Determine the day of the week with the highest average ratings for each branch.

WITH DayAvgRatings AS (
    SELECT DayName, Branch, AVG(Rating) AS avg_rating,
           RANK() OVER (PARTITION BY Branch ORDER BY AVG(Rating) DESC) AS rating_rank
    FROM amazon
    GROUP BY DayName, Branch
)
SELECT DayName, Branch, avg_rating AS highest_avg_rating
FROM DayAvgRatings
WHERE rating_rank = 1;

-- -----------------------------------------------------------------------------------
-- PRODUCT ANALYSIS
-- -----------------------------------------------------------------------------------
select  `Product line`, count(*) as order_frequency, 
	sum(Quantity) as sales_volume,
	round(SUM(quantity) / COUNT(`Product line`)) AS Avg_Quantity_per_Purchase,
	round(avg(Rating),2) as Avg_ratings
	from amazon 	
    group by `Product line`
    order by Avg_Quantity_per_Purchase desc;
    

  select  `Product line`,count(`product line`) as Purchase_frequency,
	sum(quantity) as Total_Quantity, 
	round(sum(cogs),2) as Total_COGS, 
	round(sum(Total)) as Total_Revenue,
	round(sum(`Gross Income`),2) as profit,
	round(avg(Rating),2) as Avg_ratings
	from amazon 	
    group by `Product line`
    order by Purchase_frequency,Total_COGS  desc;

select  City, Branch,`Product line`,count(`product line`) as Purchase_frequency,
	round(sum(cogs),2) as Total_COGS, 
	sum(quantity) as Total_Quantity, 
    round(sum(Total)) as Total_Revenue,
	round(sum(`Gross Income`),2) as profit,
	round(avg(Rating),2) as Avg_ratings
	from amazon 	
    group by `Product line`,City, Branch
    order by Branch, Purchase_frequency,Total_Revenue desc;

WITH RankedData AS (
    SELECT 
        City, 
        Branch, 
        `Product line`,
        count(`Product line`) AS Purchase_frequency,
        round(sum(cogs), 2) AS Total_COGS, 
        sum(quantity) AS Total_Quantity, 
        round(sum(Total)) AS Total_Revenue,
        round(sum(`Gross Income`), 2) AS profit,
        round(avg(Rating), 2) AS Avg_ratings,
        RANK() OVER (PARTITION BY Branch ORDER BY count(`Product line`) DESC) AS Rank_Purchase_frequency,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(cogs) DESC) AS Rank_Total_COGS,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(quantity) DESC) AS Rank_Total_Quantity,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(Total) DESC) AS Rank_Total_Revenue,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(`Gross Income`) DESC) AS Rank_profit,
        RANK() OVER (PARTITION BY Branch ORDER BY avg(Rating) DESC) AS Rank_Avg_ratings
    FROM amazon 
    GROUP BY `Product line`, City, Branch
)
    SELECT 
        City, 
        Branch, 
        `Product line`,
        Rank_Purchase_frequency,
        Rank_Total_COGS,
        Rank_Total_Quantity,
        Rank_Total_Revenue,
        Rank_profit,
        Rank_Avg_ratings
    FROM RankedData;
    
-- ---------------------------------------------------------------------------------------
-- Sales Trends
-- ---------------------------------------------------------------------------------------

-- Sales By Month---------------------------------------------
select monthname, count(`product line`), 
		round(sum(total),2) as Sales_By_Month,
		round(sum(`Gross income`),2) as Profit_By_Month
 from amazon 
 group by monthname;
 
 -- Sales By City, Branch and Month---------------------------------------------
 SELECT City, Branch, MonthName, 
           COUNT(`Product line`) AS Count_Product_Line, 
           ROUND(SUM(Total), 2) AS Sales_By_Month,
           ROUND(SUM(`Gross income`), 2) AS Profit_By_Month
    FROM amazon 
    GROUP BY Branch, MonthName, City
    ORDER BY Monthname,Profit_By_Month DESC;
    
 -- Sales By City, Branch,Product Line,Purchase_frequency, Total_COGS , Total_Quantity, Total_Revenue, profit and Avg_ratings-----------------------------------------------
    
select  City, Branch,`Product line`,count(`product line`) as Purchase_frequency,
	round(sum(cogs),2) as Total_COGS, 
	sum(quantity) as Total_Quantity, 
    round(sum(Total)) as Total_Revenue,
	round(sum(`Gross Income`),2) as profit,
	round(avg(Rating),2) as Avg_ratings
	from amazon 	
    group by `Product line`,City, Branch
    order by Branch, Purchase_frequency,Total_Revenue desc;	
    
 -- Ranking of Product Line,Purchase_frequency, Total_COGS , Total_Quantity, Total_Revenue, profit and Avg_ratings-----------------------------------------------
WITH RankedData AS (
    SELECT 
        City, Branch,
        `Product line`,
        count(`Product line`) AS Purchase_frequency,
        round(sum(cogs), 2) AS Total_COGS, 
        sum(quantity) AS Total_Quantity, 
        round(sum(Total)) AS Total_Revenue,
        round(sum(`Gross Income`), 2) AS profit,
        round(avg(Rating), 2) AS Avg_ratings,
        RANK() OVER (PARTITION BY Branch ORDER BY count(`Product line`) DESC) AS Rank_Purchase_frequency,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(cogs) DESC) AS Rank_Total_COGS,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(quantity) DESC) AS Rank_Total_Quantity,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(Total) DESC) AS Rank_Total_Revenue,
        RANK() OVER (PARTITION BY Branch ORDER BY sum(`Gross Income`) DESC) AS Rank_profit,
        RANK() OVER (PARTITION BY Branch ORDER BY avg(Rating) DESC) AS Rank_Avg_ratings
    FROM amazon 
    GROUP BY  Branch, City,`Product line`
)
SELECT 
    City, Branch,
    `Product line`,
    Rank_Purchase_frequency,
    Rank_Total_COGS,
    Rank_Total_Quantity,
    Rank_Total_Revenue,
    Rank_profit,
    Rank_Avg_ratings
FROM RankedData
ORDER BY City,`Product line`,Rank_Total_Quantity;
    
 -- --------------------------------------------------------------------------------
 -- Sales Trend
 -- --------------------------------------------------------------------------------
 -- Sales Trend By Month, Product Line,Purchase_frequency, Total_COGS , Total_Quantity, Total_Revenue, profit and Avg_ratings----
SELECT 
    MonthName,
    `Product line`,
		count(`Product line`) AS Purchase_frequency,
        round(sum(cogs), 2) AS Total_COGS, 
        sum(quantity) AS Total_Quantity, 
        round(sum(Total)) AS Total_Revenue,
        round(sum(`Gross Income`), 2) AS profit,
        round(avg(Rating), 2) AS Avg_ratings
FROM amazon
group by monthname,`Product line`
ORDER BY FIELD(MonthName, 'January', 'February', 'March'), `Product line`,Total_Quantity;

 -- Rank by Purchase_frequency, Total_COGS , Total_Quantity, Total_Revenue, profit and Avg_ratings----
 WITH RankedData AS (
    SELECT 
        MonthName, 
        `Product line`,
        count(`Product line`) AS Purchase_frequency,
        round(sum(cogs), 2) AS Total_COGS, 
        sum(quantity) AS Total_Quantity, 
        round(sum(Total)) AS Total_Revenue,
        round(sum(`Gross Income`), 2) AS profit,
        round(avg(Rating), 2) AS Avg_ratings,
        RANK() OVER (PARTITION BY monthname ORDER BY count(`Product line`) DESC) AS Rank_Purchase_frequency,
        RANK() OVER (PARTITION BY monthname ORDER BY sum(cogs) DESC) AS Rank_Total_COGS,
        RANK() OVER (PARTITION BY monthname ORDER BY sum(quantity) DESC) AS Rank_Total_Quantity,
        RANK() OVER (PARTITION BY monthname ORDER BY sum(Total) DESC) AS Rank_Total_Revenue,
        RANK() OVER (PARTITION BY monthname ORDER BY sum(`Gross Income`) DESC) AS Rank_profit,
        RANK() OVER (PARTITION BY monthname ORDER BY avg(Rating) DESC) AS Rank_Avg_ratings
    FROM amazon 
    GROUP BY `Product line`, MonthName
)
SELECT 
    MonthName,
    `Product line`,
    Rank_Purchase_frequency,
    Rank_Total_COGS,
    Rank_Total_Quantity,
    Rank_Total_Revenue,
    Rank_profit,
    Rank_Avg_ratings
FROM RankedData
ORDER BY FIELD(MonthName, 'January', 'February', 'March'), `Product line`,Rank_Total_Quantity;

------------------------
-- Sales By week days
------------------------

select DayName, count(`product line`), 
	round(sum(total),2) as Sales_By_WeekDay,
	round(sum(`Gross income`),2) as Profit_By_Weekday
 from amazon 
 group by DayName;
 
-- -- Sales By Branch, max and min sales by weekdays
 
 SELECT Branch, `product Line`, Max_Sales_By_Product_Line, DayName
FROM (
    SELECT Branch, `product Line`, DayName, ROUND(SUM(Total), 2) AS sales_By_WeekDays,
           max(ROUND(SUM(Total), 2)) OVER (PARTITION BY `product Line`) AS Max_Sales_By_Product_Line
    FROM amazon
    WHERE Branch = 'A'
    GROUP BY `product Line`, Branch, DayName
) AS subquery
WHERE sales_By_WeekDays = Max_Sales_By_Product_Line
order by Max_Sales_By_Product_Line desc;

SELECT Branch, `product Line`, Min_Sales_By_Product_Line, DayName
FROM (
    SELECT Branch, `product Line`, DayName, ROUND(SUM(Total), 2) AS sales_By_WeekDays,
           Min(ROUND(SUM(Total), 2)) OVER (PARTITION BY `product Line`) AS Min_Sales_By_Product_Line
    FROM amazon
    WHERE Branch = 'C'
    GROUP BY `product Line`, Branch, DayName
) AS subquery
WHERE sales_By_WeekDays = Min_Sales_By_Product_Line
order by Min_Sales_By_Product_Line desc;

-- Sales Trend By TimeOf Day
select timeofday, count(`product line`), 
	round(sum(total),2) as Sales_By_WeekDay,
	round(sum(`Gross income`),2) as Profit_By_Weekday
 from amazon 
 group by timeofday;
 
 
 select `Product line`,timeofday, count(`product line`), 
	round(sum(total),2) as Sales_By_WeekDay,
	round(sum(`Gross income`),2) as Profit_By_Weekday
 from amazon 
 group by `Product line`,timeofday
 Order by `Product line`,timeofday, Sales_By_Weekday ;

-- ------------------------------------------------------------------------
-- Customer Analysis
-- ------------------------------------------------------------------------
Select distinct(`customer type`), count(*) , sum(total)
from amazon 
group by `customer type`;

 Select Distinct(Gender), count(*), Sum(Total) 
 from amazon 
 group by gender;

  Select Gender,`customer type`, count(*), Sum(Total) 
  from amazon 
  group by gender,`customer type`
  order by count(*) desc;

  Select City,Branch, Gender,`customer type`,count(*) as Purchase_Frequency, 
  Round(Sum(Total)) as Total_sales,
  rank() over(partition by gender order by Round(Sum(Total)) desc) as Top_purchaser
  from amazon group by City, Branch,gender,`customer type`
  ORDER BY  Gender, Total_sales desc;
  
Select Gender,`Product line`, Sum(Total) as Total_Revenue
  from amazon 
  group by gender,`Product line`
  order by Total_Revenue desc;
 
Select City, Branch,Gender,`Customer type`, Round(Sum(Total)) as Total_Sales
  from amazon 
  group by City,Branch,gender,`Customer type`
  order by gender,`Customer type`,Total_Sales desc;
  
SELECT City, Branch, gender,`Customer type`, COUNT(*) AS counts_per_gender,
           RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rank_per_gender
    FROM amazon
    GROUP BY City, Branch, gender,`Customer type`

  
