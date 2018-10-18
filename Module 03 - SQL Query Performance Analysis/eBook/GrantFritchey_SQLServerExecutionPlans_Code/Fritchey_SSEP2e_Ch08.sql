/*Listing 8.1*/
DROP PROCEDURE Sales.uspGetDiscountRates; 
GO 
CREATE PROCEDURE Sales.uspGetDiscountRates
    (
      @BusinessEntityId INT ,
      @SpecialOfferId INT 
    )
AS 
    BEGIN TRY 
  -- determine if sale using special offer exists 
        IF EXISTS ( SELECT  *
                    FROM    Person.Person AS p
                            INNER JOIN Sales.Customer AS c ON p.BusinessEntityID = c.PersonID
                            INNER JOIN Sales.SalesOrderHeader AS soh ON soh.CustomerID = c.CustomerID
                            INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
                            INNER JOIN Sales.SpecialOffer AS spo ON sod.SpecialOfferID = spo.SpecialOfferID
                    WHERE   p.BusinessEntityID = @BusinessEntityId
                            AND spo.[SpecialOfferID] = @SpecialOfferId ) 
            BEGIN 
                SELECT  p.LastName + ', ' + p.FirstName ,
                        ea.EmailAddress ,
                        p.Demographics ,
                        spo.Description ,
                        spo.DiscountPct ,
                        sod.LineTotal ,
                        pr.Name ,
                        pr.ListPrice ,
                        sod.UnitPriceDiscount
                FROM    Person.Person AS p
                        INNER JOIN Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID
                        INNER JOIN Sales.Customer AS c ON p.BusinessEntityID = c.PersonID
                        INNER JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
                        INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
                        INNER JOIN Sales.SpecialOffer AS spo ON sod.SpecialOfferID = spo.SpecialOfferID
                        INNER JOIN Production.Product pr ON sod.ProductID = pr.ProductID
                WHERE   p.BusinessEntityID = @BusinessEntityId
                        AND sod.[SpecialOfferID] = @SpecialOfferId;
            END 
-- use different query to return other data set
        ELSE 
            BEGIN 
                SELECT  p.LastName + ', ' + p.FirstName ,
                        ea.EmailAddress ,
                        p.Demographics ,
                        soh.SalesOrderNumber ,
                        sod.LineTotal ,
                        pr.Name ,
                        pr.ListPrice ,
                        sod.UnitPrice ,
                        st.Name AS StoreName ,
                        ec.LastName + ', ' + ec.FirstName AS SalesPersonName
                FROM    Person.Person AS p
                        INNER JOIN Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID
                        INNER JOIN Sales.Customer AS c ON p.BusinessEntityID = c.PersonID
                        INNER JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
                        INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
                        INNER JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID
                        LEFT JOIN Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
                        LEFT JOIN Sales.Store AS st ON sp.BusinessEntityID = st.SalesPersonID
                        LEFT JOIN HumanResources.Employee AS e ON st.BusinessEntityID = e.BusinessEntityID
                        LEFT JOIN Person.Person AS ec ON e.BusinessEntityID = ec.BusinessEntityID
                WHERE   p.BusinessEntityID = @BusinessEntityId; 
            END
             
 --second result SET 
        IF @SpecialOfferId = 16 
            BEGIN 
                SELECT  p.Name ,
                        p.ProductLine
                FROM    Sales.SpecialOfferProduct sop
                        INNER JOIN Production.Product p ON sop.ProductID = p.ProductID
                WHERE   sop.SpecialOfferID = 16; 
            END      
             
    END TRY 
    BEGIN CATCH 
        SELECT  ERROR_NUMBER() AS ErrorNumber ,
                ERROR_MESSAGE() AS ErrorMessage; 
        RETURN ERROR_NUMBER(); 
    END CATCH 
    RETURN 0; 

/*Listing 8.2*/
    EXEC [Sales].[uspGetDiscountRates] @BusinessEntityId = 1423, -- int
        @SpecialOfferId = 16 -- int

/*Listing 8.3*/
WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
QueryPlans
 AS
(
SELECT RelOp.pln.value(N'@PhysicalOp', N'varchar(50)') AS OperatorName,
RelOp.pln.value(N'@NodeId',N'varchar(50)') AS NodeId,
RelOp.pln.value(N'@EstimateCPU', N'varchar(50)') AS CPUCost,
RelOp.pln.value(N'@EstimateIO', N'varchar(50)') AS IOCost,
dest.text
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY deqp.query_plan.nodes(N'//RelOp') RelOp (pln)
)

SELECT  qp.OperatorName,
        qp.NodeId,
        qp.CPUCost,
        qp.IOCost,
        qp.CPUCost + qp.IOCost AS EstimatedCost
FROM    QueryPlans AS qp
WHERE   qp.text LIKE 'CREATE PROCEDURE Sales.uspGetDiscountRates%'
ORDER BY EstimatedCost DESC

/*Listing 8.4*/
sp_configure 'show advanced options', 1; 
GO 
RECONFIGURE WITH OVERRIDE; 
GO 
sp_configure 'max degree of parallelism', 3; 
GO 
RECONFIGURE WITH OVERRIDE; 
GO

/*Listing 8.5*/
SELECT  so.ProductID ,
        COUNT(*) AS Order_Count
FROM    Sales.SalesOrderDetail so
WHERE   so.ModifiedDate >= '2003/02/01'
        AND so.ModifiedDate < DATEADD(mm, 3, '2003/02/01')
GROUP BY so.ProductID
ORDER BY so.ProductID

/*Listing 8.6*/
EXEC sp_configure 'cost threshold for parallelism', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
SELECT  so.ProductID ,
        COUNT(*) AS Order_Count
