/*Listing 4.1*/
CREATE PROCEDURE [Sales].[spTaxRateByState]
    @CountryRegionCode NVARCHAR(3)
AS 
    SET NOCOUNT ON;

    SELECT  [st].[SalesTaxRateID] ,
            [st].[Name] ,
            [st].[TaxRate] ,
            [st].[TaxType] ,
            [sp].[Name] AS StateName
    FROM    [Sales].[SalesTaxRate] st
            JOIN [Person].[StateProvince] sp ON [st].[StateProvinceID] = [sp].[StateProvinceID]
    WHERE   [sp].[CountryRegionCode] = @CountryRegionCode
    ORDER BY [StateName];
GO

/*Listing 4.2*/
EXEC [Sales].[spTaxRateByState] @CountryRegionCode = 'US';

/*Listing 4.3*/
SELECT  p.Name ,
        p.ProductNumber ,
        ph.ListPrice
FROM    Production.Product p
        INNER JOIN Production.ProductListPriceHistory ph ON p.ProductID = ph.ProductID
                                                            AND ph.StartDate = ( SELECT TOP ( 1 )
                                                              ph2.StartDate
                                                              FROM
                                                              Production.ProductListPriceHistory ph2
                                                              WHERE
                                                              ph2.ProductID = p.ProductID
                                                              ORDER BY ph2.StartDate DESC
                                                              );

/*Listing 4.4*/
SELECT  p.Name ,
        p.ProductNumber ,
        ph.ListPrice
FROM    Production.Product p
        CROSS APPLY ( SELECT TOP ( 1 )
                                ph2.ProductID ,
                                ph2.ListPrice
                      FROM      Production.ProductListPriceHistory ph2
                      WHERE     ph2.ProductID = p.ProductID
                      ORDER BY  ph2.StartDate DESC
                    ) ph;

/*Listing 4.5*/
WHERE [p].[ProductID] = '839'

/*Listing 4.6*/
ALTER PROCEDURE [dbo].[uspGetManagerEmployees]
    @BusinessEntityID [int]
AS 
    BEGIN
        SET NOCOUNT ON;
        WITH    [EMP_cte] ( [BusinessEntityID], [OrganizationNode], [FirstName], [LastName], [RecursionLevel] )
                  -- CTE name and columns
                  AS ( SELECT   e.[BusinessEntityID] ,
                                e.[OrganizationNode] ,
                                p.[FirstName] ,
                                p.[LastName] ,
                                0 -- Get the initial list of Employees
                              -- for Manager n
                       FROM     [HumanResources].[Employee] e
                                INNER JOIN [Person].[Person] p ON p.[BusinessEntityID] = e.[BusinessEntityID]
                       WHERE    e.[BusinessEntityID] = @BusinessEntityID
                       UNION ALL
                       SELECT   e.[BusinessEntityID] ,
                                e.[OrganizationNode] ,
                                p.[FirstName] ,
                                p.[LastName] ,
                                [RecursionLevel] + 1 -- Join recursive
                                                 -- member to anchor
                       FROM     [HumanResources].[Employee] e
                                INNER JOIN [EMP_cte] ON e.[OrganizationNode].GetAncestor(1) = [EMP_cte].[OrganizationNode]
                                INNER JOIN [Person].[Person] p ON p.[BusinessEntityID] = e.[BusinessEntityID]
                     )
            SELECT  [EMP_cte].[RecursionLevel] ,
                    [EMP_cte].[OrganizationNode].ToString() AS [OrganizationNode] ,
                    p.[FirstName] AS 'ManagerFirstName' ,
                    p.[LastName] AS 'ManagerLastName' ,
                    [EMP_cte].[BusinessEntityID] ,
                    [EMP_cte].[FirstName] ,
                    [EMP_cte].[LastName] -- Outer select from the CTE
            FROM    [EMP_cte]
                    INNER JOIN [HumanResources].[Employee] e ON [EMP_cte].[OrganizationNode].GetAncestor(1) = e.[OrganizationNode]
                    INNER JOIN [Person].[Person] p ON p.[BusinessEntityID] = e.[BusinessEntityID]
            ORDER BY [RecursionLevel] ,
                    [EMP_cte].[OrganizationNode].ToString()
        OPTION  ( MAXRECURSION 25 ) 
    END;

