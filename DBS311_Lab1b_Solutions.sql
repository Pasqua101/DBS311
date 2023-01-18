-- ***************************************
-- DBS311 - Fall 2022
-- Lab 1b
-- Review of JOIN statements
-- 
-- <your name>
-- <your student ID>
-- <date completed>
-- ***************************************

/* 
NOTES
-- Make sure you follow the course style guide for SQL as posted on blackboard.
-- Data should always be sorted in a logical way, for the question, even if the 
   question does not specify to sort it.
*/

-- Q1
/* 
Provide a list of ALL departments, what city they are located in, and the name
of the current manager, if there is one.  
*/
SELECT 
    d.department_id,
    department_name,
    city,
    first_name,
    last_name
FROM
    departments d 
    LEFT OUTER JOIN locations l ON d.location_id = l.location_id
    LEFT OUTER JOIN employees e ON d.manager_id = e.employee_id
ORDER BY department_name;

-- Q2
/*
Allow the user to enter the name of a country, or any part of the name, and 
then list all employees, with their job title, currently working in that country.
*/
SELECT 
    country_name,
    first_name, 
    last_name,
    job_id
FROM 
    employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    RIGHT OUTER JOIN countries c ON c.country_id = l.country_id
WHERE 
    UPPER(country_name) LIKE UPPER('%&country%')
ORDER BY 
    last_name, 
    first_name;

-- Q3
/*
Provide a contact list of all employees, and if they have a manager, 
the name of their direct manager.
*/
SELECT 
    e.employee_id,
    e.first_name AS empFirstName,
    e.last_name AS empLastName,
    e.phone_number,
    e.email,
    m.first_name AS mgrFirstName,
    m.last_name AS mgrLastName
FROM 
    employees e
    LEFT OUTER JOIN employees m ON e.manager_id = m.employee_id
ORDER BY 
    e.last_name,
    e.first_name;
    
-- Q4
/*
Provide a list of locations in the database, that currently do not have 
any employees working there.
*/
SELECT
    l.location_id,
    city
FROM 
    locations l
    LEFT OUTER JOIN departments d ON l.location_id = d.location_id
    LEFT OUTER JOIN employees e ON d.department_id = e.department_id
WHERE 
    e.employee_id IS NULL
ORDER BY city;

-- Q5
/*
Provide a list of employees whom are currently still in the same job that they
started in (i.e. they have never changed job titles).
*/
SELECT 
    e.employee_id,
    first_name,
    last_name
FROM 
    employees e
    LEFT OUTER JOIN job_history jh ON e.employee_id = jh.employee_id
WHERE jh.employee_id IS NULL
ORDER BY 
    last_name,
    first_name;