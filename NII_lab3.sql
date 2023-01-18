-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: October 2nd, 2022
-- Title: NII_week3.sql
-- ********************************************************

-- Question 1:
-- Create an INSERT statement to do this.  Add yourself as an employee with a NULL salary, 0.21 commission_pct, in department 90, and Manager 100.  
-- You started TODAY.  

INSERT INTO employees (employee_id, first_name, last_name, email, salary, commission_pct, hire_date, department_id, manager_id, job_id)
VALUES ('1', 'Marco', 'Pasqua', 'mpasqua', NULL, '0.21', TO_DATE(sysdate), '90', '100', 'ST_CLERK');

-- Question 2:
-- 2.	Create an Update statement to: Change the salary of the employees with a last name of Matos and Whalen to be 2500.

UPDATE employees
SET salary = 2500
WHERE last_name = 'Matos' OR last_name = 'Whalen';

--Question 3:
COMMIT;

--Question 4:
-- 4.	Display the last names of all employees who are in the same department as the employee named Abel.

SELECT
    last_name
FROM 
    employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE last_name = 'Abel'
    )
ORDER BY last_name;

-- Question 5:
-- 5.	Display the last name of the lowest paid employee(s)
SELECT 
    last_name
FROM 
    employees
WHERE salary = (
        SELECT MIN(salary)
        FROM employees)
ORDER BY last_name;
-- Question 6
-- 6.	Display the city that the lowest paid employee(s) are located in.
SELECT 
    l.city
FROM 
    locations l
    JOIN departments d ON l.location_id = d.location_id
    JOIN employees e ON d.department_id = e.department_id
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
    );

    

-- Question 7
-- 7.	Display the last name, department_id, and salary of the lowest paid employee(s) in each department.  
--      Sort by Department_ID. (HINT: careful with department 60)
SELECT 
    last_name,
    department_id,
    salary
FROM 
    employees
WHERE (department_id, salary) IN (
    SELECT department_id,
            MIN(salary)
    FROM employees
--    WHERE department_id != 60 --Ask if this is correct output. We get the lowest salary of the employee in department 60
    GROUP BY
        department_id
    )
ORDER BY
    department_id;

    

-- Question 8
-- 8.	Display the last name of the lowest paid employee(s) in each city
SELECT 
    l.city,
    e.last_name
FROM 
    locations l
    JOIN departments d ON l.location_id = d.location_id
    JOIN employees e ON d.department_id = e.department_id
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
    );

-- Question 9
-- 9.	Display last name and salary for all employees who earn less than the lowest salary in ANY department. 
--      Sort the output by top salaries first and then by last name.

SELECT
    last_name,
    NVL(MIN(salary),0),
    e.department_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE salary IN (
        SELECT NVL(MIN(salary),0)
        FROM employees)
GROUP BY
    last_name,
    e.department_id,
    salary
ORDER BY
    salary DESC,
    last_name;

-- Question 10
--10.	Display last name, job title and salary for all employees whose salary matches any of the salaries from the IT Department. 
--      Do NOT use Join method.  Sort the output by salary ascending first and then by last_name


SELECT
    last_name,
    job_id,
    salary
FROM employees
WHERE salary IN (
        SELECT salary
        FROM employees
        WHERE job_id = 'IT_PROG'
        )
ORDER BY
    salary ASC,
    last_name;


