-- ============================================================
-- Project 2: Customer Order Data Cleaning & Analysis
-- Tools: SQL (SQLite)
-- 
-- Description:
-- A messy "Orders_Raw" dataset (inconsistent casing, whitespace,
-- duplicate rows, invalid 'N/A' values, missing dates) is cleaned
-- using a reusable CTE pipeline, then used to answer 5 business
-- questions. Each query below is fully standalone and runnable.
--
-- Cleaning pipeline used in every query:
--   Orders_Clean   -> standardizes casing (UPPER), trims whitespace,
--                      converts 'N/A' amounts to NULL and casts to numeric
--   Orders_Deduped -> flags duplicate rows (created by inconsistent
--                      casing/spacing) using ROW_NUMBER()
--   Deduped_Final  -> keeps only the first occurrence of each unique order
-- ============================================================


-- ============================================================
-- SETUP: Sample raw data (run once before any query below)
-- ============================================================
CREATE TABLE Orders_Raw (
  order_id INT,
  customer_name TEXT,
  region TEXT,
  product TEXT,
  amount TEXT,
  order_date TEXT
);

INSERT INTO Orders_Raw VALUES
(1,  'alice',   'north',  'Laptop',  '1200',   '2026-01-05'),
(2,  'Alice',   'North',  'Laptop',  '1200',   '2026-01-05'),
(3,  '  Bob',   'SOUTH',  'phone',   '800',    '2026-01-08'),
(4,  'Carol',   'East',   'Tablet',  '450',    '2026-01-12'),
(5,  'carol ',  'east',   'tablet',  '450',    '2026-01-12'),
(6,  'David',   'West',   'Desk',    'N/A',    '2026-01-15'),
(7,  'Eva',     'North',  'Chair',   '200',    '2026-01-18'),
(8,  'Bob',     'South',  'Laptop',  '1200',   '2026-01-20'),
(9,  'Alice',   'North',  'Phone',   '800',    '2026-01-22'),
(10, 'Frank',   'West',   'Monitor', '300',    NULL),
(11, 'Carol',   'East',   'Laptop',  '1200',   '2026-02-01'),
(12, 'Eva',     'North',  'Tablet',  '450',    '2026-02-05'),
(13, 'David',   'West',   'Phone',   '800',    '2026-02-08'),
(14, 'Bob',     'South',  'Desk',    '350',    '2026-02-10'),
(15, 'Alice',   'North',  'Chair',   '200',    '2026-02-12');


-- ============================================================
-- Q1: What is the total revenue per region?
-- ============================================================
WITH Orders_Clean AS (
  SELECT 
    order_id,
    UPPER(TRIM(customer_name)) AS customer_name,  
    UPPER(TRIM(region)) AS region,
    UPPER(TRIM(product)) AS product,
    CASE 
      WHEN amount = 'N/A' THEN NULL
      ELSE CAST(amount AS DECIMAL)
    END AS amount,
    order_date
  FROM Orders_Raw
),
Orders_Deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY customer_name, region, product, amount, order_date
           ORDER BY order_id
         ) AS row_num
  FROM Orders_Clean
),
Deduped_Final AS (
  SELECT order_id, customer_name, region, product, amount, order_date
  FROM Orders_Deduped
  WHERE row_num = 1
)
SELECT region,
       SUM(amount) AS total_revenue
FROM Deduped_Final
GROUP BY region;

-- Expected:
-- EAST   | 1650
-- NORTH  | 2850
-- SOUTH  | 2350
-- WEST   | 1100   (David's NULL amount is ignored by SUM)


-- ============================================================
-- Q2: Which customer placed the most orders, and what's
-- their total spend? (full ranking shown)
-- ============================================================
WITH Orders_Clean AS (
  SELECT 
    order_id,
    UPPER(TRIM(customer_name)) AS customer_name,  
    UPPER(TRIM(region)) AS region,
    UPPER(TRIM(product)) AS product,
    CASE 
      WHEN amount = 'N/A' THEN NULL
      ELSE CAST(amount AS DECIMAL)
    END AS amount,
    order_date
  FROM Orders_Raw
),
Orders_Deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY customer_name, region, product, amount, order_date
           ORDER BY order_id
         ) AS row_num
  FROM Orders_Clean
),
Deduped_Final AS (
  SELECT order_id, customer_name, region, product, amount, order_date
  FROM Orders_Deduped
  WHERE row_num = 1
)
SELECT customer_name,
       COUNT(*) AS total_orders,
       SUM(amount) AS total_spend
