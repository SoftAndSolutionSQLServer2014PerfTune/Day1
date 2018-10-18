use master;

exec sp_configure 'show advanced options', 1;
reconfigure;

exec sp_configure 'min server memory';
exec sp_configure 'max server memory';

exec sp_configure 'min server memory', 0;
exec sp_configure 'max server memory', 2147483647;
reconfigure with override;

exec sp_configure 'show advanced options', 0;
reconfigure;

