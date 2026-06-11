-- Project 1: Sales Performance Analysis
-- Tools: SQL (SQLite)
-- Description: Analyzing rep performance, category revenue, and monthly trends

-- Q1: Top performing reps by revenue
WITH rep_revenue AS (
  SELECT r.rep_name,
         r.region,
         SUM(p.price * s.quantity) AS total_revenue
  FROM Sales s
  JOIN Reps r ON s.rep_id = r.rep_id
  JOIN Products p ON s.product_id = p.product_id
  GROUP BY r.rep_name, r.region
)

SELECT rep_name,
       region,
       ROUND(total_revenue, 2) AS total_revenue
FROM rep_revenue
ORDER BY total_revenue DESC;

-- Q2: Revenue by product category
WITH category_revenue AS (
  SELECT p.category,
         SUM(p.price * s.quantity) AS total_revenue,
         COUNT(s.sale_id) AS total_transactions
  FROM Sales s
  JOIN Products p ON s.product_id = p.product_id
  GROUP BY p.category
)

SELECT category,
       ROUND(total_revenue, 2) AS total_revenue,
       total_transactions
FROM category_revenue
ORDER BY total_revenue DESC;

-- Q3: Reps below average (with CASE flag)
WITH rep_revenue AS (
  SELECT r.rep_name,
         SUM(p.price * s.quantity) AS total_revenue
  FROM Sales s
  JOIN Reps r ON s.rep_id = r.rep_id
  JOIN Products p ON s.product_id = p.product_id
  GROUP BY r.rep_name
),

avg_revenue AS (
  SELECT AVG(total_revenue) AS company_avg
  FROM rep_revenue
)

SELECT r.rep_name,
       ROUND(r.total_revenue, 2) AS total_revenue,
       ROUND(a.company_avg, 2) AS company_avg,
       CASE
         WHEN r.total_revenue < a.company_avg THEN '⚠️ Below Average'
         ELSE '✅ Above Average'
       END AS performance_flag
FROM rep_revenue r, avg_revenue a
ORDER BY total_revenue DESC;

-- Q4: Monthly revenue trend
SELECT SUBSTR(sale_date, 1, 7) AS month,
       COUNT(s.sale_id) AS total_sales,
       ROUND(SUM(p.price * s.quantity), 2) AS monthly_revenue
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY month
ORDER BY month ASC;
