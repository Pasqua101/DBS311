-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Sept 20, 2022
-- Title: NII_week3.sql
-- ********************************************************
--Topics: Grouping and Aggregate Functions

-- Two new clauses in the SELECT statement
-- so far we have

-- SELECT
-- FROM
-- WHERE
-- ORDER BY

-- now adding GROUP BY and HAVING
-- new ORDER of the statement

-- SELECT <comma separated field list>
-- FROM <table(s)>
-- WHERE <conditions>
-- GROUP BY <comma separate field list (group by expression)>
-- HAVING < conditions on aggregated data>
-- ORDER BY <comma separated columns>

-- There are 7 aggregate function
-- AVG
-- SUM   How Much
-- COUNT How Much
-- MAX
-- MIN
-- VARIANCE

-- example:
-- How many countries are in the database

SELECT * FROM countries; -- Will display all countries

SELECT COUNT(*) FROM countries; -- Star says get all columns, count counts rows

-- better way
SELECT COUNT(country_id) AS numCountries 
FROM countries;

-- How many countries are there in each region?
SELECT COUNT(country_id) AS numCountries
FROM countries
WHERE region_id = 1;
-- but I want all data at once
SELECT
    region_id,
    COUNT(country_id) AS numCountries,
    country_name -- country_name causes an error since it is not part of an aggreate function
FROM countries
GROUP BY 
    region_id;
-- THIS FAILS due to aggregate function error
SELECT
    region_id,
    COUNT(country_id) AS numCountries,
    country_name -- country_name causes an error since it is not part of an aggreate function
FROM countries
GROUP BY 
    region_id,
    country_name;

SELECT country_id, country_name
FROM countries
WHERE region_id = 1;
--not an aggregate function


--CLINT's LAW OF GROUPING
-- Any field inclkuded in the SELECT statement NOT part of an aggregate function
-- MUST MUST MUST be included in the GROUP BY statement

-- Example:
-- How much money goes out for salary per month per department
-- Note: Salary is already monthly
SELECT
    department_id,
    SUM(salary) AS sumSalary
FROM employees
GROUP BY department_id
ORDER BY department_id;
-- What if we want the department name?
SELECT
    e.department_id,
    SUM(salary) AS sumSalary,
    department_name
FROM 
    employees e
    FULL OUTER JOIN departments d ON e.department_id = d.department_id -- Could use a left outer join to make sure all employees are included, since their salary is related to employees. Want to make sure that the money is included
                                                                        -- But it is better to use a FULL JOIN since it will also show departments that make no money
GROUP BY --Group by gives us multiple rows, and puts it into small groups of data
    e.department_id,
    department_name
ORDER BY e.department_id;

-- How much money goes out annually
SELECT
    e.department_id,
    SUM(salary) * 12 AS sumAnnualSalary,
    department_name
FROM 
    employees e
    FULL OUTER JOIN departments d ON e.department_id = d.department_id 
GROUP BY 
    e.department_id,
    department_name
ORDER BY e.department_id;

-- What if we wanted to do a $1000 raise for each employee?
SELECT
    e.department_id,
    SUM(salary) * 12 + count(employee_id) * 1000 AS sumAnnualSalary, --Could also do as SUM(salary*12 + 1000)
    department_name
FROM 
    employees e
    FULL OUTER JOIN departments d ON e.department_id = d.department_id 
GROUP BY 
    e.department_id,
    department_name
ORDER BY e.department_id;

-- Example
--How many departments have employees?
SELECT COUNT(DISTINCT department_id) AS numDepts --If DISTINCT is after SELECT, it will say 19, which is not true because we only have 8 departments. The same could be said without DISTINCT
FROM employees;

--but null depratment ignored.. could be good or bad depending on
-- if we do want to count the null department
SELECT COUNT(DISTINCT NVL(department_id,0)) AS numDepts -- make sure you're using a department_id that does not exist in the database
FROM employees; 

--what is the average sales commission per month?
-- let us start with the avgerage commission_pct
SELECT AVG(commission_pct)
FROM employees;

--But does this include all employees? The answer is no
SELECT AVG(NVL(commission_pct,0)) --This also inludes employees who's commision is 0
FROM employees;

-- OTHER FUNCTIONS
-- Produce a SINGLE sql statement that returns a SINGLE line result
-- that displays the minimum, maximum, and average salaries for ALL employees

SELECT
    MIN(salary) AS minSalaray,
    MAX(salary) AS maxSalary,
    AVG(salary) AS avgSalary
FROM employees;

--but what about volunteers, if we want to include them. Don't always use NVL, has to make sense for the question
SELECT
    MIN(NVL(salary,0)) AS minSalaray,
    MAX(NVL(salary,0)) AS maxSalary,
    AVG(NVL(salary,0)) AS avgSalary
FROM employees;

--6th CLAUSE
-- HAVING
--having and where are almost identical

-- rules
-- ALWAYS use WHERE for filter conditions that do not involve aggrate functions
-- ALWAYS use HAVING for filter conditions that DO involve agreegrate functions

-- ORDER OF XECUTION

/*
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT (AS A LOOP)
6. ORDER BY
*/
-- display the average salary for employees in each job-title in each department
SELECT
    department_id,
    job_id,
    AVG(NVL(salary,0)) AS avgSalary
FROM employees
GROUP BY
    department_id,
    job_id
ORDER BY department_id;

-- now include only those where the average is above 15000

SELECT
    department_id,
    job_id,
    AVG(NVL(salary,0)) AS avgSalary
FROM employees
WHERE department_id IN (20,60,80,90) --WHERE came in from another question
GROUP BY
    department_id,
    job_id
HAVING AVG(NVL(salary,0)) > 15000
ORDER BY department_id;

--What if I want the department name?
SELECT
    e.department_id,
    department_name,
    job_id,
    AVG(NVL(salary,0)) AS avgSalary
FROM 
    employees e
    FULL JOIN departments d ON e.department_id = d.department_id --Using a FULL JOIN to get employees with no salary's and departments with no salaries
GROUP BY
    e.department_id,
    department_name,
    job_id
ORDER BY e.department_id;

--Practice
-- How many unique employees have
-- changed jobs within the compnay?
SELECT COUNT(DISTINCT employee_id) AS numEmps 
FROM job_history;


-- Practice
-- How many employees work in each location?
-- include ALL locations!
SELECT 
    l.location_id,
    city,
    COUNT(employee_id) AS numEmps
FROM
    locations l
    LEFT OUTER JOIN departments d ON d.location_id = l.location_id --Both are left outer joins because we want all locations
    LEFT OUTER JOIN employees e ON d.department_id =  e.department_id
GROUP BY
    l.location_id,
    city
ORDER BY 
    city;
    
