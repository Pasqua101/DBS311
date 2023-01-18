-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: October 9th, 2022
-- Title: NII_Lab4 
-- ********************************************************

--Q1:
-- 1.	The HR department needs a list of Department IDs for departments that do not contain the job ID of ST_CLERK> Use a set operator to create this report.
SELECT department_id
FROM employees
MINUS
SELECT department_id
FROM employees
WHERE job_id = 'ST_CLERK';

--Q2:
-- 2.	Same department requests a list of countries that have no departments located in them. Display country ID and the country name. Use SET operators.  
SELECT 
    country_id,
    country_name
FROM countries

MINUS

SELECT
    c.country_id,
    c.country_name
FROM countries c
JOIN locations l ON c.country_id = l.country_id
JOIN departments d ON l.location_id = d.location_id
WHERE d.department_id IS NOT NULL;

--Q3:
-- 3. The Vice President needs very quickly a list of departments 10, 50, 20 in that order. job and department ID are to be displayed.
SELECT
    job_id,
    department_id
FROM employees
WHERE department_id = 10

UNION ALL --Using union all as to keep the matches between each script

SELECT
    job_id,
    department_id
FROM employees
WHERE department_id = 50

UNION ALL

SELECT 
    job_id,
    department_id
FROM employees
WHERE department_id = 20;

-- Q4:
-- 4.	Create a statement that lists the employeeIDs and JobIDs of those employees who currently have a job title that is the same as their job title 
--      when they were initially hired by the company (that is, they changed jobs but have now gone back to doing their original job).

SELECT 
    e.employee_id, 
    job_id
FROM employees e --had to create a alias name for the table, because I assume that there being 2 employee_id columns confused sql developer. Even if it returned a answer

INTERSECT

SELECT 
    j.employee_id,
    job_id
FROM job_history j;

-- Q5:
-- 5.	The HR department needs a SINGLE report with the following specifications:
-- a.	Last name and department ID of all employees regardless of whether they belong to a department or not.
-- b.	Department ID and department name of all departments regardless of whether they have employees in them or not.

SELECT
    first_name,
    last_name,
    department_id,
    NULL AS department_Name --Using NULL here since employees, does not have a departmentName column
FROM employees

UNION 

SELECT
    NULL, --Two NULLS here will be first_name and last_name, but they do not need to have an alias since the first Select will name the columns 
    NULL,
    department_id,
    department_name
FROM departments


