/*
================================================================================
PROBLEM 5: BANKING ENTERPRISE DATABASE
================================================================================
5. Consider the following database for a banking enterprise:
   BRANCH (branch_name: string, branch_city: string, assets: real)
   ACCOUNT (accno: int, branch_name: string, balance: real)
   DEPOSITOR (customer_name: string, accno: int)
   CUSTOMER (customer_name: string, customer_street: string, customer_city: string)
   LOAN (loan_number: int, branch_name: string, amount: real)
   BORROWER (customer_name: string, loan_number: int)

   (i)   Create the above tables by properly specifying the primary keys and the foreign keys.
   (ii)  Enter at least five tuples for each relation.
   (iii) Find all the customers who have at least two accounts at the Main branch.
   (iv)  Find all the customers who have an account at all the branches located in a specific city.
   (v)   Demonstrate how you delete tuples in ACCOUNT relation at every branch located in a
         specific city.
   (vi)  Generate suitable reports.
   (vii) Create suitable front end for querying and displaying the results.
================================================================================
*/

-- Database Creation & Selection (MySQL)
-- Note: For PostgreSQL (psql), use: CREATE DATABASE QUESTION5; followed by \c QUESTION5
CREATE DATABASE IF NOT EXISTS QUESTION5;
USE QUESTION5;

-- =============================================================================
-- (i) CREATE TABLES WITH PRIMARY KEYS, FOREIGN KEYS, AND CASCADE CONSTRAINTS
-- =============================================================================

-- 1. BRANCH Table
CREATE TABLE BRANCH (
    branch_name VARCHAR(25) PRIMARY KEY,
    branch_city VARCHAR(20) NOT NULL,
    assets DECIMAL(12, 2) NOT NULL
);

