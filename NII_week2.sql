-- ********************************************************
-- Name: Marco Pasqua
-- StudID: 100497213
-- Date: Sept 6, 2022
-- Title: NII_Week2 
-- ********************************************************

/*
JOINS
INNER JOINS, OUTER JOINS (LEFT, RIGHT, FULL)

Notes 1: JOINs are NOT relationships. Nothing more than linking two pieces of information (tables) together
Notes 2: ANSI89 vs ANSI92 Joins
    ANSI89 are also know as Simple Joins (Natural Joins) (Never to be used)
    ANSI89 joins are UNACCEPTABLE in all cases in DBS311
    
example of an ANSI89 Join
SELECT fields
FROM table1, table2
WHERE table.fields1 = table2.field2;

Types of ANSI92 Joins
INNER
- will include all record from both tables, but only where exact matches of the equivalency exist

OUTER JOINs
- Include INNER join results
- LEFT and RIGHT joins will include all records from one of the tables, even if there are no matches in the other table. 
  (for example, will show both customers who have an order, and do not have an order)
- FULL join - is the results of LEFT and RIGHT joins (but without the duplicates)
*/

-- Example: list all employees by name and thecity they work in!

SELECT
    first_name,
    last_name,
    city
FROM
    employees e -- e is an alias for the employees table
    LEFT OUTER JOIN departments d ON e.department_id = d.department_id --LEFT OUTER JOIN takes all the records from the table on the left(which is employees) (Determined to be a left join because we only need the employees)
    LEFT OUTER JOIN locations l on d.location_id = l.location_id -- This join joins the table from the first join with locations (Never followed up an OUTER JOIN with an INNER JOIN, because it will elminate extra records from OUTER JOIN). FULL JOIN keeps all the records from the left, including those that do not match. But it will give us all locations. So we just use LEFT OUTER JOIN 
ORDER BY
    last_name,
    first_name;
    
-- If type of join is not specified on a lab, it means an INNER JOIN. INNER JOIN is a defualt JOIN

--Can also be written as
SELECT
    first_name,
    last_name,
    city
FROM
    locations l
    JOIN departments d ON d.location_id = l.location_id --Any kind of join used here will not matter, since the RIGHT JOIN below will only keep the extra employees, and none of the extra fields
    RIGHT OUTER JOIN employees e ON e.department_id = d.department_id -- WIll be a right outer join since we need the employees from the right
ORDER BY
    last_name,
    first_name;
    
--Using statement
SELECT
    first_name,
    last_name,
    city
FROM
    locations l
    JOIN departments d USING (location_id)--Using can only be used when the 2 fields being joined together have the same name
    RIGHT OUTER JOIN employees e USING (deparment_id)-- WIll be a right outer join since we need the employees from the right (Using merges the 2 columns into 1, which can be an issue)
ORDER BY
    last_name,
    first_name;
    
-- Negative / Inverse Joins
-- Used when we want to grab all the records that do not match
-- Example: List all employees NOT associated with a city

SELECT
    first_name,
    last_name,
    city,
    e.department_id,
    d.department_id
FROM
    locations l
    JOIN departments d ON d.location_id = l.location_id 
    RIGHT OUTER JOIN employees e ON e.department_id = d.department_id 
WHERE city IS NULL
ORDER BY
    last_name,
    first_name;

--TUPLES
-- ANSI89 Join
SELECT
    first_name,
    last_name,
    e.department_id,
    d.department_id,
    department_name
FROM 
    employees e, departments d
WHERE e.department_id = d.department_id;
    