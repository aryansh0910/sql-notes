-- ============================================================
-- SQL GROUPING AND SORTING
-- (CampusX DSMP: Session 33, Week 14 — SQL Continued Part 1)
-- ============================================================

-- NOTE: Last session (DML) let you filter INDIVIDUAL rows with
-- WHERE. This session is about two DIFFERENT jobs entirely:
-- SORTING the rows you get back (ORDER BY), and COLLAPSING many
-- rows into SUMMARY groups (GROUP BY) — then filtering those
-- summarized groups specifically (HAVING). Practiced on a real,
-- messy dataset (IPL) rather than the toy `employees` table
-- used so far — closer to actual data analysis work.


-- ============================================================
-- STEP 1: SORTING DATA — ORDER BY
-- ============================================================

-- ORDER BY sorts the ROWS of your result — it doesn't reduce,
-- combine, or remove any rows, it just changes the ORDER they
-- come back in.

SELECT * FROM employees
ORDER BY salary;              -- ascending by default (lowest first)

SELECT * FROM employees
ORDER BY salary DESC;          -- descending explicitly (highest first)

SELECT * FROM employees
ORDER BY salary ASC;            -- ascending, written explicitly

-- SORTING BY MULTIPLE COLUMNS — later columns act as TIE-BREAKERS
-- only when earlier columns have equal values:
SELECT * FROM employees
ORDER BY dept_id ASC, salary DESC;
-- reads as: "group by department order first, and WITHIN each
-- department, show highest-paid employees first" — you can mix
-- ASC and DESC freely across different columns in the same query

-- COMBINING WITH LIMIT (from your DML note) — a very common
-- real-world pattern: "top N" queries
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 5;                        -- top 5 highest-paid employees


-- ============================================================
-- STEP 2: GROUP BY — COLLAPSING ROWS INTO SUMMARY GROUPS
-- ============================================================

-- GROUP BY takes rows that share the SAME value in a chosen
-- column and COLLAPSES them into ONE summary row per unique
-- value — almost always paired with an AGGREGATE FUNCTION
-- (COUNT, SUM, AVG, MAX, MIN — from your DML Functions note) to
-- actually compute something meaningful about each group.

SELECT dept_id, COUNT(*) AS num_employees
FROM employees
GROUP BY dept_id;
-- output: ONE row per unique dept_id, showing how many
-- employees belong to it — NOT one row per employee anymore

SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id;

-- ANALOGY: imagine dumping a big pile of receipts on a table,
-- then sorting them into separate labeled envelopes by store
-- name (dept_id here) — GROUP BY is the act of sorting into
-- envelopes; the aggregate function (SUM, COUNT, etc.) is you
-- then adding up the total inside EACH envelope separately

-- CRITICAL RULE: every column in your SELECT list must EITHER
-- be part of the GROUP BY, OR be wrapped in an aggregate
-- function — you can't mix a "raw" ungrouped column with
-- grouped/aggregated ones, because SQL wouldn't know WHICH
-- individual row's value to show for a column that got collapsed:

