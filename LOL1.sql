/*
================================================================================
PROBLEM 1: INSURANCE DATABASE
================================================================================
1. Consider the Insurance database given below. The primary keys are underlined 
   and the data types are specified:
   PERSON (driver – id #: String, name: string, address: string)
   CAR (regno: string, model: string, year: int)
   ACCIDENT (report-number: int, accd-date: date, location: string)
   OWNS (driver-id #: string, Regno: string)
   PARTICIPATED (driver-id: string, Regno: string, report-number: int, damage amount: int)

   (i)   Create the above tables by properly specifying the primary keys and the foreign keys.
   (ii)  Enter at least five tuples for each relation.
   (iii) Demonstrate how you:
         a. Update the damage amount to 25000 for the car with a specific
            Regno in the ACCIDENT table with report number 12.
         b. Add a new accident to the database.
   (iv)  Find the total number of people who owned cars that were involved in accidents in 2008.
   (v)   Find the number of accidents in which cars belonging to a specific model were involved.
   (vi)  Generate suitable reports.
   (vii) Create suitable front end for querying and displaying the results.
================================================================================
*/

-- Database Creation & Selection (MySQL)
-- Note: For PostgreSQL (psql), use: CREATE DATABASE QUESTION1; followed by \c QUESTION1
SHOW DATABASES;
CREATE DATABASE QUESTION1;
USE QUESTION1;
SHOW TABLES;

-- =============================================================================
-- (i) CREATE TABLES WITH PRIMARY KEYS, FOREIGN KEYS, AND CASCADE CONSTRAINTS
-- =============================================================================

-- 1. PERSON Table
CREATE TABLE PERSON (
    DRIVER_ID VARCHAR(30) PRIMARY KEY,
    NAME VARCHAR(30) NOT NULL,
    ADDRESS VARCHAR(70)
);

-- 2. CAR Table
CREATE TABLE CAR (
    REG_NO VARCHAR(30) PRIMARY KEY,
    MODEL VARCHAR(30) NOT NULL,
    YEAR INT DEFAULT 2024
);

-- 3. ACCIDENT Table
CREATE TABLE ACCIDENT (
    REPORT_NO INT PRIMARY KEY,
    DDATE DATE DEFAULT '2025-01-01',
    LOCATION VARCHAR(50) NOT NULL
);

