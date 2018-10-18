use master;

-- CPU Performance Counters
--		Rate - so need to do a sample                                                                                                                                                                                                                
declare @SQLCompilationsSec	bigint, @SQLRecompilationsSec bigint;

select @SQLCompilationsSec = cntr_value 
from sys.dm_os_performance_counters
where counter_name = 'SQL Compilations/sec';

select @SQLRecompilationsSec = cntr_value 
from sys.dm_os_performance_counters
where counter_name = 'SQL Re-Compilations/sec';
 
waitfor delay '00:00:10';
 
select (cntr_value - @SQLCompilationsSec) / 10 as [SQL Compilations/sec]
from sys.dm_os_performance_counters
where counter_name = 'SQL Compilations/sec';

select (cntr_value - @SQLRecompilationsSec) / 10 as [SQL Re-Compilations/sec]
from sys.dm_os_performance_counters
where counter_name = 'SQL Re-Compilations/sec';


-- sys.dm_os_workers
--		Indication of processor load, need to compare against baseline
--		https://www.red-gate.com/simple-talk/sql/database-administration/why-is-that-sql-server-instance-under-stress/
--		More complex query found here
--			https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-workers-transact-sql?view=sql-server-2017
select 
	  count(*)		as [Running Worker Threads]
from 
	sys.dm_os_workers
where 
	state = 'running'
;

-- sys.dm_os_schedulers
--		Indication of processor load, need to compare against baseline
--		https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-schedulers-transact-sql?view=sql-server-2017
select 
	  count(*)		as [Active Schedulers]
from 
	sys.dm_os_schedulers
where 
	is_idle = 0
;


-- sys.dm_os_wait_stats
--		Returns info about what the system has to wait for
--		https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-2017
--		sos_scheduler_yield		Can indicate CPU stress
select 
	*
from 
	sys.dm_os_wait_stats
where 
	wait_type in ('sos_scheduler_yield')
;


-- More interesting query
--		Wait time for CPU vs Other Resources
--		signal_wait_time_ms		Time waiting for CPU
--		wait_time_ms			Overall Wait Time
--		% Signal (CPU) Wait		System running well should be around 20%
select 
	  100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms)					as [% Signal (CPU) Waits]
	, 100.0 * sum(wait_time_ms - signal_wait_time_ms) / sum (wait_time_ms)	as [% Resource Waits] 
from 
	sys.dm_os_wait_stats
;