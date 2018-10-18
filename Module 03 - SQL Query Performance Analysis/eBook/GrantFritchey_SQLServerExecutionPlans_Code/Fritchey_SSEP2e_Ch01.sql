/*Listing 1.1*/
SELECT  d.Name
FROM    HumanResources.Department AS d
WHERE   d.DepartmentID = 42

/*Listing 1.2*/
DBCC FREEPROCCACHE

/*Listing 1.3*/
GRANT SHOWPLAN TO [username];

/*Listing 1.4*/
SELECT  *
FROM    dbo.DatabaseLog;

/*Listing 1.5*/
SET SHOWPLAN_ALL ON;

/*Listing 1.6*/
SET SHOWPLAN_ALL OFF;

/*Listing 1.7*/
SET STATISTICS PROFILE ON;

/*Listing 1.8*/
SET STATISTICS PROFILE OFF;

/*Listing 1.9 */
SET STATISTICS PROFILE ON;
GO
SELECT  *
FROM    [dbo].[DatabaseLog]; 
GO
SET SHOWPLAN_ALL OFF;
GO

/*Listing 1.10 */
SET SHOWPLAN_XML ON
…
SET SHOWPLAN_XML OFF

/*Listing 1.11 */
SET STATISTICS XML ON
…
SET STATISTICS XML OFF

/*Listing 1.12*/
SET SHOWPLAN_XML ON;
GO
SELECT  *
FROM    [dbo].[DatabaseLog]; 
SET SHOWPLAN_XML OFF;
GO

/*Listing 1.18*/
SELECT  [cp].[refcounts] ,
        [cp].[usecounts] ,
        [cp].[objtype] ,
        [st].[dbid] ,
        [st].[objectid] ,
        [st].[text] ,
        [qp].[query_plan]
FROM    sys.dm_exec_cached_plans cp
        CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
        CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp;

/*Listing 1.19*/
DBCC FREEPROCCACHE(0x05000E007721DF00B8E0AF0B000000000000000000000000)

/*Listing 1.20*/
CREATE TABLE TempTable
    (
      Id INT IDENTITY(1, 1) ,
      Dsc NVARCHAR(50)
    );
INSERT  INTO TempTable
        ( Dsc 
        )
        SELECT  [Name]
        FROM    [Sales].[Store];
SELECT  *
FROM    TempTable;
DROP TABLE TempTable;

