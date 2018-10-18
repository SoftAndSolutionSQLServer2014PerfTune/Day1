use AdventureWorks;
go

-- Turn on Performance Stats
set statistics io on;
set statistics time on;
go

-- How many rows in each table
select count(*) from HumanResources.Employee;		-- 290 rows
select count(*) from Sales.SalesPerson;				--  17 rows


-- Nested Loop Join - Good when both inputs are small
--		Note: Top Input (Clustered Index Scan) is Outer Input and 
--			  Bottom Input (Clustered Index Seek) is Inner Input
--		Property Window:
--		      Number Of Executions: Outer Input fired once, 
--									Inner Input fired 17 times
--			  Outer References: On Nested Loops Operator
select e.BusinessEntityID, TerritoryID
from 
		 HumanResources.Employee	as e
	join 
		 Sales.SalesPerson			as sp	
		 on e.BusinessEntityID = sp.BusinessEntityID
;


-- Nested Loop Join - Reverse Table Order
--		Note: No Difference due to Heuristic Join Reordering Step
--			  Not always true
select e.BusinessEntityID, TerritoryID
from 
		 Sales.SalesPerson			as sp	
	join 
		 HumanResources.Employee	as e
		 on e.BusinessEntityID = sp.BusinessEntityID
;


-- Nested Loop Join with filter
--		Note: Predicates and Number of Executions
select e.BusinessEntityID, TerritoryID
from 
		 Sales.SalesPerson			as sp	
	join 
		 HumanResources.Employee	as e
		 on e.BusinessEntityID = sp.BusinessEntityID
where TerritoryID = 1
;


-- Merge Join - Requires both inputs be sorted on the join columns
--		Note: Good performance when both inputs are pre-sorted
--			  by indexes, like a PK / indexed FK scenario
select soh.SalesOrderID, sod.SalesOrderDetailID, OrderDate
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;


-- Hash Join - Good for large, unsorted, non-indexed inputs
select soh.SalesOrderID, sod.SalesOrderDetailID
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;


-- Force Different Join Operators
-- Force Nested Loops to Merge Join
select e.BusinessEntityID, TerritoryID
from 
		 Sales.SalesPerson			as sp	
	join 
		 HumanResources.Employee	as e
		 on e.BusinessEntityID = sp.BusinessEntityID
;
select e.BusinessEntityID, TerritoryID
from 
		 Sales.SalesPerson			as sp	
	join 
		 HumanResources.Employee	as e
		 on e.BusinessEntityID = sp.BusinessEntityID
option (merge join)
;


-- Force Merge Join to Hash Join
select soh.SalesOrderID, sod.SalesOrderDetailID, OrderDate
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;
select soh.SalesOrderID, sod.SalesOrderDetailID, OrderDate
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
option (hash join)
;

-- Force Hash Join to Nested Loops
select soh.SalesOrderID, sod.SalesOrderDetailID
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;
select soh.SalesOrderID, sod.SalesOrderDetailID
from 
		 Sales.SalesOrderHeader		as soh
	join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
option (loop join)
;


-- Outer Joins (Try each with right, left, and full outer join)
select e.BusinessEntityID, TerritoryID
from 
		 HumanResources.Employee	as e
	left outer join 
		 Sales.SalesPerson			as sp	
		 on e.BusinessEntityID = sp.BusinessEntityID
;

select soh.SalesOrderID, sod.SalesOrderDetailID, OrderDate
from 
		 Sales.SalesOrderHeader		as soh
	left outer join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;

select soh.SalesOrderID, sod.SalesOrderDetailID
from 
		 Sales.SalesOrderHeader		as soh
	left outer join 
		 Sales.SalesOrderDetail		as sod		
		 on soh.SalesOrderID = sod.SalesOrderID
;
