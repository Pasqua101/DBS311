-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: November 8, 2022
-- Title: NII_Week9_DEMO_PLSQL_Continued.sql
-- PL/SQL Continued - Cursers and UDFs
-- ********************************************************

SET SERVEROUTPUT ON;

-- CURSORS
    -- Implicit and Explicit
    -- IMPLICIT
        -- already shown
        --SQL%ROWCOUNT is an example
            -- returns the # of rows effected by the previous SQL statement
        -- SQL%%FOUND -- boolean, if last statement effected at least one ...
        -- SQL%NOT FOUND -- boolean, opposite of FOUND
        -- plus more ...
        
    -- EXPLICIT CURSORS
        -- analogy would be an array of javascript objects
        -- ability to iteratre through multiple rows of data
        
-- example
-- output all employees with the letter M in their job title

--Creating it as a non-saved procedure (anonymous function)
DECLARE
    lName employees.last_name%TYPE;
    fName employees.first_name%TYPE;
    jTitle employees.job_id%TYPE;
    CURSOR c IS --Cursor is a data source, can be defined as an array, select statement, etc
        SELECT last_name, first_name, job_id
        FROM employees
        WHERE UPPER(job_id) LIKE '%M%'
        ORDER BY last_name, first_name;
BEGIN

    DBMS_OUTPUT.PUT_LINE(RPAD('-',40,'-'));
    OPEN c; -- Opens and executes the cursor
        LOOP
            FETCH c INTO lName, fName, jTitle; --FECTH is a command that states to Fetch (get) x amount of rows --Fetch grabs the next row in this loop
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(RPAD(fName, 15, ' ')
            || RPAD(lName, 15, ' ') || jTitle);
        END LOOP;
    CLOSE c; -- Anytime we explicitly open a cursor we must close it, since it is like a database connection. It will also finalize any transactions done

    DBMS_OUTPUT.PUT_LINE(RPAD('-',40,'-'));
END;

-- parameters
-- the cursor itself can recieve parameters
-- example: return all players with the given initials
DECLARE
--    player ROW; -- Declaring it as ROW can be kind of pointless and complex
    player players%ROWTYPE; --  So we use this instead, and it works like %TYPE. Except that the player variable will be the same as a row in the Players table
                --first letter -- last letter
    CURSOR pc ( fLetter CHAR, lLetter CHAR ) IS
        SELECT * FROM players 
        WHERE UPPER(firstname) LIKE UPPER(fLetter) || '%'
            AND UPPER(lastname) LIKE UPPER(lLetter) || '%'
        ORDER BY 
            lastname, firstname;
BEGIN

    DBMS_OUTPUT.PUT_LINE(RPAD('-',40,'-'));
    OPEN pc('C', 'M');
    LOOP
        FETCH pc INTO player;
        
        EXIT WHEN pc%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(RPAD(player.firstname, 15, ' ')
            || RPAD(player.lastname, 15, ' ') || player.regNumber);
    END LOOP;
    CLOSE pc;
    DBMS_OUTPUT.PUT_LINE(RPAD('-',40,'-'));
END;


--UDFs - User Defined Functions

CREATE OR REPLACE FUNCTION fncFindHigherNumber (
    num1 INT, num2 INT) RETURN INT IS
BEGIN
    IF num2 > num1
    THEN
        RETURN num2;
        
    ELSE 
        RETURN num1;
    END IF;
END fncFindHigherNumber;

-- use the function
BEGIN
    DBMS_OUTPUT.PUT_LINE(fncFindHigherNumber(12, 45));
    DBMS_OUTPUT.PUT_LINE(fncFindHigherNumber(36, 15));
    DBMS_OUTPUT.PUT_LINE(fncFindHigherNumber(10, 10));
    DBMS_OUTPUT.PUT_LINE(fncFindHigherNumber(09, 10));
END;

-- function using SQL

SELECT
    gameID,
    homescore,
    visitscore,
    fncFindHigherNumber(homescore, visitscore) AS higherScore
FROM games
ORDER BY gameID;

-- new examples
-- UDFs with SQL
--CREATE OR REPLACE FUNCTION fncMostGoalsInAGame
--    RETURN NUMBER IS
--    maxG
    
-- Functions with SQL Data

CREATE OR REPLACE FUNCTION fncGetPlayerData(pID INT)
    RETURN players%ROWTYPE IS
    pData players%ROWTYPE;
BEGIN
    SELECT * INTO pData
    FROM players
    WHERE playerID = PID;
    
    RETURN pData;
END fncGetPlayerData;

-- use this
DECLARE
    playData players%ROWTYPE;
BEGIN
    playData := fncGetPlayerData(1303);
    
    DBMS_OUTPUT.PUT_LINE('Player: ' ||
    playData.firstname
    || ' ' || playData.lastName || '-' || playData.regNumber);
END;