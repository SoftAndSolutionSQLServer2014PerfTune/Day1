-- Test Running Extended Events Session
--		This should not be captured due to filter on DatabaseName = AdventureWorks
use master;
select * from sys.dm_os_wait_stats;

--		This should be captured
use AdventureWorks;
select * from Production.Product;


-- View Running Extended Events Sessions
select [name], create_time 
from sys.dm_xe_sessions
;


-- Start Session
alter event session [Module 03 - SQL Query Performance Analysis] 
on server state=start
;


-- Display Event Data
select cast(t.target_data as xml)		as [Event Data]
from 
			sys.dm_xe_session_targets	as t 
	join	sys.dm_xe_sessions			as s		on s.[address] = t.event_session_address 
where s.[name] = 'Module 03 - SQL Query Performance Analysis'
;


-- Stop Session
alter event session [Module 03 - SQL Query Performance Analysis] 
on server state=stop
;
