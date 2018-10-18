/*Listing 5.2*/
SELECT  p.Suffix ,
        COUNT(p.Suffix) AS SuffixUsageCount
FROM    Person.Person AS p
GROUP BY p.Suffix;

/*Listing 5.3*/
SELECT  p.Suffix ,
        COUNT(p.Suffix) AS SuffixUsageCount
FROM    Person.Person AS p
GROUP BY p.Suffix
OPTION  ( ORDER GROUP );

/*Listing 5.4*/
SELECT  [pm1].[Name] ,
        [pm1].[ModifiedDate]
FROM    [Production].[ProductModel] pm1
UNION
SELECT  [pm2].[Name] ,
        [pm2].[ModifiedDate]
FROM    [Production].[ProductModel] pm2;

/*Listing 5.5*/
SELECT  pm1.Name ,
        pm1.ModifiedDate
FROM    Production.ProductModel pm1
UNION
SELECT  pm2.Name ,
        pm2.ModifiedDate
FROM    Production.ProductModel pm2
OPTION  ( MERGE UNION );

/*Listing 5.6*/
SELECT  pm1.Name ,
        pm1.ModifiedDate
FROM    Production.ProductModel pm1
UNION
SELECT  pm2.Name ,
        pm2.ModifiedDate
FROM    Production.ProductModel pm2
OPTION  ( HASH UNION );

/*Listing 5.7*/
SELECT  pm.Name ,
        pm.CatalogDescription ,
        p.Name AS ProductName ,
        i.Diagram
FROM    Production.ProductModel AS pm
        LEFT JOIN Production.Product AS p ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration AS pmi ON p.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration AS i ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;

/*Listing 5.9*/
OPTION  ( LOOP JOIN );

/*Listing 5.11*/
OPTION  ( MERGE JOIN );

/*Listing 5.13*/
OPTION  ( HASH JOIN );

/*Listing 5.15*/
SELECT  *
FROM    Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID;

/*Listing 5.16*/
OPTION  ( FAST 10 );

/*Listing 5.17*/
SELECT  pc.Name AS ProductCategoryName ,
        ps.Name AS ProductSubCategoryName ,
        p.Name AS ProductName ,
        pdr.Description ,
        pm.Name AS ProductModelName ,
        c.Name AS CultureName ,
        d.FileName ,
        pri.Quantity ,
        pr.Rating ,
        pr.Comments
FROM    Production.Product AS p
        LEFT JOIN Production.ProductModel AS pm ON p.ProductModelID = pm.ProductModelID
        LEFT JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        LEFT JOIN Production.ProductInventory AS pri ON p.ProductID = pri.ProductID
        LEFT JOIN Production.ProductReview AS pr ON p.ProductID = pr.ProductID
        LEFT JOIN Production.ProductDocument AS pd ON p.ProductID = pd.ProductID
        LEFT JOIN Production.Document AS d ON pd.DocumentNode = d.DocumentNode
        LEFT JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
        LEFT JOIN Production.ProductModelProductDescriptionCulture AS pmpdc ON pm.ProductModelID = pmpdc.ProductModelID
        LEFT JOIN Production.ProductDescription AS pdr ON pmpdc.ProductDescriptionID = pdr.ProductDescriptionID
        LEFT JOIN Production.Culture AS c ON c.CultureID = pmpdc.CultureID;

/*Listing 5.18*/
OPTION (FORCE ORDER);

/*Listing 5.19*/
sp_configure 'cost threshold for parallelism', 1;
GO

RECONFIGURE WITH OVERRIDE;
GO

SELECT  wo.DueDate ,
        MIN(wo.OrderQty) MinOrderQty ,
        MIN(wo.StockedQty) MinStockedQty ,
        MIN(wo.ScrappedQty) MinScrappedQty ,
        MAX(wo.OrderQty) MaxOrderQty ,
        MAX(wo.StockedQty) MaxStockedQty ,
        MAX(wo.ScrappedQty) MaxScrappedQty
FROM    Production.WorkOrder wo
GROUP BY wo.DueDate
ORDER BY wo.DueDate;
GO

sp_configure 'cost threshold for parallelism', 50;
GO

RECONFIGURE WITH OVERRIDE;
GO

/*Listing 5.20*/
OPTION  ( MAXDOP 1 );

/*Listing 5.21*/
SELECT  *
FROM    Person.Address
WHERE   City = 'Mentor'

SELECT  *
FROM    Person.Address
WHERE   City = 'London'

/*Listing 5.22*/
DECLARE @City NVARCHAR(30)

