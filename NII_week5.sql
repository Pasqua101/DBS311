-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Oct 4, 2022
-- Title: NII_week3.sql
-- ********************************************************
-- Topics: SETS and SEQUENCES

/*
SETS and SEQUENCES

    Let A  = { 1,2,5,8,9 }
    let B = { 2,4,6,8,10 }
    
    A U B = { 1,2,4,5,6,8,9,10 } -> equivalent of UNION ALL
          = { 1,1,2,3,4,5,6,7,8,8,9 } -> Sorts first - by PK
          = { 1,2,3,4,5,6,7,8,9 } -> Eliminates duplicates --Much more effiencent to sort then eliminate duplicates, not get the duplicates and then eliminate
    A ? B = { 2,8 }
    A - B = { 1,5,9 }

in SQL  we have the equivalent

UNION
UNION ALL
INTERSECT
MINUS (SUBTRACT in SQL Server)
    
    

*/


-- example 
-- list all employees who's first name starts wil 'S'
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%';
-- List all employees who's last name starts with 'H'
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'H%';
--What if I want to show BOTH
SELECT * FROM employees
WHERE 
    UPPER(first_name) LIKE 'S%'
    OR UPPER(last_name) LIKE 'H%' ;
-- NOTE: Shelley only appears once
-- NOTE: pay attention to the ORDER in which the results display
SELECT * FROM employees
WHERE 
    UPPER(first_name) LIKE 'T%'
    OR UPPER(last_name) LIKE 'H%' ;
-- Sorted in the same manor as they are in the db table itself
--We can use set operators
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%'
UNION
SELECT * FROM employees
WHERE UPPER(last_name) LIKE 'H%';
-- NOTE: Duplicates are removed
-- NOTE: The data is SORTED BY PK
--UNION eliminates duplicates and sorted by PK

-- If we did NOT want duplicates removed
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%'
UNION ALL --UNION ALL takes results of the first select statement and outputs it, and put the output for the next select statment underneath it. That's how the duplicates are shown
SELECT * FROM employees
WHERE UPPER(last_name) LIKE 'H%';
-- UNION ALL does NOT eliminate duplicates and DOES NOT sort

/*-- REAL WORLD EXAMPLE
    -- We are holding an event at SENECA and we want to invite everyone from the community
    -- do not send multiple invites to the same person
-- Could use
-- SELECT * FROM students
-- SELECT * FROM faculty
-- SELECT * FROM employees

-- Problem is that some people belong to more than one of those groups

SELECT * FROM students
UNION
SELECT * FROM faculty
UNION
SELECT * FROM employees
-- still does not work because of the * - some fields will sti;; be different in the 3 table
SELECT studentID FROM students
UNION
SELECT facultyID FROM faculty
UNION
SELECT employeeID FROM employees

--list all people whom are in more than one categorey
SELECT 
    pID,
    COUNT(pID) --pID is person ID, all 3 tables in the example are linked to the person table
FROM(
    SELECT studentID FROM students
    UNION ALL
    SELECT facultyID FROM faculty
    UNION ALL
    SELECT employeeID FROM employees
    )
GROUP BY pID
HAVING COUNT (pID) > 1;


*/
-- new example
-- back to the previous example
-- show those whom meet BOTH criteria only
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%'
INTERSECT --INTERSECT can be used for different tables
SELECT * FROM employees
WHERE UPPER(last_name) LIKE 'H%';
-- is equivalent to
SELECT * FROM employees
WHERE 
    UPPER(first_name) LIKE 'S%'
    AND UPPER(last_name) LIKE 'H%';
    
/*
Back to faculty example
List all pepople in ALL three categories

SELECT pID FROM (
    SELECT studentID AS pID FROM students
    INTERSECT
    SELECT facultyID FROM faculty
    INTERSECT
    SELECT employeeID FROM employees
    );
    
-- What if we wanted names
-- multiple columns
SELECT pID, firstName, lastName FROM (
    SELECT studentID  AS pID , firstName, lName AS LastNaemFROM students --If a table has differnt values, we use an alias, such as here since the first select determines what the column name is
    INTERSECT
    SELECT facultyID, firstName, NULL FROM faculty --If there is no lastName, we can use NULL and it will macth it as lastName. We could even do this in the first select, but there must be an alias. i.e. NULL as firstName
    INTERSECT
    SELECT employeeID, NULL, lastName FROM employees --If there is no firstName, we can use NULL and it will match it as firstName
    );
*/
-- MINUS
-- Show all employees whose first name starts with 'S'
--  but their last name does NOT start with 'H'
SELECT * FROM employees
WHERE
    UPPER(first_name) LIKE 'S%'
    AND NOT UPPER(last_name) LIKE 'H%';
