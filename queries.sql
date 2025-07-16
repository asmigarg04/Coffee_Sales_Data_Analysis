-- Monday Coffee Data Analysis
SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Data Analysis

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_name,
round((population * 0.25)/1000000,2),
 city_rank
from city
order by population desc;

-- Q.2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select sum(total) as total_sales
from sales
where year(sale_date)=2023
and quarter(sale_date)=4;

-- What is the total revenue generated from coffee sales across each city in the last quarter of 2023?
select ci.city_name,sum(s.total) as total_revenue
from sales as s
JOIN customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id=c.city_id
where year(s.sale_date)=2023
and quarter(s.sale_date)=4
group by city_name
order by 2 desc;

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
select p.product_name,count(s.product_id) as total_units
from products as p
join sales as s
on p.product_id=s.product_id
group by 1
order by 2 desc;

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city and total sale
-- no cx in each these city
SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
			SUM(s.total)/
				COUNT(DISTINCT s.customer_id)
			,2) as avg_sale_pr_cx
	
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.

select city_name,population,round((population*0.25)/1000000,2) as coffee_consumers
from city;
-- return city_name, total current cx, estimated coffee consumers (25%)
select ci.city_name,round((ci.population)*0.25/1000000,2) as coffee_cx_in_millions,count(distinct c.customer_id) as unique_cx
from sales as s
join customers as c
on s.customer_id=c.customer_id
join city as ci
on ci.city_id=c.city_id
group by ci.city_name,ci.population;

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select ranked.city_name,
       ranked.product_name,
	   ranked.total_sales_volume
from
(
select ci.city_name,
p.product_name,
sum(s.total) as total_sales_volume,
rank() over(partition by ci.city_name order by sum(s.total) desc) as product_rank
from sales s
join customers c
on c.customer_id=s.customer_id
join city ci
on ci.city_id=c.city_id
join products p
on p.product_id=s.product_id
group by 1,2) as ranked
where ranked.product_rank<=3
order by ranked.city_name,ranked.total_sales_volume desc;

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select count(distinct c.customer_id) as unique_customers,ci.city_name
from city as ci
join customers c
on ci.city_id=c.city_id
join sales s
on s.customer_id=c.customer_id
join products p
on p.product_id=s.product_id
where s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
group by city_name
order by 1 desc;

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
with city_table
as
(select ci.city_name,
       sum(s.total) as total_revenue,
       count(distinct s.customer_id) as unique_customer,
       round( sum(s.total)/ count(distinct s.customer_id),2) as avg_sale_pr_cus
from sales s
join customers c
on c.customer_id=s.customer_id
join city ci
on ci.city_id=c.city_id
group by city_name
),
city_rent
as
(
select city_name,estimated_rent
from city
)
select cr.city_name,
cr.estimated_rent,
ct.unique_customer,ct.avg_sale_pr_cus,
round((cr.estimated_rent/ct.unique_customer),2) as avg_rent_per_cus
from city_rent as cr
join city_table as ct
on cr.city_name=ct.city_name
order by 5 desc;

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH monthly_sales AS (
    SELECT 
        ci.city_name,
        MONTH(s.sale_date) AS month,
        YEAR(s.sale_date) AS year,
        SUM(s.total) AS total_sale
    FROM sales s
    JOIN customers c ON c.customer_id = s.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name, MONTH(s.sale_date), YEAR(s.sale_date)
    ORDER BY ci.city_name, year, month
),
growth_ratio AS (
    SELECT
        city_name,
        month,
        year,
        total_sale AS cr_month_sale,
        LAG(total_sale, 1) OVER (PARTITION BY city_name ORDER BY year, month) AS last_month_sale
    FROM monthly_sales
)

SELECT
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    ROUND(((cr_month_sale - last_month_sale) * 100) / NULLIF(last_month_sale, 0), 2) AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL;

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

WITH city_table AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(SUM(s.total) / COUNT(DISTINCT s.customer_id), 2) AS avg_sale_pr_cx
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN city ci ON ci.city_id = c.city_id
    GROUP BY ci.city_name
    ORDER BY total_revenue DESC
),

city_rent AS (
    SELECT 
        city_name, 
        estimated_rent,
        ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumer_in_millions
    FROM city
)

SELECT 
    cr.city_name,
    ct.total_revenue,
    cr.estimated_rent AS total_rent,
    ct.total_cx,
    cr.estimated_coffee_consumer_in_millions,
    ct.avg_sale_pr_cx,
    ROUND(cr.estimated_rent / NULLIF(ct.total_cx, 0), 2) AS avg_rent_per_cx
FROM city_rent cr
JOIN city_table ct ON cr.city_name = ct.city_name
ORDER BY ct.total_revenue DESC;


/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.

