CREATE DATABASE org;
USE org;

-- CREATING TABLES
CREATE TABLE depts (
    dept_code INT PRIMARY KEY,
    dept_title VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS emps (
    emp_code INT PRIMARY KEY,
    emp_fname VARCHAR(255),
    dept_code INT,
    manager_id INT,
    join_date DATE,
    salary DECIMAL(10, 2),
    FOREIGN KEY (dept_code) REFERENCES depts(dept_code),
    FOREIGN KEY (manager_id) REFERENCES emps(emp_code)
);

CREATE TABLE IF NOT EXISTS salaries (
    emp_code INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (emp_code) REFERENCES emps(emp_code)
);

-- INSERTING VALUES INTO THE TABLES

-- Departments
INSERT INTO depts VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Marketing');

-- Employees
INSERT INTO emps VALUES
(1, 'Robert', 1, NULL, '2022-01-01', 60000.00),
(2, 'Silvia', 2, 1, '2020-02-15', 80000.00),
(3, 'Amar', 2, 1, '2022-01-10', 80000.00),
(4, 'Akbar', 3, 2, '2022-04-20', 30000.00),
(5, 'Anthony', 3, 2, '2022-05-05', 60000.00),
(6, 'David', 4, 3, '2022-06-15', 80000.00),
(7, 'Grace', 4, 3, '2022-07-01', 80000.00),
(8, 'Frank', 1, NULL, '2022-08-10', 65000.00),
(9, 'Helen', 3, 2, CURDATE() - INTERVAL 1 YEAR, 70000.00),
(10, 'Salman', 4, 3, CURDATE() - INTERVAL 6 MONTH, 60000.00),
(11, 'Variko', 2, 1, CURDATE() - INTERVAL 1 YEAR, 80000.00),
(12, 'Aparichita', 3, 1, '2024-03-15', 67916),
(13, 'Saksham', NULL, 1, '2024-02-10', 80000),
(14, 'Vidushi', 1, 1, '2024-01-12', 60000);

-- Salaries
INSERT INTO salaries VALUES
(1, 60000.00),
(2, 70000.00),
(3, 70000.00),
(4, 55000.00),
(5, 60000.00),
(6, 80000.00),
(7, 80000.00),
(8, 65000.00),
(9, 70000.00),
(10, 75000.00),
(11, 100000.00),
(12, 67916.60),
(13, 80000.00),
(14, 60000.00);


-- QUERYING THE DATABASE


-- Retrieve all employees and their departments, including those without a department.
SELECT * 
FROM emps e 
LEFT JOIN depts d 
ON e.dept_code = d.dept_code;

-- Find the second highest salary from the “salaries” table.
SELECT MAX(s.salary) AS "Second highest Salary"
FROM emps e JOIN salaries s 
ON e.emp_code = s.emp_code 
WHERE s.salary < (SELECT MAX(salary) FROM salaries);

-- Calculate the average salary for each department.
SELECT dept_title, ROUND(AVG(salary),2) AS "Average_salary" 
FROM emps e 
JOIN depts d 
ON e.dept_code = d.dept_code GROUP BY dept_title;

-- List the employees who have the same salary as the second highest-paid employee.
SELECT * FROM emps WHERE salary = (SELECT MAX(salary) FROM emps WHERE salary < (SELECT MAX(salary) FROM emps));

-- Retrieve the employees who joined before their manager.
SELECT * FROM emps e JOIN emps m ON e.manager_id = m.emp_code WHERE e.join_date < m.join_date;

-- Find the top 3 departments with the highest average salary.
SELECT dept_title, AVG(salary) AS "avg_salary" 
FROM emps e 
JOIN depts d 
ON e.dept_code = d.dept_code 
GROUP BY dept_title 
ORDER BY avg_salary DESC LIMIT 3;

-- List the departments where the average salary is above the overall average salary.

SELECT dept_title, AVG(s.salary) as "avg_salary" FROM emps e 
JOIN depts d ON e.dept_code = d.dept_code
JOIN salaries s ON e.emp_code = s.emp_code
GROUP BY dept_title
HAVING avg_salary > (SELECT AVG(salary) FROM salaries);

-- Find the employees who have the same salary and department as their manager.
SELECT * FROM emps e 
JOIN emps m ON e.manager_id = m.emp_code 
WHERE e.salary = m.salary and e.dept_code = m.dept_code;

-- Find the third maximum salary from the “salaries” table without using the LIMIT clause.
SELECT * FROM (
SELECT *, row_number() OVER(ORDER BY salary DESC) as S FROM salaries
) as sub WHERE S = 3;

--  List the employees who have never been assigned to a department.
SELECT * FROM emps WHERE dept_code IS NULL;

-- Retrieve the employees with the highest salary in each department.
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY dept_code ORDER BY salary DESC) AS "Ranking" FROM emps
) AS sub
WHERE ranking = 1;