-- This is INVALID in strict SQL mode (ambiguous — which
-- employee's emp_name would represent the whole group?):
-- SELECT emp_name, dept_id, COUNT(*) FROM employees GROUP BY dept_id;


-- ============================================================
-- STEP 3: GROUP BY ON MULTIPLE COLUMNS
-- ============================================================

-- You can group by MORE THAN ONE column — this creates a
-- separate summary group for every UNIQUE COMBINATION of the
-- listed columns, not just each column individually.

SELECT dept_id, join_year, COUNT(*) AS num_employees
FROM employees
GROUP BY dept_id, join_year;
-- output: one row per UNIQUE (dept_id, join_year) pair — e.g.
-- "dept 101, joined 2023" is a DIFFERENT group from
-- "dept 101, joined 2024", even though dept_id matches

-- REAL EXAMPLE ON THE IPL DATASET (what the session practices
-- on): find how many times each BATSMAN got out to each BOWLER
SELECT batsman, bowler, COUNT(*) AS times_dismissed
FROM deliveries
WHERE player_dismissed IS NOT NULL
GROUP BY batsman, bowler
ORDER BY times_dismissed DESC;
-- this is a genuinely realistic multi-column GROUP BY use case
-- — a single-column GROUP BY couldn't answer this question at all


-- ============================================================
-- STEP 4: HAVING — FILTERING GROUPS (NOT INDIVIDUAL ROWS)
-- ============================================================

-- WHERE filters INDIVIDUAL ROWS, BEFORE any grouping happens.
-- HAVING filters GROUPS, AFTER GROUP BY has already collapsed
-- rows into summaries — and HAVING can reference AGGREGATE
-- functions directly, which WHERE cannot do.

-- This FAILS — you cannot use an aggregate function inside WHERE:
-- SELECT dept_id, COUNT(*) FROM employees
-- WHERE COUNT(*) > 5 GROUP BY dept_id;    -- INVALID

-- This is the CORRECT way — use HAVING instead:
SELECT dept_id, COUNT(*) AS num_employees
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 5;
-- "only show departments that end up with MORE THAN 5 employees
-- AFTER grouping" — this question is fundamentally impossible to
-- ask using WHERE, since WHERE runs before COUNT(*) even exists

-- YOU CAN USE WHERE AND HAVING TOGETHER — they filter at
-- DIFFERENT STAGES of the same query:
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
WHERE join_year >= 2022        -- STEP 1: filter individual rows FIRST
GROUP BY dept_id                -- STEP 2: THEN group the filtered rows
HAVING AVG(salary) > 50000;      -- STEP 3: THEN filter the resulting groups


-- ============================================================
-- STEP 5: THE FULL QUERY EXECUTION ORDER (CRITICAL MENTAL MODEL)
-- ============================================================

-- SQL clauses are WRITTEN in one order, but actually EXECUTED
-- in a DIFFERENT logical order — understanding this explains
-- exactly WHY WHERE can't use aggregates but HAVING can:

--   WRITTEN ORDER:      SELECT -> FROM -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT
--   EXECUTION ORDER:      FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

-- Walking through WHY this order makes sense:
--   1. FROM     -> figure out which table(s) we're even working with
--   2. WHERE     -> filter individual rows FIRST, before any
--                    grouping/aggregation exists at all
--   3. GROUP BY   -> collapse the (already-filtered) rows into groups
--   4. HAVING      -> NOW aggregate values exist -> filter GROUPS
--                      using them
--   5. SELECT       -> decide which columns/computed values to
--                       actually display
--   6. ORDER BY      -> sort the final result set
--   7. LIMIT           -> finally, cut down to N rows

-- This is WHY: WHERE runs at step 2, before COUNT()/SUM()/AVG()
-- results even exist yet (those get computed at step 3) — so
-- WHERE literally has nothing aggregate to filter on. HAVING
-- runs at step 4, AFTER aggregation, so it CAN reference COUNT(),
-- SUM(), etc. directly.


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  CLAUSE          FILTERS WHAT              RUNS WHEN (execution order)   CAN USE AGGREGATES?
--  ─────────────────────────────────────────────────────────────────────────────────────
--  WHERE                individual rows            BEFORE grouping                  NO
--  GROUP BY               collapses rows into groups   AFTER WHERE, before HAVING       n/a (creates the groups)
--  HAVING                    filters GROUPS               AFTER GROUP BY                    YES
--  ORDER BY                    sorts the final rows          near the END (before LIMIT)       YES (can sort by an aggregate)
--  LIMIT                         restricts row count             VERY LAST                          n/a


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  ORDER BY sorts rows (ascending by default, DESC for
--     descending) WITHOUT changing how many rows come back —
--     it's purely about display order
-- 2.  Sorting by MULTIPLE columns uses later columns only as
--     TIE-BREAKERS when earlier columns are equal — ASC and DESC
--     can be mixed freely across different columns
-- 3.  GROUP BY collapses rows sharing the same value into ONE
--     summary row per group, almost always paired with an
--     aggregate function (COUNT/SUM/AVG/MAX/MIN)
-- 4.  Every column in SELECT must either be in the GROUP BY list
--     or wrapped in an aggregate function — mixing raw ungrouped
--     columns with aggregated ones is invalid/ambiguous
-- 5.  GROUP BY on MULTIPLE columns creates a separate group for
--     every UNIQUE COMBINATION of those columns, not each column
--     independently
-- 6.  WHERE filters INDIVIDUAL ROWS before grouping happens;
--     HAVING filters GROUPS after grouping/aggregation has
--     already occurred — this is why only HAVING can reference
--     aggregate functions like COUNT()/SUM() directly
-- 7.  The full logical execution order is: FROM -> WHERE ->
--     GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT — this
--     explains every rule above about what each clause can and
--     can't reference
-- 8.  GROUP BY vs DISTINCT (from your DML note): DISTINCT only
--     removes duplicate rows from output; GROUP BY does that too,
--     but ADDITIONALLY allows aggregate calculations per group —
--     GROUP BY is strictly more powerful for analysis purposes


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. NULLS FIRST / NULLS LAST in ORDER BY: by default, how NULL
--    values get sorted (first or last) can vary by database
--    system. Some databases (like PostgreSQL) let you control
--    this explicitly: ORDER BY column NULLS LAST. MySQL doesn't
--    support this exact syntax (it uses a workaround with
--    ISNULL() instead) — worth knowing this behavior isn't
--    universal if you ever switch database systems.

-- 2. ROLLUP / CUBE (advanced grouping): some databases support
--    GROUP BY ... WITH ROLLUP to automatically add SUBTOTAL rows
--    (e.g. a grand total row after all the individual dept_id
--    groups) — genuinely useful for reporting-style queries, but
--    a step beyond basic GROUP BY and likely not covered until
--    much later, if at all, in this course.

-- 3. FILTERING vs AGGREGATING PERFORMANCE NOTE: WHERE filtering
--    rows BEFORE grouping is not just a syntax rule — it's also
--    a PERFORMANCE consideration. Filtering early (WHERE) means
--    less data needs to be grouped/aggregated at all, which is
--    faster than grouping everything first and filtering
--    afterward with HAVING when a WHERE clause could have
--    accomplished the same row-level filtering earlier.

-- ============================================================
-- NEXT TOPIC (per your playlist): likely SQL Joins — combining
-- data from MULTIPLE tables (INNER, LEFT, RIGHT, FULL joins)
-- ============================================================