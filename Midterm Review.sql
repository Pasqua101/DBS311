
-- Week 3
-- Aggregation function
-- COUNT()
SELECT COUNT(playerID) AS numPlayers FROM players; -- Counts the number of rows in the player table. Should produce a unique list as playerid is a primary key, so there is no need for the DISTINCT, in other cases there may be the need for it 

--SUM()
SELECT SUM(salary) FROM employees; -- returns the sum of all salaries rows in the table
-- to format it as actually dollar value, we use to_char()
SELECT TO_CHAR(SUM(salary), '$999,999.00') AS TotalSalary FROM employees;

--MIN()
SELECT MIN(salary) FROM employees; --Returns the lowest earning employee from the table

--MAX()
SELECT MAX(salary) FROM employees; --Returns the highest earning employee from the table

--AVG()
SELECT AVG(salary) FROM employees; -- Returns the average of all salaries
-- Also STDDEV() and VARIANCE()
--VARIANCE()
--Variance is equal to the square of the standard deviation. It shows the spread or variation of a group of numbers in a sample.
SELECT VARIANCE(salary)
FROM employees;

--STDDEV()
--Returns cumulative standard deviation of the salaries
SELECT STDDEV(salary)
FROM employees
--GROUP BY
--How many players are on each team
SELECT
    teamName,
    COUNT(p.playerID) AS NumPlayers
FROM players p
JOIN rosters r ON p.playerID = r.playerID
JOIN teams t ON r.teamID = t.teamID
GROUP BY teamName;
-- NOTE: Remember Clint's Law, any field in the SELECT clause that is not part of an aggregrate function, like COUNT(), must be in the GROUP BY

-- Week 4
-- SUB-OR Nested Queries

--Types of queries results
-- Table - returns at least 1 column and x amount of rows
-- List - returns exactly 1 column and x amount of rows
-- Scalar - returns only 1 column and one row

-- Example of Tables
SELECT * FROM employees;

SELECT 
    last_name, 
    first_name
FROM employees;

SELECT employee_id, first_name, last_name 
FROM employees 
WHERE lower(last_name) LIKE 'jones' AND lower(first_name) LIKE 'andrew';

--Examples of lists
SELECT employee_ID FROM  employees;
SELECT last_name FROM employees;
SELECT employee_id
FROM employees
WHERE lower(last_name) LIKE 'pasqua' AND lower(first_name) like 'marco';


--Example of Scalar
SELECT COUNT(employee_id)
FROM employees;

SELECT MAX(salary) FROM employees;

SELECT teamName
FROM teams
WHERE teamID = 210;

-- Inserting sub-qeuries
-- Any of the above work in a FROM clause
-- Placing a sub-query after an '=' will require scalar query
-- Placing a sub-querit within an IN() will accept a LIST query. IN() requries a comman separated list i.e. IN ( (3,4), (5,6), (7,3), (-2,8) );

--Example
-- List all employees who work in the city of Seattle NO JOINS

--Step 1
SELECT location_id
FROM locations
WHERE lower(city) = 'seattle';
-- let us say this query return the value of 1700
-- it must also be noted that although we only got 1 result, it is possible to get more than one, 
--     so this must be considered a list query and not a scalar Query

-- Step 2
SELECT department_id
FROM departments
WHERE location_id IN (1700);
-- note that we used IN rather than =, because the previous query may have produced more than one value
-- we might get results like 10, 90, 110, 190
-- Step 3
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (10, 90, 110, 190);
-- Since it took us 3 queries to find this answer, lets shorten it down

-- first we will replace 'Seattle' from Step 1 above with a parameter
SELECT location_id
FROM locations
WHERE lower(city) LIKE '%' || TRIM(lower(&cityInput)) || '%';
-- this allows us to find the location_ids from any city typed in by a user.
SELECT department_id
FROM departments
WHERE location_id IN (
    SELECT location_id 
    FROM locations 
    WHERE lower(city) LIKE '%' || TRIM(lower(&cityInput)) || '%'
 );
 -- Now we take step 3 and replace the hard coded values with the query above that would produce those values anyways
 SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id IN (
        SELECT location_id 
        FROM locations 
        WHERE lower(city) LIKE '%' || TRIM(lower(&cityInput)) || '%'
        )
    );
    