FROM Deduped_Final
GROUP BY customer_name
ORDER BY total_orders DESC;

-- Expected (top row = answer to "most orders"):
-- ALICE  | 3 | 2200
-- BOB    | 3 | 2350
-- CAROL  | 2 | 1650
-- DAVID  | 2 | 800   (NULL amount excluded from SUM)
-- EVA    | 2 | 650
-- FRANK  | 1 | 300


-- ============================================================
-- Q3: Which product generates the highest total revenue?
-- ============================================================
WITH Orders_Clean AS (
  SELECT 
    order_id,
    UPPER(TRIM(customer_name)) AS customer_name,  
    UPPER(TRIM(region)) AS region,
    UPPER(TRIM(product)) AS product,
    CASE 
      WHEN amount = 'N/A' THEN NULL
      ELSE CAST(amount AS DECIMAL)
    END AS amount,
    order_date
  FROM Orders_Raw
),
Orders_Deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY customer_name, region, product, amount, order_date
           ORDER BY order_id
         ) AS row_num
  FROM Orders_Clean
),
Deduped_Final AS (
  SELECT order_id, customer_name, region, product, amount, order_date
  FROM Orders_Deduped
  WHERE row_num = 1
)
SELECT product,
       SUM(amount) AS total_revenue
FROM Deduped_Final
GROUP BY product
ORDER BY total_revenue DESC;

-- Expected (top row = highest revenue product):
-- LAPTOP  | 3600
-- PHONE   | 1600
-- TABLET  | 900
-- CHAIR   | 400
-- DESK    | 350   (only Bob's 350; David's N/A desk excluded)
-- MONITOR | 300


-- ============================================================
-- Q4: Data quality check - which orders have missing
-- amount or order_date? (flagged for follow-up with the team)
-- ============================================================
WITH Orders_Clean AS (
  SELECT 
    order_id,
    UPPER(TRIM(customer_name)) AS customer_name,  
    UPPER(TRIM(region)) AS region,
    UPPER(TRIM(product)) AS product,
    CASE 
      WHEN amount = 'N/A' THEN NULL
      ELSE CAST(amount AS DECIMAL)
    END AS amount,
    order_date
  FROM Orders_Raw
),
Orders_Deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY customer_name, region, product, amount, order_date
           ORDER BY order_id
         ) AS row_num
  FROM Orders_Clean
),
Deduped_Final AS (
  SELECT order_id, customer_name, region, product, amount, order_date
  FROM Orders_Deduped
  WHERE row_num = 1
)
SELECT *
FROM Deduped_Final
WHERE amount IS NULL OR order_date IS NULL;

-- Expected:
-- order_id 6  | DAVID | WEST | DESK    | NULL | 2026-01-15   (amount was 'N/A')
-- order_id 10 | FRANK | WEST | MONITOR | 300  | NULL          (order_date missing)


-- ============================================================
-- Q5: What is each customer's average order value,
-- ranked from highest to lowest?
-- ============================================================
WITH Orders_Clean AS (
  SELECT 
    order_id,
    UPPER(TRIM(customer_name)) AS customer_name,  
    UPPER(TRIM(region)) AS region,
    UPPER(TRIM(product)) AS product,
    CASE 
      WHEN amount = 'N/A' THEN NULL
      ELSE CAST(amount AS DECIMAL)
    END AS amount,
    order_date
  FROM Orders_Raw
),
Orders_Deduped AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY customer_name, region, product, amount, order_date
           ORDER BY order_id
         ) AS row_num
  FROM Orders_Clean
),
Deduped_Final AS (
  SELECT order_id, customer_name, region, product, amount, order_date
  FROM Orders_Deduped
  WHERE row_num = 1
)
SELECT customer_name,
       ROUND(AVG(amount), 2) AS avg_order_value,
       RANK() OVER (ORDER BY AVG(amount) DESC) AS spend_rank
FROM Deduped_Final
GROUP BY customer_name
ORDER BY spend_rank;

-- Expected:
-- CAROL | 825.00 | 1
-- DAVID | 800.00 | 2
-- BOB   | 783.33 | 3
-- ALICE | 733.33 | 4
-- EVA   | 325.00 | 5
-- FRANK | 300.00 | 6