SET @City = 'Mentor'
SELECT  *
FROM    Person.Address
WHERE   City = @City

SET @City = 'London'
SELECT  *
FROM    Person.Address
WHERE   City = @City;

/*Listing 5.23*/
DECLARE @City NVARCHAR(30)

SET @City = 'London'
SELECT  *
FROM    Person.Address
WHERE   City = @City

SET @City = 'London'
SELECT  *
FROM    Person.Address
WHERE   City = @City
OPTION  ( OPTIMIZE FOR ( @City = 'Mentor' ) );

/*Listing 5.24*/
DECLARE @PersonId INT = 277;
SELECT  soh.SalesOrderNumber ,
        soh.OrderDate ,
        soh.SubTotal ,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID = @PersonId;

SET @PersonId = 288;
SELECT  soh.SalesOrderNumber ,
        soh.OrderDate ,
        soh.SubTotal ,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID = @PersonId;

/*Listing 5.25*/
DECLARE @PersonId INT = 277;
SELECT  soh.SalesOrderNumber ,
        soh.OrderDate ,
        soh.SubTotal ,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID = @PersonId
OPTION  ( RECOMPILE );

SET @PersonId = 288;
SELECT  soh.SalesOrderNumber ,
        soh.OrderDate ,
        soh.SubTotal ,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID = @PersonId
OPTION  ( RECOMPILE );

/*Listing 5.26*/
SELECT  *
FROM    Person.vStateProvinceCountryRegion;

/*Listing 5.27*/
SELECT  pm.Name ,
        pm.CatalogDescription ,
        p.Name AS ProductName ,
        i.Diagram
FROM    Production.ProductModel pm
        LEFT JOIN Production.Product p ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration pmi ON pm.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration i ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;

/*Listing 5.28*/
SELECT  pm.Name ,
        pm.CatalogDescription ,
        p.Name AS ProductName ,
        i.Diagram
FROM    Production.ProductModel pm
        LEFT LOOP JOIN Production.Product p ON pm.ProductModelID = p.ProductModelID
        LEFT JOIN Production.ProductModelIllustration pmi ON pm.ProductModelID = pmi.ProductModelID
        LEFT JOIN Production.Illustration i ON pmi.IllustrationID = i.IllustrationID
WHERE   pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;

/*Listing 5.30*/
SELECT  a.City ,
        v.StateProvinceName ,
        v.CountryRegionName
FROM    Person.Address AS a
        JOIN Person.vStateProvinceCountryRegion AS v WITH ( NOEXPAND ) ON a.StateProvinceID = v.StateProvinceID
WHERE   a.AddressID = 22701;

/*Listing 5.31*/
FROM TableName WITH (INDEX(0))

/*Listing 5.32*/
FROM TableName WITH (INDEX ([IndexName]))

/*Listing 5.33*/
SELECT  de.Name ,
        e.JobTitle ,
        p.LastName + ', ' + p.FirstName
FROM    HumanResources.Department de
        JOIN HumanResources.EmployeeDepartmentHistory edh ON de.DepartmentID = edh.DepartmentID
        JOIN HumanResources.Employee e ON edh.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE   de.Name LIKE 'P%'

/*Listing 5.34*/
SELECT  de.Name ,
        e.JobTitle ,
        p.LastName + ', ' + p.FirstName
FROM    HumanResources.Department de WITH ( INDEX ( PK_Department_DepartmentID ) )
        JOIN HumanResources.EmployeeDepartmentHistory edh ON de.DepartmentID = edh.DepartmentID
        JOIN HumanResources.Employee e ON edh.BusinessEntityID = e.BusinessEntityID
        JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE   de.Name LIKE 'P%';

/*Listing 5.35*/
SELECT  pm.Name AS ProductModelName ,
        p.Name AS ProductName ,
        SUM(pin.Quantity)
FROM    Production.ProductModel pm
        JOIN Production.Product p ON pm.ProductModelID = p.ProductModelID
        JOIN Production.ProductInventory pin ON p.ProductID = pin.ProductID
GROUP BY pm.Name ,
        p.Name;

/*Listing 5.36*/
SELECT  pm.Name AS ProductModelName ,
        p.Name AS ProductName ,
        SUM(pin.Quantity)
FROM    Production.ProductModel pm
        JOIN Production.Product p WITH ( FASTFIRSTROW ) ON pm.ProductModelID = p.ProductModelID
        JOIN Production.ProductInventory pin ON p.ProductID = pin.ProductID
GROUP BY pm.Name ,
        p.Name; 

