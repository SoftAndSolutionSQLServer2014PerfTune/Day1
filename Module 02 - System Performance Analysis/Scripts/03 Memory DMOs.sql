use master;

-- Simple DMO Memory Counters
select *
from 
	sys.dm_os_performance_counters
where 
	counter_name in (
		  'Memory Grants Pending'
		, 'Page life expectancy'
		, 'Target Server Memory (KB)'
		, 'Total Server Memory (KB)'
	)
;


-- Calculate Buffer Cache Hit Ratio
--		Buffer cache hit ratio / Buffer cache hit ratio base * 100
declare @BufferCacheHitRatio bigint;

select @BufferCacheHitRatio = cntr_value 
from sys.dm_os_performance_counters
where counter_name = 'Buffer cache hit ratio';

select @BufferCacheHitRatio / cntr_value * 100 as [Buffer Cache Hit Ratio]
from sys.dm_os_performance_counters
where counter_name = 'Buffer cache hit ratio base';


-- Checkpoints and Lazy Writes Per Second
--		Need to take samples over time
declare @CheckpointPagesSec	bigint, @LazyWritesSec bigint;

select @CheckpointPagesSec = cntr_value 
from sys.dm_os_performance_counters
where counter_name = 'Checkpoint pages/sec';

select @LazyWritesSec = cntr_value 
from sys.dm_os_performance_counters
where counter_name = 'Lazy writes/sec';
 
waitfor delay '00:00:10';
 
select (cntr_value - @CheckpointPagesSec) / 10 as [Checkpoint Pages/Sec]
from sys.dm_os_performance_counters
where counter_name = 'Checkpoint pages/sec';

select (cntr_value - @LazyWritesSec) / 10 as [Lazy Writes/Sec]
from sys.dm_os_performance_counters
where counter_name = 'Lazy writes/sec';