FROM    Sales.SalesOrderDetail so
WHERE   so.ModifiedDate >= '2003/02/01'
        AND so.ModifiedDate < DATEADD(mm, 3, '2003/02/01')
GROUP BY so.ProductID
ORDER BY so.ProductID
GO
EXEC sp_configure 'cost threshold for parallelism', 5;
GO

/*Listing 8.7*/
sp_configure 'cost threshold for parallelism', 5;
GO
RECONFIGURE WITH OVERRIDE;
GO

/*Listing 8.8*/
DELETE  FROM Person.EmailAddress
WHERE   BusinessEntityID = 42;

/*Listing 8.9*/
SELECT  42 AS TheAnswer ,
        em.EmailAddress ,
        e.BirthDate ,
        a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE 'david%'
        AND sp.StateProvinceCode = 'WA';

/*Listing 8.10*/
ALTER DATABASE AdventureWorks2008R2
SET PARAMETERIZATION FORCED
GO
DBCC freeproccache
GO

/*Listing 8.11*/
SELECT  42 AS TheAnswer ,
        em.EmailAddress ,
        e.BirthDate ,
        a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE 'david%'
        AND sp.StateProvinceCode = @0

/*Listing 8.12*/
ALTER DATABASE AdventureWorks2008R2
SET PARAMETERIZATION SIMPLE
GO

/*Listing 8.13*/
EXEC sp_create_plan_guide @name = N'MyFirstPlanGuide',
    @stmt = N'WITH [EMP_cte]([BusinessEntityID], [OrganizationNode],
                              [FirstName], [LastName], [RecursionLevel])
                              -- CTE name and columns
AS (
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], 0 -- Get initial list of Employees for Manager n
FROM [HumanResources].[Employee] e 
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
WHERE e.[BusinessEntityID] = @BusinessEntityID
UNION ALL
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], [RecursionLevel] + 1
-- Join recursive member to anchor
FROM [HumanResources].[Employee] e 
     INNER JOIN [EMP_cte]
            ON e.[OrganizationNode].GetAncestor(1) =
                  [EMP_cte].[OrganizationNode]
    INNER JOIN [Person].[Person] p 
           ON p.[BusinessEntityID] = e.[BusinessEntityID]
)
SELECT [EMP_cte].[RecursionLevel],
       [EMP_cte].[OrganizationNode].ToString() as [OrganizationNode],
       p.[FirstName] AS ''ManagerFirstName'',
       p.[LastName] AS ''ManagerLastName'',
       [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName],
       [EMP_cte].[LastName] -- Outer select from the CTE
FROM [EMP_cte] 
     INNER JOIN [HumanResources].[Employee] e 
             ON [EMP_cte].[OrganizationNode].GetAncestor(1) = 
                  e.[OrganizationNode]
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
OPTION (MAXRECURSION 25) ', @type = N'OBJECT',
    @module_or_batch = N'dbo.uspGetManagerEmployees', @params = NULL,
    @hints = N'OPTION(RECOMPILE,MAXRECURSION 25)'

/*Listing 8.14*/
EXEC dbo.uspGetManagerEmployees @BusinessEntityID = 42 -- int

/*Listing 8.15*/
SELECT  *
FROM    Person.Address
WHERE   City = 'LONDON';

/*Listing 8.16*/
EXEC sp_create_plan_guide @name = N'MySecondPlanGuide',
    @stmt = N'SELECT * FROM Person.Address WHERE City
            = @0', @type = N'SQL', @module_or_batch = NULL,
    @params = N'@0 VARCHAR(8000)',
    @hints = N'OPTION(OPTIMIZE FOR (@0 = ''Mentor''))'

/*Listing 8.17*/
EXEC sp_create_plan_guide @name = N'MyThirdPlanGuide',
    @stmt = N'SELECT  42 AS TheAnswer
       ,em.EmailAddress
       ,e.BirthDate
       ,a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e
            ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea
            ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a
            ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em
        ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE ''david%''
        AND sp.StateProvinceCode = ''WA'' ;', @type = N'TEMPLATE',
    @module_or_batch = NULL, @params = N'@0 VARCHAR(8000)',
    @hints = N'OPTION(PARAMETERIZATION FORCED)'

/*Listing 8.18*/
SELECT  *
FROM    sys.plan_guides

/*Listing 8.19*/
EXEC sp_control_plan_guide @operation = N'DROP', @name = N'MyFourthPlanGuide'

/*Listing 8.20*/
ALTER PROCEDURE Sales.uspGetCreditInfo ( @SalesPersonID INT )
AS 
    SELECT  soh.AccountNumber ,
            soh.CreditCardApprovalCode ,
            soh.CreditCardID ,
            soh.OnlineOrderFlag
    FROM    Sales.SalesOrderHeader AS soh
    WHERE   soh.SalesPersonID = @SalesPersonId;

/*Listing 8.21*/
    SET STATISTICS XML ON
GO
SELECT  soh.AccountNumber ,
        soh.CreditCardApprovalCode ,
        soh.CreditCardID ,
        soh.OnlineOrderFlag
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesPersonID = 288;
GO
SET STATISTICS XML OFF
GO

/*Listing 8.22*/
EXEC sp_create_plan_guide @name = N'UsePlanPlanGuide',
    @stmt = N'SELECT  soh.AccountNumber
       ,soh.CreditCardApprovalCode
       ,soh.CreditCardID
       ,soh.OnlineOrderFlag]
FROM    Sales.SalesOrderHeader soh 
WHERE   soh.SalesPersonID = @SalesPersonID --288 --277', @type = N'OBJECT',
    @module_or_batch = N'Sales.uspGetCreditInfo', @params = NULL,
    @hints = N'OPTION(USE PLAN N''<ShowPlanXML>'

/*Listing 8.23*/
EXEC [Sales].uspGetCreditInfo @SalesPersonID = 277

