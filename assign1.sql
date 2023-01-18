-- ***************************************
-- Name: Ali Omar  
-- StudID: 150648210
-- Name: Tran Minh Quan Nguyen
-- StudID:116796210
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Oct 13, 2022
-- Purpose: Assignment 1
-- ***************************************

/* Question 1 - Display the employee number, full employee name, job 
--and hire date of all employees hired in May or November of any year, 
with the most recently hired employees displayed first. */ 
-- Q1 SOLUTION --
SELECT 
    employee_id,
    Substr(last_name || ', ' || first_name, 0, 25 ) AS fullName, 
    job_id,
    To_Char(Last_Day(hire_date), '[fmMonth ddth "of" YYYY]') AS StartDate   
FROM employees
WHERE
    EXTRACT(MONTH FROM HIRE_DATE) IN(5,11) 
    AND EXTRACT(YEAR FROM hire_date) NOT IN(2015,2016)
ORDER BY hire_date DESC;


/*
Question 2 - List the employee number, full name, job and the modified salary for all 
employees whose monthly earning (without this increase) is outside the range $6,500 ? 
$11,500 and who are employed as Vice Presidents or Managers 
*/
-- Q2 SOLUTION --
SELECT
    'Emp# ' || employee_id || ' named ' || fullName 
        || ' who is ' || job_id || ' will have a new salary of $' 
        || salaryNew AS EmployeesWithIncreasedPay
FROM (
    SELECT
        employee_id,
        first_name || ' ' || last_name AS fullName,
        job_id,
        CASE
            WHEN Upper(job_id) LIKE '%VP%' THEN salary + (salary * .25)
            WHEN Upper(job_id) LIKE '%MAN%' THEN salary + (salary * .18)
            WHEN Upper(job_id) LIKE '%MGR%' THEN salary + (salary * .18)
            ELSE salary
            END AS salaryNew
    FROM employees
    WHERE salary NOT BETWEEN 6500 AND 11500
    ORDER BY salary DESC
)
WHERE job_id LIKE '%VP%' OR job_id LIKE '%MAN%';


/* 3.- Display the employee last name, salary, job title and manager# of all employees 
not earning a commission OR if they work in the SALES department, but only  if their
total monthly salary with $1000 included bonus and  commission (if  earned) is  greater  
than  $15,000. */
-- QUESTION 3 SOLUTION --
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


/*4.Display Department_id, Job_id and the Lowest salary for this combination under 
the alias Lowest Dept/Job Pay, but only if that Lowest Pay falls in the range $6500 - $16800. */
-- QUESTION 4 SOLUTION --
SELECT
   department_id, 
    job_id,
    MIN(salary) AS "lowestDept/jobPay"
FROM employees
GROUP BY department_id, job_id
HAVING MIN(salary) BETWEEN 6500 AND 16800
MINUS
SELECT
    e.department_id, 
    job_id,
    MIN(salary)
FROM 
    employees e LEFT JOIN departments d 
    ON e.department_id = d.department_id 
WHERE 
    Upper(job_id) LIKE '%REP%' 
    OR Upper(d.department_name) = 'IT' 
    OR Upper(d.department_name) = 'SALES'
GROUP BY e.department_id, job_id;

/*5. Display last_name, salary and job for all 
employees who earn more than all lowest paid employees 
per department outside the US locations.*/
-- Q5 SOLUTION --
SELECT
    last_name,
    salary,
    job_id
FROM 
    employees
WHERE salary > ALL (
    SELECT Min(salary)
    FROM employees e LEFT JOIN departments d ON e.department_id = d.department_id
    LEFT JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id != 'US'
    GROUP BY e.department_id
    )
    AND job_id NOT LIKE '%AD%'
    AND job_id NOT LIKE '%PRES%'
ORDER BY job_id ASC;


/*6. Who are the employees who work either in IT 
or MARKETING department and earn more than the worst 
paid person in the ACCOUNTING department. */
-- Q6 SOLUTION --
SELECT
    last_name,
    salary,
    job_id
FROM employees
WHERE 
    ( Upper(job_id) LIKE '%IT%'
    OR Upper(job_id) LIKE '%MK%'
    )
    AND salary > (    
        SELECT
            Min(salary)
        FROM employees
        WHERE upper(job_id) LIKE '%AC%'
    )
ORDER BY last_name ASC;

/*7. Display ...
for each employee who earns less than the 
best paid unionized employee... */
-- Q7 SOLUTION
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
        WHERE employee_id NOT IN(
            SELECT DISTINCT nvl(manager_id, 0) FROM employees
            )
        )
    AND department_id IN (
        SELECT department_id
        FROM departments
        WHERE Upper(department_name) IN ('SALES','MARKETING' )
        )
ORDER BY employee ASC;




/* 8. Display department name, city and number of different jobs in each department. 
If city is null, you should print Not Assigned Yet*/
-- Q8 SOLUTION
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

