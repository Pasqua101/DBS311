-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Oct 13, 2022
-- Title: NII_Assignment1.sql
-- ********************************************************

-- Q1
-- SELECT empID last name and first name as FullName, job_id and hire_date of employees hired in May or November of any year
-- Exclude employees hired in 2015 and 2016 in this search
-- Hire_date points to the last day in May or Novemeber of the year, and must be in the form of 'May 31<st,nd,rd,th> of 2016] with alias Start Date
-- Display 1 row per output line by limiting width of FullName to 25 characters

--Q1 Solution
SELECT
    employee_id,
    CAST(last_name || ',' || first_name AS CHAR(25)) as FullName,
    job_id,
    TO_CHAR(LAST_DAY(hire_date),'FMMonth ddth "of" YYYY') AS "Start Date"
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) IN (5, 11)
MINUS
SELECT
    employee_id,
    CAST(last_name || ',' || first_name AS CHAR(25)) as FullName,
    job_id,
    TO_CHAR(LAST_DAY(hire_date),'FMMonth ddth "of" YYYY') AS "Start Date"
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) IN (2015, 2016)
ORDER BY "Start Date" DESC;

-- Q2 
-- list employee num, name, job, and modified salary for all employees who's monthlye arnings are outside the rangeof $6,500 - $11,500
-- And are employeed as Vice President or Manager
-- VPs get 25% increase, and managers 18% increase 

--Q2 solution

SELECT
    'Emp#' || employee_id || 
    ' named ' || first_name || '' || last_name ||
    ' with Job ID of ' || job_id || 
    ' will hve a new salary of $' || 
    CASE
        WHEN job_id LIKE '%_VP' THEN (salary * 1.25)
        WHEN job_id LIKE '%_MAN' THEN (salary * 1.18)
        WHEN job_id LIKE '%_MGR' THEN (salary * 1.18)
    END AS "Employees with Increased Pay" 
FROM employees
WHERE (salary NOT BETWEEN 6500 AND 11500) AND
    (job_id LIKE '%_VP' OR job_id LIKE '%_MAN')
ORDER BY salary DESC;

--Q3
-- Display last name, salary, job_id, manager number of employees not earning a commision OR if they work in SALES
-- , but only if their monthly salary with $1000 bonus and commision (if earned) if freater than $15k
-- All employess recieve $1k bonus
-- If an employees has no manager, display none
-- Manager column should has an alias Manager#
-- Display total annual salary in form of $135,600.00 with alias Total income
-- Best paid employees are shown first

-- Q3 Solution
SELECT
    last_name,
    job_id,
    NVL(TO_CHAR(manager_id), 'none') AS "Manager#", -- Have to convert manger_id to char, if we wanted to relace all NULL instances with none
    CASE
        WHEN job_id LIKE 'SA_%' THEN TO_CHAR(((salary * 12) + 1000), '$999,999.00')
        WHEN commission_pct IS NULL THEN TO_CHAR(((salary * 12) + 1000), '$999,999.00')
    END AS "TOTAL ANNUAL SALARY"
FROM employees
WHERE (salary > 15000)
ORDER BY salary DESC;


-- Ali's solution below
SELECT 
    last_name,
    salary,
    job_id,
    Nvl(to_char(manager_id), 'NONE') AS Manager#,
    '$' || To_char(Round(salary * 12 + 1000, 2), '999,999.99') AS TotalIncome
FROM employees
WHERE 
    (commission_pct IS NULL 
    OR department_id = (
        SELECT department_id
        FROM departments
        WHERE Upper(department_name) = 'SALES'
    ))
    AND (salary + (salary * nvl(commission_pct, 0))) + 1000 > 15000;
--Q4
-- Display dept_id, job_id, and lowest salary under alias Lowest Dept/Job Pay
-- But only if the lowest pay falls in the range of $6500 - $16800
-- Exclude those who work as some kind of rep and departments IT and SALES
-- Sort output by department id, then by job_id
-- MUST NOT use subquery

--Q4 solution
SELECT
    e.department_id AS "Department",
    job_id AS "Job",
    MIN(salary) AS "Lowest Salary"
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE salary BETWEEN 6500 AND 16800 AND
    UPPER(d.department_name) NOT IN ('IT', 'SALES') AND
    UPPER(e.job_id) NOT IN '%_REP'
GROUP BY 
    e.department_id,
    job_id
ORDER BY
    e.department_id DESC,
    job_id;
    
-- Q5
-- Display last_name, salary, and job_id for all employees who earn more than the lowest paid employees per departmet outside the US
-- Exclude president, vice president,, sort by job title ascending, must use subquery and join

-- Q5 solution
SELECT
    last_name,
    salary,
    job_id
FROM employees
WHERE salary > ALL
             (
                SELECT MIN(salary)
                FROM employees e
                JOIN departments d ON e.department_id = d.department_id
                JOIN locations l ON d.location_id = l.location_id
                WHERE UPPER(l.country_id) != 'US'
                GROUP BY e.department_id
            )
