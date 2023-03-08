USE [master]
--RESTORE DATABASE [AdventureWorks2014] 
--	FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Backup\AdventureWorks2014.bak' 
--	WITH  FILE = 1,  NOUNLOAD,  STATS = 5;
--GO
USE [master]
RESTORE DATABASE [AdventureWorks2014] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Backup\AdventureWorks2014.bak' 
	WITH  FILE = 1,  
	MOVE N'AdventureWorks2014_Data' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\AdventureWorks2014_Data.mdf',  
	MOVE N'AdventureWorks2014_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\AdventureWorks2014_Log.ldf',  
	NOUNLOAD,  STATS = 5;
GO


