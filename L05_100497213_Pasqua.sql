-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Nov 6, 2022
-- Title: L05_100497213_Pasqua.sql
-- PL/SQL part 1
-- ********************************************************

SET SERVEROUTPUT ON;

--Q1
CREATE OR REPLACE PROCEDURE spPrintInt(n IN INT) AS
BEGIN
    IF(MOD(n,2) = 0)
    THEN
    DBMS_OUTPUT.PUT_LINE('The number is even');
    ELSE
    DBMS_OUTPUT.PUT_LINE('The number is odd');
    END IF;

END spPrintInt;

DECLARE
    n INT:=&n;
BEGIN
    spPrintInt(n);
END;

--Q2
CREATE OR REPLACE PROCEDURE find_employee(
    empID IN employees.employee_id%type
    ) AS 
    BEGIN
    DECLARE
    firstname employees.first_name%type; 
    lastname employees.last_name%type;
    lemail employees.email%type;
    phonenum employees.phone_number%type;
    hiredt employees.hire_date%type;
    jobid employees.job_id%type;
BEGIN
    SELECT 
        first_name,
        last_name,
        email,
        phone_number,
        hire_date,
        job_id
        INTO firstname, lastname, lemail, phonenum, hiredt, jobid
    FROM employees
    WHERE employee_id = empID;

    DBMS_OUTPUT.PUT_LINE('First name: '|| firstname);
    DBMS_OUTPUT.PUT_LINE('Last name: ' || lastname);
    DBMS_OUTPUT.PUT_LINE('Email: ' || lemail);
    DBMS_OUTPUT.PUT_LINE('Phone number: ' || phonenum);
    DBMS_OUTPUT.PUT_LINE('Hire date: ' || hiredt);
    DBMS_OUTPUT.PUT_LINE('Job title: ' || jobid);

EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
WHEN TOO_MANY_ROWS
    THEN
        DBMS_OUTPUT.PUT_LINE('Employee has more than 1 record');
WHEN OTHERS
  THEN 
      DBMS_OUTPUT.PUT_LINE ('Error!');
END;
END find_employee;

DECLARE
    empID employees.employee_id%type:=&empID;
BEGIN
    find_employee(empID);
END;

--Q3
CREATE OR REPLACE PROCEDURE update_salary_by_dept(
    deptName IN departments.department_name%type,
    salaryIncrease IN employees.salary%type
) AS
BEGIN
    
    UPDATE employees
    SET salary = salary * salaryIncrease
    WHERE department_id IN 
    (
        SELECT 
            department_id
        FROM departments
        WHERE UPPER(department_name) = UPPER(deptName)
    )
    AND (salary > 0);
    
    DBMS_OUTPUT.PUT_LINE('Number of rows updated is : ' || SQL%ROWCOUNT);  --Using SQL%ROWCOUNT will show how many rows got updated
EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Department not found');
WHEN OTHERS
  THEN 
      DBMS_OUTPUT.PUT_LINE ('Error!');
END update_salary_by_dept;
--Executing it
DECLARE
-- Tried setting it up to get user input, however I recieved errors when doing so
--    deptName departments.department_name%type:=&deptName;
--    salaryPct employees.salary%type:=&salaryPct;
     deptName VARCHAR2(30) := 'Marketing';
     salaryPct NUMBER := 2.5;
BEGIN
    update_salary_by_dept(deptName, salaryPct);
END;

--Q4

CREATE OR REPLACE PROCEDURE spUpdateSalary_UnderAvg AS
BEGIN
DECLARE
    avgSalary employees.salary%type;
BEGIN

    SELECT
        AVG(salary) INTO avgSalary
    FROM employees;
    
    UPDATE employees
    SET salary  = CASE
                    WHEN avgSalary <= 9000
                    THEN salary * 1.02
                    WHEN avgSalary > 9000
                    THEN salary * 1.01
                    END;
    DBMS_OUTPUT.PUT_LINE('Number of rows updated ' || SQL%ROWCOUNT);
EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Salary not found');
WHEN OTHERS
  THEN 
      DBMS_OUTPUT.PUT_LINE ('Error!');
END;
END spUpdateSalary_UnderAvg;

--Execute it
BEGIN
    spUpdateSalary_UnderAvg;
END;

--Q5
CREATE OR REPLACE PROCEDURE spSalaryReport AS
BEGIN
DECLARE
    numOfLowSal NUMBER;
    numOfFairSal NUMBER;
    numOfHighSal NUMBER;
    minAvgSal employees.salary%type;
    maxAvgSal employees.salary%type;
BEGIN
    
    SELECT 
        (AVG(salary) - MIN(salary))/2,
        (MAX(salary) - AVG(salary))/2 INTO minAvgSal, maxAvgSal
    FROM employees;
    
    SELECT
        COUNT(salary) INTO numOfLowSal
    FROM employees
    WHERE salary < minAvgSal;
    
    SELECT
        COUNT(salary) INTO numOfFairSal
    FROM employees
    WHERE salary > minAvgSal AND  salary < maxAvgSal;
    
    SELECT
        COUNT(salary) INTO numOfHighSal
    FROM employees
    WHERE salary > maxAvgSal;
    
    DBMS_OUTPUT.PUT_LINE('Low: ' || numOfLowSal);
    DBMS_OUTPUT.PUT_LINE('Fair: ' || numOfFairSal);
    DBMS_OUTPUT.PUT_LINE('High: ' || numOfHighSal);
    
EXCEPTION
WHEN NO_DATA_FOUND
    THEN
        DBMS_OUTPUT.PUT_LINE('Error: No salaries found');
WHEN OTHERS
  THEN 
      DBMS_OUTPUT.PUT_LINE ('Error!');
END;
END spSalaryReport;

--Execute
BEGIN
    spSalaryReport;
END;
