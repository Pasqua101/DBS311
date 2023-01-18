-- ***************************************
-- DBS311 - Fall 2022
-- Lab 1b
-- Review of JOIN statements
-- 
-- Marco Pasqua
-- 100497213
-- Sunday, September 18, 2022
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
    d.department_name,
    d.manager_id,
    e.first_name || ' ' || e.last_name AS "Employee Name",
    l.city
FROM
    departments d
    LEFT OUTER JOIN employees e ON d.department_id = e.department_id
    LEFT OUTER JOIN locations l ON d.location_id = l.location_id
ORDER BY
    "Employee Name";

-- Q2
/*
Allow the user to enter the name of a country, or any part of the name, and 
then list all employees, with their job title, currently working in that country.
*/
SELECT 
    e.first_name,
    e.last_name,
    d.department_id,
    l.city,
    c.country_name
From 
    employees e
    RIGHT JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    JOIN countries c ON l.country_id = c.country_id
WHERE
    UPPER(c.country_name) LIKE '%' || TRIM(UPPER('&countryName')) || '%'
ORDER BY
    c.country_name ASC;

-- Q3
/*
Provide a contact list of all employees, and if they have a manager, 
the name of their direct manager.
*/
SELECT 
    e.employee_id AS "Employee ID",
    e.first_name || ' ' || e.last_name AS "Employee Name",
    e.email AS "Email",
    e.phone_number AS "Phone Number",
    m.first_name || ' ' || m.last_name AS "Manager Name"
FROM 
    employees e
    LEFT JOIN employees m ON e.manager_id  = m.employee_id
ORDER BY
    "Employee Name";
    
    

-- Q4
/*
Provide a list of locations in the database, that currently do not have 
any employees working there.
*/

SELECT DISTINCT --Using distinct to remove duplicate matches, as that was an issues I was facing previously where it would bring up duplicate matches
    city || ', ' || state_province AS "location",
    street_address AS "Address",
    l.location_id
FROM 
    locations l 
    JOIN departments d ON d.location_id = l.location_id
    JOIN employees e ON d.department_id != e.department_id
ORDER BY
    "location";
    
    
-- Q5
/*
Provide a list of employees whom are currently still in the same job that they
started in (i.e. they have never changed job titles).
*/
SELECT DISTINCT
    first_name || ' ' || last_name AS "Employee Name",
    e.job_id,
    e.employee_id
FROM
    employees e
    JOIN job_history j ON e.job_id = j.job_id
ORDER BY
    "Employee Name";

