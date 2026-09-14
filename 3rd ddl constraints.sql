-- ============================================================
-- SQL CONSTRAINTS — DEEP DIVE
-- (CampusX DSMP: covered as part of Session 31 — SQL DDL Commands)
-- ============================================================

-- NOTE: The last note (DDL Commands) mentioned constraints
-- briefly while covering CREATE TABLE — PRIMARY KEY, NOT NULL,
-- UNIQUE, DEFAULT, FOREIGN KEY. This note is the proper deep
-- dive Nitish gives each one, since constraints are really the
-- mechanism that ENFORCES the "properties of a good database"
-- from Session 30 (consistency, reduced redundancy, data
-- integrity) — theory becoming actual enforceable rules.


-- ============================================================
-- STEP 1: WHAT IS A CONSTRAINT, CONCEPTUALLY?
-- ============================================================

-- A CONSTRAINT is a RULE enforced by the DBMS on a column (or
-- combination of columns) that restricts what values can
-- actually be inserted or updated into that column. If an
-- INSERT/UPDATE would violate a constraint, the DBMS REJECTS
-- the operation entirely — it never lets bad data get in in
-- the first place.

-- WHY THIS MATTERS: recall from Session 30, "properties of a
-- good database" included consistency and reduced redundancy —
-- constraints are the ACTUAL mechanism that makes those
-- properties real, rather than just good intentions. Without
-- constraints, NOTHING stops you from accidentally inserting a
-- negative age, a duplicate employee ID, or an order with no
-- customer attached — the database would happily store garbage.

-- ANALOGY: constraints are like a bouncer at a club's entrance —
-- they check every single person (every row being inserted)
-- against a specific rule (age requirement, dress code, guest
-- list) BEFORE letting them in. If someone doesn't meet the
-- rule, they're turned away at the door — they never make it
-- inside to cause a problem later.


-- ============================================================
-- STEP 2: NOT NULL
-- ============================================================

-- Ensures a column can NEVER be left empty — every row MUST
-- have a value for this column, or the insert is rejected.

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50) NOT NULL,   -- every employee MUST have a name
    email VARCHAR(100)                -- email is optional (can be NULL)
);

-- This will FAIL, because emp_name is required:
-- INSERT INTO employees (emp_id, email) VALUES (1, 'test@mail.com');

-- WHEN TO USE IT: any column where a missing value would make
-- the row meaningless or break downstream logic (a person's
-- name, an order's total amount, a required date).


-- ============================================================
-- STEP 3: UNIQUE
-- ============================================================

-- Ensures NO TWO ROWS can have the same value in this column.
-- Unlike PRIMARY KEY, a UNIQUE column CAN still contain NULL
-- (usually just one NULL, depending on the database system),
-- and a table CAN have MULTIPLE UNIQUE columns (only ONE
-- PRIMARY KEY is allowed per table).

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,     -- no two employees share an email
    phone VARCHAR(15) UNIQUE        -- no two employees share a phone number
);

-- WHEN TO USE IT: any column that should never repeat across
-- rows, but ISN'T the table's main identifying key — email,
-- phone number, username, national ID number, etc.


-- ============================================================
-- STEP 4: PRIMARY KEY (REVISITED WITH FULL DETAIL)
-- ============================================================

-- Uniquely identifies EVERY row in a table. Technically, PRIMARY
-- KEY = UNIQUE + NOT NULL COMBINED, automatically, in one constraint.

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,    -- automatically UNIQUE and NOT NULL
    emp_name VARCHAR(50)
);

-- RULES SPECIFIC TO PRIMARY KEY:
--   - A table can have ONLY ONE primary key (unlike UNIQUE,
--     where you can have several)
--   - It can be a SINGLE column, or a COMPOSITE KEY (multiple
--     columns combined) if no single column is unique enough alone:

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id)   -- composite primary key:
                                            -- the COMBINATION must be
                                            -- unique, even if individual
                                            -- student_id or course_id
                                            -- values repeat elsewhere
);

-- WHY COMPOSITE MATTERS HERE: a student can enroll in MANY
-- courses, and a course has MANY students — so neither
-- student_id NOR course_id alone is unique. But the PAIR
-- (this student, this course) should never repeat — that's
-- exactly what a composite key enforces.

-- ============================================================
-- STEP 4B: AUTO_INCREMENT
-- ============================================================

-- AUTO_INCREMENT automatically generates a unique, incrementing
-- number for a column every time a new row is inserted — you
-- never have to manually specify a value for that column yourself.

CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(50)
);

