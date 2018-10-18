/*Listing 3.1*/
SELECT  e.BusinessEntityID ,
        e.JobTitle ,
        e.LoginID
FROM    HumanResources.Employee AS e
WHERE   e.LoginID = 'adventure-works\marc0';

/*Listing 3.2*/
SET SHOWPLAN_ALL ON;
GO
SELECT  e.BusinessEntityID ,
        e.JobTitle ,
        e.LoginID
FROM    HumanResources.Employee AS e
WHERE   e.LoginID = 'adventure-works\marc0';
GO
SET SHOWPLAN_ALL OFF;

/*Listing 3.6*/
SET SHOWPLAN_ALL ON;
GO

SELECT  c.CustomerID ,
        a.City ,
        s.Name ,
        st.Name
FROM    Sales.Customer AS c
        JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
        JOIN Sales.SalesTerritory AS st ON c.TerritoryId = st.TerritoryID
        JOIN Person.BusinessEntityAddress AS bea ON c.CustomerID = bea.BusinessEntityID
        JOIN Person.Address AS a ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';
GO

SET SHOWPLAN_ALL OFF;
GO

/*Listing 3.9*/
SET SHOWPLAN_XML ON;
GO
SELECT  c.CustomerID ,
        a.City ,
        s.Name ,
        st.Name
FROM    Sales.Customer AS c
        JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
        JOIN Sales.SalesTerritory AS st ON c.TerritoryId = st.TerritoryID
        JOIN Person.BusinessEntityAddress AS bea ON c.CustomerID = bea.BusinessEntityID
        JOIN Person.Address AS a ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';
GO
SET SHOWPLAN_XML OFF;
GO

/*Listing 3.16*/
SET STATISTICS XML ON;
GO
SELECT  c.CustomerID ,
        a.City ,
        s.Name ,
        st.Name
FROM    Sales.Customer AS c
        JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
        JOIN Sales.SalesTerritory AS st ON c.TerritoryId = st.TerritoryID
        JOIN Person.BusinessEntityAddress AS bea ON c.CustomerID = bea.BusinessEntityID
        JOIN Person.Address AS a ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';
GO
SET STATISTICS XML OFF;
GO

/*Listing 3.19*/
SELECT TOP 3
        RelOp.op.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; 
           @PhysicalOp', 'varchar(50)') AS PhysicalOp ,
        dest.text ,
        deqs.execution_count ,
        RelOp.op.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
        @EstimatedTotalSubtreeCost', 'float') AS EstimatedCost
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
        CROSS APPLY deqp.query_plan.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
    //RelOp') RelOp ( op )
ORDER BY deqs.execution_count DESC

