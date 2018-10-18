-- Create Some Execution Plans
use AdventureWorks;
go
select * from Production.Product;
go
select * from Sales.SalesOrderHeader;
go


use master;
go

-- Display All Cached Plans
select 
	* 
from 
	sys.dm_exec_query_stats
;


-- Display Cached Plans with SQL Text
select * 
from 
					sys.dm_exec_query_stats
	cross apply		sys.dm_exec_sql_text(plan_handle)
;


-- Display Cached Plans with their their Execution Plans
select 
	* 
from 
					sys.dm_exec_query_stats
	cross apply		sys.dm_exec_query_plan(plan_handle)
;


-- Just Display Execution Plans and SQL Text
select 
	  [text]												as [Statement Text]
	, query_plan											as [Execution Plan]
from 
					sys.dm_exec_query_stats
	cross apply		sys.dm_exec_query_plan(plan_handle)
	cross apply		sys.dm_exec_sql_text(plan_handle)
;


-- Display SQL Text and Execution Plans for Top 10 Most Expensive Queries by CPU
select top 10 
	  total_worker_time / execution_count					as [Avg CPU Time]
	, [text]												as [Statement Text]
	, query_plan 											as [Execution Plan]
from 
					sys.dm_exec_query_stats
	cross apply		sys.dm_exec_query_plan(plan_handle)
	cross apply		sys.dm_exec_sql_text(plan_handle)
order by 
	[Avg CPU Time]	desc
;


-- Display SQL Text and Execution Plans for a specific Object
exec AdventureWorks.dbo.uspGetEmployeeManagers 9;
go
select 
	  qp.objectid											as [Object ID]
	, st.[text]												as [Statement Text]
	, qp.query_plan 										as [Execution Plan]
from 
					sys.dm_exec_query_stats					as qs
	cross apply		sys.dm_exec_query_plan(plan_handle)		as qp
	cross apply		sys.dm_exec_sql_text(sql_handle)		as st
where
	qp.objectid = object_id('AdventureWorks.dbo.uspGetEmployeeManagers')
;


-- Display SQL Text and Execution Plans for Top 10 Most Expensive Queries by Duration
select top 10
	  qs.total_elapsed_time										as [Total Time]
	, st.text													as [Statement Text]
	, db_name(qp.dbid)											as [Database Name]
    , qp.query_plan												as [Execution Plan]
	, qs.*
from
					sys.dm_exec_query_stats						as qs			-- Reverse comments to
					--sys.dm_exec_procedure_stats					as qs			-- View Stored Procs
	cross apply		sys.dm_exec_sql_text(qs.sql_handle)			as st 
	cross apply		sys.dm_exec_query_plan(qs.plan_handle)		as qp
where 
	db_name(qp.dbid) = 'AdventureWorks'
order by 
     qs.total_elapsed_time desc
;
