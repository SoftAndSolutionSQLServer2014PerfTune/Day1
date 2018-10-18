/*Listing 2.1*/
SELECT  ct.*
FROM    Person.ContactType AS ct;

/*Listing 2.2*/
SELECT  ct.*
FROM    Person.ContactType AS ct
WHERE   ct.ContactTypeID = 7

/*Listing 2.3*/
SELECT  ct.ContactTypeId
FROM    Person.ContactType AS ct
WHERE   Name LIKE 'Own%'

/*Listing 2.4*/
SELECT  p.BusinessEntityID ,
        p.LastName ,
        p.FirstName ,
        p.NameStyle
FROM    Person.Person AS p
WHERE   p.LastName LIKE 'Jaf%';

/*Listing 2.5*/
SELECT  *
FROM    dbo.DatabaseLog;

 
/*Listing 2.6*/
SELECT  *
FROM    [dbo].[DatabaseLog]
WHERE   DatabaseLogID = 1

/*Listing 2.7*/
SELECT  e.JobTitle ,
        a.City ,
        p.LastName + ', ' + p.FirstName AS EmployeeName
FROM    HumanResources.Employee AS e
        JOIN Person.BusinessEntityAddress AS bea ON e.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a ON bea.AddressID = a.AddressID
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID;

/*Listing 2.8*/
SELECT  c.CustomerID
FROM    Sales.SalesOrderDetail od
        JOIN Sales.SalesOrderHeader oh ON od.SalesOrderID = oh.SalesOrderID
        JOIN Sales.Customer c ON oh.CustomerID = c.CustomerID

/*Listing 2.9*/
SELECT  e.[Title] ,
        a.[City] ,
        c.[LastName] + ',' + c.[FirstName] AS EmployeeName
FROM    [HumanResources].[Employee] e
        JOIN [HumanResources].[EmployeeAddress] ed ON e.[EmployeeID] = ed.[EmployeeID]
        JOIN [Person].[Address] a ON [ed].[AddressID] = [a].[AddressID]
        JOIN [Person].[Contact] c ON e.[ContactID] = c.[ContactID]
WHERE   e.[Title] = 'Production Technician - WC20';

/*Listing 2.10*/
SELECT  Shelf
FROM    Production.ProductInventory
ORDER BY Shelf

/*Listing 2.11*/
SELECT  *
FROM    Production.ProductInventory
ORDER BY ProductID

 
/*Listing 2.12*/
SELECT  [City] ,
        COUNT([City]) AS CityCount
FROM    [Person].[Address]
GROUP BY [City]

/*Listing 2.13*/
SELECT  [City] ,
        COUNT([City]) AS CityCount
FROM    [Person].[Address]
GROUP BY [City]
HAVING  COUNT([City]) > 1

/*Listing 2.14*/
SELECT  sod.SalesOrderDetailID
FROM    Sales.SalesOrderDetail AS sod
WHERE   LineTotal < ( SELECT    AVG(dos.LineTotal)
                      FROM      Sales.SalesOrderDetail AS dos
                      WHERE     dos.ModifiedDate < sod.ModifiedDate
                    )

/*Listing 2.15*/
INSERT  INTO Person.Address
        ( AddressLine1 ,
          AddressLine2 ,
          City ,
          StateProvinceID ,
          PostalCode ,
          rowguid ,
          ModifiedDate
        )
VALUES  ( N'1313 Mockingbird Lane' , -- AddressLine1 - nvarchar(60)
          N'Basement' , -- AddressLine2 - nvarchar(60)
          N'Springfield' , -- City - nvarchar(30)
          79 , -- StateProvinceID - int
          N'02134' , -- PostalCode - nvarchar(15)
          NEWID() , -- rowguid - uniqueidentifier
          GETDATE()  -- ModifiedDate - datetime
        )

/*Listing 2.16*/
UPDATE  [Person].[Address]
SET     [City] = 'Munro' ,
        [ModifiedDate] = GETDATE()
WHERE   [City] = 'Monroe';

/*Listing 2.17*/
BEGIN TRAN
DELETE  FROM Person.EmailAddress
WHERE   BusinessEntityID = 42
ROLLBACK TRAN