SELECT
    first_name,
    last_name,
    (   SELECT department_name
        FROM departments
        WHERE department_id = e.department_id )
FROM employees e
ORDER BY last_name, first_name;


-- Lab 3 Practice Questions
-- Question 4 Display the last names of all employess in the same department as Abel
SELECT
    last_name,
    department_id
FROM employees
WHERE department_id IN ( --Clause inside of IN() will return the deartment_id of the employeee with the last of Abel. Using = instead of IN would work, but if there is another employee with the last name of abel, this will not work
    SELECT department_id
    FROM employees
    WHERE UPPER(last_name) LIKE 'ABEL'
    );

-- Question 5: Display the last name of the lowest paid employees
SELECT
    last_name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);

-- Question 6 Display the city the lowest paid employee(s) are in
SELECT DISTINCT
    city
FROM locations
WHERE location_id IN (
    SELECT location_id 
    FROM departments
    WHERE department_id IN (
        SELECT department_id
        FROM employees
        WHERE salary = ( --Could use IN or = on this line
            SELECT MIN(salary)
            FROM employees
        )
    )
);

-- Question 7 
--Not the proper method below as it does not return all results, but still somewhat works
SELECT
    last_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE salary IN (
    SELECT MIN(salary)
    FROM employees)
    )
ORDER BY
    department_id;
    
--Proper method
SELECT
    last_name,
    department_id,
    salary
FROM employees
WHERE (department_id, salary) IN (
    SELECT 
        department_id, --No alias are required here as what comes first overwrites the column names
        MIN(salary)
    FROM employees
    GROUP BY department_id
    )
ORDER BY
    department_id;
    
-- Question 8
SELECT
    last_name,
    t1.city,
    t1.salary
FROM (
    SELECT 
        last_name,
        city,
        salary
    FROM employees e 
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    ) t1 JOIN (
    SELECT 
        city,
        MIN(salary) AS MinSal
    FROM (
			SELECT last_name, city, salary
            FROM employees e JOIN departments d ON e.department_id = d.department_id 
				JOIN locations l ON l.location_id = d.location_id
			)
        GROUP BY city
        )t2 ON (t1.city = t2.city AND t1.salary = t2.MinSal);

-- Lab 4 SET operators review

-- Question 1 
SELECT department_id
FROM employees
MINUS
SELECT department_id
FROM employees
WHERE UPPER(job_id) = 'ST_CLERK';

-- Question 2
SELECT 
    country_id,
    country_name
FROM countries
MINUS
SELECT
    l.country_id,
    c.country_name
FROM locations l 
JOIN countries c ON l.country_id = c.country_id
JOIN departments d ON l.location_id = d.location_id;
-- without join

SELECT
    country_id,
    country_name
FROM countries
MINUS
SELECT 
    country_id,
    country_name
FROM countries
WHERE country_id IN (
    SELECT country_id
    FROM locations
    WHERE location_id IN (
        SELECT location_id
        FROM  departments
        )
    );
    

SELECT DISTINCT -- USING DISTINCT TO REMOVE duplicates
    job_id,
    department_id
FROM employees
WHERE department_id = 10

UNION ALL -- Union all to keep all similarities, and to make sure that they output as specified

SELECT DISTINCT
    job_id,
    department_id
FROM employees
WHERE department_id = 50

UNION ALL

SELECT DISTINCT
    job_id,
    department_id
FROM employees
WHERE department_id = 20;

-- Question 4
SELECT
    employee_id,
    job_id
FROM employees

INTERSECT

SELECT 
    e.employee_id,
    e.job_id
FROM employees e
JOIN job_history jh ON e.job_id = jh.job_id;

--Question 5
SELECT
    last_name,
    department_id,
    TO_CHAR(NULL) AS DepartmentName -- NOTE: First results are the column names query outputs, we can bypass if a column is missing a name than another one by using NULL and making an alias
FROM employees

UNION
SELECT
    TO_CHAR(NULL),
    department_id,
    department_name
FROM departments;


--Lab 2 review 
--Question 1
SELECT
    TO_CHAR(
    ROUND(
            AVG(salary + salary * NVL(commission_pct, 0)) -
            MIN(salary + salary * NVL(commission_pct, 0))
        , 2)
    , '$999,999.00') AS "Real Amount"
FROM employees

