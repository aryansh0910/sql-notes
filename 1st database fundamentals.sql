-- ============================================================
-- DATABASE FUNDAMENTALS
-- (CampusX DSMP: Session 30, Week 13 — SQL Basics)
-- ============================================================

-- NOTE: This is the very first SQL session in DSMP — before any
-- actual SQL syntax, Nitish spends this whole session building
-- the CONCEPTUAL foundation: what data and databases even are,
-- the operations you do on them, database properties, types,
-- what DBMS means, keys, relationships, and where databases
-- fall short. No queries written yet — that starts next session
-- (DDL). This is the "why do we even need this" groundwork.


-- ============================================================
-- STEP 1: INTRODUCTION TO DATA AND DATABASE
-- ============================================================

-- DATA = raw facts and figures with no context attached on
-- their own (a number, a name, a date — meaningless in isolation)
-- INFORMATION = data that has been processed/organized to
-- actually mean something (e.g. "25" is just data; "customer's
-- age is 25" is information)

-- A DATABASE is an organized collection of data, stored and
-- accessed electronically, structured so it can be efficiently
-- managed, updated, and retrieved.

-- WHY NOT JUST USE EXCEL/CSV FILES FOR EVERYTHING?
-- Files work fine for small, single-user, simple data. But real
-- applications need to handle LARGE volumes of data, MULTIPLE
-- users accessing/modifying it AT THE SAME TIME, and need
-- guarantees that the data stays consistent and safe even when
-- things go wrong (power failure, crashes, concurrent edits).
-- Plain files can't reliably do any of this at scale — that's
-- the whole reason databases (and the software that manages
-- them) exist.


-- ============================================================
-- STEP 2: CRUD OPERATIONS
-- ============================================================

-- Every single thing you'll ever do to data in a database boils
-- down to just FOUR fundamental operations — CRUD:

--   C — CREATE   -> add new data       (e.g. INSERT in SQL)
--   R — READ     -> retrieve/view data  (e.g. SELECT in SQL)
--   U — UPDATE   -> modify existing data (e.g. UPDATE in SQL)
--   D — DELETE   -> remove data          (e.g. DELETE in SQL)

-- ANALOGY: think of a notes app on your phone — writing a new
-- note is CREATE, opening and reading a note is READ, editing an
-- existing note is UPDATE, and deleting a note is DELETE. Every
-- app that stores data anywhere is fundamentally just doing
-- these 4 operations, in different combinations, all the time.

-- WHY THIS MATTERS UPFRONT: almost every SQL command you'll
-- learn from the NEXT session onward maps directly onto one of
-- these 4 categories — this framework is the mental model
-- everything else gets organized under.


-- ============================================================
-- STEP 3: PROPERTIES OF A (GOOD) DATABASE
-- ============================================================

-- A well-designed database should have these key properties:

--   1. REAL-WORLD ENTITY REPRESENTATION — a database should
--      accurately model real-world objects and their
--      relationships (a "Customer" table should genuinely
--      reflect what a customer actually is and how they relate
--      to "Orders", etc.)
--   2. REDUCED REDUNDANCY — the same piece of data shouldn't be
--      needlessly duplicated across multiple places (storing a
--      customer's address in 10 different tables wastes space
--      and risks inconsistency if only some copies get updated)
--   3. CONSISTENCY — the data should remain accurate and
--      uniform across the whole database at all times — no
--      contradictions between related pieces of data
--   4. QUERY-ABILITY — data should be structured so it's easy
--      and efficient to search, filter, and retrieve using
--      structured queries
--   5. EASE OF UPDATE — modifying existing data shouldn't be
--      cumbersome or require touching many unrelated places
--   6. SECURITY — the database should be able to restrict who
--      can view or modify what data (access control)
--   7. ABILITY TO HANDLE CONCURRENCY — supports MULTIPLE users
--      reading and writing data AT THE SAME TIME without
--      corrupting or losing data
--   8. BACKUP AND RECOVERY — the ability to safely recover data
--      after a failure (crash, power loss, accidental deletion)

-- These properties are exactly what separates a proper database
-- system from just "a folder full of spreadsheets."


-- ============================================================
-- STEP 4: TYPES OF DATABASES
-- ============================================================

-- Databases broadly fall into 2 major categories:

--   1. RELATIONAL DATABASES (RDBMS) — data organized into
--      structured TABLES (rows and columns), with defined
--      relationships between tables via KEYS. Uses SQL
--      (Structured Query Language) to interact with it.
--      Examples: MySQL, PostgreSQL, Oracle, SQL Server
--
--   2. NON-RELATIONAL DATABASES (NoSQL) — data stored in more
--      flexible formats that DON'T require a fixed table
--      structure. Several sub-types exist:
--        - DOCUMENT-based (e.g. MongoDB — stores JSON-like docs)
--        - KEY-VALUE stores (e.g. Redis — simple key-to-value
--          lookups, extremely fast)
--        - COLUMN-family stores (e.g. Cassandra)
--        - GRAPH databases (e.g. Neo4j — optimized for
--          relationship-heavy data like social networks)

-- WHEN IS EACH USED? Relational databases suit structured data
-- with clear, stable relationships (e.g. banking, e-commerce
-- orders). NoSQL suits less structured, rapidly-changing, or
-- massive-scale data (e.g. social media feeds, IoT sensor logs).

-- THIS COURSE (and most data science work) focuses on
-- RELATIONAL databases and SQL specifically — that's the entire
-- point of the sessions that follow this one.


-- ============================================================
-- STEP 5: WHAT IS A DBMS?
-- ============================================================

-- DBMS = Database Management System — the actual SOFTWARE that
-- sits between the user/application and the physical data,
-- handling all the operations (CRUD), enforcing the database
-- properties from Step 3, and managing storage/security/
-- concurrency behind the scenes.

-- IMPORTANT DISTINCTION: the DATABASE is the organized
-- collection of data itself; the DBMS is the SOFTWARE that
-- manages, creates, and lets you interact with that data.
-- You don't talk to raw stored data directly — you always go
-- through the DBMS (e.g. MySQL Server, PostgreSQL) using a
-- query language like SQL.

-- RDBMS = Relational DBMS — specifically a DBMS that manages
-- data in the RELATIONAL (table-based) format. MySQL,
-- PostgreSQL, and Oracle are all technically RDBMS software.


-- ============================================================
-- STEP 6: KEYS
-- ============================================================

-- Keys are what allow rows within a table (and across DIFFERENT
-- tables) to be uniquely identified and correctly related to
-- each other. Several important types:

--   PRIMARY KEY — a column (or combination of columns) that
--     uniquely identifies EACH ROW in a table. No two rows can
--     share the same primary key value, and it can't be NULL.
--     Example: a "customer_id" column in a Customers table.

--   FOREIGN KEY — a column in ONE table that refers to the
--     PRIMARY KEY of ANOTHER table — this is literally what
--     creates a RELATIONSHIP between two tables. Example: an
--     "customer_id" column inside an Orders table, pointing
--     back to the Customers table's primary key, so you know
--     WHICH customer placed WHICH order.

--   CANDIDATE KEY — any column (or set of columns) that COULD
--     have been chosen as the primary key (i.e., it also
--     uniquely identifies rows) — one candidate key eventually
--     gets picked to actually BE the primary key; the rest
--     remain candidate keys.

--   COMPOSITE KEY — a primary key made up of MORE THAN ONE
--     column combined together (used when no single column is
--     unique enough on its own, but the COMBINATION of two or
--     more columns is).

-- ANALOGY: think of a PRIMARY KEY like a student's unique roll
-- number in a school — no two students share it, and every
-- student MUST have one. A FOREIGN KEY is like writing that same
-- roll number on a library card to indicate WHICH student that
-- particular library card belongs to — it's how the "Library
-- Cards" table stays correctly linked back to the "Students" table.


-- ============================================================
-- STEP 7: CARDINALITY OF RELATIONSHIPS
-- ============================================================

-- Cardinality describes HOW MANY records in one table relate to
-- HOW MANY records in another table. Three main types:

--   1. ONE-TO-ONE (1:1) — one record in Table A relates to
--      EXACTLY one record in Table B, and vice versa.
--      Example: one Person has exactly one Passport, and that
--      Passport belongs to exactly that one Person.

--   2. ONE-TO-MANY (1:N) — one record in Table A can relate to
--      MULTIPLE records in Table B, but each record in Table B
--      relates back to only ONE record in Table A.
--      Example: one Customer can place MANY Orders, but each
--      Order belongs to exactly ONE Customer.

--   3. MANY-TO-MANY (M:N) — multiple records in Table A can
--      relate to multiple records in Table B, and vice versa.
--      Example: a Student can enroll in MANY Courses, and a
--      Course can have MANY Students enrolled — this
--      relationship type is usually implemented using an extra
--      "junction/bridge" table in real database design, since
--      relational databases can't directly represent M:N without
--      one.

-- UNDERSTANDING CARDINALITY MATTERS because it directly shapes
-- how tables and their foreign keys should actually be designed
-- — get this wrong, and you either lose information or create
-- messy, duplicated data.


-- ============================================================
-- STEP 8: DRAWBACKS OF DATABASES
-- ============================================================

-- Even with all their advantages over plain files, databases
-- (and DBMS software) aren't free of downsides:

--   1. COST — commercial DBMS software (like Oracle) can be
--      expensive to license, plus hardware/hosting costs at scale
--   2. COMPLEXITY — designing, maintaining, and optimizing a
--      proper database (especially a large one) requires real
--      expertise — poor design leads to poor performance
--   3. PERFORMANCE OVERHEAD — the extra layer of structure,
--      constraints, and consistency-checking a DBMS provides
--      comes at some performance cost compared to raw,
--      unstructured file access
--   4. MAINTENANCE — databases need continuous upkeep: backups,
--      security patches, performance tuning, monitoring
--   5. SCALABILITY CHALLENGES — traditional relational databases
--      can be harder to scale horizontally (across many servers)
--      compared to some NoSQL alternatives, especially at very
--      large scale

-- This is exactly WHY NoSQL databases (Step 4) exist as
-- alternatives — they trade away some of relational databases'
-- strict structure/consistency guarantees in exchange for
-- easier horizontal scaling and more flexible data models,
-- depending on what a given application actually needs.


-- ============================================================
-- CHEAT SHEET
-- ============================================================

--  CONCEPT                  WHAT IT MEANS
--  ─────────────────────────────────────────────────────────────
--  Data vs Information         raw facts vs facts given meaning/context
--  CRUD                          Create, Read, Update, Delete — the 4
--                                 fundamental operations on any data
--  DBMS                           the SOFTWARE that manages the database
--  RDBMS                           a DBMS specifically for relational
--                                  (table-based) data
--  Primary Key                    uniquely identifies each row in a table
--  Foreign Key                     links one table to another table's
--                                  primary key
--  Cardinality                     1:1, 1:N, or M:N — describes how records
--                                  across two tables relate in QUANTITY


-- ============================================================
-- KEY POINTS TO REMEMBER
-- ============================================================

-- 1.  A database is an organized data collection; a DBMS is the
--     SOFTWARE that manages and lets you interact with it —
--     these are two distinct things, often confused as one
-- 2.  Every operation on data reduces to CRUD — Create, Read,
--     Update, Delete — this framework underlies every SQL
--     command covered in the sessions ahead
-- 3.  A good database should minimize redundancy, stay
--     consistent, support concurrent access, and allow safe
--     backup/recovery — these properties are what distinguish
--     it from a plain file/spreadsheet
-- 4.  Databases split into RELATIONAL (structured tables, SQL,
--     e.g. MySQL/PostgreSQL) and NON-RELATIONAL/NoSQL (flexible
--     formats, e.g. MongoDB, Redis) — this course focuses on
--     relational databases and SQL specifically
-- 5.  PRIMARY KEYS uniquely identify rows within a table;
--     FOREIGN KEYS reference another table's primary key to
--     create relationships BETWEEN tables
-- 6.  Cardinality (1:1, 1:N, M:N) describes how records across
--     two related tables correspond in quantity, and directly
--     shapes how tables should be designed
-- 7.  Databases aren't free of tradeoffs — cost, complexity,
--     performance overhead, and scalability challenges are real
--     drawbacks, which is part of why NoSQL alternatives exist
--     for use cases where relational databases' strict structure
--     isn't the best fit


-- ============================================================
-- EXTRAS — THINGS THIS SPECIFIC SESSION LIKELY DOESN'T COVER
-- IN DEPTH (based on the syllabus, since these come up in
-- Normalization/Advanced SQL later, not Session 30 itself)
-- ============================================================

-- 1. NORMALIZATION (1NF, 2NF, 3NF, BCNF): the formal process of
--    structuring tables to minimize redundancy and avoid update
--    anomalies — Session 30 introduces "reduced redundancy" as a
--    goal but doesn't teach the formal normalization RULES for
--    achieving it. Worth learning separately if you want to
--    design your own database schemas well, not just query them.

-- 2. ACID PROPERTIES (Atomicity, Consistency, Isolation,
--    Durability): the formal guarantees a good DBMS provides for
--    TRANSACTIONS (a sequence of operations that should all
--    succeed or all fail together, e.g. a bank transfer). This
--    session's "properties of a database" list touches
--    consistency/concurrency informally but doesn't name ACID
--    explicitly — a common interview topic worth knowing by name.

-- 3. SUPER KEY vs CANDIDATE KEY vs PRIMARY KEY (formal distinction):
--    a SUPER KEY is ANY combination of columns that can uniquely
--    identify a row (even with extra, unnecessary columns
--    included); a CANDIDATE KEY is a MINIMAL super key (no
--    unnecessary columns); the PRIMARY KEY is the one candidate
--    key actually chosen. This session covers candidate/primary/
--    composite but the "super key" terminology itself is a
--    common quiz/interview distinction worth knowing precisely.

-- ============================================================
-- NEXT TOPIC (per your playlist): Session 31 — SQL DDL Commands
-- (Types of SQL commands, DDL commands specifically — the first
-- ACTUAL SQL syntax you'll write)
-- ============================================================