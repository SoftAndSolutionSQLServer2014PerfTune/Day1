use master;

-- sys.dm_io_virtual_file_stats
--		Returns info about files that make up a database
select 
	  * 
from 
	sys.dm_io_virtual_file_stats(
		  db_id('AdventureWorks')			-- @DatabaseID
		, null								-- @FileID
	);


-- Join to bring in filename
select 
	  ssaf.name
	, sdivfs.* 
from 
	sys.dm_io_virtual_file_stats(
		  db_id('AdventureWorks')			-- @DatabaseID
		, null								-- @FileID
	)							as sdivfs
	join	sys.sysaltfiles		as ssaf		on sdivfs.database_id = ssaf.dbid and sdivfs.file_id = ssaf.fileid
;


-- sys.dm_os_wait_stats
--		Returns info about what the system has to wait for
--		https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-2017

--		Latches are light versions of locks used for internal memory structures
--			https://sqlperformance.com/2014/06/io-subsystem/knee-jerk-waits-pageiolatch-sh
--			PAGEIOLATCH_NL (null - not used)
--			PAGEIOLATCH_KP (keep - not used)
--			PAGEIOLATCH_SH (shared - waiting for data pages to be loaded for read, most common)
--			PAGEIOLATCH_UP (update - waiting for data pages to be loaded for update)
--			PAGEIOLATCH_EX (exclusive - waiting for data pages to be loaded for structural change)
--			PAGEIOLATCH_DT (destroy - not used)

--		logbuffer				wait for log record to be created in log buffer
--		writelog				wait for writing log buffer to t-log
--			https://www.mssqltips.com/sqlservertip/4131/troubleshooting-sql-server-transaction-log-related-wait-types/
--		io_completion			wait for non-data page I/O (dll load, tempdb write, dbcc ops)
--		async_io_completion		wait for async I/O (backup ops)
select 
	*
from 
	sys.dm_os_wait_stats
where 
		wait_type like 'pageiolatch%'
	or	wait_type in (
			  'logbuffer'
			, 'writelog'
			, 'io_completion'
			, 'async_io_completion'
		)
;