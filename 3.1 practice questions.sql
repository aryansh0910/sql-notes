-- ============================================================
-- PRACTICE QUESTIONS 2.1 — DDL COMMANDS & CONSTRAINTS
-- (My answers vs corrected answers, with mistakes to remember)
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Create `students` table — roll_no PK, name NOT NULL,
-- email UNIQUE, age CHECK >= 15
-- ------------------------------------------------------------

-- MY ANSWER:
CREATE TABLE students(
    roll_no INT(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT(10) CHECK (age>=15),
    email VARCHAR(255) UNIQUE,
    branch VARCHAR(255)
);

-- MISTAKE: INT(10) — the (10) is NOT a length limit like
-- VARCHAR(n). For INT, it's just a display-width hint (mostly
-- meaningless, deprecated in MySQL 8.0.19+). Use plain INT.

-- CORRECTED:
CREATE TABLE students(
    roll_no INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT CHECK (age >= 15),
    email VARCHAR(255) UNIQUE,
    branch VARCHAR(255)
);


-- ------------------------------------------------------------
-- Q1b: Same table, but with NAMED constraints
-- ------------------------------------------------------------

-- MY ANSWER:
CREATE TABLE students(
    roll_no INT(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT(10) CHECK (age>=15),
    email VARCHAR(255),
    branch VARCHAR(255),
    CONSTRAINT un_email UNIQUE(email)
);

-- MISTAKE: only UNIQUE was named — PRIMARY KEY and CHECK were
-- still inline/unnamed. Also, NOT NULL can NEVER be named in
-- MySQL (it's a column attribute, not a standalone constraint
-- object) — correctly left it alone without trying to name it.

-- CORRECTED (naming everything nameable):
CREATE TABLE students(
    roll_no INT,
    name VARCHAR(255) NOT NULL,
    age INT,
    email VARCHAR(255),
    branch VARCHAR(255),
    CONSTRAINT pk_roll_no PRIMARY KEY(roll_no),
    CONSTRAINT chk_age CHECK (age >= 15),
    CONSTRAINT un_email UNIQUE(email)
);


-- ------------------------------------------------------------
-- Q2: Create `courses` (auto-increment PK), then ALTER
-- `students` to add course_id as a FOREIGN KEY
-- ------------------------------------------------------------

-- MY ANSWER:
-- CREATE TABLE courses(
-- course_id INT AUTO-GENERATED PRIMARY KEY,
-- course_name VARCHAR(50),
-- )
--
-- ALTER students ADD COLUMN
-- (course_id NOT NULL,
-- CONSTRAINT for_ky  FORGEIN KEY (course_id) REFERENCES ON (courses.courses_id)
-- )

-- MISTAKES:
--   1. "AUTO-GENERATED" isn't a real keyword -> AUTO_INCREMENT
--   2. trailing comma before closing bracket -> syntax error
--   3. "ALTER students" missing the TABLE keyword -> ALTER TABLE students
--   4. "course_id NOT NULL" missing its data type -> course_id INT NOT NULL
--   5. "FORGEIN KEY" misspelled -> FOREIGN KEY
--   6. "REFERENCES ON (courses.courses_id)" -> no ON needed, and
--      "courses_id" typo'd (extra "s") -> courses(course_id)

-- CORRECTED:
CREATE TABLE courses(
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(50)
);

ALTER TABLE students 
ADD COLUMN course_id INT NOT NULL,
ADD CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES courses(course_id);

-- KEY LESSON: ALTER TABLE ALWAYS needs the table name right
-- after "ALTER TABLE" — this exact mistake (forgetting the
-- table name after ALTER TABLE / after ALTER) repeated across
-- MULTIPLE questions (Q2, Q3, Q4) — this is my #1 recurring error.


-- ------------------------------------------------------------
-- Q3: Named CHECK on branch, RENAME students, DROP course_name
-- ------------------------------------------------------------

-- MY ANSWER (across multiple attempts):
--   "DROP COLUMN course_name"                          -> missing ALTER TABLE + table name
--   "ALTER"                                              -> incomplete on its own
--   "ALTER courses DROP column course_name"                -> missing TABLE keyword
--   "ALTER TABLE RENAME students AS student_info"             -> table name missing after
--                                                                ALTER TABLE; AS is wrong,
--                                                                should be TO

-- CORRECTED (all 3 parts):
ALTER TABLE students 
ADD CONSTRAINT chk_branch CHECK (branch IN ('CSE', 'ECE', 'ME'));

ALTER TABLE students RENAME TO student_info;

ALTER TABLE courses DROP COLUMN course_name;

-- KEY LESSON: "MODIFY" is for changing a column's TYPE/SIZE.
-- "ADD CONSTRAINT" is for attaching a NEW rule to an existing
-- column. These are DIFFERENT keywords for what feels like a
-- similar "changing the column" action — don't mix them up.
-- Also: RENAME uses TO, not AS (AS is for aliasing, not renaming).


-- ------------------------------------------------------------
-- Q4: TRUNCATE courses, DROP courses entirely, MODIFY email to 150 chars
-- ------------------------------------------------------------

-- MY ANSWER:
--   "TRUNCATE TABLE student_info;"        -> WRONG TABLE (asked
--                                            for courses, not student_info)
--   "ALTER TABLE DROP COLUMN courses"        -> confused DROP COLUMN
--                                              with DROP TABLE; also
--                                              missing table name
--   "ALTER TABLE DROP  courses"                -> still missing TABLE
--                                                name; DROP TABLE
--                                                needed, not ALTER TABLE DROP
--   "DROP TABLE courses"                          -> CORRECT!
--   "ALTER TABLE\nMODIFY COLUMN email VARCHAR(50)"   -> missing table
--                                                        name; ALSO
--                                                        wrong size
--                                                        (50 instead
--                                                        of 150 — shrinks
--                                                        instead of expands)

-- CORRECTED (all 3 parts):
TRUNCATE TABLE courses;

DROP TABLE courses;

ALTER TABLE student_info
MODIFY email VARCHAR(150);

-- KEY LESSON: DROP TABLE deletes the WHOLE table (no ALTER
-- needed at all) — completely different command from ALTER
-- TABLE ... DROP COLUMN (which only removes ONE column from
-- within a table). Also: always re-read the question for WHICH
-- table/value is actually being asked about before writing the query.


-- ------------------------------------------------------------
-- Q5: DEFAULT constraint on status, composite PRIMARY KEY table
-- ------------------------------------------------------------

-- MY ANSWER:
-- ALTER TABLE courses ADD column(status DEFAUT in("ACtIVE))

-- MISTAKES:
--   1. "DEFAUT" misspelled -> DEFAULT
--   2. Used IN(...) instead of just writing the value directly
--      -> DEFAULT doesn't take a list, just ONE value
--   3. Unclosed quote, inconsistent capitalization -> 'Active'
--   4. Missing the column's data TYPE (e.g. VARCHAR(20))
--   5. Extra/misplaced parentheses around column(status ...)

-- CORRECTED:
ALTER TABLE courses
ADD COLUMN status VARCHAR(20) DEFAULT 'Active';

-- MY ANSWER (composite key table):
CREATE TABLE enrollmenst (student_roll INT AUTO_INCREMNET , course_id INT NOT NULL
CONStraint pri_ky PRIMARY KEY(student_roll,course_id))

-- MISTAKES:
--   1. "enrollmenst" typo -> enrollments
--   2. "AUTO_INCREMNET" misspelled -> AUTO_INCREMENT
--   3. CONCEPTUAL: AUTO_INCREMENT doesn't make sense on
--      student_roll here — it's meant to reference an EXISTING
--      student's real roll number (a foreign key relationship),
--      not generate a brand new one
--   4. Missing comma between course_id INT NOT NULL and the
--      CONSTRAINT line

-- CORRECTED:
CREATE TABLE enrollments (
    student_roll INT NOT NULL,
    course_id INT NOT NULL,
    CONSTRAINT pri_ky PRIMARY KEY(student_roll, course_id),
    CONSTRAINT fk_student FOREIGN KEY (student_roll) REFERENCES student_info(roll_no),
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


-- ============================================================
-- MY TOP RECURRING MISTAKES — READ THIS BEFORE EVERY PRACTICE SESSION
-- ============================================================

-- 1. FORGETTING THE TABLE NAME after ALTER TABLE — by far my
--    #1 repeated mistake, happened in nearly every ALTER
--    question. ALWAYS check: "ALTER TABLE ___ <- did I fill this in?"
-- 2. Confusing DROP COLUMN (removes 1 column) with DROP TABLE
--    (deletes the whole table) — different commands, don't mix them
-- 3. Confusing MODIFY (change column type/size) with ADD
--    CONSTRAINT (attach a new rule) — different jobs, different keywords
-- 4. RENAME uses TO, not AS — AS is only for aliasing in SELECT/subqueries
-- 5. Spelling keywords carefully: AUTO_INCREMENT, FOREIGN KEY,
--    CONSTRAINT, DEFAULT — small typos = syntax errors every time
-- 6. INT(n) does NOT limit value size like VARCHAR(n) limits
--    text length — the (n) on INT is a mostly-meaningless display width
-- 7. Always double-check WHICH table/value the question is
--    actually asking about before writing the query — a couple
--    of my mistakes were correct SYNTAX on the WRONG target