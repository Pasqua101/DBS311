-- ------------------------------
-- DBS311 - Lab 5 (PL/SQL part 1)
-- Clint MacDonald
-- Nov 2021
-- SOLUTIONS
-- ------------------------------
SET SERVEROUTPUT ON;
-- Question 1
CREATE OR REPLACE PROCEDURE spEvenOdd ( NumIn IN INT ) AS
BEGIN
    IF MOD(NumIn, 2) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('The number ' || NumIn || ' is even.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The number ' || NumIn || ' is odd.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('An Error has occured!');
END spEvenOdd;
/
-- -------- EXECUTE Q1
    BEGIN
        spEvenOdd(6);
        spEvenOdd(23);
        spEvenOdd(0);
        spEvenOdd(1);
    END;
    /

-- Question 2
CREATE OR REPLACE PROCEDURE spFind_Employee (
    empID IN number) AS 

fName varchar(50);
lName varchar(50);
email varchar(50);
phone varchar(50);
hireDate date;
jobTitle varchar(255);
BEGIN
    SELECT first_name, last_name, email, phone, hire_date, job_id
        INTO fName, lName, email, phone, hireDate, jobTitle
    FROM employees
    WHERE employee_id = empID;
    DBMS_OUTPUT.PUT_LINE('-------------------');
    DBMS_OUTPUT.PUT_LINE('First Name: ' || fName);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || lName);
    DBMS_OUTPUT.PUT_LINE('Email: ' || Email);
    DBMS_OUTPUT.PUT_LINE('Phone: ' || Phone);
    DBMS_OUTPUT.PUT_LINE('Hire Date: ' || TO_CHAR(hireDate, 'dd-mon-yy'));
    DBMS_OUTPUT.PUT_LINE('Job Title: ' || JobTitle);
EXCEPTION
	WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error!');
END spFind_Employee;
/
-- Execute Q2
BEGIN
    spFind_Employee(34);
    spFind_Employee(107);
END;
/

-- Question 3
CREATE OR REPLACE PROCEDURE spUpdate_Salary_By_Dept (
    deptID IN employees.department_id%type,
    raiseAmt IN employees.salary%type ) AS
BEGIN
    UPDATE employees e
        SET salary = salary * (1 + raiseAmt / 100)
        WHERE department_ID = deptID;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE ('No records where found in that category, no records updated.');
    ELSE DBMS_OUTPUT.PUT_LINE (SQL%ROWCOUNT || ' records updated.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('An error occured! ******* ');
END spUpdate_Salary_By_Dept;
/
-- Execute Q3
    BEGIN
        spUpdate_Salary_By_Dept(50,2.5);
        spUpdate_Salary_By_Dept(60,3);
    END;

-- Question 4
CREATE OR REPLACE PROCEDURE spUpdateSalary_UnderAvg AS
    avgSalary employees.salary%type;
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------');
    SELECT avg(salary) INTO avgSalary FROM employees;  -- gets average
    
    IF avgSalary <= 9000.0 THEN
        UPDATE employees SET salary = salary * 1.02 WHERE salary < avgSalary;
    ELSE
        UPDATE employees SET salary = salary * 1.01 WHERE salary < avgSalary;
    END IF;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rows updated.');
    DBMS_OUTPUT.PUT_LINE('----------------------------');
EXCEPTION
	WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error!');
END spUpdateSalary_UnderAvg;
/
-- Execute it - with option not to actually change the numbers....
BEGIN 
    spUpdateSalary_UnderAvg();
END;
/
-- COMMIT or ROLLBACK
/* FEEDBACK COMMENTS 
Q4,5 - Should use TOO_MANY_ROWS and NO_DATA_FOUND exception handling when using SELECT INTO
*/

-- Question 5
CREATE OR REPLACE PROCEDURE spSalaryReport AS
    minSalary NUMBER;
	maxSalary NUMBER;
	avgSalary NUMBER;
	countLow INT := 0;
	countFair INT := 0;
	countHigh INT := 0;
BEGIN
	SELECT min(salary), max(salary), avg(salary)
		INTO minSalary, maxSalary, avgSalary
	FROM employees;
	
	SELECT COUNT(employee_id) INTO countLow
	FROM employees
	WHERE salary < (avgSalary - minSalary) / 2;
	
	SELECT COUNT(employee_id) INTO countFair 
	FROM employees
	WHERE salary BETWEEN (avgSalary - minSalary) / 2 AND (maxSalary-avgSalary) / 2;
	
	SELECT COUNT(employee_id) INTO countHigh
	FROM employees
	WHERE salary > (maxSalary-avgSalary) / 2;
	
	DBMS_OUTPUT.PUT_LINE('Low: ' || countLow);
	DBMS_OUTPUT.PUT_LINE('Fair: ' || countFair);
	DBMS_OUTPUT.PUT_LINE('High: ' || countHigh);
EXCEPTION
	WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE('You Query resulted in too many returned rows');
	WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No data was returned by your query');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Error!');
END spSalaryReport;
/

-- Execute Q5
    BEGIN
        spSalaryReport();
    END;
    /
    
/* Marking Notes
All SPs required exception handling as stated on lab sheet
Please INDENT your code, for easier code reading
Don't just copy and paste your exceptions, use the right ones for the right scenario.

Q1 - No Exception Handling
Q1 - Inappropriate exception handling

Q2 - Should use TOO_MANY_ROWS exception handling when using SELECT INTO
Q2 - No Exception handling

Q3 - No exception handling
Q3 - Inappropriate exception handling

Q4 - Should use TOO_MANY_ROWS and NO_DATA_FOUND exception handling when using SELECT INTO
Q4 - use SQL%ROWCOUNT for getting the number of affected rows.

Q5 - Should use TOO_MANY_ROWS and NO_DATA_FOUND exception handling when using SELECT INTO
Q5 - min, max and avg could all be in one SELECT
Q5 - No exception handling
Q5 - COUNT(employee_id) is much better than COUNT(*)
Q5 - COUNT(salary) is not necessarily unique counting - COUNT(employee_id) is more consistent
*/