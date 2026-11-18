/*
================================================================================
PROBLEM 2: ORDER PROCESSING DATABASE APPLICATION
================================================================================
2. Consider the following relations for an order processing database application in a
   company:
   CUSTOMER (cust #: int, cname: string, city: string)
   ORDER (order #: int, odate: date, cust #: int, ord-Amt: int)
   ORDER – ITEM (order #: int, item #: int, qty: int)
   ITEM (item # : int, unit price: int)
   SHIPMENT (order #: int, warehouse#: int, ship-date: date)
   WAREHOUSE (warehouse #: int, city: string)

   (i)   Create the above tables by properly specifying the primary keys and the foreign keys.
   (ii)  Enter at least five tuples for each relation.
   (iii) Produce a listing: CUSTNAME, #oforders, AVG_ORDER_AMT, where the middle
         column is the total numbers of orders by the customer and the last column is the average
         order amount for that customer.
   (iv)  List the order# for orders that were shipped from all the warehouses that the company
         has in a specific city.
   (v)   Demonstrate the deletion of an item from the ITEM table and demonstrate a method of
         handling the rows in the ORDER_ITEM table that contain this particular item.
   (vi)  Generate suitable reports.
   (vii) Create suitable front end for querying and displaying the results.
================================================================================
*/

-- Database Creation & Selection (MySQL)
-- Note: For PostgreSQL (psql), use: CREATE DATABASE QUESTION2; followed by \c QUESTION2
CREATE DATABASE IF NOT EXISTS QUESTION2;
USE QUESTION2;

-- =============================================================================
-- (i) CREATE TABLES WITH PRIMARY KEYS, FOREIGN KEYS, AND CASCADE CONSTRAINTS
-- =============================================================================

-- 1. CUSTOMER Table
CREATE TABLE CUSTOMER (
    CID INT PRIMARY KEY,
    CNAME VARCHAR(20) NOT NULL,
    CITY VARCHAR(20) NOT NULL
);

