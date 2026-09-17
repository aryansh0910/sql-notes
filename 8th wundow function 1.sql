-- ============================================================
-- WINDOW FUNCTIONS IN SQL — PART 1
-- (CampusX DSMP: Session 36, Week 16 — Advanced SQL)
-- ============================================================

-- NOTE: GROUP BY (your earlier note) COLLAPSES multiple rows
-- into ONE summary row per group — you lose the individual
-- rows. Window functions solve a DIFFERENT problem: "I want to
-- compute something ACROSS a set of related rows, but still
-- show EVERY individual row in the output." This is the single
-- most important conceptual distinction in this whole session.


-- ============================================================
-- STEP 1: WHAT ARE WINDOW FUNCTIONS?
-- ============================================================

-- A WINDOW FUNCTION performs a calculation across a SET of rows
-- that are somehow related to the CURRENT row (this related set
-- is called the "window") — but UNLIKE GROUP BY, it does NOT
-- collapse those rows into one summary row. Every original row
-- stays visible in the output, now WITH an extra computed
-- column showing the window calculation's result.

-- CONCRETE COMPARISON — same data, two totally different outputs:

-- GROUP BY version: collapses to ONE row per department
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id;
-- Output: 1 row per department — individual employees are GONE

-- WINDOW FUNCTION version: shows EVERY employee, PLUS their
-- department's average sitting alongside them
SELECT emp_name, dept_id, salary,
    AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg_salary
FROM employees;
-- Output: EVERY employee row still shows up individually, each
-- one ALSO displaying their department's average salary

-- ANALOGY: GROUP BY is like asking each department to submit
-- ONE combined report instead of individual employee records.
-- A window function is like giving EVERY employee their OWN
-- individual record, but with a sticky note attached showing
-- "by the way, here's your department's average" — nobody's
-- individual information gets thrown away.


-- ============================================================
-- STEP 2: THE OVER() CLAUSE — THE HEART OF EVERY WINDOW FUNCTION
-- ============================================================

-- OVER() is what turns an ordinary function into a WINDOW
-- function — it defines the "window" (the related set of rows)
-- that the function should look at for each row.

--   FUNCTION_NAME() OVER (
--       PARTITION BY column   -- optional: splits rows into groups
--       ORDER BY column         -- optional: defines order WITHIN each group
--   )

-- PARTITION BY works similarly in spirit to GROUP BY — it
-- splits rows into separate buckets by a shared column value.
-- BUT unlike GROUP BY, PARTITION BY does NOT collapse anything
-- — it just tells the window function "only look at rows within
-- THIS SAME partition when computing your result for this row."

SELECT emp_name, dept_id, salary,
    AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg
FROM employees;
-- "for each employee, compute the average salary, but ONLY
-- considering employees within their SAME department"

-- WITHOUT PARTITION BY, the window is the ENTIRE result set:
SELECT emp_name, salary,
    AVG(salary) OVER () AS company_avg
FROM employees;
-- every row gets the SAME company-wide average attached


-- ============================================================
-- STEP 3: ROW_NUMBER() — UNIQUE SEQUENTIAL NUMBERING
-- ============================================================

SELECT emp_name, dept_id, salary,
    ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS row_num
FROM employees;

-- WHAT IT DOES: assigns 1, 2, 3, 4... in order, WITHIN each
-- partition (here, within each department), based on the
-- ORDER BY. Numbers are ALWAYS unique and sequential — even if
-- two employees have the EXACT same salary, they still get
-- DIFFERENT numbers (SQL picks an arbitrary tie-breaker order
-- internally when values are equal).

-- COMMON REAL USE CASE: "find the TOP 1 highest-paid employee
-- PER department" — something GROUP BY genuinely cannot answer
-- alone, since GROUP BY can give you the MAX salary, but not
-- WHICH employee has it, by name, per group:

