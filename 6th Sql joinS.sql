-- ============================================================
-- SQL JOINS
-- (CampusX DSMP: Session 34, Week 15 — SQL Continued Part 2)
-- ============================================================

-- NOTE: Everything so far (DDL, constraints, DML, grouping) has
-- worked within a SINGLE table. This session's entire point is
-- combining data ACROSS MULTIPLE tables — the natural next step,
-- since real databases split data into separate tables linked
-- by FOREIGN KEYS (from your Constraints note), not one giant
-- table with everything crammed in. Covers all join types, SET
-- operations, self joins, and revisits query execution order
-- now that JOIN enters the picture.


-- ============================================================
-- STEP 1: WHY DO WE EVEN NEED JOINS?
-- ============================================================

-- Recall from your Database Fundamentals note: reduced
-- redundancy is a core property of a good database. If you kept
-- department NAME repeated inside every single employee row,
-- you'd be duplicating that string hundreds of times. Instead,
-- you store department info ONCE (in a `departments` table) and
-- just keep a dept_id FOREIGN KEY reference inside `employees`.

-- The tradeoff: now the FULL picture ("Aryan works in the
-- Engineering department") is SPLIT across two tables. A JOIN
-- is how you stitch that split information back together into
-- one combined result, using the shared key (dept_id) as the
-- connecting thread.

-- Setup used throughout this note:
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Sample data to trace through every join type below:
-- departments: (10, 'Engineering'), (20, 'Sales'), (30, 'HR')
-- employees:   (1,'Aryan',10), (2,'Priya',20), (3,'Rohan',NULL)
-- NOTE: Rohan has NO department (dept_id is NULL), and 'HR' (30)
-- has NO employees — these two "gaps" are exactly what
-- distinguish the different join types from each other below.


-- ============================================================
-- STEP 2: INNER JOIN — ONLY WHAT MATCHES ON BOTH SIDES
-- ============================================================

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- RESULT: only Aryan-Engineering and Priya-Sales show up.
-- Rohan is EXCLUDED (his dept_id is NULL, matches nothing).
-- HR is EXCLUDED (no employee has dept_id = 30).

-- ANALOGY: INNER JOIN is the OVERLAP region of a Venn diagram —
-- only rows that exist meaningfully on BOTH sides survive.

-- NOTE THE `e` and `d` ALIASES: when joining tables, giving each
-- table a short alias (e, d) lets you write `e.dept_id` instead
-- of the full `employees.dept_id` every time — purely for
-- readability, especially once queries involve 3+ tables.


-- ============================================================
-- STEP 3: LEFT JOIN (LEFT OUTER JOIN) — ALL OF LEFT, MATCHED FROM RIGHT
-- ============================================================

SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- RESULT: ALL 3 employees appear — Aryan-Engineering,
-- Priya-Sales, AND Rohan-NULL (since Rohan has no matching
-- department, the department column just shows NULL instead of
-- dropping his row entirely).

-- WHEN TO USE: "show me every employee, and their department IF
-- they have one" — you want to KEEP every row from the LEFT
-- table (employees, listed first in FROM) no matter what.


-- ============================================================
-- STEP 4: RIGHT JOIN (RIGHT OUTER JOIN) — ALL OF RIGHT, MATCHED FROM LEFT
-- ============================================================

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- RESULT: ALL 3 departments appear — Aryan-Engineering,
-- Priya-Sales, AND NULL-HR (HR has no employees, so the
-- emp_name column shows NULL for that row, but HR still appears).

-- RIGHT JOIN is just LEFT JOIN with the tables' roles reversed
-- — practically, most people just swap table order and use LEFT
-- JOIN instead, since it reads more naturally left-to-right, but
-- RIGHT JOIN exists and behaves exactly as this mirror logic suggests.


-- ============================================================
-- STEP 5: FULL OUTER JOIN — EVERYTHING FROM BOTH SIDES
-- ============================================================

SELECT e.emp_name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- RESULT: ALL employees AND all departments — Aryan-Engineering,
-- Priya-Sales, Rohan-NULL, AND NULL-HR — nothing gets dropped
-- from either side, gaps filled with NULL wherever there's no match.

-- MYSQL-SPECIFIC NOTE: MySQL does NOT support FULL OUTER JOIN
-- directly (unlike PostgreSQL/SQL Server) — you have to simulate
-- it using UNION of a LEFT JOIN and a RIGHT JOIN:
SELECT e.emp_name, d.dept_name FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- Worth knowing this workaround exists, since DSMP uses MySQL
-- (Workbench/XAMPP) — you may hit this exact limitation in practice.


-- ============================================================
-- STEP 6: CROSS JOIN — EVERY POSSIBLE COMBINATION
-- ============================================================

SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- RESULT: EVERY employee paired with EVERY department — 3
-- employees x 3 departments = 9 total rows. No ON condition at
-- all — this is the CARTESIAN PRODUCT of both tables.

-- WHEN IS THIS ACTUALLY USEFUL? Rare in everyday querying, but
-- genuinely useful for generating COMBINATIONS — e.g. every
-- possible (product, size) pairing for a retail catalog, or
-- every (date, store) combination for a reporting calendar,
-- even before you have real sales data for each combination yet.

-- WARNING: CROSS JOIN on large tables gets HUGE fast (a
-- 1000-row table cross joined with another 1000-row table = 1
-- million rows) — easy to accidentally do this by forgetting an
-- ON condition on a regular JOIN, which is a common beginner mistake.


-- ============================================================
-- STEP 7: SELF JOIN — JOINING A TABLE TO ITSELF
-- ============================================================

-- A SELF JOIN isn't a separate join TYPE (it still uses INNER/
-- LEFT/etc.) — it's just a join where a table is joined to
-- ITSELF, using two different ALIASES to distinguish the "two
-- copies" being compared.

