CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    QOH INT
);

-- Order table
CREATE TABLE Order_ (
    OrderID INT PRIMARY KEY,
    OrderTime TIMESTAMP,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- OrderItem table
CREATE TABLE OrderItem (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    FOREIGN KEY (OrderID) REFERENCES Order_(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Customer table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    MailingAddress VARCHAR(255)
);


INSERT INTO Product (ProductID, Name, QOH)
VALUES
    (1, 'Product 1', 50),
    (2, 'Product 2', 30),
    (3, 'Product 3', 20),
    (4, 'Product 4', 40),
    (5, 'Product 5', 60),
    (6, 'Product 6', 25),
    (7, 'Product 7', 35),
    (8, 'Product 8', 45),
    (9, 'Product 9', 55),
    (10, 'Product 10', 15),
    (11, 'Product 11', 10),
    (12, 'Product 12', 5),
    (13, 'Product 13', 22),
    (14, 'Product 14', 18),
    (15, 'Product 15', 33),
    (16, 'Product 16', 28),
    (17, 'Product 17', 38),
    (18, 'Product 18', 48),
    (19, 'Product 19', 58),
    (20, 'Product 20', 13),
    (21, 'Product 21', 8),
    (22, 'Product 22', 3),
    (23, 'Product 23', 27),
    (24, 'Product 24', 43),
    (25, 'Product 25', 53);




INSERT INTO Customer (CustomerID, CustomerName, Email, MailingAddress)
VALUES
    (1, 'Alice Cooper', 'alicecooper@example.com', '1 Soho Drive, NYC'),
    (2, 'Dixie Mason', 'dixiemason@example.com', '1 GA Ln, GA'),
    (3, 'Ashlee', 'ashlee@example.com', 'Berry lane, Randolph NJ'),
    (4, 'Ari', 'ari4@example.com', '12 star drive, NJ'),
    (5, 'Rafal', 'rafal5@example.com', 'Rockstar DR, Rock, NJ'),
    (6, 'Eric', 'eric6@example.com', '15 Peace Rd'),
    (7, 'Anna', 'anna7@example.com', '16 Feb Drive, Randolph, NJ'),
    (8, 'Aly', 'aly@example.com', 'ATL, GA'),
    (9, 'Houston', 'houston@example.com', '1 Texas Drive, Randolph, NJ'),
    (10, 'Emily', 'emily10@example.com', '1 Main Street, Chatham, NJ');

SELECT * FROM order_;

INSERT INTO "order_" (OrderID, OrderTime, CustomerID)
VALUES
    (1, NOW(), 1),
    (2, NOW(), 2),
    (3, NOW(), 3),
    (4, NOW(), 4),
    (5, NOW(), 5),
    (6, NOW(), 6),
    (7, NOW(), 7),
    (8, NOW(), 8),
    (9, NOW(), 9),
    (10, NOW(), 10);
	
INSERT INTO OrderItem (OrderItemID, OrderID, ProductID)
VALUES
    -- Order 1
    (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3),
    (4, 1, 4),
    (5, 1, 5),

    -- Order 2
    (6, 2, 6),
    (7, 2, 7),
    (8, 2, 8),
    (9, 2, 9),
    (10, 2, 10),
	
	-- Order 3 
	(11, 3, 2),
	(12, 3, 11),
	(13, 3, 8),
	(14, 3, 13),
	(15, 3, 7),
	
	--Order 4 
	(16, 4, 14),
	(17, 4, 15),
	(18, 4, 16),
	(19, 4, 17),
	(20, 4, 18),
	
	--Order 5
	(21, 5, 19),
	(22, 5, 20),
	(23, 5, 21),
	(24, 5, 22),
	(25, 5, 23),
	
	--Order 6 
	(26, 6, 24),
	(27, 6, 25),
	(28, 6, 2),
	(29, 6, 3),
	(30, 6, 5),
	
	--Order 7 
	(31, 7, 5),
	(32, 7, 3),
	(33, 7, 4),
	(34, 7, 9),
	(35, 7, 10),
	
	--Order 8 
	(36, 8, 3),
	(37, 8, 5),
	(38, 8, 9),
	(39, 8, 23),
	(40, 8, 4),
	
	--Order 9 
	(41, 9, 8),
	(42, 9, 10),
	(43, 9, 16),
	(44, 9, 9), 
	(45, 9, 7),
	
	--Order 10
	(46, 10, 1),
	(47, 10, 2),
	(48, 10, 3),
	(49, 10, 4),
	(50, 10, 5);
	
CREATE OR REPLACE FUNCTION AddProductToOrder(
    IN p_OrderID INT,
    IN p_ProductID INT
)
RETURNS VOID AS
$$
DECLARE
    v_ProductQOH INT;
BEGIN
    -- Start a transaction
    BEGIN
        -- Check if QOH is greater than 0
        SELECT QOH INTO v_ProductQOH
        FROM Product
        WHERE ProductID = p_ProductID;

        IF v_ProductQOH <= 0 THEN
            RAISE EXCEPTION 'Product is out of stock (QOH is 0)';
        END IF;

        -- Add product to order
        INSERT INTO OrderItem (OrderID, ProductID)
        VALUES (p_OrderID, p_ProductID);

        -- Decrement QOH
        UPDATE Product
        SET QOH = QOH - 1
        WHERE ProductID = p_ProductID;

    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback the transaction in case of any exception
            ROLLBACK;
            RAISE;
    END;

    -- Commit the transaction
    COMMIT;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION GenerateOutOfStockReport()
RETURNS TABLE (ProductID INT, Name VARCHAR(255), QOH INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT Product.ProductID, Product.Name, Product.QOH
    FROM Product
    WHERE Product.QOH = 0;
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION ExtractOrderInformation(
    IN p_OrderID INT
)
RETURNS TABLE (
    CustomerID INT,
    CustomerName VARCHAR(255),
    Email VARCHAR(255),
    MailingAddress VARCHAR(255),
    ProductID INT,
    ProductName VARCHAR(255),
    QuantityOrdered INT
) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        "order".CustomerID,
        C.CustomerName,
        C.Email,
        C.MailingAddress,
        OI.ProductID,
        P.Name AS ProductName,
        OI.QuantityOrdered
    FROM "order"
    JOIN Customer C ON "order".CustomerID = C.CustomerID
    JOIN OrderItem OI ON "order".OrderID = OI.OrderID
    JOIN Product P ON OI.ProductID = P.ProductID
    WHERE "order".OrderID = p_OrderID;
END;
$$
LANGUAGE PLPGSQL;


SELECT * FROM  ExtractOrderInformation();




