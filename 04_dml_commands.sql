-- ============================================================
-- SQL DML COMMANDS
-- (CampusX DSMP: Session 32, Week 14 — SQL Continued Part 1)
-- ============================================================

-- NOTE: Session 31 covered DDL (structure). This session covers
-- DML — actually putting DATA into that structure, reading it
-- back, changing it, and removing it. It also introduces a NEW
-- tool (MySQL Workbench) and closes with FUNCTIONS in SQL —
-- both easy to overlook if you only remember "INSERT/UPDATE/DELETE."


-- ============================================================
-- STEP 1: MYSQL WORKBENCH — SWITCHING TOOLS
-- ============================================================

-- Session 31 used XAMPP + phpMyAdmin (browser-based). This
-- session introduces MySQL WORKBENCH — a dedicated desktop
-- application for working with MySQL databases, with a proper
-- SQL editor, schema browser, and query result grid.

-- WHY SWITCH? phpMyAdmin is fine for quick, beginner-level
-- browser-based use, but MySQL Workbench is the actual
-- INDUSTRY-STANDARD tool professionals use daily — better query
-- editing (syntax highlighting, autocomplete), visual schema/ER
-- diagrams, and more robust handling of larger databases. Moving
-- to Workbench here is Nitish easing you toward the tool you'd
-- realistically use in an actual job, not just a learning sandbox.

-- Practical setup: install MySQL Server + MySQL Workbench,
-- connect to your local server instance, and you get a proper
-- SQL editor pane to run every command below.


-- ============================================================
-- STEP 2: INSERT — ADDING NEW DATA
-- ============================================================

-- INSERT adds new ROWS into an existing table (whose STRUCTURE
-- was already defined back in the DDL session).

-- Full syntax — specify every column, in table order:
INSERT INTO employees (emp_id, emp_name, salary, dept_id)
VALUES (1, 'Aryan', 45000, 101);

-- Partial insert — specify ONLY certain columns; the rest fall
-- back to DEFAULT or NULL (assuming no NOT NULL violation):
INSERT INTO employees (emp_id, emp_name)
VALUES (2, 'Priya');

-- MULTIPLE ROWS in a single INSERT statement — more efficient
-- than writing separate INSERT statements one at a time:
INSERT INTO employees (emp_id, emp_name, salary, dept_id)
VALUES
    (3, 'Rohan', 52000, 102),
    (4, 'Simran', 48000, 101),
    (5, 'Karan', 61000, 103);

