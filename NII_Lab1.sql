-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Sept 11, 2022
-- Title: NII Lab 1
-- ********************************************************
UPDATE employees SET hire_date = hire_date + (20*365);
UPDATE job_history SET end_date = end_date + (20*365);
UPDATE job_history SET start_date = start_date + (20*365);

-- Question 1:
--If the following SELECT statement does NOT execute successfully, how would you fix it (Answer in commented text) and then write the corrected statement (not commented)

--SELECT last_name "LName", job_id "Job Title", 
--       Hire Date "Job Start"
--FROM employees;
-- Explanation:
-- This command will not work due to AS command for alias' not being used. Based on that I would use the AS command for where the alias names would be.
-- Another error would be with the way the variables from the employees table are being written. For example, the hire_date variable from the table is written as "Hire Date".
-- So I would also fix this by writting the variable as hire_date. The sql style is not correct, so I would make some changes with that.

-- Solution:
SELECT 
    last_name AS "LName", 
    job_id AS "Job Title", 
    hire_date AS "Job Start" 
FROM employees;

-- Question 2;
--2.	Display the employee_id, last name and salary of employees earning in the range of $8,000 to $11,000.  Sort the output by top salaries first and then by last name.  Output the salary such that it “looks” like money (i.e. with a $ and 2 decimal places).

SELECT 
    employee_id,
    last_name,
    TO_CHAR(salary, '$99999999.99') AS "SALARY" -- $99999999.99 is the format to print out money in $00.00 format. Number of 9's used can be changed, as long as it is enough to hold the number from the table
FROM employees
WHERE 
    salary >= 8000 AND salary <= 11000
ORDER BY 
    salary DESC, -- DESC will order the list from greatest to smallest
    last_name DESC;

-- Question 3
--3.	Write the solution for question 2 again with the salary being in a format appropriate to send to another software application.

SELECT 
    employee_id,
    last_name,
    salary
FROM employees
WHERE 
    salary >= 8000 AND salary <= 11000
ORDER BY 
    salary DESC,
    last_name DESC;

-- Question 4
--4.	Display the job titles and full names of employees whose first name contains an ‘e’ or ‘E’ anywhere. The output should look like: (BONUS MARK FOR NOT using the OR keyword in the solution but obtaining the same results)
--Job Title		Full name
----------------------------------------
--AD_VP		Neena 	Kochhar
--	    … more rows


SELECT
    job_id AS "Job Title",
    first_name || ' ' || last_name AS "Full name"
FROM employees
WHERE 
    LOWER(first_name) like '%e%';

-- Question 5
--5.	Create a query to display the address of the various locations where offices are located.  Add a parameter to the query such that the user can enter all, or part of, the city name and all locations from the resultant cities will be shown. 
 
SELECT 
    street_address,
    city
FROM locations
WHERE
    UPPER(city) like UPPER('&cityName%');
    
-- Question 6
--6.	Write a query to display the tomorrow’s date in the following format:
--     September 15th of year 2019
--the result will depend on the day when you RUN/EXECUTE this query.  Label the column “Tomorrow”.

SELECT
    to_char(sysdate + 1, 'Month dd "of the year ", yyyy') AS "Tomorrow" 
FROM job_history 
WHERE 
    rownum = 1; -- Rownum is used to print out only one row instead of all 9 in job_history
    
-- Question 7
-- For each employee in departments 20, 50 and 60 display last name, first name, department name, salary, and salary increased by 4% and expressed as a whole number.  Label the increased salary column “Good Salary”.  
-- Also add a column that subtracts the old salary from the new salary and multiplies by 12. Label the column "Annual Pay Increase".
-- Note: Salary in this database is stored as “Monthly Salary” – see column descriptions in the database columns tab

SELECT 
    last_name,
    first_name,
    department_id,
    salary,
    salary * 1.04 AS "Good Salary",
    (salary * 1.04) - salary AS "Annual Pay Increase"
FROM employees
WHERE
    department_id = 20 
    OR department_id = 50 
    OR department_id =  60;
    
-- Hint for question 8
--Cannot use 365, do not use extract year from
-- 12 months in a year, use that since it is a precise number
-- use function months between which is an exact calculation
-- Question 8
-- For each employee hired before 2014, display the employee’s last name, hire date and calculate the number of YEARS between TODAY (not hard coded) and the date the employee was hired.
-- a.	Label the column Years worked. 
-- b.	Order your results by the number of years employed.  Round the number of years employed DOWN to the closest whole number.

SELECT
    last_name,
    hire_date,                                                                                                     -- Notes after finishing lab, TO_DATE was not needed on hire_date, since it is already a date
    FLOOR((MONTHS_BETWEEN(TO_DATE('14-01-01', 'yy-mm-dd'), TO_DATE (hire_date, 'yy-mm-dd')))/12) AS "Years worked" -- Calculation works in the way of having it 
                                                                                                                   -- first find the months between January 1st, 2014, 
                                                                                                                   -- and the hiredate of employees who were hired before 
                                                                                                                   --2014 and then dividing it by 12 to show how many years the employees worked
                                                                                                                   -- Rounding the number down using FLOOR, which will show how many years the employees worked
FROM employees
WHERE
    hire_date < TO_DATE('14-01-01', 'yy-mm-dd')
    ORDER BY 
    hire_date ASC;
    
    
-- Question 9
-- Create a query that displays the city names, country codes and state province names, but only for those cities that starts with S and has at least 8 characters in their name. If city does not have a province name assigned, then put Unknown Province.  Be cautious of case sensitivity!
SELECT
    city,
    country_id,
    CASE WHEN state_province IS NULL THEN 'Unknown Province' ELSE state_province END AS state_province-- CASE Function is similar to IF statement, but can be easily used with a WHERE, ORDER BY and GROUP BY.
FROM Locations
WHERE
    city LIKE UPPER('S_______%'); -- Put Down 7 '_' as they can be used to match exactly one character. 
                                -- So having 7 '_' will force the query to look for anything that starts with 'S' that is then followed by 7 letters,
                                -- that could possibly have anything after those letters due to the wildcard (%) being used.
                  
-- Question 10
--10.	Display each employee’s last name, hire date, and salary review date, which is the first Thursday after a year of service, but only for those hired after 2017.  
--a.	Label the column REVIEW DAY. 
--b.	Format the dates to appear in the format like:
--    WEDNESDAY, SEPTEMBER the Eighteenth of year 2019
--Sort by review date

SELECT 
    last_name,
    hire_date,
    TO_CHAR(NEXT_DAY((hire_date + 365), 'Thursday'),'DAY", "Month" the "dd" of year "yyyy') AS "Review Day" -- Using NEXT_DAY in TO_CHAR to find the next Thursday of that week a year from now
FROM employees
WHERE hire_date >= TO_DATE('17-01-01', 'yy-mm-dd')
ORDER BY "Review Day";