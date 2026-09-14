-- ============================================================
-- SQL DDL COMMANDS
-- (CampusX DSMP: Session 31, Week 13 — SQL Basics)
-- ============================================================

-- NOTE: Session 30 was pure theory (no SQL syntax at all).
-- THIS is where actual SQL commands start. Nitish's flow: set
-- up the tool first (XAMPP), give the big-picture map of ALL
-- SQL command categories, THEN zoom into just ONE category
-- (DDL) in full detail. Next sessions will cover the remaining
-- categories (DML, etc.) the same way.


-- ============================================================
-- STEP 1: XAMPP — THE TOOL SETUP
-- ============================================================

-- Before writing any SQL, you need somewhere to actually RUN it.
-- XAMPP is a free, local software package that bundles together:
--   X = cross-platform (works on Windows/Mac/Linux)
--   A = Apache (web server, not directly needed for SQL practice)
--   M = MySQL/MariaDB (the actual DATABASE SERVER you'll use)
--   P = PHP (scripting language, also not core to SQL practice)
--   P = Perl

-- WHY USE XAMPP JUST FOR THE MySQL PART? It bundles MySQL with
-- phpMyAdmin — a browser-based visual interface for managing
-- your databases (create tables, run queries, see results in a
-- grid) — WITHOUT needing to install MySQL Server and configure
-- everything manually from scratch. For a beginner, this removes
-- a lot of setup friction: install XAMPP, start the "MySQL"
-- module from its control panel, open phpMyAdmin in your
-- browser, and you're ready to run SQL commands immediately.

-- (Practical note for you: you're not restricted to XAMPP going
-- forward — many people use MySQL Workbench, DBeaver, or even
-- an online SQL sandbox for practice. XAMPP is just the specific
-- beginner-friendly path Nitish uses to get started fastest.)


-- ============================================================
-- STEP 2: TYPES OF SQL COMMANDS — THE BIG PICTURE MAP
-- ============================================================

-- SQL commands are organized into 5 categories, based on WHAT
-- KIND of thing they do to the database:

--   1. DDL — Data Definition Language
--      Defines/modifies the STRUCTURE of the database itself
--      (creating tables, changing table structure, deleting
--      tables) — NOT the actual data inside them.
--      Commands: CREATE, ALTER, DROP, TRUNCATE, RENAME

--   2. DML — Data Manipulation Language
--      Manipulates the actual DATA/ROWS inside existing tables.
--      Commands: INSERT, UPDATE, DELETE
--      (covered in the NEXT session, Session 32)

--   3. DQL — Data Query Language
--      Used specifically to QUERY/RETRIEVE data.
--      Command: SELECT
--      (technically sometimes grouped under DML by some
--      textbooks, but SELECT is important enough to call out
--      as its own thing — you'll use it constantly)

--   4. DCL — Data Control Language
--      Controls ACCESS/PERMISSIONS to the database.
--      Commands: GRANT, REVOKE

--   5. TCL — Transaction Control Language
--      Manages TRANSACTIONS (groups of operations that should
--      succeed or fail together).
--      Commands: COMMIT, ROLLBACK, SAVEPOINT

-- ANALOGY: think of a database like a building.
--   DDL = constructing/renovating/demolishing the building itself
--         (the rooms, walls, structure)
--   DML = moving furniture in and out of rooms (the actual
--         contents, once the rooms already exist)
--   DQL = looking inside a room to see what's there
--   DCL = deciding who's allowed to enter which rooms
--   TCL = making sure that if you're moving furniture between
--         two rooms, either BOTH moves complete successfully, or
--         NEITHER does (no furniture left stranded halfway)

-- THIS SESSION covers ONLY category 1 (DDL) in depth.


-- ============================================================
-- STEP 3: DDL COMMAND 1 — CREATE
-- ============================================================

-- CREATE DATABASE — makes a new, empty database
CREATE DATABASE company_db;

-- To actually start using it:
USE company_db;

-- CREATE TABLE — defines a new table's structure: column names,
-- their DATA TYPES, and any CONSTRAINTS
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,          -- unique identifier for each row
    emp_name VARCHAR(50) NOT NULL,   -- text, up to 50 characters, can't be empty
    salary DECIMAL(10, 2),           -- number with 2 decimal places (money)
    join_date DATE                    -- date value
);

-- COMMON DATA TYPES you'll use constantly:
--   INT              -> whole numbers
--   VARCHAR(n)        -> variable-length text, up to n characters
--   CHAR(n)            -> fixed-length text, always exactly n characters
--   DECIMAL(p, s)       -> precise decimal numbers (p=total digits, s=decimal places)
--   DATE                -> calendar date (YYYY-MM-DD)
--   BOOLEAN              -> true/false

-- COMMON CONSTRAINTS (rules enforced on columns):
--   PRIMARY KEY   -> uniquely identifies each row, can't be NULL
--   NOT NULL       -> this column can never be left empty
--   UNIQUE          -> no two rows can have the same value here
--   DEFAULT value    -> if nothing is provided, use this value automatically
--   FOREIGN KEY       -> links this column to another table's primary key


-- ============================================================
-- STEP 4: DDL COMMAND 2 — ALTER
-- ============================================================

-- ALTER modifies the STRUCTURE of an EXISTING table (add/remove/
-- modify columns) — it does NOT touch the data already inside,
-- except where structurally necessary (e.g. dropping a column
-- removes that column's data along with it).

-- Add a new column:
ALTER TABLE employees
ADD department VARCHAR(30);

-- Remove an existing column:
ALTER TABLE employees
DROP COLUMN join_date;

-- Modify an existing column's data type/constraint:
ALTER TABLE employees
MODIFY emp_name VARCHAR(100);   -- widen the character limit


-- ============================================================
-- STEP 5: DDL COMMAND 3 — DROP
-- ============================================================

-- DROP completely DELETES a table (or database) — including its
-- STRUCTURE and ALL its data. This is irreversible without a backup.

DROP TABLE employees;
DROP DATABASE company_db;

-- WARNING WORTH FLAGGING: DROP removes the table definition
-- itself, not just its rows — if you re-create a table with the
-- same name afterward, you're starting completely fresh with no
-- memory of the old structure or constraints.


-- ============================================================
-- STEP 6: DDL COMMAND 4 — TRUNCATE
-- ============================================================

-- TRUNCATE removes ALL ROWS from a table, but KEEPS the table's
-- STRUCTURE intact (columns, data types, constraints all remain
-- — the table just becomes empty).

TRUNCATE TABLE employees;

-- KEY DIFFERENCE FROM DROP:
--   DROP     -> deletes the table itself (structure + data) —
--               the table no longer exists at all afterward
--   TRUNCATE -> empties the table's data, but the table (with
--               its exact structure) still exists afterward,
--               ready to have new data inserted into it


-- ============================================================
-- STEP 7: DDL COMMAND 5 — RENAME
-- ============================================================

-- RENAME changes the name of an existing table.

RENAME TABLE employees TO staff;

-- (Syntax can vary slightly by database system — some use
-- ALTER TABLE employees RENAME TO staff; instead — but the
-- PURPOSE is identical: just relabeling the table, structure
-- and data both stay exactly the same)


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  COMMAND       WHAT IT DOES                              REVERSIBLE?    AFFECTS DATA?
--  ────────────────────────────────────────────────────────────────────────────────
--  CREATE           makes a new database/table                  n/a            n/a (nothing existed before)
--  ALTER              modifies an existing table's structure       depends        only for dropped columns
--  DROP                 deletes table/database ENTIRELY             NO (no backup)  YES — everything gone
--  TRUNCATE               empties ALL rows, keeps structure           NO (no backup)  YES — data gone, structure stays
--  RENAME                   changes a table's name                      YES (rename back) NO


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  SQL commands split into 5 categories: DDL (structure), DML
--     (data manipulation), DQL (querying), DCL (permissions),
--     TCL (transactions) — this session covers ONLY DDL
-- 2.  DDL commands affect the STRUCTURE of the database/table,
--     not the day-to-day data inside it — that's DML's job
--     (next session)
-- 3.  CREATE builds a new database or table structure, with
--     specific data types and constraints (PRIMARY KEY, NOT
--     NULL, UNIQUE, DEFAULT) defined per column
-- 4.  ALTER changes an EXISTING table's structure — add, remove,
--     or modify columns — without wiping unrelated data
-- 5.  DROP vs TRUNCATE is a very common point of confusion:
--     DROP deletes the table ENTIRELY (structure + data), while
--     TRUNCATE only empties the DATA, keeping the table's
--     structure intact and ready for new rows
-- 6.  RENAME just changes a table's name — the least destructive
--     DDL command, structure and data both remain untouched
-- 7.  Choosing the RIGHT data type and constraints upfront in
--     CREATE TABLE matters — it's what enforces data integrity
--     (e.g. NOT NULL preventing empty required fields) before
--     any data even gets inserted


-- ============================================================
-- EXTRAS — BEYOND WHAT THIS SPECIFIC SESSION LIKELY COVERS
-- ============================================================

-- 1. DROP vs TRUNCATE vs DELETE (3-way comparison): this session
--    covers DROP and TRUNCATE, but DELETE (a DML command,
--    covered next session) is the third related command people
--    often confuse. Quick preview: DELETE removes rows from a
--    table's data (like TRUNCATE), but row-by-row with optional
--    WHERE conditions, and CAN be rolled back if used inside a
--    transaction — TRUNCATE typically cannot be rolled back and
--    always removes ALL rows at once, no conditions allowed.

-- 2. IF EXISTS / IF NOT EXISTS clauses: in practice, you'll
--    often see CREATE TABLE IF NOT EXISTS ... or DROP TABLE IF
--    EXISTS ... — these prevent errors if you accidentally try
--    to create something that already exists, or drop something
--    that's already gone. Small but genuinely useful in real
--    scripts, easy to add once you know the base syntax.

-- 3. CASCADING DELETES/FOREIGN KEY CONSTRAINTS ON DROP: if a
--    table has FOREIGN KEY relationships to other tables,
--    DROPping it can fail (or cascade-delete related rows,
--    depending on how the constraint was defined) — worth
--    knowing this exists once you start working with multiple
--    linked tables (covered later, in the Joins session).

-- ============================================================
-- NEXT TOPIC (per your playlist): Session 32 — SQL DML Commands
-- (INSERT, UPDATE, DELETE — manipulating actual data/rows)
-- ============================================================