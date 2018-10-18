use AdventureWorks;
go

-- Enable Time and IO Statistics
set statistics time on;
set statistics io on;
go

-- Clear Buffer and Procedure Caches
checkpoint;
go
dbcc dropcleanbuffers;
dbcc freeproccache;
go

-- Add Queries Here


-- Disable Time and IO Statistics
set statistics time off;
set statistics io off;
go