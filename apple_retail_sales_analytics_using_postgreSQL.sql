-- Apple retails Millions Rows Sales Schemas

-- DROP Table Command
DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category;  -- parent
DROP TABLE IF EXISTS stores;  -- parent

--  CREATE TABLE COMMANDS

CREATE TABLE stores(
store_id VARCHAR(5) PRIMARY KEY,
store_name VARCHAR(30),
city VARCHAR(25),
country VARCHAR(25)
);

DROP TABLE IF EXISTS category;
CREATE TABLE category(
category_id VARCHAR(10) PRIMARY KEY,
category_name VARCHAR(20)
);

CREATE TABLE products(
product_id VARCHAR(10) PRIMARY KEY,
product_name VARCHAR(35),
category_id VARCHAR(10),
launch_date date,
price FLOAT,
CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE sales(
sale_id VARCHAR(15) PRIMARY KEY,
sale_date DATE,
store_id VARCHAR(10),  -- this fk
product_id VARCHAR(10),  -- this fk
quantity INT,
CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
DROP TABLE IF EXISTS warranty;
CREATE TABLE warranty(
claim_id VARCHAR(10) PRIMARY KEY,
claim_date date,
sale_id VARCHAR(15),
repair_status VARCHAR(15),
CONSTRAINT fk_sales FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

-- Success Message

SELECT 'Schema created successful' as Success_Message;


-- Check all Tables

SELECT * FROM CATEGORY;
SELECT * FROM PRODUCTS;
SELECT *FROM STORES;
SELECT * FROM SALES;
SELECT * FROM warranty;

-- EDA

SELECT DISTINCT repair_status FROM warranty;
SELECT COUNT(*) FROM sales;


-- Improving querry performance 
-- PT = 0.48 ms
-- ET = 81 ms

-- after indexing PT = 30 ms
-- After indexing ET = 9.53 ms

EXPLAIN ANALYZE
SELECT * FROM sales
WHERE product_id = 'P-44'

CREATE INDEX sales_product_id ON sales(product_id);



-- PT = 0.097 ms
-- ET = 151 ms

-- after indexing PT = 0.077 ms
-- After indexing ET = 54 ms

EXPLAIN ANALYZE
SELECT * FROM sales
WHERE store_id = 'ST-31'

CREATE INDEX sales_product_id ON sales(store_id);

CREATE INDEX sales_sale_date ON sales(sale_date);

/*
The project is split into three tiers of questions to test SQL skills of increasing complexity:

Easy to Medium (10 Questions)

1. Find the number of stores in each country.
2. Calculate the total number of units sold by each store.
3. Identify how many sales occurred in December 2023.
4. Determine how many stores have never had a warranty claim filed.
5. Calculate the percentage of warranty claims marked as "Warranty Void".
6. Identify which store had the highest total units sold in the last year.
7. Count the number of unique products sold in the last year.
8. Find the average price of products in each category.
9. How many warranty claims were filed in 2020?
10. For each store, identify the best-selling day based on highest quantity sold.

Medium to Hard (5 Questions)

11. Identify the least selling product in each country for each year based on total units sold.
12. Calculate how many warranty claims were filed within 180 days of a product sale.
13. Determine how many warranty claims were filed for products launched in the last two years.
14. List the months in the last three years where sales exceeded 5,000 units in the USA.
15. Identify the product category with the most warranty claims filed in the last two years.

Complex (5 Questions)

16. Determine the percentage chance of receiving warranty claims after each purchase for each country.
17. Analyze the year-by-year growth ratio for each store.
18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.  
20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.

Bonus Question

21. Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
*/

-- 1. Find the number of stores in each country.

SELECT 
	country,
	count(store_id) as count_stores
FROM stores
GROUP BY country
ORDER BY 2 DESC;

-- 2. Calculate the total number of units sold by each store.

-- v1
SELECT 
	store_id,
	sum(quantity) as total_unit_sold
FROM sales
GROUP BY store_id;

-- v2
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

-- 3. Identify how many sales occurred in December 2023.

SELECT
	*
	--TO_CHAR(sale_date, 'MM-YYYY')
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';
-- 
SELECT
	count(sale_id) as total_sales
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';


-- 4. Determine how many stores have never had a warranty claim filed.

SELECT count(*) FROM stores
WHERE store_id NOT IN (
						SELECT 
							DISTINCT store_id
						FROM sales as s
						RIGHT JOIN warranty as w
						ON s.sale_id = w.sale_id
						);

SELECT COUNT(*) 
FROM stores
WHERE store_id NOT IN (
    
    SELECT DISTINCT store_id
    FROM sales AS s
    RIGHT JOIN warranty AS w
    ON s.sale_id = w.sale_id

);

-- 5. Calculate the percentage of warranty claims marked as "In Progress".

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

-- 6. Identify which store had the highest total units sold in the last year.

SELECT
	store_id,
	sum(quantity)
FROM sales
WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

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


-- 7. Count the number of unique products sold in the last year.

select * from products
select * from sales

SELECT 
	DISTINCT s.product_id,
	p.product_name
FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')
GROUP BY 1,2;

SELECT
	COUNT(DISTINCT product_id)
FROM sales
WHERE sale_date >= (CURRENT_DATE - INTERVAL '3 year')

-- 8. Find the average price of products in each category.

SELECT
	p.category_id,
	c.category_name,
	avg(price) as avg_price
FROM products as p
JOIN category as c
ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 3 DESC

-- 9. How many warranty claims were filed in 2020?

SELECT 
	COUNT(*) as warranty_claim
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2024

-- 10. For each store, identify the best-selling day based on highest quantity sold.

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


-- 11. Identify the least selling product in each country for each year based on total units sold.

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


-- 12. Calculate how many warranty claims were filed within 180 days of a product sale.

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

--  13. Determine how many warranty claims were filed for products launched in the last two years.

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

-- 14. List the months in the last three years where sales exceeded 5,000 units in the USA.

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

--   15. Identify the product category with the most warranty claims filed in the last two years.

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


-- 16. Determine the percentage chance of receiving warranty claims after each purchase for each country.


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


-- 17. Analyze the year-by-year growth ratio for each store.

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


--  18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

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


-- 19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.

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


-- 20. Write a query to calculate the monthly running total of sales for each store over the past four years
-- and compare trends during this period.


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


-- Bonus Question

-- 21. Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.

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