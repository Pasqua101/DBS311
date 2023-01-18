-- -------------------------------------
-- DBS311 - Fall 2021 - Lab 1 Solutions
-- Clint MacDonald
-- September 2021
-- -------------------------------------

-- preparation
UPDATE employees SET hire_date = hire_date + (20*365);
UPDATE job_history SET end_date = end_date + (20*365);
UPDATE job_history SET start_date = start_date + (20*365);

-- Question 1

-- fixes: Hire Date is not singular, needs to be hire_date
SELECT 
    last_name AS "Last Name", 
    job_id AS "Job Title", 
    hire_date AS "Job Start" 
FROM employees;

-- Question 2
/*  Display the employee_id, last name and salary of employees earning in the 
    range of $8,000 to $11,000.  Sort the output by top salaries first and then
    by last name.  
    Output the salary such that it “looks” like money 
    (i.e. with a $ and 2 decimal places). */
SELECT 
    employee_id AS "Emp ID", 
    last_name AS "Last Name", 
    to_char(salary, '$99,999.99') AS "Salary"
FROM employees
WHERE salary BETWEEN 8000 AND 11000
ORDER BY 
    salary DESC, 
    last_name;

-- Question 3
/*  Write the solution for question 2 again with the salary being in a 
    format appropriate to send to another software application. */
SELECT 
    employee_id AS EmpID, 
    last_name AS LastName, 
    salary              -- remove all formatting and leave it as a number
FROM employees
WHERE salary BETWEEN 8000 AND 11000
ORDER BY 
    salary DESC, 
    last_name;

-- Question 4
/*  Display the job titles and full names of employees whose first name 
    contains an ‘e’ or ‘E’ anywhere.  
    (BONUS MARK FOR NOT using the OR keyword in the solution but obtaining 
    the same results) */
SELECT 
    Job_id as "Job Title", 
    First_Name || ' ' || Last_Name AS "Full Name"
FROM employees
WHERE upper(first_name) LIKE '%E%';

-- Question 5
/*  Create a query to display the address of the various locations where 
    offices are located.  Add a parameter to the query such that the user 
    can enter all, or part of, the city name and all locations from the 
    resultant cities will be shown. */
SELECT 
    street_address, 
    city, 
    state_province, 
    postal_code, 
    country_id
FROM locations
WHERE upper(city) LIKE '%' || trim(upper('&CityName')) || '%'; --trim function will remove whitespaces

-- Question 6
/*  Write a query to display the tomorrow’s date in the following format:
        September 15th of year 2019
    the result will depend on the day when you RUN/EXECUTE this query.  
    Label the column “Tomorrow”. */
SELECT to_char(sysdate + 1, 'fmMonth ddth "of year" yyyy') AS "Tomorrow"  --fm format removes duplicate space. For example, June 17th of year 2022 would print out with extra spaces after June because September is the longest month. So we use fm to remove the whitespaces
FROM dual;
--sysdate uses the time in the server. currdate uses the time on the computer, which gives us different answers, depending on where the person running the code is. So sysdate would be better becaue the server is only in one place
-- Advanced BONUS answer
DEFINE today = sysdate;
SELECT  to_char(&today + 1,'Month') || ' ' 
        || to_char(&today+1,'Ddth') || ' of the year ' 
        || to_char(&today+1, 'YYYY') AS "Tomorrow" 
FROM dual;
UNDEFINE today;

-- Question 7
/*  For each employee in departments 20, 50 and 60 display last name, 
    first name, department name, salary, and salary increased by 4% and 
    expressed as a whole number.  Label the increased salary column 
    "Good Salary".  Also add a column that subtracts the old salary from the new
    salary and multiplies by 12. Label the column "Annual Pay Increase".
    Note: Salary in this database is stored as “Monthly Salary” – see column 
    descriptions in the database columns tab */
SELECT
    last_name AS "Last Name",
    first_name AS "First Name",
    salary AS "Salary",
    department_name,
    ROUND(salary * 1.04, 0) AS "Good Salary",
    (ROUND(salary * 1.04, 0) - salary) * 12 AS "Annual Pay Increase"
FROM 
    employees e
    JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id IN (20, 50, 60);

-- Question 8
/*  For each employee hired before 2014, display the employee’s last name, 
    hire date and calculate the number of YEARS between TODAY (not hard coded) 
    and the date the employee was hired.
        a.	Label the column Years worked. 
        b.	Order your results by the number of years employed.  Round the 
            number of years employed DOWN to the closest whole number. */
      
-- okay'ish answer: note 365 is NOT GOOD ENOUGH
SELECT
    last_name AS "Last Name", 
    hire_date AS "Hire Date",
    TRUNC(((sysdate-hire_date)/365.25),0) AS "Years Worked" -- i do not like 365
FROM employees
WHERE hire_date < to_date('20140101','yyyymmdd')
ORDER BY "Years Worked";
-- better more exact answer
SELECT  last_name AS "Last Name", 
        hire_date AS "Hire Date",
        TRUNC(months_between(sysdate,hire_date)/12,0) AS "Years Worked" -- TRUNC returns a date value
FROM employees
WHERE hire_date < to_date('20140101','yyyymmdd')
ORDER BY "Years Worked";

-- Question 9
/*  Create a query that displays the city names, country codes and state 
    province names, but only for those cities that starts with 'S' and has at 
    least 8 characters in their name. If city does not have a province name 
    assigned, then put 'Unknown Province'.  Be cautious of case sensitivity! */
SELECT
    city,
    country_id,
    NVL(state_province, 'Unknown Province') AS "Province" -- NVL Function works where if the value comes out to NULL, it will replace it with something that makes sense to a human
FROM locations                                             -- NVL2 Will replace the value whether or not it is NULL
WHERE 
    upper(city) LIKE 'S%' 
    AND length(city) >= 8;
    
-- Question 10
/*  Display each employee’s last name, hire date, and salary review date, which
    is the first Thursday after a year of service, but only for those hired 
    after 2017.  
        a.	Label the column REVIEW DAY. 
        b.	Format the dates to appear in the format like:
            WEDNESDAY, SEPTEMBER the Eighteenth of year 2019
    Sort by review date */
SELECT
    last_name,
    hire_date,
    to_char ( 
        next_day ( 
            add_months(hire_date,12), 'Thursday' 
            ) , 'fmDAY, MONTH "the" Ddspth "of year" yyyy' ) AS "Review Day" --ddspth will using First, Teenth, Eight for date
FROM employees
WHERE extract(year from hire_date) > 2017
ORDER BY hire_date; -- Order by hire_date, because review date is a string, and will make the first month April or August, as in the case with my answer
--ORDER BY 3 will order by the third column. Can sometimes cause a refactoring problem, if you make an update to the SELECT function and don't update ORDER BY, since now whatever you were sorting in the third column is now in the fourth column