-- 4. OWNS Table (Composite Primary Key + Referential Integrity with Cascade)
CREATE TABLE OWNS (
    DRIVER_ID VARCHAR(30),
    REG_NO VARCHAR(30),
    PRIMARY KEY (DRIVER_ID, REG_NO),
    FOREIGN KEY (DRIVER_ID) REFERENCES PERSON(DRIVER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (REG_NO) REFERENCES CAR(REG_NO) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. PARTICIPATED Table (Composite Primary Key + Referential Integrity with Cascade)
CREATE TABLE PARTICIPATED (
    DRIVER_ID VARCHAR(30),
    REG_NO VARCHAR(30),
    REPORT_NO INT NOT NULL,
    DAMAGE_AMOUNT INT DEFAULT 0,
    PRIMARY KEY (DRIVER_ID, REG_NO, REPORT_NO),
    FOREIGN KEY (DRIVER_ID) REFERENCES PERSON(DRIVER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (REG_NO) REFERENCES CAR(REG_NO) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (REPORT_NO) REFERENCES ACCIDENT(REPORT_NO) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Verify created tables
SHOW TABLES;

-- =============================================================================
-- (ii) ENTER AT LEAST FIVE TUPLES FOR EACH RELATION
-- =============================================================================

-- Insert 5 tuples into PERSON
INSERT INTO PERSON VALUES ('D001', 'ADARSH', 'JPNAGAR');
INSERT INTO PERSON VALUES ('D002', 'ANOOP', 'JAYANAGAR');
INSERT INTO PERSON VALUES ('D003', 'KIRAN', 'JAYANAGAR');
INSERT INTO PERSON VALUES ('D004', 'ABHISHEK', 'PEENYA');
INSERT INTO PERSON VALUES ('D005', 'SANJAY', 'RAJAJINAGAR');

-- Insert 5 tuples into CAR
INSERT INTO CAR VALUES 
    ('KA01M1001', 'SKODA', 2002),
    ('KA02B2002', 'BMW', 2008),
    ('KA03M3003', 'MARUTI', 2008),
    ('KA04H4004', 'HYUNDAI', 2001),
    ('KA05A5005', 'AUDI', 2008);

-- Insert 5 tuples into ACCIDENT (Including Report #12 and accidents in 2008)
INSERT INTO ACCIDENT VALUES 
    (1, '2002-01-01', 'RJNGR'),
    (2, '2003-02-03', 'JNGR'),
    (3, '2003-04-05', 'PEENYA'),
    (12, '2008-05-15', 'MGROAD'),
    (15, '2008-08-20', 'JPNGR');

-- Insert 5 tuples into OWNS
INSERT INTO OWNS VALUES 
    ('D001', 'KA01M1001'),
    ('D002', 'KA02B2002'),
    ('D003', 'KA03M3003'),
    ('D004', 'KA04H4004'),
    ('D005', 'KA05A5005');

-- Insert 5 tuples into PARTICIPATED
INSERT INTO PARTICIPATED VALUES 
    ('D001', 'KA01M1001', 1, 9000),
    ('D002', 'KA02B2002', 12, 15000),
    ('D003', 'KA03M3003', 12, 10000),
    ('D004', 'KA04H4004', 3, 67800),
    ('D005', 'KA05A5005', 15, 20000);

-- View all inserted records across all 5 tables
SELECT * FROM PERSON;
SELECT * FROM CAR;
SELECT * FROM ACCIDENT;
SELECT * FROM OWNS;
SELECT * FROM PARTICIPATED;

-- =============================================================================
-- (iii) DEMONSTRATE UPDATES AND NEW ACCIDENT INSERTION
-- =============================================================================

-- a. Update the damage amount to 25000 for the car with a specific REG_NO
--    ('KA02B2002') in the accident with report number 12:
UPDATE PARTICIPATED 
SET DAMAGE_AMOUNT = 25000 
WHERE REG_NO = 'KA02B2002' AND REPORT_NO = 12;

-- Verify updated record
SELECT * FROM PARTICIPATED;

-- b. Add a new accident to the database:
INSERT INTO ACCIDENT VALUES (20, '2008-11-25', 'INDIRANAGAR');

-- Verify new accident entry
SELECT * FROM ACCIDENT;

-- =============================================================================
-- (iv) FIND THE TOTAL NUMBER OF PEOPLE WHO OWNED CARS INVOLVED IN ACCIDENTS IN 2008
-- =============================================================================
-- Note: If using PostgreSQL, replace YEAR(A.DDATE) = 2008 with EXTRACT(YEAR FROM A.DDATE) = 2008
SELECT COUNT(DISTINCT O.DRIVER_ID) AS TOTAL_PEOPLE
FROM OWNS O, PARTICIPATED P, ACCIDENT A
WHERE O.REG_NO = P.REG_NO 
  AND P.REPORT_NO = A.REPORT_NO
  AND YEAR(A.DDATE) = 2008;

-- =============================================================================
-- (v) FIND THE NUMBER OF ACCIDENTS IN WHICH CARS OF A SPECIFIC MODEL WERE INVOLVED
-- =============================================================================
SELECT COUNT(DISTINCT P.REPORT_NO) AS ACCIDENT_COUNT
FROM PARTICIPATED P, CAR C
WHERE P.REG_NO = C.REG_NO 
  AND C.MODEL = 'MARUTI';

-- =============================================================================
-- (vi) GENERATE SUITABLE REPORTS
-- =============================================================================

-- Report 1: List all car owners along with their car model, registration number, and year
SELECT P.NAME, C.MODEL, C.REG_NO, C.YEAR
FROM PERSON P, CAR C, OWNS O
WHERE P.DRIVER_ID = O.DRIVER_ID 
  AND O.REG_NO = C.REG_NO;

-- Report 2: Complete accident history showing driver name, car model, location, and damage amount
SELECT P.NAME, C.MODEL, A.REPORT_NO, A.DDATE, A.LOCATION, PA.DAMAGE_AMOUNT
FROM PERSON P, CAR C, ACCIDENT A, PARTICIPATED PA
WHERE P.DRIVER_ID = PA.DRIVER_ID 
  AND C.REG_NO = PA.REG_NO 
  AND A.REPORT_NO = PA.REPORT_NO;

-- =============================================================================
-- (vii) FRONT-END NOTE FOR LAB PRACTICALS / VIVA
-- =============================================================================
-- As per lab guidelines, this database can be connected to a front-end interface
-- (such as Visual Basic via ODBC/ADODB or Python Tkinter/Streamlit) using standard
-- SQL SELECT, INSERT, and UPDATE queries against the QUESTION1 database[cite: 1, 8].