-- IMPORTANT: the ORDER of values must match the order of
-- columns listed right after the table name — mismatching them
-- silently inserts wrong data into wrong columns if data types
-- happen to be compatible (e.g. swapping two INT columns won't
-- error, it'll just be WRONG).


-- ============================================================
-- STEP 3: SELECT — READING DATA BACK
-- ============================================================

-- SELECT retrieves/reads data — technically its own category
-- (DQL, from your DDL Commands note), but taught here alongside
-- DML since you need SOME way to verify your INSERT/UPDATE/
-- DELETE operations actually worked.

-- Retrieve EVERY column, every row:
SELECT * FROM employees;

-- Retrieve SPECIFIC columns only:
SELECT emp_name, salary FROM employees;

-- Filter rows using WHERE:
SELECT * FROM employees
WHERE dept_id = 101;

-- WHY LEARN SELECT HERE, EVEN THOUGH IT'S "DQL" NOT "DML"?
-- Practically, you ALWAYS pair INSERT/UPDATE/DELETE with SELECT
-- — to confirm data went in correctly, to find WHICH rows need
-- updating, and to verify a delete actually removed what you
-- intended. It's inseparable from real DML workflow, even if
-- it's technically its own formal category.


-- ============================================================
-- STEP 4: UPDATE — MODIFYING EXISTING DATA
-- ============================================================

UPDATE employees
SET salary = 55000
WHERE emp_id = 1;

-- UPDATING MULTIPLE COLUMNS AT ONCE (comma-separated):
UPDATE employees
SET salary = 60000, dept_id = 103
WHERE emp_id = 2;

-- *** THE SINGLE MOST IMPORTANT WARNING IN THIS ENTIRE SESSION ***
-- If you FORGET the WHERE clause, UPDATE modifies EVERY SINGLE
-- ROW in the table, not just the one you meant to change:

-- DANGEROUS — sets EVERY employee's salary to 60000:
-- UPDATE employees SET salary = 60000;

-- ALWAYS run a SELECT with the same WHERE condition FIRST, to
-- confirm you're targeting exactly the rows you intend, BEFORE
-- running the actual UPDATE:
SELECT * FROM employees WHERE emp_id = 2;   -- check first
UPDATE employees SET salary = 60000 WHERE emp_id = 2;   -- then update


-- ============================================================
-- STEP 5: DELETE — REMOVING EXISTING DATA
-- ============================================================

DELETE FROM employees
WHERE emp_id = 5;

-- SAME CRITICAL WARNING AS UPDATE: forgetting WHERE deletes
-- EVERY ROW in the table (though the table structure itself
-- remains, unlike DROP or TRUNCATE from your DDL note):

-- DANGEROUS — deletes ALL rows in the employees table:
-- DELETE FROM employees;

-- RECALL FROM YOUR DDL NOTES: DELETE (this DML command) is
-- DIFFERENT from TRUNCATE (a DDL command):
--   DELETE    -> removes rows one at a time, CAN use WHERE to
--                target specific rows, CAN be rolled back (if
--                inside a transaction), slower on large tables
--   TRUNCATE  -> removes ALL rows at once, no WHERE allowed,
--                typically CANNOT be rolled back, much faster


-- ============================================================
-- STEP 6: FUNCTIONS IN SQL
-- ============================================================

-- SQL includes built-in FUNCTIONS that let you compute,
-- transform, or aggregate values directly within a query,
-- instead of pulling raw data out and processing it elsewhere.

-- --- AGGREGATE FUNCTIONS (operate on a whole SET of rows,
-- return ONE summary value) ---
SELECT COUNT(*) FROM employees;              -- total number of rows
SELECT SUM(salary) FROM employees;            -- total of all salaries
SELECT AVG(salary) FROM employees;             -- average salary
SELECT MAX(salary) FROM employees;              -- highest salary
SELECT MIN(salary) FROM employees;               -- lowest salary

-- --- STRING FUNCTIONS (operate on text values) ---
SELECT UPPER(emp_name) FROM employees;         -- convert to uppercase
SELECT LOWER(emp_name) FROM employees;          -- convert to lowercase
SELECT LENGTH(emp_name) FROM employees;          -- number of characters
SELECT CONCAT(emp_name, ' - Dept ', dept_id) AS full_label FROM employees;
                                                   -- combine multiple values into one string

-- --- NUMERIC FUNCTIONS ---
SELECT ROUND(AVG(salary), 2) FROM employees;    -- round to 2 decimal places
SELECT ABS(-15);                                  -- absolute value -> 15

-- --- DATE FUNCTIONS ---
SELECT NOW();                    -- current date and time
SELECT CURDATE();                 -- current date only

-- WHY FUNCTIONS MATTER HERE SPECIFICALLY: they let you do real
-- DATA ANALYSIS directly inside SQL — "what's the average
-- salary in department 101?" — without needing to export data
-- to Python/Excel just to compute a simple aggregate. This is
-- exactly the kind of query you'll be asked to write in a SQL
-- interview screening round.

-- ============================================================
-- STEP 3B: SELECT — ADDITIONAL CLAUSES (WHERE, DISTINCT, LIMIT,
-- AS, comparison/logical operators)
-- ============================================================

-- --- COMPARISON OPERATORS in WHERE ---
SELECT * FROM employees WHERE salary > 50000;
SELECT * FROM employees WHERE salary >= 50000;
SELECT * FROM employees WHERE salary != 50000;   -- not equal (also <>)
SELECT * FROM employees WHERE salary BETWEEN 40000 AND 60000;
SELECT * FROM employees WHERE dept_id IN (101, 102);   -- matches ANY value in the list
SELECT * FROM employees WHERE emp_name LIKE 'A%';       -- starts with 'A' (pattern matching)
SELECT * FROM employees WHERE salary IS NULL;             -- checking for NULL needs IS, not =

-- --- LOGICAL OPERATORS — combining multiple conditions ---
SELECT * FROM employees WHERE dept_id = 101 AND salary > 45000;
SELECT * FROM employees WHERE dept_id = 101 OR dept_id = 102;
SELECT * FROM employees WHERE NOT dept_id = 101;

-- --- DISTINCT — removes duplicate rows from the result ---
SELECT DISTINCT dept_id FROM employees;
-- WHY IT MATTERS: without DISTINCT, if 5 employees share dept_id
-- 101, that value shows up 5 times in your result — DISTINCT
-- collapses repeated values down to each UNIQUE one, only once

-- --- LIMIT — restricts how many rows come back ---
SELECT * FROM employees LIMIT 3;         -- only the first 3 rows
SELECT * FROM employees LIMIT 3 OFFSET 2;  -- skip 2, then take next 3
-- WHY IT MATTERS: real tables can have millions of rows —
-- pulling everything back when you only need a quick sample is
-- wasteful; LIMIT is also essential for PAGINATION (showing
-- results 10-at-a-time on a website, for example)

-- --- AS — renaming a column (or table) in the OUTPUT only ---
SELECT emp_name AS name, salary AS monthly_pay FROM employees;
-- doesn't change the actual column name in the table — just how
-- it's LABELED in this specific query's result

-- --- CALCULATED/DERIVED COLUMNS — SELECT isn't limited to raw
-- columns, you can compute new values directly in the query ---
SELECT emp_name, salary, salary * 12 AS annual_salary
FROM employees;


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  COMMAND       CATEGORY    WHAT IT DOES                     WITHOUT WHERE CLAUSE
--  ─────────────────────────────────────────────────────────────────────────────
--  INSERT           DML          adds new row(s)                    n/a (always adds specified data)
--  SELECT             DQL          retrieves/reads data                returns ALL rows (often intended)
--  UPDATE               DML          modifies existing row(s)             *** MODIFIES EVERY ROW *** (dangerous)
--  DELETE                 DML          removes existing row(s)              *** DELETES EVERY ROW *** (dangerous)
--  Functions                n/a          compute/aggregate/transform values   used INSIDE the above commands


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  This session switches tools from phpMyAdmin (Session 31)
--     to MySQL Workbench — the more professional, industry-
--     standard SQL editor
-- 2.  INSERT adds new rows — you can insert full rows, partial
--     rows (relying on DEFAULT/NULL for the rest), or multiple
--     rows in one statement
-- 3.  SELECT (technically DQL, not DML) is taught alongside DML
--     because it's inseparable in practice — you always verify
--     INSERT/UPDATE/DELETE results with a SELECT
-- 4.  THE single most important rule of this whole session:
--     UPDATE and DELETE without a WHERE clause affect EVERY ROW
--     in the table — always double-check your WHERE condition
--     (ideally by running it as a SELECT first) before running
--     an UPDATE or DELETE
-- 5.  DELETE (DML) differs from TRUNCATE (DDL, from your earlier
--     note): DELETE allows WHERE conditions and can be rolled
--     back; TRUNCATE removes everything at once and typically can't
-- 6.  SQL Functions — aggregate (COUNT/SUM/AVG/MAX/MIN), string
--     (UPPER/LOWER/LENGTH/CONCAT), numeric (ROUND/ABS), and date
--     (NOW/CURDATE) — let you compute and transform values
--     directly inside a query, without exporting data elsewhere


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. TRANSACTIONS AND ROLLBACK (TCL, from your Session 30/31
--    "types of SQL commands" list): if you're working inside a
--    transaction (BEGIN/START TRANSACTION), a mistaken UPDATE or
--    DELETE can be undone with ROLLBACK before it's COMMITted.
--    Outside an explicit transaction, most DBMS setups auto-
--    commit every statement immediately — meaning a WHERE-less
--    DELETE is often unrecoverable unless you have a backup.
--    Worth knowing as your real safety net once you're doing
--    DML against anything you actually care about.

-- 2. UPSERT (INSERT ... ON DUPLICATE KEY UPDATE in MySQL): lets
--    you INSERT a row, but automatically UPDATE it instead if a
--    row with that key already exists — avoids writing separate
--    "check if exists, then insert or update" logic yourself.

-- 3. CASE WHEN inside UPDATE/SELECT: lets you apply conditional
--    logic directly in SQL (e.g. assigning a grade based on a
--    score range) — genuinely useful once basic INSERT/UPDATE/
--    DELETE feel comfortable, and commonly asked about in
--    interviews as a step up from plain WHERE filtering.

-- ============================================================
-- NEXT TOPIC (per your playlist): Session 33 — SQL Grouping and
-- Sorting (ORDER BY, GROUP BY, GROUP BY on multiple columns,
-- HAVING clause, practiced on the IPL Dataset)
-- ============================================================