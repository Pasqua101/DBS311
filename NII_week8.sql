-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: November 1, 2022
-- Title: NII_week8.sql
-- Introduction to PL/SQL
-- ********************************************************

--Must always execute this line whenever opening SQL dev
SET SERVEROUTPUT ON;

-- parameters with same name as the field
CREATE OR REPLACE PROCEDURE spInsertPeople2 (
    firstName VARCHAR2,
    lastName VARCHAR2,
    DOB date,
    isActive NUMERIC,
    favNum INT
) AS 
BEGIN
    INSERT INTO xPeople p ( 
        p.firstName, p.lastName, p.dob, p.isactive, p.favNum)
    VALUES (firstName, lastName, DOB, isActive, favNum);
    DBMS_OUTPUT.PUT_LINE('Insert Successful');
EXCEPTION --EXCEPTIONS must be in every procedure
    WHEN OTHERS -- When others is like an else statement. Last one to go after all other exceptions
        THEN
            DBMS_OUTPUT.PUT_LINE('An error occured!');
END spInsertPeople2; --Optional to put the name of the procedure at the end, but can leave it there to help make it make sense

CREATE OR REPLACE PROCEDURE spInsertPeople3 (
    firstName VARCHAR2,
    lastName VARCHAR2,
    DOB date,
    isActive IN NUMERIC, --IN declares it as an input variable
    favNum IN INT,
    peepID OUT INT -- OUT declares it as an output variable
) AS 
BEGIN
    INSERT INTO xPeople p ( 
        p.firstName, p.lastName, p.dob, p.isactive, p.favNum)
    VALUES (firstName, lastName, DOB, isActive, favNum);
    
    SELECT pID INTO peepID
    FROM xPeople
    WHERE rowNum = 1
    ORDER BY pID DESC;
    DBMS_OUTPUT.PUT_LINE('Insert Successful');
EXCEPTION --EXCEPTIONS must be in every procedure
    WHEN OTHERS -- When others is like an else statement. Last one to go after all other exceptions
        THEN
            DBMS_OUTPUT.PUT_LINE('An error occured!');
END spInsertPeople3; --Optional to put the name of the procedure at the end, but can leave it there to help make it make sense



DECLARE 
    NewPeepID INT := 0; --Declaring a variable named NewPepID and giving a value of 0
BEGIN
    spInsertPeople3('Ruth', 'Marks',sysdate, 1,4, NewPeepID);
    DBMS_OUTPUT.PUT_LINE('New PeepID: ' || NewPeepID);
END;


CREATE OR REPLACE PROCEDURE spInsertPeople4 (
    firstName VARCHAR2,
    lastName VARCHAR2,
    DOB date,
    isActive IN NUMERIC, --IN declares it as an input variable
    favNum IN INT,
    peepID OUT INT, -- OUT declares it as an output variable
    NumPeeps OUT INT
) AS 
BEGIN
    INSERT INTO xPeople p ( 
        p.firstName, p.lastName, p.dob, p.isactive, p.favNum)
    VALUES (firstName, lastName, DOB, isActive, favNum);
    
    SELECT pID INTO peepID
        FROM xPeople
        WHERE rowNum = 1
    ORDER BY pID DESC;
    
    SELECT COUNT(pID) INTO NumPeeps FROM xPeople;
    
    DBMS_OUTPUT.PUT_LINE('Insert Successful');
EXCEPTION --EXCEPTIONS must be in every procedure
    WHEN OTHERS -- When others is like an else statement. Last one to go after all other exceptions
        THEN
            DBMS_OUTPUT.PUT_LINE('An error occured!');
END spInsertPeople4;


DECLARE
    NewPeepID INT := 0;
    NumPeeps INT := 0;
BEGIN
    spInsertPeople4('Sarah', 'Jones', sysdate, 1, 4, NewPeepID, NumPeeps);
    DBMS_OUTPUT.PUT_LINE('New PeepID: ' || NewPeepID);
    DBMS_OUTPUT.PUT_LINE('Num of rows: ' || NumPeeps);
    
END;

-- IN OUT parameters
CREATE OR REPLACE PROCEDURE spNewSalary (salary IN OUT FLOAT) AS
BEGIN
        salary := salary * 1.2;
EXCEPTION
    WHEN OTHERS -- When others is like an else statement. Last one to go after all other exceptions
        THEN
            DBMS_OUTPUT.PUT_LINE('An error occured!');
END spNewSalary;

--Executing it
DECLARE
    mySalary FLOAT := ROUND(74500.43/12,2);
BEGIN
    DBMS_OUTPUT.PUT_LINE('The old salary : $' || mySalary);
    spNewSalary(mySalary);
    DBMS_OUTPUT.PUT_LINE('The new salary : $' || mySalary);
END;

-- CONDITIONAL STATEMENTS
-- and explicit cursors

-- SP to delete people and return the results of the deletion
CREATE OR REPLACE PROCEDURE spDelPeep( peepID xPeople.pid%type) AS --using % with type will convert peepID into whatever type xPeople.pid's type is
--Prof note on %type, get the data type of the left side
BEGIN
    DELETE FROM xPeople WHERE pID = peepID;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('pID ' || peepID ||' DOES NOT exists');
    
    ELSIF (SQL%ROWCOUNT = 1) THEN
        DBMS_OUTPUT.PUT_LINE('pID ' || peepID ||' deleted successfully');
    ELSE
        DBMS_OUTPUT.PUT_LINE('MULTIPLE ROWS DELETED - WARNING');
    
    END IF;

EXCEPTION
WHEN OTHERS -- When others is like an else statement. Last one to go after all other exceptions
        THEN
            DBMS_OUTPUT.PUT_LINE('An error occured!');
END spDelPeep;

--execute it
BEGIN
    spDelPeep(200);
END;

BEGIN
    spDelPeep(1);
END;

-- LOOPS
DECLARE
    currNum INT := 0;
    maxNum INT := 7;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-----------------');
    LOOP
    DBMS_OUTPUT.PUT_LINE('Power: ' || currNum || ' - ' || POWER(2, currNum));
        currNum := currNum + 1;
        IF currNum > maxNum THEN
            EXIT;
        END IF;
    END LOOP; -- exit strategy MUST be present (ONLY way to get out of LOOP)
    DBMS_OUTPUT.PUT_LINE('-----------------');
END;


--NESTED LOOPING
DECLARE
    r NUMBER := 0; -- row variable
    c NUMBER := 0; -- column variable
    max# NUMBER := &Num;
    rowString VARCHAR2(255) := '';
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------');
    LOOP -- ROWS
        rowString := LPAD(r, 3, ' ');
        LOOP -- Columns
            rowString := rowString || LPAD(r*c, 4, ' ');
            EXIT WHEN c > max#;
        END LOOP;
        c :=0;
        r := r+1;
        DBMS_OUTPUT.PUT_LINE(rowString);
        EXIT WHEN r > max#;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('----------------');
END;

SELECT MOD(100, 2)
FROM DUAL;