--  Find the employees who have the same manager as the employee with ID 3.
SELECT * FROM emps WHERE manager_id = (SELECT manager_id FROM emps WHERE emp_code = 3);

-- Retrieve the employees who have the highest salary in their respective department and joined in the last 6 months.
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY dept_code ORDER BY salary DESC) as "Ranking" FROM emps WHERE join_date >= CURDATE() - INTERVAL 6 MONTH
) as SUB
WHERE Ranking = 1;

-- List the departments with more than 3 employees.
SELECT dept_code, COUNT(*) AS "employee_count" FROM emps GROUP BY dept_code HAVING employee_count > 3;

-- Retrieve the employees with the second lowest salary.
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY dept_code ORDER BY salary ASC) AS "Ranking" FROM emps
) AS sub
WHERE Ranking = 2;

-- Retrieve the employees who have the highest salary in their respective department and joined in the last 6 months.
SELECT * FROM
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY dept_code ORDER BY salary DESC) as "Ranking" FROM emps WHERE join_date >= CURDATE() - INTERVAL 6 MONTH
) AS sub
WHERE Ranking = 1;

-- List the departments with more than 3 employees.
SELECT dept_title, e.dept_code, COUNT(*) as "total_records" 
FROM emps e 
JOIN depts d 
	ON e.dept_code = d.dept_code 
GROUP BY dept_code 
HAVING total_records > 3;

-- Retrieve the employees with the second lowest salary.
SELECT * FROM emps ORDER BY salary LIMIT 1 OFFSET 1;

-- Find the departments where the highest and lowest salaries differ by more than $10,000.
SELECT dept_code, MAX(salary) - MIN(salary) AS "difference" 
FROM emps 
GROUP BY dept_code 
HAVING difference > 10000;

-- Retrieve the employees who have the same salary as the employee with ID 2 in a different department.
SELECT * 
FROM emps 
WHERE salary = (SELECT salary FROM emps WHERE emp_code = 2) 
	AND dept_code <> (SELECT dept_code FROM emps WHERE emp_code = 2);

-- Calculate the difference in days between the hire dates of each employee and their manager.
SELECT *, DATEDIFF(e.join_date,m.join_date) AS "Difference in days" FROM emps e
JOIN emps m 
	ON e.manager_id = m.emp_code;

-- Find the departments where the sum of salaries is greater than the overall average salary.
SELECT dept_code,SUM(salary) AS "Total" FROM emps GROUP BY dept_code HAVING Total > (SELECT AVG(SALARY) FROM emps);

-- List the employees who have the same salary as at least one other employee.
SELECT e.emp_fname FROM emps e
WHERE EXISTS (SELECT 1 FROM emps WHERE salary = e.salary AND emp_code <> e.emp_code);

SELECT salary,GROUP_CONCAT(emp_fname) FROM emps GROUP BY salary; -- Cross-checking the above query

SELECT * FROM
(
SELECT *, 
MIN(SALARY) OVER (PARTITION BY dept_code) AS "min_salary",
MAX(SALARY) OVER(PARTITION BY dept_code) AS "Max_salary"
FROM emps
) AS sub
WHERE salary = min_salary OR salary = max_salary;

-- List the employees who have a higher salary than their manager.
SELECT * FROM emps e JOIN emps m ON e.manager_id = m.emp_code WHERE e.salary > m.salary;

-- Retrieve the top 5 departments with the highest salary sum.
SELECT dept_code, SUM(salary) AS "Total" FROM emps GROUP BY dept_code ORDER BY Total DESC LIMIT 5;

-- Find the employees who have the same salary as the average salary in their department.
SELECT * FROM emps e WHERE salary = (SELECT AVG(salary) FROM emps WHERE dept_code = e.dept_code);

-- Calculate the moving average salary for each employee over the last 3 months.
SELECT * FROM 
(
SELECT 
*, 
	AVG(salary) OVER(PARTITION BY emp_code ORDER BY join_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS "moving_average" 
FROM emps
) AS sub;

-- List the employees who have joined in the same month as their manager.
SELECT * FROM emps e
JOIN emps m
ON e.manager_id = m.emp_code
WHERE MONTH(m.join_date) = MONTH(e.join_date);

-- Retrieve the employees with salaries in the top 10% within their department.
SELECT * FROM 
(
SELECT *, PERCENT_RANK() OVER(PARTITION BY dept_code ORDER BY salary) AS "percentile_rank" FROM emps
) AS sub
WHERE percentile_rank >= 0.9;

-- Find the departments where the number of employees is greater than the number of employees in the “IT” department.
SELECT e.dept_code, dept_title, COUNT(*) AS "counter" FROM emps e
JOIN depts d
	ON e.dept_code = d.dept_code
GROUP BY dept_code, dept_title HAVING counter > (SELECT COUNT(*) FROM emps e JOIN depts d ON e.dept_code = d.dept_code GROUP BY dept_title HAVING dept_title = "IT"); 
