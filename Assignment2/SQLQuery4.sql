CREATE VIEW vwCustomerOrder AS
SELECT 
    
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    p.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    (od.OrderQty * od.UnitPrice) AS TotalPrice
FROM 
    Sales.Customer c
    JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
    JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
    JOIN Production.Product p ON od.ProductID = p.ProductID


select * from vwCustomerOrder;

create view vwOrderCopy as
select * from vwCustomerOrder;

select * from vwOrderCopy;
drop view vwOrderCopy;


CREATE VIEW vwOrderCopy  AS
SELECT 
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    p.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    (od.OrderQty * od.UnitPrice) AS TotalPrice
FROM 
    Sales.Customer c
    JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
    JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
    JOIN Production.Product p ON od.ProductID = p.ProductID
WHERE 
     o.OrderDate = CAST(GETDATE() - 1 AS DATE)

/*orders that where placed yesterday*/
select * from vwOrderCopy;

drop view MyProducts;
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.StandardCost AS UnitPrice,
    v.Name AS CompanyName,
    c.Name AS CategoryName
FROM 
    Production.Product p
    JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
    JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
    JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
WHERE 
    p.SellEndDate IS NULL;

select * from MyProducts;

USE AdventureWorks;

GO

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4, 2) = 0
AS
BEGIN
    DECLARE @ProductUnitPrice DECIMAL(10, 2)
    DECLARE @UnitsInStock INT
    DECLARE @ReorderLevel INT

    -- Get product details from Product table
    SELECT 
        @ProductUnitPrice = UnitPrice,
        @UnitsInStock = UnitsInStock,
        @ReorderLevel = ReorderLevel
    FROM Product
    WHERE ProductID = @ProductID

    -- If no UnitPrice provided, use the UnitPrice from the Product table
    IF @UnitPrice IS NULL
    BEGIN
        SET @UnitPrice = @ProductUnitPrice
    END

    -- Check if there is enough stock
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available. The order could not be placed.'
        RETURN
    END

    -- Insert order details
    INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount)

    -- Check if the insert was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.'
        RETURN
    END

    -- Update the stock quantity
    UPDATE Product
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID

    -- Check if the stock level drops below reorder level
    IF @UnitsInStock - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock of the product has dropped below its reorder level.'
    END

    PRINT 'Order placed successfully.'

END

GO

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(4, 2) = NULL
AS
BEGIN
    DECLARE @OriginalUnitPrice DECIMAL(10, 2)
    DECLARE @OriginalQuantity INT
    DECLARE @OriginalDiscount DECIMAL(4, 2)
    DECLARE @NewQuantity INT
    DECLARE @QuantityDiff INT

    -- Get the current order details
    SELECT
        @OriginalUnitPrice = UnitPrice,
        @OriginalQuantity = Quantity,
        @OriginalDiscount = Discount
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- If the order doesn't exist, exit the procedure
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Order not found.'
        RETURN
    END

    -- Determine the new values, retaining original values if parameters are NULL
    SET @UnitPrice = ISNULL(@UnitPrice, @OriginalUnitPrice)
    SET @Quantity = ISNULL(@Quantity, @OriginalQuantity)
    SET @Discount = ISNULL(@Discount, @OriginalDiscount)

    -- Calculate the quantity difference
    SET @QuantityDiff = @Quantity - @OriginalQuantity

    -- Update the order details
    UPDATE OrderDetails
    SET
        UnitPrice = @UnitPrice,
        Quantity = @Quantity,
        Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to update the order. Please try again.'
        RETURN
    END

    -- Adjust the UnitsInStock in the Product table
    UPDATE Product
    SET UnitsInStock = UnitsInStock - @QuantityDiff
    WHERE ProductID = @ProductID

    -- Check if the stock level drops below reorder level
    DECLARE @UnitsInStock INT
    DECLARE @ReorderLevel INT

    SELECT
        @UnitsInStock = UnitsInStock,
        @ReorderLevel = ReorderLevel
    FROM Product
    WHERE ProductID = @ProductID

    IF @UnitsInStock < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock of the product has dropped below its reorder level.'
    END

    PRINT 'Order updated successfully.'

