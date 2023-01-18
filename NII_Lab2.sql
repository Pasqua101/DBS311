-- ***************************************
-- DBS311 - Fall 2022
-- Lab 2
-- Aggregate Functions (Multi-Line Queries)
-- 
-- Marco Pasqua
-- 100497213
-- Sunday, September 25, 2022
-- ***************************************

-- Note: Pay is equal to salary + commission = salary + (compct * salary)

--Question 1:
-- 1.	Display the difference between the Average pay and Lowest pay in the company.  Name this result Real Amount.
--      Format the output as currency with 2 decimal places.
    
SELECT
    TO_CHAR(AVG(salary + (salary * NVL(commission_pct,0))) - 
            MIN(salary + (salary * NVL(commission_pct,0))),'$999999.99') AS "Real Amount"
FROM
    employees;
--Question 2:
-- Display the department number and Highest, Lowest and Average pay per each department. Name these results High, Low and Avg.  
-- Sort the output so that the department with highest average salary is shown first.  Format the output as currency where appropriate.

SELECT
    d.department_id,
    TO_CHAR(MAX(salary +  (salary * NVL(commission_pct, 0))), '$99999999.99') AS High,
    TO_CHAR(AVG(salary + (salary * NVL(commission_pct, 0))), '$99999999.99') AS Avg,
    TO_CHAR(MIN(salary + (salary * NVL(commission_pct, 0))), '$99999999.99') AS Low
FROM departments d
    LEFT OUTER JOIN employees e ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    commission_pct
ORDER BY
    High DESC;
    
    
-- Question 3:
-- 3.	Display how many people work the same job in the same department. Name these results Dept#, Job and How Many. 
--      Include only jobs that involve more than one person.  Sort the output so that jobs with the most people involved are shown first.
-- CHECK DATATBASE TO MAKE SURE ANSWER IS CORRECT 
SELECT
    d.department_id AS Dept#,
    job_id AS Job,
    COUNT(job_id) AS "How Many"
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    job_id
HAVING COUNT(employee_id) > 1
ORDER BY
    "How Many" DESC;

-- Question 4:
-- 4.   For each job title display the job title and total amount paid each month for this type of the job. 
--      Exclude titles AD_PRES and AD_VP and also include only jobs that require more than $11,000.  Sort the output so that top paid jobs are shown first.

SELECT
    job_id,
    TO_CHAR(SUM(salary + (salary * NVL(commission_pct, 0))), '$99,999,999.99') AS "Total Monthly Pay" 
FROM
    employees
GROUP BY
    job_id,
    salary
HAVING job_id NOT IN('AD_PRESS', 'AD_VP') 
    AND salary > 11000
ORDER BY
    "Total Monthly Pay" DESC; 
--When using not in the parameters must be written in all uppercase due to how the database stores the variables

-- Question 5:
-- 5.	For each manager number display how many persons he / she supervises. 
--      Exclude managers with numbers 100, 101 and 102 and also include only those managers that supervise more than 2 persons. 
--      Sort the output so that manager numbers with the most supervised persons are shown first.
SELECT
    manager_id AS ManagerNUM,
    COUNT(employee_id) as EmpNUM
FROM employees
GROUP BY
    manager_id
HAVING manager_id NOT IN(100, 101, 102) 
       AND manager_id IS NOT NULL -- Creating this line to remove the need for the script to check through each and every employee,  and look only at employees with a manager
       AND COUNT(employee_id) > 2;


--Question 6:
--6.	For each department show the latest and earliest hire date, BUT
-- - exclude departments 10 and 20 
-- - exclude those departments where the last person was hired in this decade. (it is okay to hard code dates in this question only)
-- - Sort the output so that the most recent, meaning latest hire dates, are shown first.

SELECT
    department_id,
    MAX(hire_date) AS "Latest Hire Date",
    MIN(hire_date) AS "Earlierst Hire Date"
FROM
    employees
GROUP BY
    department_id
HAVING department_id NOT IN (10,20)
    AND MAX(hire_date) < TO_DATE('2001-12-01','yyyy-mm-dd');

