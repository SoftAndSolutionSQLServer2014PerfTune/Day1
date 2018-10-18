use master;

-- DMOs
-- http://technet.microsoft.com/en-us/library/ms188754(v=sql.105).aspx

-- System Logins DMV Example
-- https://blogs.msdn.microsoft.com/psssql/2013/09/23/interpreting-the-counter-values-from-sys-dm_os_performance_counters/
-- https://docs.microsoft.com/en-us/windows/desktop/WmiSdk/base-counter-types
select 
	  object_name		as [ObjectName]
	, counter_name		as [CounterName]
	, cntr_value		as [CounterValue]
	, cntr_type			as [CounterType]
from 
	sys.dm_os_performance_counters
where 
	counter_name = 'Total Server Memory (KB)'
;

-- With case statement to interpret cntr_type value
--		Beware:  Average, Rate, and Ratio will need to be calculated manually
select 
	  object_name		as [ObjectName]
	, counter_name		as [CounterName]
	, cntr_value		as [CounterValue]
	, cntr_type			as [CounterType]
	, case cntr_type
			when 1073939712 then 'PERF_LARGE_RAW_BASE (Value)'
			when 537003264  then 'PERF_LARGE_RAW_FRACTION (Ratio)'
			when 1073874176 then 'PERF_AVERAGE_BULK (Average)'
			when 272696576  then 'PERF_COUNTER_BULK_COUNT (Rate)'
			when 65792		then 'PERF_COUNTER_LARGE_RAWCOUNT (Last Observed)'
			else 'Other'
	  end				as [CounterTypeName]
from 
	sys.dm_os_performance_counters
where 
	counter_name = 'Total Server Memory (KB)'
;


-- Longest Wait Times DMV
-- https://blogs.msdn.microsoft.com/psssql/2009/11/02/the-sql-server-wait-type-repository/
-- wait_type that could indicate IO contention
--    ASYNC_IO_COMPLETION, IO_COMPLETION, LOGMGR, WRITELOG, PAGEIOLATCH
select top (10) 
	*
from 
	sys.dm_os_wait_stats 
order by 
	wait_time_ms desc
;


-- Database Page Allocation DMF
select 
	* 
from 
	sys.dm_db_database_page_allocations(
		  db_id()								-- @DatabaseID
		, object_id('Production.Product')		-- @TableID
		, null									-- @IndexID
		, null									-- @PartitionID
		,'detailed'								-- @Mode (detailed or limited)
	)
;