-- 2. ACCOUNT Table (References BRANCH with ON DELETE CASCADE and ON UPDATE CASCADE)
CREATE TABLE ACCOUNT (
    accno INT PRIMARY KEY,
    branch_name VARCHAR(25) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (branch_name) REFERENCES BRANCH(branch_name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. CUSTOMER Table
CREATE TABLE CUSTOMER (
    customer_name VARCHAR(25) PRIMARY KEY,
    customer_street VARCHAR(30) NOT NULL,
    customer_city VARCHAR(20) NOT NULL
);

-- 4. DEPOSITOR Table (Composite Primary Key referencing CUSTOMER and ACCOUNT)
CREATE TABLE DEPOSITOR (
    customer_name VARCHAR(25) NOT NULL,
    accno INT NOT NULL,
    PRIMARY KEY (customer_name, accno),
    FOREIGN KEY (customer_name) REFERENCES CUSTOMER(customer_name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (accno) REFERENCES ACCOUNT(accno) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. LOAN Table (References BRANCH with ON DELETE CASCADE and ON UPDATE CASCADE)
CREATE TABLE LOAN (
    loan_number INT PRIMARY KEY,
    branch_name VARCHAR(25) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (branch_name) REFERENCES BRANCH(branch_name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. BORROWER Table (Composite Primary Key referencing CUSTOMER and LOAN)
CREATE TABLE BORROWER (
    customer_name VARCHAR(25) NOT NULL,
    loan_number INT NOT NULL,
    PRIMARY KEY (customer_name, loan_number),
    FOREIGN KEY (customer_name) REFERENCES CUSTOMER(customer_name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (loan_number) REFERENCES LOAN(loan_number) ON DELETE CASCADE ON UPDATE CASCADE
);

-- View schema structures (Note: In PostgreSQL psql, use \d tablename)
DESCRIBE BRANCH;
DESCRIBE ACCOUNT;
DESCRIBE CUSTOMER;
DESCRIBE DEPOSITOR;
DESCRIBE LOAN;
DESCRIBE BORROWER;

-- =============================================================================
-- (ii) ENTER AT LEAST FIVE TUPLES FOR EACH RELATION
-- =============================================================================

-- 1. BRANCH (6 tuples across Bangalore, Mumbai, and Sydney)
INSERT INTO BRANCH (branch_name, branch_city, assets) VALUES
    ('Main', 'Bangalore', 500000.00),
    ('Citibank', 'Bangalore', 10000.23),
    ('HDFC', 'Mumbai', 25675.98),
    ('SBI', 'Bangalore', 35000.00),
    ('Gandhi Bazar', 'Bangalore', 15000.00),
    ('Town Hall', 'Sydney', 45000.00);

SELECT * FROM BRANCH;

-- 2. CUSTOMER (7 tuples)
INSERT INTO CUSTOMER (customer_name, customer_street, customer_city) VALUES
    ('Smith', 'Lincoln Street', 'Bangalore'),
    ('John', 'Mount Street', 'Mumbai'),
    ('Tom', 'MG Road', 'Bangalore'),
    ('Eliza', 'Brigade Road', 'Bangalore'),
    ('Aaa', 'Residency Road', 'Bangalore'),
    ('Bbb', 'Koramangala', 'Bangalore'),
    ('Ccc', 'Indiranagar', 'Bangalore');

SELECT * FROM CUSTOMER;

-- 3. ACCOUNT (9 tuples distributed across branches)
INSERT INTO ACCOUNT (accno, branch_name, balance) VALUES
    (100, 'Citibank', 8000.23),
    (122, 'Citibank', 4556.98),
    (201, 'Main', 15000.00),
    (202, 'Main', 25000.00),
    (456, 'Citibank', 3000.00),
    (457, 'Main', 7000.00),
    (458, 'SBI', 9000.00),
    (459, 'Gandhi Bazar', 11000.00),
    (601, 'Town Hall', 12000.00);

SELECT * FROM ACCOUNT;

-- 4. DEPOSITOR (8 tuples: 'Tom' has 2 accounts at 'Main'; 'Eliza' has accounts at all 4 Bangalore branches)
INSERT INTO DEPOSITOR (customer_name, accno) VALUES
    ('Smith', 100),
    ('John', 122),
    ('Tom', 201),
    ('Tom', 202),
    ('Eliza', 456),
    ('Eliza', 457),
    ('Eliza', 458),
    ('Eliza', 459);

SELECT * FROM DEPOSITOR;

-- 5. LOAN (5 tuples)
INSERT INTO LOAN (loan_number, branch_name, amount) VALUES
    (877, 'Citibank', 7887.09),
    (901, 'HDFC', 23455.22),
    (902, 'Gandhi Bazar', 3434.34),
    (903, 'Gandhi Bazar', 889.91),
    (904, 'Main', 4334.16);

SELECT * FROM LOAN;

-- 6. BORROWER (5 tuples)
INSERT INTO BORROWER (customer_name, loan_number) VALUES
    ('Smith', 877),
    ('John', 901),
    ('Aaa', 902),
    ('Bbb', 903),
    ('Ccc', 904);

SELECT * FROM BORROWER;

-- =============================================================================
-- (iii) FIND ALL THE CUSTOMERS WHO HAVE AT LEAST TWO ACCOUNTS AT THE MAIN BRANCH
-- =============================================================================
SELECT a.branch_name, d.customer_name, COUNT(a.accno) AS no_of_accounts
FROM ACCOUNT a, DEPOSITOR d
WHERE a.accno = d.accno 
  AND a.branch_name = 'Main'
GROUP BY a.branch_name, d.customer_name
HAVING COUNT(a.accno) >= 2;

-- =============================================================================
-- (iv) FIND ALL THE CUSTOMERS WHO HAVE AN ACCOUNT AT ALL THE BRANCHES LOCATED IN A SPECIFIC CITY
-- =============================================================================
-- Relational Division using GROUP BY and HAVING COUNT (for city 'Bangalore')
SELECT d.customer_name
FROM DEPOSITOR d, ACCOUNT a, BRANCH b
WHERE d.accno = a.accno 
  AND a.branch_name = b.branch_name 
  AND b.branch_city = 'Bangalore'
GROUP BY d.customer_name
HAVING COUNT(DISTINCT b.branch_name) = (
    SELECT COUNT(branch_name)
    FROM BRANCH
    WHERE branch_city = 'Bangalore'
);

-- =============================================================================
-- (v) DEMONSTRATE HOW YOU DELETE TUPLES IN ACCOUNT RELATION AT EVERY BRANCH LOCATED IN A SPECIFIC CITY
-- =============================================================================
DELETE FROM ACCOUNT
WHERE branch_name IN (
    SELECT branch_name
    FROM BRANCH
    WHERE branch_city = 'Sydney'
);

-- Display ACCOUNT relation after deletion
SELECT * FROM ACCOUNT;

-- =============================================================================
-- (vi) GENERATE SUITABLE REPORTS
-- =============================================================================

-- Report 1: Display the names of all the customers who have taken a loan, 
--           count of the number of loans taken, and the total amount taken by each customer.
SELECT b.customer_name, COUNT(l.loan_number) AS no_of_loans, SUM(l.amount) AS total_amount_taken
FROM BORROWER b, LOAN l
WHERE l.loan_number = b.loan_number
GROUP BY b.customer_name;

-- Report 2: Find the names of all the customers who have taken a loan in a particular branch (e.g., 'Gandhi Bazar').
SELECT b.customer_name
FROM BORROWER b, LOAN l
WHERE l.loan_number = b.loan_number 
  AND l.branch_name = 'Gandhi Bazar';

-- Report 3: Update the balance for the customer with a given customer name to 10000 
--           (demonstrating account balance update for a specific customer).
UPDATE ACCOUNT
SET balance = 10000.00
WHERE accno IN (
    SELECT accno 
    FROM DEPOSITOR 
    WHERE customer_name = 'Smith'
);

-- Display ACCOUNT table after the balance update
SELECT * FROM ACCOUNT;

-- =============================================================================
-- (vii) FRONT-END NOTE FOR LAB PRACTICALS / VIVA
-- =============================================================================
-- As per lab guidelines, this database can be connected to a front-end interface
-- (such as Visual Basic via ODBC/ADODB or Python Tkinter/Streamlit) using standard
-- SQL SELECT, INSERT, UPDATE, and DELETE queries against the QUESTION5 database[cite: 1, 3].