/*Listing 4.7*/
    SET STATISTICS XML ON;
GO
EXEC [dbo].[uspGetEmployeeManagers] @EmployeeID = 9;
GO
SET STATISTICS XML OFF;
GO

/*Listing 4.9*/
DECLARE @BusinessEntityId INT = 42 ,
    @AccountNumber NVARCHAR(15) = 'SSHI' ,
    @Name NVARCHAR(50) = 'Shotz Beer' ,
    @CreditRating TINYINT = 2 ,
    @PreferredVendorStatus BIT = 0 ,
    @ActiveFlag BIT = 1 ,
    @PurchasingWebServiceURL NVARCHAR(1024) = 'http://shotzbeer.com' ,
    @ModifiedDate DATETIME = GETDATE();

BEGIN TRANSACTION
MERGE Purchasing.Vendor AS v
    USING 
        ( SELECT    @BusinessEntityId ,
                    @AccountNumber ,
                    @Name ,
                    @CreditRating ,
                    @PreferredVendorStatus ,
                    @ActiveFlag ,
                    @PurchasingWebServiceURL ,
                    @ModifiedDate
        ) AS vn ( BusinessEntityId, AccountNumber, Name, CreditRating,
                  PreferredVendorStatus, ActiveFlag, PurchasingWebServiceURL,
                  ModifiedDate )
    ON ( v.AccountNumber = vn.AccountNumber )
    WHEN MATCHED 
        THEN 
        UPDATE
          SET   Name = vn.Name ,
                CreditRating = vn.CreditRating ,
                PreferredVendorStatus = vn.PreferredVendorStatus ,
                ActiveFlag = vn.ActiveFlag ,
                PurchasingWebServiceURL = vn.PurchasingWebServiceURL ,
                ModifiedDate = vn.ModifiedDate
    WHEN NOT MATCHED 
        THEN
         INSERT (
                  BusinessEntityID ,
                  AccountNumber ,
                  Name ,
                  CreditRating ,
                  PreferredVendorStatus ,
                  ActiveFlag ,
                  PurchasingWebServiceURL ,
                  ModifiedDate
                    
                )
          VALUES
                ( vn.BusinessEntityId ,
                  vn.AccountNumber ,
                  vn.Name ,
                  CreditRating ,
                  vn.PreferredVendorStatus ,
                  vn.ActiveFlag ,
                  vn.PurchasingWebServiceURL ,
                  vn.ModifiedDate
                    
                );
ROLLBACK TRANSACTION

/*Listing 4.10*/
…
@AccountNumber NVARCHAR(15) = 'SPEEDCO0001',
…

/*Listing 4.11*/
SELECT  *
FROM    Sales.vIndividualCustomer
WHERE   BusinessEntityId = 8743;

/*Listing 4.12*/
SELECT  *
FROM    Person.vStateProvinceCountryRegion;

/*Listing 4.13*/
SELECT  sp.Name AS StateProvinceName ,
        cr.Name AS CountryRegionName
FROM    Person.StateProvince sp
        INNER JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode;

/*Listing 4.14*/
SELECT  a.City ,
        v.StateProvinceName ,
        v.CountryRegionName
FROM    Person.Address a
        JOIN Person.vStateProvinceCountryRegion v ON a.StateProvinceID = v.StateProvinceID
WHERE   a.AddressID = 22701;

/*Listing 4.15*/
SELECT  sod.ProductID ,
        sod.OrderQty ,
        sod.UnitPrice
FROM    Sales.SalesOrderDetail sod
WHERE   sod.ProductID = 897;