-- CLASSIC USE CASE: an employees table with a manager_id column
-- that ALSO refers back to emp_id in the SAME table (employees
-- reporting to other employees):

CREATE TABLE staff (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT   -- refers back to another emp_id in THIS table
);

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM staff e
INNER JOIN staff m ON e.manager_id = m.emp_id;

-- HOW THIS WORKS: the SAME `staff` table is used TWICE in one
-- query — once aliased as `e` (representing "the employee"),
-- once aliased as `m` (representing "that employee's manager").
-- SQL doesn't physically duplicate the table — the aliases just
-- let you reference the same data as if it were two tables, so
-- you can compare rows within it against each other.

-- ANOTHER COMMON USE: comparing rows within the same table, e.g.
-- finding employees who earn MORE than a specific colleague, or
-- finding pairs of products with the same category.


-- ============================================================
-- STEP 8: SET OPERATIONS — UNION, UNION ALL, INTERSECT, EXCEPT
-- ============================================================

-- SET operations combine the RESULTS of two SEPARATE SELECT
-- queries VERTICALLY (stacking rows), unlike JOINs which combine
-- tables HORIZONTALLY (side-by-side, matching on a key).

-- REQUIREMENT: both SELECT queries must return the SAME NUMBER
-- of columns, with COMPATIBLE data types, in the same order.

-- --- UNION — combines rows from both queries, REMOVES duplicates ---
SELECT emp_name FROM employees
UNION
SELECT dept_name FROM departments;
-- (contrived example just to show mechanics — in practice
-- you'd UNION two queries with genuinely comparable meaning,
-- e.g. combining "2023 customers" and "2024 customers" into one list)

-- --- UNION ALL — combines rows from both queries, KEEPS duplicates ---
SELECT emp_name FROM employees
UNION ALL
SELECT dept_name FROM departments;
-- FASTER than UNION, since it skips the extra step of checking
-- for and removing duplicates — use UNION ALL whenever you
-- KNOW there won't be duplicates, or don't care if there are

-- --- INTERSECT — only rows that appear in BOTH queries ---
-- (Not supported in older MySQL versions — available in MySQL
-- 8.0.31+, PostgreSQL, SQL Server)
SELECT emp_name FROM employees
INTERSECT
SELECT emp_name FROM former_employees;
-- "which names appear in BOTH the current and former employee lists?"

-- --- EXCEPT (aka MINUS in some databases) — rows in the FIRST
-- query that do NOT appear in the second ---
SELECT emp_name FROM employees
EXCEPT
SELECT emp_name FROM former_employees;
-- "which current employees have NEVER been a former employee?"


-- ============================================================
-- STEP 9: QUERY EXECUTION ORDER, REVISITED WITH JOIN ADDED
-- ============================================================

-- Recall from your Grouping and Sorting note:
--   FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

-- JOIN slots in as PART of the FROM step, executed FIRST,
-- before WHERE even runs:

--   FROM + JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

-- WHY THIS ORDER MATTERS PRACTICALLY: since JOIN happens before
-- WHERE, you CAN filter on columns from EITHER joined table in
-- your WHERE clause, because by the time WHERE runs, the tables
-- are already combined:

SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Engineering';   -- filtering on the JOINED table's column works fine

