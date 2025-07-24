# Coffee Sales Analysis
The goal of this project is to analyze the online sales data of Monday Coffee, a coffee company selling products since January 2023, and to identify the top 3 cities in India where the company can open new coffee shops.

The recommendation is based on:

- Customer demand
- Sales performance
- Rent feasibility in different cities

I used variety of SQL queries to explore and analyse the dataset:

- Aggregate functions (SUM, AVG, COUNT) to calculate revenue, customer counts, sales.
- GROUP BY to analyze city-wise and product-wise trends
- JOINs across multiple tables to combine product, customer, sales, and city data
- Wndow functions for ranking top selling products and growth calculations

# Key Insights

- Coffee Consumer Estimation: 25% of city population assumed to consume coffee
- Quarterly Revenue: Total coffee revenue in Q4 2023
- Product Performance: Units sold per product
- City-wise Insights:
  - Average sales per customer
  - Population & estimated coffee consumers
  - Top 3 selling products 
  - Unique coffee buyers
  - Rent vs. sales per customer
- Monthly Sales Growth: Trend of increase/decrease in sales
- Market Potential: Ranking cities based on total sales, rent, and customer base

# Recommendations
After analyzing the data, the suggested cities for expansion are:
1. Pune
   
- Highest total revenue
- High average sales per customer
- Very low rent per customer

2. Delhi
   
- Highest estimated coffee drinkers (7.7M)
- Large customer base (68 customers)
- Affordable average rent per customer (₹330)

3. Jaipur
   
- Highest customer count (69)
- Lowest rent per customer (₹156)
- Healthy average sales per customer (~₹11.6k)