AND (job_id NOT LIKE '%_VP' AND job_id NOT LIKE '%_PRES')
ORDER BY job_ID ASC;

--Q6
-- Display last_name, salary and job_id for employees who work in IT or marketing and earn more than the least paid person in Accounting
-- Sort by last_name
-- Use subquery

--Q6 Solution
SELECT
    last_name,
    salary,
    job_id
FROM employees
WHERE salary >  (
    SELECT MIN(salary)
    FROM employees
    WHERE job_id LIKE 'AC_%'
    )
AND (job_id LIKE 'IT_%' OR  job_id LIKE 'MK_%')
ORDER BY
last_name ASC;

--Q7
-- Alphabetically display the full name, job, salary (formatted $8,600), and department number of each employee who earns less than best paid unionized employee
-- (not pres, manager, and vp) and work work in SALES or MARKETING


--Q7 solution
--SELECT
--    SUBSTR(first_name || ' ' || last_name, 0, 24) AS "FullName", --SUBSTR takes in a string, a position on where to start, then the length.
--    job_id AS "Job",
--    LPAD(TO_CHAR((salary), '$99,999'), 15, '=') AS "Salary", --LPAD takes in the variable name, then gets the number of times a character (ex. '=') should print out based, on the length of the string. In this case, using TO_CHAR((salary), '$999,999,999') will only make the = prints out twice due to the length of the string format
--    department_id
--FROM employees e
--WHERE (job_id NOT IN ('%_PRES', '%_VP', '%_MAN')) AND
--      (job_id IN ('SA_%', 'MK_%'));
-- Ali's solution
SELECT
    SUBSTR(first_name || ' ' || last_name, 0, 24 )AS employee,
    job_id,
    Lpad(To_char(Round(salary), '$999,999'), 15, '=') AS salary,
    department_id
FROM employees 
WHERE
    salary < (
        SELECT Max(salary)
        FROM employees
        WHERE job_id NOT LIKE '%_PRES'
        AND job_id NOT LIKE '%MAN%'
        AND job_id NOT LIKE '%VP%'
        )
    AND department_id IN (
        SELECT department_id
        FROM departments
        WHERE Upper(department_name) IN ('SALES','MARKETING' )
        )
ORDER BY employee ASC;


SELECT
    SUBSTR(first_name || ' ' || last_name, 0, 24 )AS employee,
    job_id,
    Lpad(To_char(Round(salary), '999,999'), 15, '=') AS salary,
    department_id
FROM employees 
WHERE
    salary < (
        SELECT Max(salary)
        FROM employees
        WHERE job_id NOT LIKE '%PRES%'
        AND job_id NOT LIKE '%MAN%'
        AND job_id NOT LIKE '%VP%'
        )
    AND department_id IN (
        SELECT department_id
        FROM departments
        WHERE Upper(department_name) IN ('SALES','MARKETING' )
        )
ORDER BY employee ASC;
--Q8
-- Display department_name, city, an num of different jobs in each department
-- If city is null , print Not Assigned Yet
-- City column has alias City
-- num of jobs column alias is # of jobs
-- limit width of city to 22 characters
-- •	You need to show complete situation from the EMPLOYEE point of view, meaning include also employees who work for NO department 
-- (but do NOT display empty departments) and from the CITY point of view meaning you need to display all cities without departments as well.

--Q8 solution
-- Solution below is hardcoded to remove an empty department that is assigned to a city
SELECT
    department_name,
    Nvl(Substr(city, 0, 22), 'Not Assigned Yet') AS City,
    Count(UNIQUE job_id) AS "#ofJobs"
FROM employees e
FULL JOIN departments d ON e.department_id = d.department_id
FULL JOIN locations l ON d.location_id = l.location_id
GROUP BY
    department_name,
    city
UNION 
SELECT 
    department_name,
    Nvl(Substr(city, 0, 22), 'Not Assigned Yet') AS City,
    Count(UNIQUE job_id) AS "#ofJobs"
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
RIGHT JOIN locations l ON d.location_id = l.location_id
WHERE d.manager_id IS NOT NULL
GROUP BY
    department_name,
    city
MINUS
SELECT 
    department_name,
    Nvl(Substr(city, 0, 22), 'Not Assigned Yet') AS City,
    Count(UNIQUE job_id) AS "#ofJobs"
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
RIGHT JOIN locations l ON d.location_id = l.location_id
WHERE UPPER(d.department_name) LIKE 'CONTRACTING'
GROUP BY
    department_name,
    city;

--Ali's soltuion
SELECT 
    department_name,
    Nvl(Substr(city, 0, 22), 'Not Assigned Yet') AS City,
    Count(UNIQUE job_id) AS "#ofJobs"
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
GROUP BY
    department_name,
    city
UNION 
SELECT 
    department_name,
    Nvl(Substr(city, 0, 22), 'Not Assigned Yet') AS City,
    Count(UNIQUE job_id) AS "#ofJobs"
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
RIGHT JOIN locations l ON d.location_id = l.location_id
WHERE 
    d.department_id IS NULL
GROUP BY
    department_name,
    city;