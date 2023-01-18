
DECLARE
       CURSOR emp_cur IS SELECT * FROM employees ORDER BY employee_id;
       emp_rec employees%ROWTYPE;
    BEGIN
       OPEN emp_cur;
       LOOP   -- loop through the table and get each employee
          FETCH emp_cur INTO emp_rec;
          IF emp_cur%FOUND THEN
--             dbms_output.put_line('Employee #' || emp_rec.employee_id ||
--                ' is ' || emp_rec.last_name);
                RETURN emp_rec;
          ELSE
             dbms_output.put_line('--- Finished processing employees ---');
             EXIT;
          END IF;
       END LOOP;
       CLOSE emp_cur;
    END;
    
    
CREATE OR REPLACE PROCEDURE spGetEmployeeName
 AS
BEGIN
	RETURN (SELECT first_name, last_name FROM employees)
END spGetEmployeeName;