SELECT * FROM (
    SELECT emp_name, dept_id, salary,
        ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
) ranked
WHERE rn = 1;
-- (using a FROM-clause subquery, from your Subqueries note,
-- since window function results can't be filtered directly in
-- WHERE — they're computed too late in the execution order,
-- same reasoning as why WHERE can't use aggregates)


-- ============================================================
-- STEP 4: RANK() vs DENSE_RANK() vs ROW_NUMBER() — THE KEY DIFFERENCE
-- ============================================================

-- All 3 assign a position/ranking, but handle TIES completely differently:

SELECT emp_name, salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
    RANK()       OVER (ORDER BY salary DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_num
FROM employees;

-- Example with a tie (2 employees both earning 60000):
--  emp_name  | salary  | row_num | rank_num | dense_rank_num
--  ---------------------------------------------------------
--  Priya       60000     1          1            1
--  Rohan        60000     2          1            1
--  Simran        55000     3          3            2
--  Aryan          50000     4          4            3

-- ROW_NUMBER: ALWAYS unique, no ties allowed — just keeps
--   counting up regardless of equal values (1,2,3,4)
-- RANK: ties get the SAME number, but the NEXT rank SKIPS
--   ahead by however many rows were tied (1,1,3,4 — notice "2" is skipped)
-- DENSE_RANK: ties get the SAME number, but NO gap afterward
--   (1,1,2,3 — every rank number is used, nothing skipped)

-- WHICH TO USE WHEN: ROW_NUMBER when you need a truly unique
-- position for each row regardless of ties (e.g. picking exactly
-- ONE "top" row per group). RANK when ties should be visible AND
-- you want the skipped-number behavior to reflect "these 2 people
-- are both tied for 1st, so the next person is genuinely 3rd
-- place." DENSE_RANK when ties should be visible but you don't
-- want any gaps in the ranking sequence at all.


-- ============================================================
-- STEP 5: FIRST_VALUE() AND LAST_VALUE()
-- ============================================================

-- Return the FIRST or LAST value within the window, based on
-- the ORDER BY — useful for comparing every row against a
-- window's starting or ending point.

SELECT emp_name, dept_id, salary,
    FIRST_VALUE(emp_name) OVER (
        PARTITION BY dept_id ORDER BY salary DESC
    ) AS highest_paid_in_dept
FROM employees;
-- every employee's row now ALSO shows who the highest earner
-- in THEIR department is — a direct comparison point attached
-- to every single row

SELECT emp_name, dept_id, salary,
    LAST_VALUE(emp_name) OVER (
        PARTITION BY dept_id ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_paid_in_dept
FROM employees;
-- NOTE the extra ROWS BETWEEN clause here — this is NOT
-- optional for LAST_VALUE to behave as expected. Without it,
-- LAST_VALUE's default frame only looks at rows UP TO the
-- current one (see Step 6), so it would give a DIFFERENT
-- "last value" for every row instead of the true group-wide
-- last value. This exact gotcha is precisely why frames
-- (Step 6) matter and get taught right after this.


-- ============================================================
-- STEP 6: THE CONCEPT OF FRAMES
-- ============================================================

-- A FRAME is a further refinement WITHIN a partition — it
-- defines EXACTLY which rows, relative to the CURRENT row,
-- should be included in the window's calculation. This is what
-- makes RUNNING TOTALS and MOVING AVERAGES possible.

-- DEFAULT FRAME BEHAVIOR (when ORDER BY is used without an
-- explicit frame): "RANGE BETWEEN UNBOUNDED PRECEDING AND
-- CURRENT ROW" — meaning the window only includes ALL ROWS
-- FROM THE START of the partition UP TO the current row —
-- NOT the whole partition. This default is EXACTLY why
-- LAST_VALUE needed that extra ROWS BETWEEN clause in Step 5 —
-- without it, "last value" effectively means "the current row
-- itself," since nothing after it is included by default.

-- EXPLICIT FRAME SYNTAX:
--   ROWS BETWEEN <start> AND <end>
--   where <start>/<end> can be:
--     UNBOUNDED PRECEDING  -> all the way to the start of the partition
--     N PRECEDING            -> N rows before the current one
--     CURRENT ROW              -> the row being processed right now
--     N FOLLOWING                -> N rows after the current one
--     UNBOUNDED FOLLOWING           -> all the way to the end of the partition

-- RUNNING TOTAL example — frame grows as you move down the rows:
SELECT emp_name, salary,
    SUM(salary) OVER (
        ORDER BY emp_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM employees;
-- row 1's running_total = just its own salary
-- row 2's running_total = row1 + row2's salaries
-- row 3's running_total = row1 + row2 + row3's salaries, and so on

-- MOVING AVERAGE example — frame is a fixed-size "sliding window":
SELECT emp_name, salary,
    AVG(salary) OVER (
        ORDER BY emp_id
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS moving_avg_3
FROM employees;
-- for each row, averages ITSELF plus the row immediately before
-- and immediately after it — a classic "3-row moving average"


-- ============================================================
-- STEP 7: LAG() AND LEAD()
-- ============================================================

-- LAG() looks BACKWARD — fetches a value from a PREVIOUS row
-- (relative to the current one, based on ORDER BY).
-- LEAD() looks FORWARD — fetches a value from a FOLLOWING row.

SELECT emp_name, join_date, salary,
    LAG(salary) OVER (ORDER BY join_date) AS previous_employee_salary,
    LEAD(salary) OVER (ORDER BY join_date) AS next_employee_salary
FROM employees;

-- YOU CAN SPECIFY HOW FAR BACK/FORWARD (default is 1 row):
SELECT emp_name, salary,
    LAG(salary, 2) OVER (ORDER BY emp_id) AS salary_2_rows_ago
FROM employees;

-- GENUINELY COMMON REAL USE CASE: comparing a value to the
-- PREVIOUS period — e.g. "how much did this month's revenue
-- change compared to LAST month's?"
SELECT month, revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS change
FROM monthly_sales;
-- for the FIRST row (no previous row exists), LAG returns NULL
-- automatically — worth handling that NULL if it matters
-- downstream (e.g. with COALESCE)


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  FUNCTION            WHAT IT RETURNS                              HANDLES TIES HOW?
--  ─────────────────────────────────────────────────────────────────────────────
--  ROW_NUMBER()             unique sequential number (1,2,3,4...)          no ties possible, always unique
--  RANK()                     position, same number for ties, SKIPS gaps     ties share rank, next skips ahead
--  DENSE_RANK()                  position, same number for ties, NO gaps       ties share rank, next is +1, no skip
--  FIRST_VALUE()                    first value in the window/frame               n/a
--  LAST_VALUE()                       last value in window/frame (needs explicit    n/a
--                                       frame to mean "whole partition")
--  LAG(col, n)                          value from n rows BEFORE current row           n/a
--  LEAD(col, n)                           value from n rows AFTER current row            n/a


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  The core distinction from GROUP BY: window functions
--     compute across a related set of rows WITHOUT collapsing
--     them — every original row stays visible in the output
-- 2.  OVER() is what makes a function a "window function" —
--     PARTITION BY splits rows into groups (like GROUP BY, but
--     without collapsing), ORDER BY defines sequence within each group
-- 3.  ROW_NUMBER always gives unique numbers even with ties;
--     RANK gives ties the same number but SKIPS the next
--     number(s); DENSE_RANK gives ties the same number with NO
--     gap in the sequence afterward
-- 4.  FIRST_VALUE/LAST_VALUE fetch the first/last value in the
--     window — but LAST_VALUE needs an EXPLICIT frame
--     (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
--     to actually mean "last in the whole partition," since the
--     DEFAULT frame only extends up to the current row
-- 5.  A FRAME defines exactly which rows (relative to the
--     current one) get included in the calculation — this is
--     what makes running totals (UNBOUNDED PRECEDING AND
--     CURRENT ROW) and moving averages (N PRECEDING AND N
--     FOLLOWING) possible
-- 6.  LAG() fetches a value from a PREVIOUS row, LEAD() from a
--     FOLLOWING row — both essential for period-over-period
--     comparisons (e.g. this month vs last month)
-- 7.  Window function results CANNOT be filtered directly in
--     WHERE (same execution-order reasoning as aggregates in
--     WHERE from your Grouping/Sorting note) — you must wrap the
--     query in a subquery/CTE and filter the OUTER query instead


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. ROWS vs RANGE in frame definitions: this note used ROWS
--    BETWEEN throughout, but SQL also supports RANGE BETWEEN —
--    the difference matters specifically when there are TIES in
--    the ORDER BY column. ROWS counts PHYSICAL rows; RANGE
--    treats all rows with the SAME order-by value as part of the
--    same logical group for framing purposes. A subtle
--    distinction, likely to come up if you ever get unexpected
--    results with duplicate values in your ORDER BY column.

-- 2. NTILE(n) — divides rows into n roughly equal buckets
--    (e.g. NTILE(4) for quartiles) — genuinely useful for
--    segmentation analysis, and worth knowing exists even though
--    it's not in THIS session's explicit topic list (it's
--    closely related to "Quantiles/Percentiles/Segmentation,"
--    which shows up in Part 3 of this Window Functions series later on).

-- 3. WINDOW FUNCTIONS AND PERFORMANCE: computing window
--    functions, especially with large frames or on huge tables,
--    can be genuinely expensive — each row potentially requires
--    scanning many other rows within its window. Worth being
--    aware of this as a performance consideration once you're
--    working with production-scale data, not just small practice tables.

-- ============================================================
-- NEXT TOPIC (per your playlist): Session 37 — Window Functions
-- Part 2 (Ranking continued, Cumulative sum and average, Running
-- average, Percent of total)
-- ============================================================