-- ============================================================
-- SUBQUERIES IN SQL
-- (CampusX DSMP: Session 35, Week 15 — SQL Continued Part 2)
-- ============================================================

-- NOTE: Joins (last session) combine tables SIDE BY SIDE using
-- a shared key. Subqueries solve a DIFFERENT kind of problem:
-- "I need the RESULT of one query, to use it as an INPUT for
-- another query." Three things covered: what a subquery even
-- is, the different TYPES based on WHERE they're placed, and
-- the crucial INDEPENDENT vs CORRELATED distinction.


-- ============================================================
-- STEP 1: WHAT IS A SUBQUERY?
-- ============================================================

-- A SUBQUERY (also called a "nested query" or "inner query") is
-- a SELECT statement written INSIDE another SQL statement (the
-- "outer query"). The inner query runs first (conceptually),
-- and its result gets used by the outer query.

-- MOTIVATING EXAMPLE: "find all employees who earn MORE than
-- the average salary." You don't know the average salary as a
-- fixed number upfront — you need SQL to CALCULATE it first,
-- then use THAT calculated value to filter employees.

SELECT emp_name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees   -- <- this is the SUBQUERY
);

-- WHY NOT JUST WRITE TWO SEPARATE QUERIES? You technically
-- could — run `SELECT AVG(salary) FROM employees` first, note
-- the number (say, 50000), then manually write
-- `WHERE salary > 50000` as a second query. But that's
-- inflexible, manual, and breaks the moment the underlying data
-- changes. A subquery does BOTH steps in ONE query, automatically
-- staying correct even as the data changes.

-- ANALOGY: a subquery is like asking someone "how does my exam
-- score compare to the class average?" — you can't answer that
-- without FIRST computing the class average (an inner
-- calculation), and THEN comparing your specific score against
-- it (the outer question). You do both in one breath, not as
-- two disconnected questions.


-- ============================================================
-- STEP 2: TYPES OF SUBQUERIES — BASED ON WHERE THEY'RE PLACED
-- ============================================================

-- Subqueries can appear in several DIFFERENT parts of a SQL
-- statement, and behave slightly differently depending on where
-- they sit:

-- --- SUBQUERY IN WHERE ---
-- (the example above — filters rows based on a computed value)
SELECT emp_name FROM employees
WHERE dept_id = (
    SELECT dept_id FROM departments WHERE dept_name = 'Engineering'
);

-- --- SUBQUERY IN FROM (also called a "derived table") ---
-- treats the subquery's RESULT as if it were a real table you
-- can then query further
SELECT dept_id, avg_salary
FROM (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) AS dept_averages          -- <- MUST be given an alias, or SQL errors
WHERE avg_salary > 50000;
-- WHY USE THIS: sometimes you need to GROUP/AGGREGATE data
-- FIRST, and THEN filter or further process the aggregated
-- result — HAVING alone (from your Grouping/Sorting note)
-- can't always express this if the logic gets more complex
-- (e.g. joining this aggregated result against another table)

-- --- SUBQUERY IN SELECT ---
-- computes a value to display as its OWN column, often per row
SELECT emp_name, salary,
    (SELECT AVG(salary) FROM employees) AS company_avg_salary
FROM employees;
-- shows EVERY employee's own salary, alongside the SAME overall
-- company average repeated on every row — useful for direct
-- row-by-row comparison in the output itself

-- --- SUBQUERY WITH IN / NOT IN ---
SELECT emp_name FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments WHERE location_id = 100
);
-- "employees who belong to ANY department located at location 100"

-- --- SUBQUERY WITH EXISTS / NOT EXISTS ---
SELECT dept_name FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id
);
-- "departments that have AT LEAST ONE employee" — EXISTS just
-- checks whether the subquery returns ANY rows at all (doesn't
-- care about their actual values), often more efficient than IN
-- for large datasets


-- ============================================================
-- STEP 3: INDEPENDENT (NON-CORRELATED) SUBQUERIES
-- ============================================================

-- An INDEPENDENT subquery runs COMPLETELY ON ITS OWN — it does
-- NOT reference anything from the outer query. It executes
-- EXACTLY ONCE, produces its result, and that single result gets
-- reused by the outer query for every row it processes.

SELECT emp_name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees   -- doesn't reference `employees`
);                                        -- from the OUTER query specifically —
                                           -- it's a totally self-contained calculation

-- KEY TRAIT: you could literally copy this inner SELECT out,
-- run it BY ITSELF in a separate query window, and it would
-- give you a sensible, complete answer with zero connection to
-- anything outside it — because it genuinely doesn't need
-- anything from outside itself.


-- ============================================================
-- STEP 4: CORRELATED SUBQUERIES
-- ============================================================

-- A CORRELATED subquery DOES reference a column from the OUTER
-- query — which means it CANNOT run on its own; it needs a
-- "current row" from the outer query to even make sense. As a
-- direct consequence, it gets RE-EXECUTED once for EVERY SINGLE
-- ROW the outer query processes, not just once overall.

SELECT e.emp_name, e.salary, e.dept_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE dept_id = e.dept_id     -- <- references `e` from the OUTER query!
);
-- "find employees who earn more than the AVERAGE salary WITHIN
-- THEIR OWN department" (not the overall company average)

