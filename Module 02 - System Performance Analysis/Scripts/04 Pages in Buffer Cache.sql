use AdventureWorks;
go

-- Query to see more pages in cache
select * from Sales.SalesOrderDetail;


-- Used to clear buffer cache to see difference
checkpoint
go
dbcc dropcleanbuffers
go


use master;
go

-- Count of pages in the buffer cache
--		Uncomment last predicate to see dirty pages only
select 
	count(*)									as [Pages in Cache]
from 
				sys.dm_os_buffer_descriptors	as bd
where 
		bd.database_id = db_id() 
	--and bd.is_modified=1
;


-- See details about pages in buffer cache
--		Uncomment last predicate to see dirty pages only
select 
	  db.name									as [Database Name]
	, o.name									as [Object Name]
	, o.type_desc								as [Object Type]
	, bd.*
from 
				sys.dm_os_buffer_descriptors	as bd
	join		sys.databases					as db		on db.database_id = bd.database_id
	left join	sys.partitions					as p		on p.partition_id = allocation_unit_id
	left join	sys.all_objects					as o		on o.object_id = p.object_id
where 
		bd.database_id = DB_ID() 
	--and bd.is_modified=1
;


-- Query to View Dirty and Clean Pages by Database
-- http://www.sqlskills.com/blogs/paul/when-dbcc-dropcleanbuffers-doesnt-work/
select 
	  DatabaseName								as [Database Name]
	, DirtyPageCount							as [Dirty Page Count]
	, CleanPageCount							as [Clean Page Count]
    , DirtyPageCount * 8 / 1024					as [Dirty Page MB]
    , CleanPageCount * 8 / 1024					as [Clean Page MB]
from
    (
		select 
			  iif(database_id = 32767, 
				'Resource Database'
				, db_name(database_id)
			  )									as DatabaseName
			, sum (iif(is_modified=1, 1, 0))	as DirtyPageCount
			, sum (iif(is_modified=1, 0, 1))	as CleanPageCount
		from 
			sys.dm_os_buffer_descriptors
		group by 
			database_id
	)											as Buffers
order by 
	DatabaseName
;
go
