SELECT name,
       department,
       salary
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees);

SELECT department,
       ROUND(avg_salary, 2) AS avg_salary
FROM (
  SELECT department,
         AVG(salary) AS avg_salary
  FROM Employees
  GROUP BY department
) AS dept_summary
ORDER BY avg_salary DESC;

WITH dept_summary AS (
  SELECT department,
         ROUND(AVG(salary), 2) AS avg_salary
  FROM Employees
  GROUP BY department
)

SELECT department,
       avg_salary
FROM dept_summary
ORDER BY avg_salary DESC;

WITH dept_avg AS (
  SELECT department,
         ROUND(AVG(salary), 2) AS avg_salary
  FROM Employees
  GROUP BY department
),

above_avg_employees AS (
  SELECT e.name,
         e.department,
         e.salary
  FROM Employees e
  JOIN dept_avg d
    ON e.department = d.department
  WHERE e.salary > d.avg_salary
)

SELECT name,
       department,
       salary
FROM above_avg_employees
ORDER BY salary DESC;

