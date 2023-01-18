-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Sept 27, 2022
-- Title: NII_Week4 
-- Sub-Queries or Nested Queries
-- ********************************************************
-- Notes on soccer league database tables
-- These tables are
-- Players
-- Rosters
-- SLlocations
-- Teams
-- TeamsIndivs
-- games
-- goalscorers

--isActive filed in slListLocations is not the same as isActive in slListDivisions and in slPlayers and teams
-- In players it is used to see if a player is still apart of the league or not
--isActive in JncRoser is to see if a player is still active on a team
-- Teams isActive field is use to see if a team isactive or not
-- Overall, DO NOT JOIN THESE FIELDS THEY ARE NOT THE SAME

---------------------------------------------------------------


-- Type of queries
-- TABULAR - returns a table with columns and rows
-- LIST - returns a SINGLE column - non, one, or more rows
-- SCALAR - returns ONE value (one column, one row) - Guaranteed

-- TABLUAR
SELECT * FROM employees;

-- LIST
SELECT employee_id FROM employees;

-- Scalar
SELECT COUNT(employee_id) FROM employees;

--be careful
SELECT department_id
FROM departments
WHERE location_id = 1800;
-- Code above looks like a scalar, but it is not. It is in fact a list. Since it is not guaranteed to be a single row, like how the code below outputs more than 1 row
SELECT department_id
FROM departments
WHERE location_id = 1700;
-- So it is really a list, because it is not Guaranteed to be a single row
SELECT city
FROM locations
WHERE location_id = 1700;
-- If we use a primary key it will guarentee use a single row. So the code above is scalar. However, if we were to use a foriegn key like department_id it is a list

-- why does it matter
-- if you have an = sign, the right side of it MUST be a scalar
-- if you have an IN() function, the brackets contain a list
--          WHERE location_id IN (10, 20, 50, 60)
-- A sub-query in the SELECT statement MIGHT have to be scalar

-- example
-- What was the most number of goals scored in a single game?
SELECT MAX(numGoals)
FROM goalScorers;
-- but who scored it? How many times has it happened?
SELECT playerID
FROM goalScorers
WHERE numGoals = 5; -- HARD CODED. If someone scores 6 goals tomorrow than this statement would be invalid
-- I can avoid this by nesting queries
SELECT playerID
FROM goalScorers
WHERE numGoals = (
    SELECT MAX(numGoals) 
    FROM goalScorers
    );
-- This statement above is scalar
-- now what about the names of the players (NO JOINS)
SELECT
    firstname,
    lastname
FROM players
WHERE playerid IN ( --Can't have to scalars so we must use IN
    SELECT playerid
    FROM goalScorers
    WHERE numgoals = (
        SELECT MAX(numGoals)
        FROM goalScorers
        )
    );
    
-- Example 2
-- without using JOINS, list all the employees who work in Seattle
-- Note for quizzes: If the question does not specify how to solve it should use JOINS most of the time for splicity
SELECT location_id
FROM locations
WHERE UPPER(city) = 'SEATTLE';
-- then departments
SELECT department_id
FROM departments
WHERE location_ID IN (
    SELECT location_id
    FROM locations
    WHERE UPPER(city) = 'SEATTLE'
    );
-- who works in those department 
SELECT
    first_name,
    last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_ID IN (
        SELECT location_id
        FROM locations
        WHERE UPPER(city) = 'SEATTLE'
        )
    );
-- let's filter this by only return employees whose first name starts with S
SELECT
    first_name,
    last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_ID IN (
        SELECT location_id
        FROM locations
        WHERE UPPER(city) = 'SEATTLE'
        )
    )
    AND lower(first_name) LIKE 's%';

-- Example 3
-- Select in the SELECT clause

-- return a list of emplouyees and the name of their department (NO JOINS)
SELECT
    first_name,
    last_name,
    department_id,
    department_name
FROM employees;
--error, you can use a sub-select to get this name
SELECT
    first_name,
    last_name,
    department_id,
    (   SELECT department_name -- can not place another column here. It can only return 1 value
        FROM departments
        WHERE department_id = e.department_id) AS deptName
FROM employees e
ORDER BY last_name;
--sub-queries areregarded as ineffiencent since each nested statement works as a loop and can run 10 times in this case

-- so let's use this by doing some random thing 
-- find employee's with department nme whose first name contains an I

SELECT
    first_name,
    last_name,
    department_id,
    (   SELECT department_name -- can not place another column here. It can only return 1 value
        FROM departments
        WHERE department_id = e.department_id) AS deptName
FROM employees e
WHERE UPPER(first_name) LIKE '%I%'
ORDER BY last_name;

--Another way is to leave the query alone
SELECT
    first_name,
    last_name,
    deptName
FROM (
    SELECT
        first_name,
        last_name,
        department_id,
        (   SELECT department_name -- can not place another column here. It can only return 1 value
            FROM departments
            WHERE department_id = e.department_id) AS deptName
    FROM employees e
    ORDER BY last_name) T
WHERE UPPER (first_name) LIke '%I%'
;

--But what is even better is to save the query as a view
CREATE VIEW vmEmpDeptNames AS
    SELECT
        first_name,
        last_name,
        department_id,
    (   SELECT department_name -- can not place another column here. It can only return 1 value
        FROM departments
        WHERE department_id = e.department_id) AS deptName
FROM employees e;

SELECT
    first_name,
    last_name,
    department_id
FROM vmEmpDeptNames
WHERE UPPER(first_name) LIKE '%I%';

--Notes for lab
-- Question 8 requires joins and subqueris
-- Question 6 and 7, could be used with joins and sub-queries for easier answers. But can not use joins at all
--Questions 1,2,5, 9 and 10 required no JOINS