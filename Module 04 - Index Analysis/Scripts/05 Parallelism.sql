use AdventureWorks;
go

-- Parallel Query, note subtree cost on SELECT node
select ProductID, COUNT(*)
from Sales.SalesOrderDetailEnlarged
group by ProductID;


-- Disable Parallelism
exec sp_configure 'show advanced options', 1;  
reconfigure with override  
exec sp_configure 'max degree of parallelism', 1;  
reconfigure with override  
go

-- Retest query, note new overall cost
--		Note: With SS2012+ There is a NonParallelPlanReason property on the SELECT node
select ProductID, COUNT(*)
from Sales.SalesOrderDetailEnlarged
group by ProductID;


-- Reenable Parallelism
exec sp_configure 'max degree of parallelism', 0;  
reconfigure with override  
exec sp_configure 'show advanced options', 0;  
reconfigure with override  
go