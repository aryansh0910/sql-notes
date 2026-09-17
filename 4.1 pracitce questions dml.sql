-- ============================================================
-- PRACTICE QUESTIONS 4.1 — DML COMMANDS
-- (My answers vs corrected answers, with mistakes to remember)
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Insert a full row (Neha), and a partial row (Vikram)
-- ------------------------------------------------------------

-- MY ANSWER (attempt 1):
-- INSERT INTO employees(emp_id,name,dept_id,salary,join_date)
-- VALUES(
-- 'Neha',102,55000,2023-06-01,
-- 7,'Vikram')

-- MISTAKES:
--   1. "name" instead of "emp_name" -> must match EXACT column names
--   2. Values didn't match columns in order/count
--   3. Tried to cram TWO different employees' data into ONE
--      VALUES(...) clause -> each row needs its own separate
--      parenthesized group (or its own INSERT statement entirely)
--   4. 2023-06-01 not quoted -> SQL reads it as subtraction
--      (2023 - 06 - 01), not a date string

-- CORRECTED (two separate rows, using multi-row INSERT syntax):
INSERT INTO employees (emp_id, emp_name, dept_id, salary, join_date)
VALUES
    (6, 'Neha', 102, 55000, '2023-06-01'),
    (7, 'Vikram', NULL, NULL, NULL);

-- KEY LESSON: in a MULTI-ROW insert, every row must fill EVERY
-- column in the list (even if that means writing NULL
-- explicitly) -- you can't "skip" columns differently per row
-- within ONE statement. To skip columns entirely (partial
-- insert), each row needs its OWN separate INSERT statement
-- with its own shorter column list:
--   INSERT INTO employees (emp_id, emp_name) VALUES (7, 'Vikram');


-- ------------------------------------------------------------
-- Q2: UPDATE Rohan's salary, give dept 101 a raise, DELETE Vikram
-- ------------------------------------------------------------

-- MY ANSWER (part 1):
-- UPDATE employees
-- SET salary = 52000 where emp_name="ROHAN"

-- MISTAKES:
--   1. Double quotes instead of single quotes ("ROHAN" -> 'Rohan')
--   2. Case mismatch (ROHAN vs Rohan) -- worked here only
--      because MySQL's default collation is often case-insensitive,
--      NOT guaranteed behavior across all setups

-- CORRECTED:
UPDATE employees
SET salary = 52000
WHERE emp_name = 'Rohan';


-- MY ANSWER (part 2):
-- UPDATE employee
-- SET salary=salary + 5000 
-- WHERE dept_id=101

-- MISTAKE: table name typo -- "employee" instead of "employees"
-- (the RAISE LOGIC ITSELF -- salary = salary + 5000 -- was correct)

-- CORRECTED:
UPDATE employees
SET salary = salary + 5000
WHERE dept_id = 101;


-- MY ANSWER (part 3):
-- DELETE  WHERE emp_name ='Vikram