-- WALK THROUGH WHY THIS RE-RUNS PER ROW: for Aryan (dept_id=10),
-- the inner query computes the average salary of dept_id=10
-- specifically. For Priya (dept_id=20), the SAME inner query
-- structure now computes the average of dept_id=20 instead —
-- because `e.dept_id` changes with EVERY outer row being
-- checked, the subquery's answer is DIFFERENT each time, so it
-- must be recalculated per row rather than computed just once.

-- TRY COPYING JUST THE INNER PART OUT ON ITS OWN:
--   SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id;
-- This FAILS by itself — `e.dept_id` doesn't exist outside the
-- context of the outer query's current row. This inability to
-- run standalone is the clearest test for "is this correlated?"


-- ============================================================
-- STEP 5: INDEPENDENT vs CORRELATED — SIDE BY SIDE
-- ============================================================

-- INDEPENDENT: "employees earning more than the OVERALL company average"
SELECT emp_name FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- CORRELATED: "employees earning more than THEIR OWN department's average"
SELECT e.emp_name FROM employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE dept_id = e.dept_id
);

-- THE QUESTION THAT TELLS THEM APART: does the answer to the
-- inner query DEPEND on which outer row you're currently
-- looking at? If NO (same answer no matter what) -> independent.
-- If YES (different answer per row) -> correlated.

-- PERFORMANCE IMPLICATION WORTH KNOWING: because correlated
-- subqueries re-execute once PER ROW, they can be significantly
-- SLOWER than independent subqueries on large tables (imagine
-- re-running an AVG() calculation 100,000 times instead of
-- once) — often a JOIN-based rewrite of the same logic performs
-- better, though the subquery version is usually easier to
-- read/reason about first.


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  SUBQUERY TYPE          PLACED IN            REFERENCES OUTER QUERY?   RUNS HOW MANY TIMES?
--  ─────────────────────────────────────────────────────────────────────────────────────
--  Subquery in WHERE          WHERE clause          depends                    once (if independent)
--  Subquery in FROM             FROM clause (derived   NO (self-contained)         once
--                                table), needs an alias
--  Subquery in SELECT             SELECT clause           depends                    once per outer row (if correlated)
--  IN / NOT IN                      WHERE clause              usually independent        once
--  EXISTS / NOT EXISTS                 WHERE clause              usually correlated          once per outer row
--  Independent (non-correlated)          any of the above           NO                          ONCE, total
--  Correlated                              any of the above           YES                         ONCE PER OUTER ROW


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  A subquery is a SELECT statement nested inside another
--     query, letting you use a COMPUTED result as an input to
--     filtering, display, or further querying — all in one statement
-- 2.  Subqueries can appear in different clauses: WHERE (filter
--     using a computed value), FROM (treat a query's result as
--     a temporary table — must be aliased), SELECT (compute a
--     value shown as its own column), and with IN/EXISTS
--     (checking membership/existence)
-- 3.  An INDEPENDENT (non-correlated) subquery runs on its OWN,
--     with NO reference to the outer query — it executes exactly
--     ONCE regardless of how many outer rows exist
-- 4.  A CORRELATED subquery references a column from the OUTER
--     query, meaning it CANNOT run standalone — it re-executes
--     ONCE PER ROW the outer query processes, since its result
--     genuinely differs depending on the current outer row
-- 5.  The clearest test to tell them apart: try running JUST the
--     inner subquery by itself. If it runs fine on its own ->
--     independent. If it errors because it references something
--     from "outside" (like e.dept_id) -> correlated
-- 6.  Correlated subqueries are typically SLOWER than
--     independent ones on large tables, since they repeat their
--     calculation per row rather than computing it once


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. CTEs (Common Table Expressions, WITH clause) — a cleaner
--    alternative syntax to FROM-clause subqueries, letting you
--    name a temporary result upfront before using it:
--      WITH dept_averages AS (
--          SELECT dept_id, AVG(salary) AS avg_salary
--          FROM employees GROUP BY dept_id
--      )
--      SELECT * FROM dept_averages WHERE avg_salary > 50000;
--    Functionally similar to a FROM subquery, but more readable
--    for complex, multi-step queries — genuinely worth learning
--    once basic subqueries feel comfortable, and commonly asked
--    about in interviews as a "cleaner way to write this" follow-up.

-- 2. ANY / ALL with subqueries: lets you compare a value against
--    an ENTIRE SET of subquery results rather than just one:
--      WHERE salary > ANY (SELECT salary FROM employees WHERE dept_id = 20)
--      -- true if salary beats AT LEAST ONE employee in dept 20
--      WHERE salary > ALL (SELECT salary FROM employees WHERE dept_id = 20)
--      -- true only if salary beats EVERY employee in dept 20
--    A less commonly taught but genuinely useful pattern once
--    IN/EXISTS feel solid.

-- 3. SUBQUERY vs JOIN — WHEN TO PREFER WHICH: many subqueries
--    (especially IN/EXISTS-based ones) can be REWRITTEN as
--    equivalent JOINs, and often run FASTER as joins on large
--    datasets, since most database engines optimize joins more
--    aggressively than correlated subqueries. Worth knowing this
--    tradeoff exists, even if this session focuses on the
--    subquery syntax itself rather than rewriting/optimizing them.

-- ============================================================
-- NEXT TOPIC (per your playlist): Session on Making a Flight
-- Dashboard using Python and SQL — connecting MySQL through
-- Python, running SQL queries with Python, and building a
-- dynamic Streamlit dashboard on the Flights dataset
-- ============================================================