-- Now you can insert WITHOUT providing emp_id at all:
INSERT INTO employees (emp_name) VALUES ('Aryan');   -- emp_id becomes 1 automatically
INSERT INTO employees (emp_name) VALUES ('Priya');    -- emp_id becomes 2 automatically
INSERT INTO employees (emp_name) VALUES ('Rohan');     -- emp_id becomes 3 automatically

-- WHY THIS IS SO COMMONLY PAIRED WITH PRIMARY KEY: a primary
-- key's whole job is to be a UNIQUE identifier — but manually
-- tracking "what was the last ID I used?" for every single
-- insert is tedious and error-prone (what if two people insert
-- at the same time and pick the same next number?). AUTO_INCREMENT
-- offloads that responsibility entirely to the DBMS, which
-- guarantees each new value is unique and sequential, even with
-- multiple simultaneous inserts happening (handles concurrency
-- safely, tying back to Session 30's "ability to handle
-- concurrency" database property).

-- IMPORTANT BEHAVIOR TO KNOW: if a row gets DELETED, its
-- AUTO_INCREMENT number is typically NOT reused — the counter
-- just keeps climbing forward. So if you delete emp_id 2
-- ("Priya"), the next insert still gets emp_id 4, NOT a reused 2.
-- This is intentional — reusing IDs could cause confusion or
-- accidentally link new data to old, unrelated references.

-- SYNTAX NOTE: AUTO_INCREMENT is MySQL's specific keyword.
-- Other databases use different syntax for the same concept:
--   MySQL       -> AUTO_INCREMENT
--   PostgreSQL   -> SERIAL or GENERATED ALWAYS AS IDENTITY
--   SQL Server    -> IDENTITY(1,1)
--   Oracle         -> SEQUENCE objects (a separate, more manual mechanism)
-- Since DSMP uses MySQL/XAMPP, AUTO_INCREMENT is the one you'll
-- actually use — but worth knowing this isn't universal SQL
-- syntax if you ever work with a different database system.

-- ============================================================
-- STEP 5: FOREIGN KEY (REVISITED WITH FULL DETAIL)
-- ============================================================

-- A FOREIGN KEY in one table (the "child") references the
-- PRIMARY KEY of another table (the "parent") — this is what
-- ENFORCES the relationships from Session 30's "cardinality" topic.

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

-- WHAT THIS ACTUALLY ENFORCES ("REFERENTIAL INTEGRITY"): you
-- CANNOT insert an employee with a dept_id that doesn't already
-- exist in the departments table. This is called REFERENTIAL
-- INTEGRITY — the relationship between the two tables can never
-- point to something that doesn't actually exist.

-- This FAILS if dept_id 99 doesn't exist in departments:
-- INSERT INTO employees VALUES (1, 'Aryan', 99);

-- KEY DIFFERENCES FROM PRIMARY KEY:
--   - a table can have MULTIPLE foreign keys (referencing
--     different parent tables), but only ONE primary key
--   - a foreign key CAN be NULL (meaning "this row doesn't
--     relate to any parent row yet"), unless you additionally
--     mark it NOT NULL — a primary key can NEVER be NULL

-- WHAT HAPPENS IF YOU TRY TO DELETE A REFERENCED PARENT ROW?
-- By default, most databases will BLOCK you from deleting a
-- department that still has employees pointing to it via
-- dept_id — this prevents "orphaned" rows (employees pointing
-- to a department that no longer exists). This behavior can be
-- customized (CASCADE, SET NULL, etc.) — worth knowing exists,
-- covered more in the Extras section below.


-- ============================================================
-- STEP 6: CHECK
-- ============================================================

-- CHECK enforces a custom CONDITION on a column's values — only
-- rows where the condition evaluates TRUE are allowed to be
-- inserted/updated.

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    age INT CHECK (age >= 18),               -- must be an adult
    salary DECIMAL(10,2) CHECK (salary > 0)    -- salary can't be negative or zero
);

-- This FAILS the CHECK constraint:
-- INSERT INTO employees VALUES (1, 15, 30000);

-- CHECK conditions can use comparison operators, AND/OR, BETWEEN,
-- IN — basically anything you could write in a WHERE clause:

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    status VARCHAR(20) CHECK (status IN ('Pending', 'Shipped', 'Delivered'))
);

-- WHEN TO USE IT: any column with a genuine business RULE
-- attached to its valid values, beyond just "not empty" or
-- "not duplicated" — age limits, valid status values, price
-- ranges, etc.


-- ============================================================
-- STEP 7: DEFAULT
-- ============================================================

