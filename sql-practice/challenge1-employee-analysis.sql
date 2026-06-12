-- Challenge 1: Employee & Project Analysis
-- Tools: SQL (SQLite)
-- Description: Analyzing employee salaries, departments, and project assignments

-- ============================================
-- Q1: Total and average salary per department
-- ============================================
SELECT department, 
       SUM(salary) AS total_salary, 
       ROUND(AVG(salary), 2) AS avg_salary
FROM Employees
GROUP BY department
ORDER BY total_salary DESC;


-- ============================================
-- Q2: All employees with or without projects
-- ============================================
SELECT e.name,
       e.department,
       p.project_name
FROM Employees e
LEFT JOIN Projects p
  ON e.emp_id = p.emp_id;


-- ============================================
-- Q3: Employees earning above their dept average
-- ============================================
WITH dept_avg AS (
  SELECT department,
         ROUND(AVG(salary), 2) AS avg_deptSal
  FROM Employees
  GROUP BY department
)

SELECT e.name,
       e.department,
       e.salary,
       CASE
         WHEN e.salary > d.avg_deptSal THEN 'Above Average'
         ELSE 'Below Average'
       END AS performance_flag
FROM Employees e
JOIN dept_avg d
  ON e.department = d.department
WHERE e.salary > d.avg_deptSal;


-- ============================================
-- Q4: Departments with avg salary above 60,000
-- ============================================
SELECT department, 
       ROUND(AVG(salary), 2) AS avg_deptSal
FROM Employees
GROUP BY department
HAVING avg_deptSal > 60000;
