use AdventureWorks;
go


-- Create Schema for test objects
go									-- Required, create schema must be first statement in a batch
create schema Test;
go


-- Create Heap Table
select 
	*
into 
	Test.SalesOrderHeader
from 
	Sales.SalesOrderHeader
;


-- Query to test index performance, will run this a lot
--		Suggestion: Copy this to another query window for easy 
--					execution and turn on 
--					Actual Execution Plan (Ctrl-M)
go
set statistics io on;
set statistics time on;
go

select 
	  PurchaseOrderNumber
	, OrderDate
	, ShipDate
	, SalesPersonID
from 
	Test.SalesOrderHeader
where 
		PurchaseOrderNumber like 'PO5%' 
	and SalesPersonID		is not null
;

go
set statistics io off;
set statistics time off;
go


--	Run test query in other window
--		Note: Inital data access operator is a table scan
--		Note: 781 Logical Reads 


-- Add Non-Clustered Index
create index IX_NonClustered 
on Test.SalesOrderHeader(PurchaseOrderNumber);

-- Run test query in other window
--		Note: Nothing changed with execution plan or logical reads

drop index Test.SalesOrderHeader.IX_NonClustered;


-- Add Composite Non-Clustered Index
create index IX_Composite_NonClustered
on Test.SalesOrderHeader(PurchaseOrderNumber, SalesPersonID);

-- Run test query in other window
--		Note: Using Non-Clustered Index now with RID Lookup
--		Note: 255 Logical Reads, Nice Improvement!


-- Add Clustered Index
create clustered index IX_Clustered
on Test.SalesOrderHeader(SalesOrderID);

-- Run test query in other window
--		Note: Using Non-Clustered Index now with Key Lookup
--		Note: 778 Logical Reads 
--		Note: What happened?  
--			For each Key Lookup not only have to read single 
--			data page, but also branch pages

drop index Test.SalesOrderHeader.IX_Clustered;


-- Add Unique Clustered Index
create unique clustered index IX_Unique_Clustered
on Test.SalesOrderHeader(SalesOrderID);

-- Run test query in other window
--		Note: Still 778 Logical Reads, no change

drop index Test.SalesOrderHeader.IX_Unique_Clustered;


-- Add PK Constraint which by default adds Clustered Index
exec sp_helpindex 'Test.SalesOrderHeader';

alter table Test.SalesOrderHeader
add constraint PK_SalesOrderHeader_SalesOrderID 
	primary key (SalesOrderID);

exec sp_helpindex 'Test.SalesOrderHeader';

-- Run test query in other window
--		Note: Still 778 Logical Reads, no change

-- Drop Non-Clustered Index from beginning
drop index Test.SalesOrderHeader.IX_Composite_NonClustered;


-- Covering Index
create index IX_Covering_NonClustered
on Test.SalesOrderHeader(PurchaseOrderNumber, SalesPersonID)
include (OrderDate, ShipDate);

-- Run test query in other window
--		Note: 5 Logical Reads, Getting Better
--		Note: Execution plan only using this NonClustered Index

-- Drop Covering Non-Clustered Index
drop index Test.SalesOrderHeader.IX_Covering_NonClustered;


-- Index Intersection
create index IX_NonClustered1 
on Test.SalesOrderHeader(PurchaseOrderNumber);
create index IX_NonClustered2 
on Test.SalesOrderHeader(SalesPersonID);

-- Run test query in other window
--		Note: The use of the 2 Non-Clustered indexes to get the data

drop index Test.SalesOrderHeader.IX_NonClustered1;
drop index Test.SalesOrderHeader.IX_NonClustered2;



-- Filtered Index
create index IX_Filtered_Covering_NonClustered
on Test.SalesOrderHeader(PurchaseOrderNumber, SalesPersonID)
include (OrderDate, ShipDate)
where PurchaseOrderNumber is not null and SalesPersonID is not null;

-- Run test query in other window
--		Note: 4 Logical Reads, Boom!


-- Cleanup 
drop table Test.SalesOrderHeader;
drop schema Test;