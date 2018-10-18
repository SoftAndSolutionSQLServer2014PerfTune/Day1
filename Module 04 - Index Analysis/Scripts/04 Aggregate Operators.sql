use AdventureWorks;
go

-- Stream Aggregate (Aggregate)
--		Note: Click on Compute Scalar and Stream Aggregate Operators 
--			  and view Defined Values in the Properties Window
select avg(ListPrice) 
from Production.Product;

-- Stream Aggregate (Aggregate)
--		Note: Sort now required since Stream Aggregate requires 
--			  sorting by group
select ProductLine, avg(ListPrice) 
from Production.Product 
group by ProductLine;

-- Stream Aggregate (Aggregate)
--		Note: Data is Pre-Sorted (SalesOrderID is a PK)
select SalesOrderID, avg(OrderQty) 
from Sales.SalesOrderDetail 
group by SalesOrderID;


-- Hash Match (Aggregate)
--		Note:  Even in group by, TerritoryID is not sorted
select TerritoryID, count(*) 
from Sales.SalesOrderHeader 
group by TerritoryID;

-- Hash Match (Aggregate)
--		Note: Sort because of order by clause
select TerritoryID, count(*) 
from Sales.SalesOrderHeader 
group by TerritoryID 
order by TerritoryID;


-- Stream Aggregate vs Hash Aggregate forced with query hint
--		Note: Compare both Execution Plans to one another
select ProductLine, avg(ListPrice) 
from Production.Product 
group by ProductLine;

select ProductLine, avg(ListPrice) 
from Production.Product 
group by ProductLine
option (hash group);


-- Hash Aggregate vs Stream Aggregate forced with query hint
--		Note: Compare both Execution Plans to one another
select TerritoryID, count(*) 
from Sales.SalesOrderHeader 
group by TerritoryID;

select TerritoryID, count(*) 
from Sales.SalesOrderHeader 
group by TerritoryID
option(order group);


-- Distinct Sort
--		Note: Indentical Execution Plans
select distinct(JobTitle) 
from HumanResources.Employee;

select JobTitle 
from HumanResources.Employee 
group by JobTitle;


-- Stream Aggregate used because of Non-Clustered index
--		Note: View Stream Aggregate Group By Property
create index IX_JobTitle on HumanResources.Employee(JobTitle);

select distinct(JobTitle) 
from HumanResources.Employee;

drop index HumanResources.Employee.IX_JobTitle;


-- Hash Aggregate may be used for bigger tables
select distinct(TerritoryID) 
from Sales.SalesOrderHeader;