--using SET operator
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%'
MINUS
SELECT * FROM employees
WHERE UPPER(last_name) LIKE 'H%';
-- this allows you to remove records from the first set,
-- that match a second criteria


-- example
-- show those that match one criteria OR the other, but not both
    SELECT * FROM employees
    WHERE UPPER(first_name) LIKE 'S%'
    UNION
    SELECT * FROM employees
    WHERE UPPER(last_name) LIKE 'H%'
    
    MINUS
    (
    SELECT * FROM employees
    WHERE UPPER(first_name) LIKE 'S%'
    INTERSECT
    SELECT * FROM employees
    WHERE UPPER(last_name) LIKE 'H%');
    
-- what about sorting
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'S%'
UNION ALL
SELECT * FROM employees
WHERE UPPER(first_name) LIKE 'H%'
ORDER BY last_name;
-- causes an error when sorting with a set operator
SELECT first_name, last_name FROM employees
WHERE UPPER(first_name) LIKE 'S%'
UNION ALL
SELECT first_name, last_name  FROM employees
WHERE UPPER(first_name) LIKE 'H%'
ORDER BY last_name;
-- reason for the error is because we were using *, which is bad practice. refer to naming the columns
-- ORDERING IS NOT allowed in SET operators
-- so this order by is not in the SET operator, it is AFTER the SET operator
-- better way to do it
SELECT * FROM
    (
    SELECT first_name, last_name FROM employees
    WHERE UPPER(first_name) LIKE 'S%'
    UNION ALL
    SELECT first_name, last_name  FROM employees
    WHERE UPPER(first_name) LIKE 'H%'
    )
ORDER BY last_name;


-- example
-- Question: ????? List all players with duplicate names... meaning they might be dupliate player entries

SELECT
    lastname,
    firstname,
    COUNT(playerID) AS numPlayers
FROM players
GROUP BY
    last_name,
    first_name
HAVING COUNT(playerID) > 1
ORDER BY numplayers DESC;


-- Description of sports table
--Getting the total sum o feach game won
    --See how many games a home team won
SELECT 
    TheTeamID,
    (SELECT teamName FROM teams WHERE teamID = TheTeamID) AS TeamName,
    SUM(GamesPlayed) AS GP,
    SUM(Wins) AS W,
    SUM(Losses) AS L,
    SUM(Ties) AS T,
    SUM(GoalsFor) AS GF,
    SUM(GoalsAgainst) AS GA,
    SUM(GoalsFor) - SUM(GoalsAgainst) AS GD,
    SUM(Wins) * 3 + SUM(Ties) * 1 AS PTS
FROM( --Using the resulting table that we get from FROM statement as the next datasource
    SELECT
        hometeam AS TheTeamID,
        COUNT(gameID) AS GamesPlayed,
        SUM(homescore) AS GoalsFor,
        SUM(visitscore)AS GoalsAgainst,
        SUM( 
            CASE
                WHEN homescore < visitscore THEN 1 
                ELSE 0
                END
            ) AS Losses,
        SUM(
            CASE
                WHEN homescore = visitscore THEN 1 
                ELSE 0
                END
            ) AS Ties,
        SUM(
            CASE
                WHEN homescore > visitscore THEN 1 
                ELSE 0
                END
            ) AS Wins
    FROM games
    WHERE isplayed = 1
    GROUP BY
        hometeam
    
    UNION ALL
        
    --See how many games a visiting team won
    SELECT
        visitteam AS TheTeamID,
        COUNT(gameID) AS GamesPlayed,
        SUM(homescore) AS GoalsFor,
        SUM(visitscore)AS GoalsAgainst,
        SUM( 
            CASE
                WHEN homescore > visitscore THEN 1 
                ELSE 0
                END
            ) AS Losses,
        SUM(
            CASE
                WHEN homescore = visitscore THEN 1 
                ELSE 0
                END
            ) AS Ties,
        SUM(
            CASE
                WHEN homescore < visitscore THEN 1 
                ELSE 0
                END
            ) AS Wins
    FROM games
    WHERE isplayed = 1
    GROUP BY
        visitteam
)
GROUP BY
    TheTeamID
ORDER BY
    PTS desc;
    