END

GO


CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    -- Declare a variable to count the number of records found
    DECLARE @RecordCount INT

    -- Select the records for the given OrderID
    SELECT *
    INTO #TempOrderDetails
    FROM OrderDetails
    WHERE OrderID = @OrderID

    -- Get the count of records
    SET @RecordCount = (SELECT COUNT(*) FROM #TempOrderDetails)

    -- Check if no records are found
    IF @RecordCount = 0
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist'
        RETURN 1
    END
    ELSE
    BEGIN
        -- Return the records found
        SELECT * FROM #TempOrderDetails
    END

    -- Drop the temporary table
    DROP TABLE #TempOrderDetails
END

GO


CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    -- Declare a variable to count the number of records found
    DECLARE @RecordCount INT

    -- Check if the given order ID and product ID exist in the OrderDetails table
    SELECT @RecordCount = COUNT(*)
    FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- Validate parameters
    IF @RecordCount = 0
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' and ProductID ' + CAST(@ProductID AS VARCHAR) + ' combination does not exist in the OrderDetails table.'
        RETURN -1
    END

    -- Delete the record from OrderDetails table
    DELETE FROM OrderDetails
    WHERE OrderID = @OrderID AND ProductID = @ProductID

    -- Check if the delete operation was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to delete the order details. Please try again.'
        RETURN -1
    END

    PRINT 'Order details deleted successfully.'
END

GO


CREATE TRIGGER InsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    -- Delete corresponding records in Order Details
    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM deleted)

    -- Delete records in Orders
    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted)

    PRINT 'Order and corresponding order details deleted successfully.'
END


CREATE TRIGGER AfterInsertOrderDetails
ON [Order Details]
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT
    DECLARE @ProductID INT
    DECLARE @Quantity INT
    DECLARE @UnitsInStock INT

    -- Get inserted values
    SELECT @OrderID = OrderID, @ProductID = ProductID, @Quantity = Quantity
    FROM inserted

    -- Check stock availability
    SELECT @UnitsInStock = UnitsInStock
    FROM Products
    WHERE ProductID = @ProductID

    IF @UnitsInStock >= @Quantity
    BEGIN
        -- Decrement stock
        UPDATE Products
        SET UnitsInStock = UnitsInStock - @Quantity
        WHERE ProductID = @ProductID

        PRINT 'Order placed successfully and stock updated.'
    END
    ELSE
    BEGIN
        -- Rollback the transaction
        ROLLBACK TRANSACTION

        PRINT 'Order could not be placed due to insufficient stock.'
    END
END

--Test Data For trigger
-- Insert sample product
INSERT INTO Products (ProductID, ProductName, UnitsInStock) VALUES (1, 'Sample Product', 50);

-- Insert sample order
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (1, 'ALFKI', GETDATE());

-- Insert sample order details
INSERT INTO [Order Details] (OrderID, ProductID, Quantity) VALUES (1, 1, 10);

--test case for delete trigger
-- Attempt to delete the order
DELETE FROM Orders WHERE OrderID = 1;

-- Verify if order and details are deleted
SELECT * FROM Orders WHERE OrderID = 1;
SELECT * FROM [Order Details] WHERE OrderID = 1;


-- Attempt to place an order with sufficient stock
INSERT INTO [Order Details] (OrderID, ProductID, Quantity) VALUES (2, 1, 20);

-- Attempt to place an order with insufficient stock
INSERT INTO [Order Details] (OrderID, ProductID, Quantity) VALUES (2, 1, 40);

-- Verify stock and order details
SELECT * FROM Products WHERE ProductID = 1;
SELECT * FROM [Order Details] WHERE OrderID = 2;




