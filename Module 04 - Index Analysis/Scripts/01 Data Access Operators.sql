use AdventureWorks;
go

-- Turn on Performance Stats
set statistics io on;
set statistics time on;
go

-- Table Scan
select * from DatabaseLog;


-- Clustered Index Scan
select * from Person.Address;


-- Index Scan 
--		Index = [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
--		Note:	AddressID is not in index column list, but is
--				included since non-clustered index uses either
--				PK column or RowID to refer back to base table
select AddressID, City, StateProvinceID from Person.Address;

exec sp_helpindex 'Person.Address';


-- Clustered Index Seek
--		Does not use non-clustered index since it is not sorted by
--		the PK AddressID
select AddressID, StateProvinceID 
from Person.Address 
where AddressID = 12037;


-- Index Seek (1 row returned)
--		Index = [AdventureWorks].[Person].[Address].[IX_Address_StateProvinceID]
--		Covering index because AddressID is the PK 
select AddressID, StateProvinceID 
from Person.Address 
where StateProvinceID = 32;


-- Index Seek 
--		Many rows returned, same execution plan as previous
--		Still a covering index
select AddressID, StateProvinceID 
from Person.Address 
where StateProvinceID = 9;


-- Key Lookup (Bookmark Lookup to clustered index table)
select * 
from Person.Address 
where StateProvinceID = 32;


-- Clustered Index Scan
--		So many rows returned, better to scan than bookmark lookup
select * 
from Person.Address 
where StateProvinceID = 9;


-- RID Lookup (Bookmark Lookup to heap table)
go
create index IX_Object on DatabaseLog(Object);
go

select * from DatabaseLog where Object = 'City';

go
drop index DatabaseLog.IX_Object;
go
