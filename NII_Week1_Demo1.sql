-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Sept 6, 2022
-- Title: NII Week 1 Demo 1
-- ********************************************************

-- Example
-- List all employees column wise
SELECT * FROM employees;

-- Example
-- List all employees from rows
SELECT * FROM employees WHERE employee_id = 100;

-- List all employees (lastname, firstname) sort by last name
-- Double quote are used to assign data to an object (Shouldn't really use) (If using one, do not include spaces)
-- Single quotes, do not use for alias name as it will not allow the code to work
SELECT 
    employee_id,
    last_name || ',' || first_name AS empName,
    email,
    phone_number,
    job_id
FROM employees
ORDER BY last_name;

-- Distinct (Looks for disctinct things in data table, for example ifit was only looking for job_id, it would look for unique job_id, but if manager_id was used it would look for unique combinations)
SELECT DISTINCT 
    job_id,
    manager_id
FROM employees
ORDER BY job_id;

-- to_char() turns something into a string
-- List all employees and show their hire date (non-human readable,ex software to software)
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date
FROM employees
ORDER BY hire_date;
-- but for human readable we need to 
SELECT 
    employee_id,
    first_name,
    last_name,
    TO_CHAR(hire_date, 'Month dd, yyyy') AS hireDate
FROM employees
ORDER BY hire_date;
-- Adding 20 years to employees hire_date
--UPDATE employees SET hire_date = hire_date + (365 * 20 + 4);

-- TO_DATE (Allows code to work on any computer regardless of the way the date format is set up, based on the region the computer was set up in)
SELECT 
    employee_id,
    first_name,
    last_name,
    TO_CHAR(hire_date, 'Month dd, yyyy') AS hireDate
FROM employees
WHERE
    hire_date > TO_DATE('11-05-10', 'yy-mm-dd')
ORDER BY hire_date;

-- Case Sensitivity
-- Find all employees whose last name starts with 'M' or 'm'
SELECT
    employee_id,
    first_name,
    last_name,
    email
From employees
WHERE UPPER(last_name) like 'M%' -- % (wildcard) will look for anything after and/or before letter based on where the % is located
ORDER BY
    last_name,
    first_name;
    
-- But now let us make a single statement that works for any letter entered  
SELECT
    employee_id,
    first_name,
    last_name,
    email
From employees
WHERE UPPER(last_name) LIKE UPPER('&letter%') -- & creates a varibale -- Use UPPPER at the variable to make work in a way where if the user enters a lower case letter, it will convert user input to upper
ORDER BY
    last_name,
    first_name;
    
-- SQL checklist
-- 1. is it international? Meaning in terms of date formats (mm-dd-yyyy) or (dd-mm-yyyy) because US or other countires use differet date formats
-- 2. Is it case sensitive
-- 3. Does it not asume anything? Make sure code makes no assumption. In terms of, do not asume the person will type in the first letter of a person's name in upper case. 
-- They may sometimes type it in lower case