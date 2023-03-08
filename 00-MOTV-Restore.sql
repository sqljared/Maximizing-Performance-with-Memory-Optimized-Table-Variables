USE [master]
GO
RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Backup\WWI-Larger.bak' 
	WITH  FILE = 1,  NOUNLOAD,  STATS = 5;
GO
USE [master]
RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1,  
	MOVE N'WWI_Primary' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\WideWorldImporters.mdf',  
	MOVE N'WWI_UserData' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\WideWorldImporters_UserData.ndf',  
	MOVE N'WWI_Log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\WideWorldImporters.ldf',  
	MOVE N'WWI_InMemory_Data_1' TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\WideWorldImporters_InMemory_Data_1',  
	NOUNLOAD,  STATS = 5
GO