--Question 2
SELECT  
	department_ID AS "Dept ID",
	to_char(max(salary + salary * nvl(commission_pct,0)), '$99,999.99') AS "High",
	to_char(min(salary + salary * nvl(commission_pct,0)), '$99,999.99') AS "Low",
	to_char(avg(salary + salary * nvl(commission_pct,0)), '$99,999.99') AS "Avg"
FROM employees
GROUP BY department_id
ORDER BY round(avg(salary + salary * nvl(commission_pct,0)),2) DESC;  
	-- note, do not sort using the alias as it is now a string
-- Question 3
SELECT
    department_id AS "Dept#",
    job_id AS "Job",
    COUNT(employee_id) AS "How Many"
FROM employees
GROUP BY
    department_id,
    job_id
HAVING COUNT(employee_id) > 1
ORDER BY
    "How Many" DESC;

-- Question 4
SELECT
	job_id,
    SUM(salary + salary * nvl(commission_pct,0)) AS AmountPaid
FROM employees
WHERE upper(job_id) NOT IN ('AD_PRES','AD_VP')
GROUP BY job_id
HAVING SUM(salary + salary * nvl(commission_pct,0)) > 11000
ORDER BY AmountPaid DESC;

--Question 5
SELECT
    manager_id,
    COUNT(employee_id) AS "numOfEmps" --Not having an alias name couls cause problems with the Group By clause
FROM employees
WHERE manager_id NOT IN (100,101,102) 
GROUP BY manager_id
HAVING COUNT(employee_id) > 2
ORDER BY "numOfEmps" DESC;
    
-- Question 6
SELECT
    department_id,
    MAX(hire_date) AS lastHireDate,
    MIN(hire_date) AS earliestHireDate
FROM employees
WHERE department_id NOT IN (10, 20)
GROUP BY
    department_id
HAVING 

-- lab 3 again
-- question 1
SELECT 
    last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE UPPER(last_name) IN 'ABEL'
    );

--Question 2
SELECT 
    last_name,
    salary
FROM employees
WHERE salary IN (
    SELECT MIN(salary)
    FROM employees
);

--Question 3
SELECT DISTINCT
    city
FROM locations l
    JOIN departments d on l.location_id = d.location_id
    JOIN employees e on d.department_id = e.department_id
WHERE e.salary IN (
    SELECT MIN(salary)
    FROM employees);

-- Question 4
SELECT
    last_name,
    department_id,
    salary
FROM employees
WHERE (department_id, salary) IN (
    SELECT 
        department_id,
        MIN(salary)
    FROM employees
    GROUP BY department_id
    )

-- Question 5
SELECT
    last_name
FROM employees
WHERE salary IN (
    SELECT MIN(salary)
    FROM employees
    WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id IN (
    SELECT location_id
    FROM locations)
    )
    );

--Question 9
SELECT
    last_name,
    department_id,
    salary
FROM employees
WHERE salary < ANY ( 
    SELECT MIN(salary)
    FROM employees
    GROUP BY department_id
);

-- Question 10
SELECT
    last_name,
    job_id,
    salary
FROM employees
WHERE salary = ANY (
    SELECT salary
    FROM employees
    WHERE UPPER(job_ID) IN ('IT_PROG'));
    
-- LAB 4  again
-- q1
SELECT department_id
FROM employees
MINUS
SELECT department_id
FROM employees
WHERE UPPER(job_id) = 'ST_CLERK'

-- q2
SELECT 
    country_id,
    country_name
FROM countries
MINUS
SELECT 
    c.country_id,
    c.country_name
FROM countries c
INNER JOIN locations l ON c.country_id = l.country_id
INNER JOIN departments d ON l.location_id = d.location_id;

--q3
SELECT DISTINCT
    department_id,
    job_id
FROM employees
WHERE department_id = 10
UNION ALL 
SELECT DISTINCT
    department_id,
    job_id
FROM employees
WHERE department_id = 50
UNION ALL
SELECT DISTINCT
    department_id,
    job_id
FROM employees
WHERE department_id = 20

SELECT
    employee_id,
    job_id
FROM employees

INTERSECT
SELECT
    employee_id,
    job_id
FROM job_history;

-- question 5
SELECT
    last_name,
    department_id,
    TO_CHAR(NULL) AS DepartmentName
FROM employees
UNION 
SELECT
    TO_CHAR(null),
    department_id,
    department_name
FROM departments;