/*Listing 4.16*/
IF EXISTS ( SELECT  *
            FROM    sys.indexes
            WHERE   OBJECT_ID = OBJECT_ID(N'Sales.SalesOrderDetail')
                    AND name = N'IX_SalesOrderDetail_ProductID' ) 
    DROP INDEX IX_SalesOrderDetail_ProductID
        ON Sales.SalesOrderDetail
        WITH ( ONLINE = OFF );
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON Sales.SalesOrderDetail
(ProductID ASC)
INCLUDE ( OrderQty, UnitPrice ) WITH ( PAD_INDEX = OFF,
STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY
= OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON,
ALLOW_PAGE_LOCKS = ON )
ON [PRIMARY];
GO

SET STATISTICS XML ON;
GO

SELECT  sod.ProductID ,
        sod.OrderQty ,
        sod.UnitPrice
FROM    Sales.SalesOrderDetail sod
WHERE   sod.ProductID = 897;
GO
SET STATISTICS XML OFF;
GO

--Recreate original index
IF EXISTS ( SELECT  *
            FROM    sys.indexes
            WHERE   OBJECT_ID = OBJECT_ID(N'Sales.SalesOrderDetail')
                    AND name = N'IX_SalesOrderDetail_ProductID' ) 
    DROP INDEX IX_SalesOrderDetail_ProductID
               ON Sales.SalesOrderDetail
               WITH ( ONLINE = OFF );
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON Sales.SalesOrderDetail
(ProductID ASC)
WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 
SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF,
DROP_EXISTING = OFF,
ONLINE = OFF, ALLOW_ROW_LOCKS = ON,
ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY];
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nonclustered index.', @level0type = N'SCHEMA',
    @level0name = N'Sales', @level1type = N'TABLE',
    @level1name = N'SalesOrderDetail', @level2type = N'INDEX',
    @level2name = N'IX_SalesOrderDetail_ProductID';

/*Listing 4.17*/
DBCC SHOW_STATISTICS('Sales.SalesOrderDetail',
                     'IX_SalesOrderDetail_ProductID');

/*Listing 4.18*/
SELECT  sod.OrderQty ,
        sod.SalesOrderID ,
        sod.SalesOrderDetailID ,
        sod.LineTotal
FROM    Sales.SalesOrderDetail sod
WHERE   sod.OrderQty = 10;

/*Listing 4.19*/
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_OrderQty
ON Sales.SalesOrderDetail ( OrderQty ASC )
WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
SORT_IN_TEMPDB = OFF,IGNORE_DUP_KEY = OFF,
DROP_EXISTING = OFF, ONLINE = OFF,
ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS = ON ) 
ON [PRIMARY];

/*Listing 4.20*/
DROP INDEX Sales.SalesOrderDetail.IX_SalesOrderDetail_OrderQty;

/*Listing 4.21*/
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[NewOrders]')
                    AND type IN ( N'U' ) ) 
    DROP TABLE [NewOrders]
GO
SELECT  *
INTO    NewOrders
FROM    Sales.SalesOrderDetail
GO
CREATE INDEX IX_NewOrders_ProductID ON NewOrders ( ProductID )
GO

/*Listing 4.22*/
-- Estimated Plan
SET SHOWPLAN_XML ON
GO
SELECT  OrderQty ,
        CarrierTrackingNumber
FROM    NewOrders
WHERE   ProductID = 897
GO
SET SHOWPLAN_XML OFF
GO

BEGIN TRAN
UPDATE  NewOrders
SET     ProductID = 897
WHERE   ProductID BETWEEN 800 AND 900
GO

-- Actual Plan
SET STATISTICS XML ON
GO
SELECT  OrderQty ,
        CarrierTrackingNumber
FROM    NewOrders
WHERE   ProductID = 897

ROLLBACK TRAN
GO
SET STATISTICS XML OFF
GO
