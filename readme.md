# 🍎 Apple Retail Sales Analytics using PostgreSQL (1M+ Records)

![Apple Retail store image](https://github.com/TechByJay/apple-retail-sales-analytics-using-postgresql-with-1m-records/blob/master/apple_retail_store_img.png)

![Entity relationship diagrams](https://github.com/TechByJay/apple-retail-sales-analytics-using-postgresql-with-1m-records/blob/master/Entity_relationship_diagrams.png)


## 1. Project Title

# Apple Retail Sales Analytics using PostgreSQL (1M+ Records)

---

## 2. Brief One Line Summary

A large-scale SQL analytics project that analyzes over 1 million Apple retail sales records using PostgreSQL to generate business insights on sales, stores, products, and warranty claims.

---

## 3. Overview

This project focuses on analyzing large-scale Apple retail sales data using PostgreSQL.  
The dataset contains more than 1 million rows and simulates real-world retail operations involving stores, products, sales transactions, and warranty claims.

The project demonstrates advanced SQL concepts such as:

- Joins
- Window Functions
- Common Table Expressions (CTEs)
- Aggregations
- Ranking Functions
- Subqueries
- Time-Based Analysis
- Query Optimization

The goal of the project is to solve real-world business problems and generate meaningful insights from retail sales data.

---

## 4. Problem Statement

Retail companies generate massive amounts of transactional data daily.  
Analyzing this data helps businesses:

- Identify sales trends
- Understand customer purchasing behavior
- Monitor warranty claims
- Improve inventory management
- Evaluate store performance
- Optimize business strategies

This project aims to solve real-world business problems using SQL queries on a large Apple retail sales dataset.

---

## 5. Dataset

The project dataset contains over **1 million rows** of retail sales data.

### Database Tables

| Table Name | Description |
|------------|-------------|
| stores | Store details including location and country |
| category | Product category information |
| products | Product details including launch date and price |
| sales | Sales transaction records |
| warranty | Warranty claim and repair status records |

---

## Database Schema

```sql
stores(
    store_id,
    store_name,
    city,
    country
)

category(
    category_id,
    category_name
)

products(
    product_id,
    product_name,
    category_id,
    launch_date,
    price
)

sales(
    sale_id,
    sale_date,
    store_id,
    product_id,
    quantity
)

warranty(
    claim_id,
    claim_date,
    sale_id,
    repair_status
)
```

---

## 6. Tools and Technologies

### Technologies Used

- PostgreSQL
- SQL
- pgAdmin
- GitHub

### SQL Concepts Covered

- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- GROUP BY
- HAVING
- Subqueries
- CTEs
- Window Functions
- RANK()
- ROW_NUMBER()
- Aggregate Functions
- Date Functions
- Query Optimization

---

## 7. Methods

The project follows a structured SQL analytics workflow:

### Step 1: Database Design
- Created relational database schema
- Defined primary and foreign keys
- Established table relationships

### Step 2: Data Loading
- Imported large-scale retail sales data into PostgreSQL

### Step 3: Data Analysis
Performed:
- Sales trend analysis
- Store performance analysis
- Product category analysis
- Warranty claim analysis
- Country-wise sales analysis

### Step 4: Business Insights
Generated business insights using advanced SQL queries and aggregations.

---

## 8. Key Insights

### 📌 Sales Insights
- Identified best-selling stores
- Determined highest sales months
- Found top-performing products

### 📌 Warranty Insights
- Analyzed warranty claim rates
- Calculated product risk percentages
- Identified categories with maximum warranty claims

### 📌 Store Insights
- Compared country-wise store performance
- Measured yearly growth ratios
- Evaluated sales trends across stores

---


### 9. Sample Business Problems Solved

---

### Problem 1: Find the number of stores in each country.

```sql
SELECT 
	country,
	count(store_id) as count_stores
FROM stores
GROUP BY country
ORDER BY 2 DESC;
```

---

### Problem 2: Calculate the total number of units sold by each store.

```sql
SELECT 
	s.store_id,
	st.store_name,
	sum(s.quantity) as total_unit_sold
FROM sales as s
JOIN
stores as st
ON st.store_id = s.store_id
GROUP BY 1, 2
ORDER BY 3 DESC
```

---

### Problem 3: Identify how many sales occurred in December 2023.

```sql
SELECT
	*
	FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';
 
SELECT
	count(sale_id) as total_sales
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';

```

---

### Problem 4: Determine how many stores have never had a warranty claim filed.

```sql
SELECT count(*) FROM stores
WHERE store_id NOT IN (
						SELECT 
							DISTINCT store_id
						FROM sales as s
						RIGHT JOIN warranty as w
						ON s.sale_id = w.sale_id
						);
```

---

### Problem 5: Calculate the percentage of warranty claims marked as "In Progress".

```sql
SELECT * from warranty;

SELECT DISTINCT repair_status from warranty;

SELECT 
	ROUND
		(COUNT(claim_id)/
						(SELECT COUNT(*) FROM warranty)::numeric
		* 100
	,2) as warranty_in_progress
FROM warranty
WHERE repair_status = 'In Progress';
```
---

### Problem 6:Identify which store had the highest total units sold in the last year.

```sql
SELECT
	s.store_id,
	st.store_name,
	sum(s.quantity)
FROM sales as s
JOIN stores as st
ON s.store_id = st.store_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 1
```

---

### Problem 7:Count the number of unique products sold in the last year.

```sql 
SELECT 
	DISTINCT s.product_id,
	p.product_name
FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')
GROUP BY 1,2;
```


---

### Problem 8:Find the average price of products in each category.

```sql 
SELECT
	p.category_id,
	c.category_name,
	avg(price) as avg_price
FROM products as p
JOIN category as c
ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 3 DESC 
```

---

### Problem 9: How many warranty claims were filed in 2024?

```sql 
SELECT 
	COUNT(*) as warranty_claim
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2024
```

---

### Problem 10: For each store, identify the best-selling day based on highest quantity sold.

```sql 
SELECT *
FROM(
		SELECT
			store_id,
			TO_CHAR(sale_date, 'Day') as day_name,
			SUM(quantity) as total_unit_sold,
			RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) as rank
		FROM sales
		GROUP BY 1, 2
) as t1
WHERE rank = 1
```

---

### Problem 11: Identify the least selling product in each country for each year based on total units sold.

```sql 
WITH product_rank
AS
(
SELECT
	st.country,
	p.product_name,
	sum(s.quantity) as total_gty_sold,
	RANK() OVER(PARTITION BY st.country ORDER BY SUM(s.quantity)) as rank
FROM sales as s
JOIN
stores as st
ON s.store_id = st.store_id
JOIN
products as p
ON s.product_id = p.product_id
GROUP BY 1, 2
)

SELECT
*
FROM product_rank
WHERE rank = 1
```

---

### Problem 12: Calculate how many warranty claims were filed within 180 days of a product sale.

```sql 
SELECT
	w.*,
	s.sale_date,
	w.claim_date - s.sale_date
FROM warranty as w
LEFT JOIN
sales as s
ON s.sale_id = w.sale_id
WHERE
	w.claim_date - s.sale_date <= 180


SELECT
	count(*)
FROM warranty as w
LEFT JOIN
sales as s
ON s.sale_id = w.sale_id
WHERE
	w.claim_date - s.sale_date <= 180
```

---

### Problem 13: Determine how many warranty claims were filed for products launched in the last two years.

```sql 
SELECT 
	p.product_name,
	COUNT(w.claim_id) as no_claim,
	COUNT(s.sale_id)
FROM warranty as w
RIGHT JOIN
sales as s
ON s.sale_id = w.sale_id
JOIN products as p
ON p.product_id = s.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL '3 years'
GROUP BY 1
HAVING COUNT(w.claim_id) > 0
```

---

### Problem 14: List the months in the last three years where sales exceeded 5,000 units in the USA.

```sql 
SELECT
	TO_CHAR(sale_date, 'MM-YYYY') as month,
	SUM(s.quantity) as total_unit_sold
FROM sales as s
JOIN 
stores as st
ON s.store_id = st.store_id
WHERE
	st.country = 'USA'
	AND
	s.sale_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1
HAVING SUM(s.quantity)> 5000
```

---

### Problem 15: Identify the product category with the most warranty claims filed in the last two years.

```sql 
SELECT
	c.category_name,
	COUNT(w.claim_id) as total_claims
FROM warranty as w
LEFT JOIN
sales as s
ON w.sale_id = s.sale_id
JOIN products as p
ON p.product_id = s.product_id
JOIN
category as c
ON c.category_id = p.category_id
WHERE
	w.claim_date >= CURRENT_DATE - INTERVAL '2 year'
GROUP BY 1
```

---

### Problem 16: Determine the percentage chance of receiving warranty claims after each purchase for each country.

```sql 
SELECT 
	country,
	total_unit_sold,
	total_claim,
	COALESCE(total_claim::numeric/total_unit_sold:: numeric * 100, 0)
	as risk
FROM 
(SELECT 
	st.country,
	SUM(s.quantity) as total_unit_sold,
	COUNT(w.claim_id) as total_claim
FROM sales as s
JOIN stores as st
ON s.store_id = st.store_id
LEFT JOIN
warranty as w
ON w.sale_id = s.sale_id
GROUP BY 1) t1
ORDER BY 4 DESC
```

---

### Problem 17: Analyze the year-by-year growth ratio for each store.

```sql 
WITH yearly_sales
AS
(
	SELECT
		s.store_id,
		st.store_name,
		EXTRACT(YEAR FROM sale_date) as year,
		SUM(s.quantity * p.price) as total_sale
	FROM sales as s
	JOIN
	products as p
	ON s.product_id = p.product_id
	JOIN stores as st
	ON st.store_id = s.store_id
	GROUP BY 1, 2, 3
	ORDER BY 2, 3
),
growth_ratio
AS
(
SELECT
	store_name,
	year,
	LAG(total_sale, 1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
	total_sale as current_year_sale
FROM yearly_sales
)

SELECT
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND(
			(current_year_sale - last_year_sale):: numeric/
							last_year_sale::numeric * 100
	,3) as growth_ratio
FROM growth_ratio
WHERE
	last_year_sale IS NOT NULL
	AND
	YEAR <> EXTRACT(YEAR FROM CURRENT_DATE)
```

---

### Problem 18: Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

```sql 
SELECT
	CASE
		WHEN p.price < 500 THEN 'Less Expenses Product'
		When p.price BETWEEN 500 AND 1000 THEN 'Mid range Product'
		ELSE 'Expensive Product'
	END as price_segment,
	COUNT(w.claim_id) as total_Claim
FROM warranty as w
LEFT JOIN
sales as s
ON w.sale_id = s.sale_id
JOIN
products as p
ON p.product_id = s.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1
```

---

### Problem 19: Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.

```sql 
SELECT DISTINCT repair_status from warranty


WITH paid_repair
AS
(SELECT
	s.store_id,
	COUNT(w.claim_id) as paid_Repaired
FROM sales as s
RIGHT JOIN warranty as w
ON w.sale_id = s.sale_id
WHERE w.repair_status = 'Paid Repaired'
GROUP BY 1
),

total_repaired
AS
(SELECT
	s.store_id,
	COUNT(w.claim_id) as total_repaired
FROM sales as s
RIGHT JOIN warranty as w
ON w.sale_id = s.sale_id
GROUP BY 1)

SELECT
	tr.store_id,
	st.store_name,
	pr.paid_repaired,
	ROUND(pr.paid_repaired::numeric/
			tr.total_repaired::numeric * 100
		,2) as percentage_paid_repaired
FROM paid_repair as pr
JOIN
total_repaired tr
ON pr.store_id = tr.store_id
JOIN stores as st
ON tr.store_id = st.store_id
```

---

### Problem 20: Write a query to calculate the monthly running total of sales for each store over the past four yearsand compare trends during this period.

```sql 
WITH monthly_sales
AS
(SELECT
	store_id,
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	SUM(p.price * s.quantity) as total_revenue
FROM sales as s
JOIN
products as p
ON s.product_id = p.product_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
)

SELECT 
	store_id,
	month,
	year,
	total_revenue,
	SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) as running_total
FROM monthly_sales
```

---

### Bouns Question 21: Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.

```sql 
SELECT
	p.product_name,
	CASE
		WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month' THEN '0-6 month'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN '6-12'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month' THEN '12-18'
		ELSE '18 +'
	END as plc,
	SUM(s.quantity) as total_qty_sale

FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC
```

---

## 10. How to Run this Project?

### Step 1: Clone Repository

```bash
https://github.com/TechByJay/apple-retail-sales-analytics-using-postgresql-with-1m-records/tree/master
```

### Step 2: Open PostgreSQL / pgAdmin

Create a new database.

---

### Step 3: Run SQL Schema File

Execute:


apple_retail_sales_analytics_using_postgreSQL.sql


---

### Step 4: Import Dataset

Load CSV or dataset files into PostgreSQL tables.

---

### Step 5: Run SQL Queries

Execute analytical SQL queries to generate insights.

---

## 11. Results and Conclusion

This project demonstrates how SQL can be used to analyze large-scale retail data efficiently.

### Key Outcomes

- Built a normalized relational database
- Processed over 1 million sales records
- Solved real-world business analytics problems
- Applied advanced PostgreSQL querying techniques
- Generated meaningful sales and warranty insights

The project strengthens practical SQL skills and showcases real-world data analytics capabilities.

---

## 12. Future Work

Future improvements for this project include:

- Building interactive Power BI dashboards
- Creating Tableau visualizations
- Adding Python data analysis
- Implementing ETL pipelines
- Performing predictive analytics
- Deploying cloud-based database systems

---

## 13. Author and Contact

# 👨‍💻 Author

## Jay Vasant Rande

### 📧 Email
- jayrandecs@gmail.com

### 💼 LinkedIn
- [Linkedin](https://www.linkedin.com/in/jay-rande/)


---