-- MISTAKES:
--   1. Missing "FROM employees" entirely -- DELETE needs FROM,
--      just like ALTER needs TABLE
--   2. Unclosed quote ('Vikram -> 'Vikram')

-- CORRECTED:
DELETE FROM employees
WHERE emp_name = 'Vikram';

-- KEY LESSON: UPDATE and DELETE without a WHERE clause affect
-- EVERY ROW in the table -- always double check the WHERE
-- condition before running either.


-- ------------------------------------------------------------
-- Q3: DISTINCT, ORDER BY + LIMIT, LIKE with OR, AS
-- ------------------------------------------------------------

-- MY ANSWER (part 1) -- CORRECT (parentheses around dept_id
-- unnecessary but harmless):
SELECT DISTINCT dept_id FROM employees;


-- MY ANSWER (part 2):
-- SELECT emp_name,salary FROM employees ORDER BY salary LIMIT 1,2

-- MISTAKES:
--   1. Missing DESC -- ORDER BY defaults to ASCENDING (lowest
--      first), but question asked for the HIGHEST paid
--   2. "LIMIT 1,2" means "skip 1 row, then take 2" (offset
--      syntax) -- NOT "give me the top 3." Needed plain LIMIT 3.

-- CORRECTED:
SELECT emp_name, salary FROM employees 
ORDER BY salary DESC 
LIMIT 3;


-- MY ANSWER (part 3):
-- SELECT * FROM employee WHERE emp_name LIKE 'A%' OR 'P%'

-- MISTAKES:
--   1. Table name typo ("employee" -> "employees")
--   2. "OR 'P%'" is NOT a valid condition on its own -- OR needs
--      a FULL condition on BOTH sides, can't "share" the column
--      name/LIKE across both halves

-- CORRECTED:
SELECT * FROM employees 
WHERE emp_name LIKE 'A%' OR emp_name LIKE 'P%';

-- KEY LESSON: AND/OR always join two COMPLETE conditions --
-- never a bare value on one side.


-- MY ANSWER (part 4):
-- SELECT emp_name,salary AS monthly_pay FROM employee

-- MISTAKE: table name typo only -- logic and AS usage were
-- already correct

-- CORRECTED:
SELECT emp_name, salary AS monthly_pay FROM employees;


-- ------------------------------------------------------------
-- Q4: COUNT, AVG+ROUND, UPPER, CONCAT
-- ------------------------------------------------------------

-- MY ANSWERS (parts 1-3) -- ALL CORRECT, no mistakes:
SELECT COUNT(*) FROM employees;
SELECT ROUND(AVG(salary),2) FROM employees;
SELECT UPPER(emp_name), salary FROM employees;


-- MY ANSWER (part 4):
-- SELECT CONCAT(emp_name,'-'dept_id_ FROM employees

-- MISTAKES:
--   1. Missing comma between '-' and dept_id -- CONCAT()
--      arguments must be comma-separated
--   2. Unclosed parenthesis
--   3. Stray underscore after dept_id
--   4. Didn't fully match the expected output format
--      ("Aryan - Dept 101" needs the literal word "Dept" too,
--      not just a dash and the number)

-- CORRECTED:
SELECT CONCAT(emp_name, ' - Dept ', dept_id) AS emp_label
FROM employees;

-- KEY LESSON: CONCAT() takes MULTIPLE separate comma-separated
-- arguments -- string literals with spaces baked in ('  - Dept  ')
-- are valid arguments right alongside column names.


-- ------------------------------------------------------------
-- Q5: Dept with most employees, insert NULL salary, find NULLs
-- ------------------------------------------------------------

-- MY ANSWER (part 1):
-- SELECT MAX(COUNT(emp _name)),dept_id FROM employees GROUP BY dept_id

-- MISTAKES:
--   1. Stray space in "emp _name"
--   2. CANNOT nest one aggregate function directly inside
--      another (MAX(COUNT(...)) is invalid) -- COUNT() already
--      collapses rows per group; MAX() would need to operate on
--      THAT result separately, not inside the same query level
--   3. Even fixed, this structure gives EVERY department's
--      count, not just the top one

-- CORRECTED (Approach A -- ORDER BY + LIMIT, simplest):
SELECT dept_id, COUNT(emp_name) AS emp_count
FROM employees
GROUP BY dept_id
ORDER BY emp_count DESC
LIMIT 1;

-- CORRECTED (Approach B -- subquery, handles TIES properly):
SELECT dept_id, COUNT(emp_name) AS emp_count
FROM employees
GROUP BY dept_id
HAVING COUNT(emp_name) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(emp_name) AS cnt
        FROM employees
        GROUP BY dept_id
    ) AS dept_counts
);


-- MY ANSWER (part 2):
-- INSERT INTO employees(emp_id,name,dept_id,salary,joined)
-- VALUES(8,'Ananya',101,NULL,'2024-02-14'

-- MISTAKES:
--   1. "name" instead of "emp_name" -- SAME mistake repeated
--      from Q1 -- worth double-checking column names every time
--   2. "joined" instead of "join_date" -- also repeated from Q1
--   3. Missing closing parenthesis
--   (NULL handling itself -- writing NULL directly, no quotes --
--   was CORRECT)

-- CORRECTED:
INSERT INTO employees (emp_id, emp_name, dept_id, salary, join_date)
VALUES (8, 'Ananya', 101, NULL, '2024-02-14');


-- MY ANSWER (part 3): did not attempt

-- CORRECTED:
SELECT * FROM employees
WHERE salary IS NULL;

-- KEY LESSON: NULL means "unknown," not "empty" or "zero."
-- salary = NULL never matches anything (evaluates to UNKNOWN,
-- not TRUE), even for rows where salary genuinely IS NULL --
-- always use IS NULL / IS NOT NULL instead of = NULL.
-- ALSO connects back to Grouping/Sorting: COUNT(*) counts ALL
-- rows including NULLs, but COUNT(column_name) SKIPS NULLs in
-- that specific column -- these can give different numbers.


-- ============================================================
-- MY TOP RECURRING MISTAKES — READ THIS BEFORE EVERY PRACTICE SESSION
-- ============================================================

-- 1. COLUMN NAME MISMATCHES -- "name" vs "emp_name", "joined"
--    vs "join_date" -- happened TWICE across this session.
--    Always double-check exact column names against the table
--    structure before writing INSERT/UPDATE statements.
-- 2. TABLE NAME TYPOS -- "employee" instead of "employees" --
--    happened multiple times. Slow down and re-read the table
--    name before submitting.
-- 3. Double quotes instead of single quotes for string values
--    -- carried over from DDL practice, still showing up here.
-- 4. LIMIT n vs LIMIT offset,count -- these mean COMPLETELY
--    different things. LIMIT 3 = "first 3 rows." LIMIT 1,2 =
--    "skip 1, then take 2." Don't confuse them.
-- 5. AND/OR need a FULL condition on BOTH sides -- can't drop
--    the column name/operator on the second half and just leave
--    a bare value.
-- 6. Cannot nest aggregate functions directly (MAX(COUNT(...))
--    is invalid) -- need a subquery or ORDER BY+LIMIT instead to
--    find "the top result of a grouped calculation."
-- 7. NEVER use = NULL -- always IS NULL / IS NOT NULL. NULL
--    represents "unknown," and unknown compared with = always
--    evaluates to UNKNOWN, not TRUE, so = NULL silently matches
--    nothing, with no error to warn you.