-- DEFAULT provides an automatic fallback value for a column
-- WHEN no value is explicitly given during an INSERT.

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    join_date DATE DEFAULT CURRENT_DATE,   -- auto-fills today's date if not given
    status VARCHAR(20) DEFAULT 'Active'      -- assumes 'Active' unless specified otherwise
);

-- If you insert without specifying join_date or status:
INSERT INTO employees (emp_id, emp_name) VALUES (1, 'Aryan');
-- -> join_date automatically becomes today's date, status becomes 'Active'

-- NOTE: DEFAULT is NOT the same as NOT NULL — DEFAULT just fills
-- in a fallback value when nothing's provided; it doesn't
-- prevent someone from EXPLICITLY inserting a NULL if they
-- choose to (unless you ALSO add NOT NULL alongside it).

-- ============================================================
-- STEP 8: NAMED CONSTRAINTS — WHY GIVE A CONSTRAINT A NAME?
-- ============================================================

-- Every constraint you've written so far (NOT NULL, UNIQUE,
-- PRIMARY KEY, FOREIGN KEY, CHECK) has been UNNAMED — the
-- database auto-generates some internal, often cryptic name for
-- it behind the scenes (like SQL0001 or a long auto-generated
-- string, depending on the DBMS). You CAN instead explicitly
-- NAME a constraint yourself using the CONSTRAINT keyword.

-- SYNTAX: CONSTRAINT constraint_name TYPE (...)

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    age INT,
    dept_id INT,

    CONSTRAINT pk_emp PRIMARY KEY (emp_id),
    CONSTRAINT chk_age CHECK (age >= 18),
    CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    CONSTRAINT uq_email UNIQUE (emp_id, dept_id)
);

-- NAMING CONVENTION Nitish uses: a short prefix indicating the
-- constraint TYPE, followed by what it applies to —
--   pk_  -> primary key      (pk_emp)
--   fk_  -> foreign key        (fk_dept)
--   chk_ -> check                (chk_age)
--   uq_  -> unique                 (uq_email)
-- This isn't a strict SQL rule — it's a readability convention,
-- but a genuinely useful one to adopt consistently.


-- ============================================================
-- STEP 9: THE ACTUAL BENEFITS OF NAMING CONSTRAINTS
-- ============================================================

-- BENEFIT 1 — EASIER TO DROP/MODIFY LATER:
-- Without a name, removing a specific constraint later is
-- painful — you'd have to look up the DBMS's auto-generated
-- name first (often an ugly system-generated string) before you
-- can even reference it. With a name, dropping it is direct and
-- readable:

ALTER TABLE employees
DROP CONSTRAINT chk_age;

-- Compare that to needing to first RUN A QUERY just to discover
-- what the system auto-named the constraint, before you can
-- even attempt to drop it — named constraints skip that
-- entire lookup step.

-- BENEFIT 2 — CLEARER, MORE READABLE ERROR MESSAGES:
-- If a constraint gets violated, the DBMS's error message
-- typically INCLUDES the constraint's name. Compare:
--   "Violation of constraint SQL0001_2039484"   <- unnamed, meaningless
--   "Violation of constraint chk_age"             <- named, immediately
--                                                     tells you WHAT rule
--                                                     was broken, without
--                                                     digging further
-- This matters a lot when debugging a failed INSERT/UPDATE in a
-- large table with MANY constraints — a named constraint tells
-- you exactly which rule failed, at a glance, from the error
-- message alone.

-- BENEFIT 3 — SELF-DOCUMENTING TABLE DEFINITIONS:
-- When someone else (or you, months later) reads your CREATE
-- TABLE statement, named constraints make the INTENT of each
-- rule immediately obvious, rather than needing to mentally
-- parse what an unnamed inline constraint is even for. This
-- matters more as tables get more complex, with many
-- constraints layered onto the same table.

-- BENEFIT 4 — CONSISTENT MANAGEMENT ACROSS A LARGER DATABASE:
-- In a real production database with dozens of tables, a
-- consistent naming convention (pk_, fk_, chk_, uq_) lets you
-- quickly identify and manage constraints database-wide — e.g.
-- searching for all constraints starting with "fk_" to review
-- every foreign key relationship at once — something that's
-- much harder to do with inconsistent auto-generated names.


-- ============================================================
-- ADD TO KEY POINTS TO REMEMBER (append after point 7):
-- ============================================================

