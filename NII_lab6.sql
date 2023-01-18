-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Nov 13, 2022
-- Title: NII_lab6.sql
-- PL/SQL part 2
-- ********************************************************

SET SERVEROUTPUT ON;

-- Q1
CREATE OR REPLACE FUNCTION fncCalcFactorial(
    n IN INT
)RETURN INT IS
BEGIN
DECLARE
    factorial INT := 1;
    temp INT := n;
BEGIN
    WHILE temp > 0 LOOP
    factorial := temp* factorial;
    temp:= temp - 1;
    END LOOP;
    
     
    RETURN factorial;
END;
END fncCalcFactorial;
--Execute it
DECLARE
    fac INT := 0;
BEGIN
        fac := fncCalcFactorial(5);
        DBMS_OUTPUT.PUT_LINE('The factorial of 5 ' || ' is ' || fac);
        fac := fncCalcFactorial(10);
        DBMS_OUTPUT.PUT_LINE('The factorial of 10 ' || ' is ' || fac);
        fac := fncCalcFactorial(15);
        DBMS_OUTPUT.PUT_LINE('The factorial of 15 ' || ' is ' || fac);
END;

--Q2
CREATE OR REPLACE PROCEDURE spCalcCurrentSalary(
    empID IN employees.employee_id%TYPE
) AS
BEGIN 
DECLARE
fName employees.first_name%TYPE;
lName employees.last_name%TYPE;
hiredt employees.hire_date%TYPE;
annualSalary employees.salary%TYPE;
vacationWeeks INT := 2; --Each employee starts with 2 weeks of vacation

yearsWorked INT := 0;
loopRunTime INT :=0;
BEGIN

    SELECT
        first_name,
        last_name,
        hire_date,
        FLOOR(MONTHS_BETWEEN(sysdate, hire_date) / 12),
        salary *12 INTO
        fName, 
        lName, 
        hiredt, 
        yearsWorked,
        annualSalary 
    FROM
        employees
    WHERE
        employee_id = empID;
    
    WHILE loopRunTime != yearsWorked
    LOOP 
        IF loopRunTime >= 1
            THEN
            annualSalary :=  annualSalary * 1.04;
        END IF;
        -- Using MOD to see if it's been 3 years since the employee started to work. i.e if the loop has run twice, 
        -- that means it's been 2 years since the employee worked. The code in the IF will not be used. However, if the loop has ran 3 time, MOD returns 0 and will use the logic in the IF statement
        IF vacationWeeks != 6  AND (MOD(loopRunTime, 3) = 0) 
            THEN 
                vacationWeeks:= vacationWeeks + 1;
        END IF;
        loopRunTime := loopRunTime + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('First Name: ' || fName);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || lName);
    DBMS_OUTPUT.PUT_LINE('Hire Date: ' || TO_CHAR(hiredt, 'Mon. DD, YYYY'));
    DBMS_OUTPUT.PUT_LINE('Salary: ' || TO_CHAR(annualSalary , '$999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Vacation Weeks: ' || vacationWeeks);
EXCEPTION
WHEN TOO_MANY_ROWS
    THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: There is more than 1 employee with the id of ' || empID); 
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Employee #' || empID || ' could not be found');
WHEN OTHERS
    THEN
        DBMS_OUTPUT.PUT_LINE('An error occred');
END;
END spCalcCurrentSalary;

BEGIN
    
    spCalcCurrentSalary(100);
    DBMS_OUTPUT.PUT_LINE('');
    spCalcCurrentSalary(0);
    DBMS_OUTPUT.PUT_LINE('');
    spCalcCurrentSalary(101);
    DBMS_OUTPUT.PUT_LINE('');
    
END;

--Q3
CREATE OR REPLACE PROCEDURE spDepartmentsReport
AS
BEGIN
DECLARE
    deptID departments.department_id%TYPE;
    deptName departments.department_name%TYPE;
    cityName locations.city%TYPE;
    empRow employees%ROWTYPE;
    numEmp INT :=0;
    CURSOR report IS
    
    SELECT
        d.department_id,
        d.department_name,
        l.city,
        COUNT(e.employee_id) 
    FROM employees e
    RIGHT OUTER JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    GROUP BY
        d.department_id,
        d.department_name,
        l.city;
BEGIN
    OPEN report;
    DBMS_OUTPUT.PUT_LINE(LPAD('DeptID', 6) ||' ' || RPAD('Department', 15) ||  RPAD('City', 20) || LPAD('NumEmp', 10));
        LOOP
            FETCH report INTO deptID, deptName, cityName, numEmp;
            IF report%FOUND
                THEN
                
                DBMS_OUTPUT.PUT_LINE(LPAD(deptID, 6) || ' ' || RPAD(deptName, 15) || RPAD(cityName, 20) || LPAD(numEmp, 10));
            ELSE
                EXIT;
            END IF;
        END LOOP;
    
    CLOSE report;
EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Could not find any information'); 
WHEN OTHERS
    THEN
        DBMS_OUTPUT.PUT_LINE('An error occured'); 
END;
END spDepartmentsReport;

BEGIN
    spDepartmentsReport;
END;


-- Q4 a.

CREATE OR REPLACE FUNCTION spDetermineWinningTeam(
    matchID IN games.gameID%TYPE
) RETURN INT IS
BEGIN
DECLARE
    datePlayed games.gamedatetime%TYPE;
    matchPlayed games.isplayed%TYPE;
    l_homeScore games.homescore%TYPE; --Used l_ to show it's a local variable in case the program gets confused
    awayScore games.visitscore%TYPE;
    homeID games.hometeam%TYPE;
    awayID games.visitteam%TYPE;
BEGIN

SELECT
    gamedatetime,
    isplayed,
    homescore,
    visitscore,
    hometeam,
    visitteam INTO
    datePlayed,
    matchPlayed,
    l_homeScore,
    awayScore,
    homeID,
    awayID
FROM games
WHERE gameID = matchID;

IF matchplayed = 0
    THEN
        RETURN -1;
ELSE
    IF l_homeScore > awayScore --Home team won
        THEN
            RETURN homeID;

    ELSE IF l_homeScore < awayScore -- visiting team wonb
        THEN 
            RETURN awayID;
    ELSE IF l_homeScore = awayScore --if both teams tied
        THEN
            RETURN 0;
    END IF;
    END IF;
    END IF;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Could not find a match with that ID');
WHEN TOO_MANY_ROWS
    THEN
        DBMS_OUTPUT.PUT_LINE('More than one match was found with the same ID');
WHEN OTHERS
    THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred');
END;
END spDetermineWinningTeam;

--Executing it
DECLARE
    retVal INT :=&findGame;
BEGIN
    retVal := spDetermineWinningTeam(retVal);
    IF retVal = 0
        THEN
            DBMS_OUTPUT.PUT_LINE('Both Teams tied');
    ELSE IF retVal = -1
        THEN
            DBMS_OUTPUT.PUT_LINE('That game has not been played yet');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The winning team was ' || retVal);
    END IF;
END IF;

END;

-- Q4 b.
--DECLARE
--    gamesWon INT := 0;
--    retVal INT :=0;
--BEGIN
SELECT
    teamid,
    gameid,
    CASE 
        WHEN spDetermineWinningTeam(gameid) = -1 
        THEN null
        WHEN spDetermineWinningTeam(gameid) = 0
        THEN null
        ELSE 
            spDetermineWinningTeam(gameid)
            
    END AS gamesWon
FROM teams t
JOIN games g ON t.teamid in g.hometeam
GROUP BY
    teamid,
    hometeam,
    visitteam,
    gameid;
--END;

    