-- ONE SUBTLE GOTCHA WORTH KNOWING: putting a filter condition on
-- the RIGHT table INSIDE the ON clause behaves DIFFERENTLY than
-- putting it in WHERE, specifically for OUTER joins:

SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.dept_name = 'Engineering';
-- this keeps ALL employees (LEFT JOIN still preserves every
-- employee row), but only shows dept_name when it's Engineering
-- — non-Engineering employees get NULL for dept_name, not
-- excluded entirely

SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Engineering';
-- this ELIMINATES non-Engineering rows entirely (including
-- Rohan, who had no department at all) — because WHERE runs
-- AFTER the join, and NULL != 'Engineering' fails the condition
-- This is a genuinely common source of subtle bugs — worth
-- testing carefully whenever mixing OUTER JOINs with WHERE.


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  JOIN TYPE          MATCHED ROWS    UNMATCHED LEFT    UNMATCHED RIGHT
--  ─────────────────────────────────────────────────────────────────
--  INNER JOIN              kept              dropped            dropped
--  LEFT JOIN                 kept              kept (NULL)        dropped
--  RIGHT JOIN                  kept              dropped            kept (NULL)
--  FULL OUTER JOIN                kept              kept (NULL)        kept (NULL)
--  CROSS JOIN                       every combination (no matching concept at all)
--  SELF JOIN                          same table, aliased twice — behaves per join type used

--  SET OPERATION      DUPLICATES?       REQUIRES SAME COLUMN COUNT/TYPES?
--  ─────────────────────────────────────────────────────────────────
--  UNION                   removed               YES
--  UNION ALL                 kept                   YES
--  INTERSECT                   only rows in BOTH        YES
--  EXCEPT/MINUS                   only rows in FIRST only   YES


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  Joins combine data ACROSS tables (horizontally, using a
--     shared key); SET operations combine RESULTS of separate
--     queries (vertically, stacking rows) — genuinely different
--     mechanisms, easy to conflate as "just more ways to combine data"
-- 2.  INNER JOIN keeps only rows that match on BOTH sides; LEFT/
--     RIGHT JOIN additionally preserve ALL rows from one
--     specific side (filling gaps with NULL); FULL OUTER JOIN
--     preserves everything from BOTH sides
-- 3.  CROSS JOIN produces the CARTESIAN PRODUCT (every
--     combination) — no matching logic at all, and can explode
--     in size quickly on larger tables
-- 4.  SELF JOIN isn't a distinct join type — it's any join
--     (usually INNER) applied to ONE table referenced TWICE
--     under different aliases, most commonly for hierarchical
--     data like employee-manager relationships
-- 5.  UNION removes duplicate rows across two queries' results;
--     UNION ALL keeps duplicates and is faster; both require
--     matching column count/types across the combined queries
-- 6.  JOIN executes as part of the FROM step, BEFORE WHERE — so
--     WHERE can filter on columns from either joined table, but
--     be careful: filtering an OUTER-joined table's column in
--     WHERE (vs inside the ON clause) can unintentionally
--     eliminate rows that the OUTER JOIN was specifically meant
--     to preserve
-- 7.  MySQL doesn't natively support FULL OUTER JOIN — it must
--     be simulated with a UNION of a LEFT JOIN and a RIGHT JOIN


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. SEMI-JOINS AND ANTI-JOINS: not real SQL keywords, but
--    common PATTERNS — a semi-join ("does a matching row exist?"
--    without pulling its columns) is typically written with
--    WHERE ... IN (subquery) or WHERE EXISTS (...); an anti-join
--    ("rows with NO match") is written with NOT IN or
--    WHERE NOT EXISTS, or LEFT JOIN ... WHERE right_table.key IS
--    NULL. Genuinely useful patterns, likely to come up more
--    naturally once your NEXT session (Subqueries) is covered.

-- 2. JOINING 3+ TABLES: everything shown here uses 2 tables, but
--    real queries often chain multiple JOINs together
--    (employees -> departments -> locations, for example) — the
--    same ON-condition logic just repeats for each additional
--    JOIN clause, executed left to right.

-- 3. JOIN PERFORMANCE / INDEXES: joining on a column that has an
--    INDEX (often automatically true for PRIMARY KEY/FOREIGN
--    KEY columns) is dramatically faster than joining on an
--    un-indexed column, especially as tables grow large — a
--    practical consideration once you move beyond toy-sized
--    tables, not usually covered until a dedicated performance/
--    optimization topic.

-- ============================================================
-- NEXT TOPIC (per your playlist): SQL Case Study 1 — Zomato
-- Dataset (applying joins to a real dataset), then Session 35 —
-- Subqueries in SQL
-- ============================================================