-- 2. ORDERTAB Table (Tracks orders placed by customers)
CREATE TABLE ORDERTAB (
    ONO INT PRIMARY KEY,
    ODATE DATE NOT NULL,
    CID INT NOT NULL,
    ORD_AMT INT NOT NULL,
    FOREIGN KEY (CID) REFERENCES CUSTOMER(CID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. ITEMTAB Table (Tracks items and their unit prices)
CREATE TABLE ITEMTAB (
    INO INT PRIMARY KEY,
    PRICE INT NOT NULL
);

-- 4. ORDER_ITEM Table (Composite Primary Key + Referential Integrity with Cascade)
-- Note: Primary key columns (ONO, INO) cannot be NULL, so ON DELETE CASCADE is used
-- to automatically remove dependent rows when an item or order is deleted.
CREATE TABLE ORDER_ITEM (
    ONO INT NOT NULL,
    INO INT NOT NULL,
    QTY INT NOT NULL,
    PRIMARY KEY (ONO, INO),
    FOREIGN KEY (ONO) REFERENCES ORDERTAB(ONO) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (INO) REFERENCES ITEMTAB(INO) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 5. WAREHOUSE Table
CREATE TABLE WAREHOUSE (
    WARENO INT PRIMARY KEY,
    CITY VARCHAR(20) NOT NULL
);

-- 6. SHIPMENT Table (Composite Primary Key referencing ORDERTAB and WAREHOUSE)
CREATE TABLE SHIPMENT (
    ONO INT NOT NULL,
    WARENO INT NOT NULL,
    SHIPDATE DATE NOT NULL,
    PRIMARY KEY (ONO, WARENO),
    FOREIGN KEY (ONO) REFERENCES ORDERTAB(ONO) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (WARENO) REFERENCES WAREHOUSE(WARENO) ON DELETE CASCADE ON UPDATE CASCADE
);

-- View created schema structures (Note: In PostgreSQL psql, use \d tablename)
DESCRIBE CUSTOMER;
DESCRIBE ORDERTAB;
DESCRIBE ITEMTAB;
DESCRIBE ORDER_ITEM;
DESCRIBE WAREHOUSE;
DESCRIBE SHIPMENT;

-- =============================================================================
-- (ii) ENTER AT LEAST FIVE TUPLES FOR EACH RELATION
-- =============================================================================

-- 1. Insert 5 tuples into CUSTOMER
INSERT INTO CUSTOMER (CID, CNAME, CITY) VALUES 
    (100, 'A', 'BAN'),
    (200, 'B', 'MAD'),
    (300, 'C', 'DEL'),
    (400, 'D', 'LUC'),
    (500, 'E', 'BOM');

SELECT * FROM CUSTOMER;

-- 2. Insert 5 tuples into ORDERTAB
INSERT INTO ORDERTAB (ONO, ODATE, CID, ORD_AMT) VALUES 
    (1000, '2002-05-10', 100, 10000),
    (2000, '2003-05-11', 200, 30000),
    (3000, '2002-05-12', 100, 12500),
    (4000, '2003-05-13', 200, 35000),
    (5000, '2002-05-14', 500, 7500);

SELECT * FROM ORDERTAB;

-- 3. Insert 5 tuples into ITEMTAB
INSERT INTO ITEMTAB (INO, PRICE) VALUES 
    (10, 2000),
    (20, 3000),
    (30, 2500),
    (40, 3500),
    (50, 1500);

SELECT * FROM ITEMTAB;

-- 4. Insert 5 tuples into ORDER_ITEM
INSERT INTO ORDER_ITEM (ONO, INO, QTY) VALUES 
    (1000, 10, 5),
    (2000, 20, 10),
    (3000, 30, 5),
    (4000, 40, 10),
    (5000, 50, 5);

SELECT * FROM ORDER_ITEM;

-- 5. Insert 5 tuples into WAREHOUSE
INSERT INTO WAREHOUSE (WARENO, CITY) VALUES 
    (15, 'SYD'),
    (25, 'SYD'),
    (35, 'BOM'),
    (45, 'BOM'),
    (55, 'DEL');

SELECT * FROM WAREHOUSE;

-- 6. Insert tuples into SHIPMENT
-- Note: Order 1000 is shipped from both warehouses in 'SYD' (15 and 25) to satisfy query (iv)
INSERT INTO SHIPMENT (ONO, WARENO, SHIPDATE) VALUES 
    (1000, 15, '2002-06-16'),
    (1000, 25, '2002-06-18'),
    (2000, 25, '2003-07-17'),
    (3000, 35, '2002-08-18'),
    (4000, 45, '2003-09-19'),
    (5000, 55, '2002-10-20');

SELECT * FROM SHIPMENT;

-- =============================================================================
-- (iii) PRODUCE A LISTING: CUSTNAME, NO_OF_ORDERS, AVG_ORDER_AMT
-- =============================================================================
SELECT C.CNAME AS CUSTNAME, 
       COUNT(DISTINCT OT.ONO) AS NO_OF_ORDERS, 
       AVG(OT.ORD_AMT) AS AVG_ORDER_AMT
FROM CUSTOMER C
JOIN ORDERTAB OT ON C.CID = OT.CID
GROUP BY C.CID, C.CNAME;

-- =============================================================================
-- (iv) LIST THE ORDER# FOR ORDERS SHIPPED FROM ALL WAREHOUSES IN A SPECIFIC CITY
-- =============================================================================
-- Relational Division using GROUP BY and HAVING COUNT (e.g., for city 'SYD')
SELECT S.ONO
FROM SHIPMENT S
JOIN WAREHOUSE W ON S.WARENO = W.WARENO
WHERE W.CITY = 'SYD'
GROUP BY S.ONO
HAVING COUNT(DISTINCT S.WARENO) = (
    SELECT COUNT(*) 
    FROM WAREHOUSE 
    WHERE CITY = 'SYD'
);

-- =============================================================================
-- (v) DEMONSTRATE DELETION OF AN ITEM AND HANDLING DEPENDENT ROWS IN ORDER_ITEM
-- =============================================================================
-- Delete Item# 10 from ITEMTAB; ON DELETE CASCADE automatically deletes matching
-- rows in ORDER_ITEM without violating composite primary key NOT NULL rules.
DELETE FROM ITEMTAB 
WHERE INO = 10;

-- Verify deletion from ITEMTAB and automatic cascade removal from ORDER_ITEM
SELECT * FROM ITEMTAB;
SELECT * FROM ORDER_ITEM;

-- =============================================================================
-- (vi) GENERATION OF SUITABLE REPORTS
-- =============================================================================

-- Report 1: Order numbers of all orders placed by customers belonging to a specific city ('BAN')
SELECT O.ONO
FROM CUSTOMER C
JOIN ORDERTAB O ON C.CID = O.CID
WHERE C.CITY = 'BAN';

-- Report 2: Details of all orders that the company has received
SELECT * FROM ORDERTAB;

-- =============================================================================
-- (vii) FRONT-END NOTE FOR LAB PRACTICALS / VIVA
-- =============================================================================
-- As per lab guidelines, this database can be connected to a front-end interface
-- (such as Visual Basic via ODBC/ADODB or Python Tkinter/Streamlit) using standard
-- SQL SELECT, INSERT, UPDATE, and DELETE queries against the QUESTION2 database[cite: 1, 3].
