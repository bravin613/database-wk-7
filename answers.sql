-- ============================================
-- DATABASE NORMALIZATION ASSIGNMENT
-- Sales Database (salesDB)
-- ============================================

-- ============================================
-- Question 1: Achieving 1NF 
-- ============================================


-- Step 1: Create the original non-normalized table
DROP TABLE IF EXISTS ProductDetail;

CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert the sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Create the normalized table in 1NF
DROP TABLE IF EXISTS ProductDetail_1NF;

CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    PRIMARY KEY (OrderID, Product)
);

-- Step 3: Insert normalized data (each product in separate row)
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product) VALUES
(101, 'John Doe', 'Laptop'),
(101, 'John Doe', 'Mouse'),
(102, 'Jane Smith', 'Tablet'),
(102, 'Jane Smith', 'Keyboard'),
(102, 'Jane Smith', 'Mouse'),
(103, 'Emily Clark', 'Phone');

-- Verify the result
SELECT * FROM ProductDetail_1NF ORDER BY OrderID, Product;

/*
RESULT:
+----------+--------------+----------+
| OrderID  | CustomerName | Product  |
+----------+--------------+----------+
| 101      | John Doe     | Laptop   |
| 101      | John Doe     | Mouse    |
| 102      | Jane Smith   | Keyboard |
| 102      | Jane Smith   | Mouse    |
| 102      | Jane Smith   | Tablet   |
| 103      | Emily Clark  | Phone    |
+----------+--------------+----------+
*/


-- ============================================
-- Question 2: Achieving 2NF (Second Normal Form)
-- ============================================

-- Step 1: Create the original table (already in 1NF but not 2NF)
DROP TABLE IF EXISTS OrderDetails_1NF;

CREATE TABLE OrderDetails_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert sample data
INSERT INTO OrderDetails_1NF (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 2: Create normalized tables in 2NF

-- Table 1: Orders (stores customer information per order)
DROP TABLE IF EXISTS Orders_2NF;

CREATE TABLE Orders_2NF (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);

-- Insert data into Orders_2NF (remove duplicates)
INSERT INTO Orders_2NF (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails_1NF;

-- Table 2: OrderDetails (stores product and quantity per order)
DROP TABLE IF EXISTS OrderDetails_2NF;

CREATE TABLE OrderDetails_2NF (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT NOT NULL,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders_2NF(OrderID)
);

-- Insert data into OrderDetails_2NF
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails_1NF;

-- Step 3: Verify the results

-- View Orders table
SELECT * FROM Orders_2NF ORDER BY OrderID;

-- View OrderDetails table
SELECT * FROM OrderDetails_2NF ORDER BY OrderID, Product;

-- Verify with JOIN to reconstruct original data
SELECT 
    o.OrderID,
    o.CustomerName,
    od.Product,
    od.Quantity
FROM Orders_2NF o
JOIN OrderDetails_2NF od ON o.OrderID = od.OrderID
ORDER BY o.OrderID, od.Product;

/*
RESULTS:

Orders_2NF:
+----------+--------------+
| OrderID  | CustomerName |
+----------+--------------+
| 101      | John Doe     |
| 102      | Jane Smith   |
| 103      | Emily Clark  |
+----------+--------------+

OrderDetails_2NF:
+----------+----------+----------+
| OrderID  | Product  | Quantity |
+----------+----------+----------+
| 101      | Laptop   | 2        |
| 101      | Mouse    | 1        |
| 102      | Keyboard | 1        |
| 102      | Mouse    | 2        |
| 102      | Tablet   | 3        |
| 103      | Phone    | 1        |
+----------+----------+----------+
*/
