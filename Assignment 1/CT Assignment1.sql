/*Query having red mark are from database AdeventureWorks2022*/

select * from SalesLT.Customer;

select * from SalesLT.Customer where CompanyName LIKE '%N';
 
SELECT DISTINCT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    a.AddressLine1,
    a.City,
    a.PostalCode,
    a.CountryRegion
FROM
    SalesLT.Customer c
JOIN
    SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN
    SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE
    a.City IN ('London', 'Berlin');

SELECT DISTINCT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    a.AddressLine1,
    a.City,
    a.StateProvince,
    a.PostalCode,
    a.CountryRegion
FROM
    SalesLT.Customer c
JOIN
    SalesLT.CustomerAddress ca ON c.CustomerID = ca.CustomerID
JOIN
    SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE
    a.CountryRegion IN ('United Kingdom', 'United States');

SELECT * FROM
    SalesLT.Product
ORDER BY
    Name;

select * from SalesLT.Product where Name like 'A%';

SELECT DISTINCT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.EmailAddress,
    c.Phone
FROM
    SalesLT.Customer c
JOIN
    SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
ORDER BY
    c.CustomerID;

SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE UPPER(a.City) = 'London'
AND p.Name = 'Chai'
AND pc.Name = 'Beverages';

SELECT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
WHERE soh.CustomerID IS NULL;

SELECT DISTINCT c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE soh.OrderDate = (
    SELECT MIN(OrderDate)
    FROM SalesLT.SalesOrderHeader
);

SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID, c.FirstName, c.LastName, soh.TotalDue
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE soh.TotalDue = (
    SELECT MAX(TotalDue)
    FROM SalesLT.SalesOrderHeader
);

SELECT soh.SalesOrderID, AVG(sod.OrderQty) AS AvgQuantity
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID;

SELECT soh.SalesOrderID, MIN(sod.OrderQty) AS MinQuantity, MAX(sod.OrderQty) AS MaxQuantity
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID;

SELECT soh.SalesOrderID, SUM(sod.OrderQty) AS TotalQuantity
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.SalesOrderID
HAVING SUM(sod.OrderQty) > 300;

SELECT SalesOrderID, OrderDate
FROM SalesLT.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


SELECT soh.SalesOrderID, soh.OrderDate
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Address AS a ON soh.ShipToAddressID = a.AddressID
WHERE a.CountryRegion = 'Canada';

SELECT SalesOrderID, TotalDue
FROM SalesLT.SalesOrderHeader
WHERE TotalDue > 200;

SELECT a.CountryRegion AS Country, SUM(soh.TotalDue) AS TotalSales
FROM SalesLT.Address AS a
LEFT JOIN SalesLT.SalesOrderHeader AS soh ON soh.ShipToAddressID = a.AddressID
GROUP BY a.CountryRegion;

SELECT c.Phone, c.EmailAddress
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.Phone, c.EmailAddress
HAVING COUNT(soh.SalesOrderID) > 3;

SELECT p.ProductID, p.Name AS ProductName
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL
AND soh.OrderDate >= '1997-01-01'
AND soh.OrderDate < '1998-01-01';


/*QUERY HAVING RED MARKS ARE FROM DATABSE ADVENTUREWORKS2022*/

SELECT CONCAT(ep.FirstName, ' ', ep.LastName) AS EmployeeName
FROM HumanResources.Employee AS e
JOIN Person.Person AS ep ON e.BusinessEntityID = ep.BusinessEntityID
WHERE ep.FirstName LIKE '%a%';

SELECT sp.BusinessEntityID AS EmployeeID, CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesPerson AS sp
JOIN Sales.SalesOrderHeader AS soh ON sp.BusinessEntityID = soh.SalesPersonID
JOIN Person.Person AS p ON sp.BusinessEntityID = p.BusinessEntityID
GROUP BY sp.BusinessEntityID, p.FirstName, p.LastName;

SELECT sod.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p ON sod.ProductID = p.ProductID;

SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID = (
    SELECT TOP 1 CustomerID
    FROM (
        SELECT CustomerID, SUM(TotalDue) AS TotalSales
        FROM SalesLT.SalesOrderHeader
        GROUP BY CustomerID
        ORDER BY SUM(TotalDue) DESC
    ) AS BestCustomer
);

SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID, c.FirstName, c.LastName
FROM SalesLT.SalesOrderHeader AS soh
JOIN SalesLT.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID NOT IN (
    SELECT CustomerID
    FROM SalesLT.Customer
    WHERE Freight IS NOT NULL
);

SELECT DISTINCT a.PostalCode
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
JOIN SalesLT.SalesOrderHeader AS sh ON sod.SalesOrderID = sh.SalesOrderID
JOIN SalesLT.CustomerAddress AS ca ON sh.ShipToAddressID = ca.AddressID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE p.Name = 'Tofu';

SELECT DISTINCT p.Name AS ProductName
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p ON sod.ProductID = p.ProductID
JOIN SalesLT.SalesOrderHeader AS sh ON sod.SalesOrderID = sh.SalesOrderID
JOIN SalesLT.CustomerAddress AS ca ON sh.ShipToAddressID = ca.AddressID
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE a.CountryRegion = 'France';


SELECT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor AS pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor AS v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

SELECT p.ProductID, p.Name AS ProductName
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

SELECT 
    ProductID, 
    Name AS ProductName, 
    UnitsInStock, 
    UnitsOnOrder
FROM 
    Production.Product
WHERE 
    UnitsInStock < 10 
    AND UnitsOnOrder = 0;

SELECT 
    TOP 10
    CTRY.CountryRegionCode AS CountryCode,
    CTRY.Name AS CountryName,
    SUM(SOH.TotalDue) AS TotalSales
FROM 
    SalesLT.Customer AS C
JOIN 
    SalesLT.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
JOIN 
    SalesLT.CustomerAddress AS CA ON C.CustomerID = CA.CustomerID
JOIN 
    SalesLT.Address AS A ON CA.AddressID = A.AddressID
JOIN 
    SalesLT.CountryRegion AS CTRY ON A.CountryRegionCode = CTRY.CountryRegionCode
GROUP BY 
    CTRY.CountryRegionCode, CTRY.Name
ORDER BY 
    TotalSales DESC;


SELECT TOP 1
    OrderDate
FROM 
    SalesLT.SalesOrderHeader
ORDER BY 
    TotalDue DESC;

SELECT 
    p.Name AS ProductName,
    SUM(sod.UnitPrice * sod.OrderQty) AS TotalRevenue
FROM 
    SalesLT.Product AS p
JOIN 
    SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.Name
ORDER BY 
    TotalRevenue DESC;

SELECT 
    pv.BusinessEntityID AS SupplierID,
    COUNT(pv.ProductID) AS NumberOfProductsOffered
FROM 
    Purchasing.ProductVendor AS pv
GROUP BY 
    pv.BusinessEntityID
ORDER BY 
    NumberOfProductsOffered DESC;

SELECT TOP 10
    c.CustomerID,
    c.CompanyName,
    SUM(soh.TotalDue) AS TotalBusiness
FROM 
    SalesLT.Customer AS c
JOIN 
    SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    c.CustomerID, c.CompanyName
ORDER BY 
    TotalBusiness DESC;

SELECT 
    SUM(TotalDue) AS TotalRevenue
FROM 
    SalesLT.SalesOrderHeader;






















