-- 8.  Constraints can be explicitly NAMED using the CONSTRAINT
--     keyword instead of relying on the DBMS's auto-generated
--     name — syntax: CONSTRAINT constraint_name TYPE (...)
-- 9.  Naming constraints gives 4 real benefits: easier to DROP
--     or modify later (no need to look up an ugly auto-generated
--     name first), clearer error messages when a constraint is
--     violated, self-documenting table definitions for anyone
--     reading the schema later, and easier database-wide
--     constraint management using a consistent naming convention
--     (pk_, fk_, chk_, uq_ prefixes)

-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  CONSTRAINT       WHAT IT ENFORCES                     CAN REPEAT ON TABLE?    ALLOWS NULL?
--  ─────────────────────────────────────────────────────────────────────────────────────
--  NOT NULL             value must be provided                  YES (many columns)      NO
--  UNIQUE                 no duplicate values in this column       YES (many columns)      YES (usually 1 NULL allowed)
--  PRIMARY KEY              unique row identifier (UNIQUE+NOT NULL)  NO (only 1 per table)    NO
--  FOREIGN KEY               value must exist in another table's PK  YES (many per table)     YES (unless also NOT NULL)
--  CHECK                       value must satisfy a custom condition    YES (many columns)      depends on condition itself
--  DEFAULT                       auto-fills a value if none provided       YES (many columns)      n/a (fallback, not a block)


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  Constraints are RULES the DBMS enforces automatically on
--     every INSERT/UPDATE, REJECTING anything that violates
--     them — this is the actual mechanism behind Session 30's
--     "consistency" and "reduced redundancy" database properties
-- 2.  PRIMARY KEY = UNIQUE + NOT NULL combined, and a table can
--     have only ONE — but it CAN be a composite key across
--     multiple columns when no single column is unique alone
-- 3.  UNIQUE is like PRIMARY KEY's more flexible cousin: a table
--     can have SEVERAL unique columns, and unlike PRIMARY KEY,
--     a UNIQUE column can typically hold one NULL value
-- 4.  FOREIGN KEY enforces REFERENTIAL INTEGRITY — it prevents
--     inserting a value that doesn't already exist as a primary
--     key in the referenced ("parent") table, and by default
--     blocks deleting a parent row that's still referenced
-- 5.  CHECK lets you enforce CUSTOM business rules beyond just
--     uniqueness/emptiness — age limits, valid status values,
--     positive-only numbers, using the same kind of conditions
--     you'd write in a WHERE clause
-- 6.  DEFAULT is different in KIND from the others — it doesn't
--     REJECT bad data, it just fills in a fallback value when
--     nothing was explicitly provided
-- 7.  Constraints are usually defined right inside CREATE TABLE,
--     but can also be ADDED to an existing table later using
--     ALTER TABLE (from your DDL Commands note)


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. FOREIGN KEY CASCADE OPTIONS (ON DELETE / ON UPDATE): by
--    default, deleting/updating a referenced parent row is
--    BLOCKED if child rows still reference it. But you can
--    customize this behavior explicitly:
--      ON DELETE CASCADE  -> automatically delete child rows too
--      ON DELETE SET NULL -> set the child's foreign key to NULL
--                             instead of blocking the delete
--      ON DELETE RESTRICT  -> the default — block the delete entirely
--    Example:
--      FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
--        ON DELETE CASCADE
--    This is a common follow-up interview question once basic
--    foreign keys are understood — worth knowing these options exist.

-- 2. ADDING CONSTRAINTS TO AN EXISTING TABLE (via ALTER, not
--    just at CREATE TABLE time):
--      ALTER TABLE employees
--      ADD CONSTRAINT chk_age CHECK (age >= 18);
--    Naming constraints explicitly (CONSTRAINT chk_age ...)
--    also makes them easier to later DROP or reference by name
--    — worth knowing beyond just defining constraints inline.

-- 3. SUPER KEY vs CANDIDATE KEY, FORMALLY (flagged as a gap in
--    your Database Fundamentals note too): a SUPER KEY is ANY
--    set of columns that can uniquely identify a row (even with
--    redundant extra columns thrown in); a CANDIDATE KEY is a
--    MINIMAL super key (no unnecessary columns); PRIMARY KEY is
--    simply the one candidate key actually chosen to be it. This
--    formal hierarchy often shows up in interview questions
--    asking you to distinguish all three precisely.

-- ============================================================
-- NEXT TOPIC (per your playlist): Session 32 — SQL DML Commands
-- (INSERT, UPDATE, DELETE — manipulating actual data/rows,
-- now that the table STRUCTURE and its constraints are understood)
-- ============================================================