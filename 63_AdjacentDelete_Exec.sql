USE WideWorldImporters
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO

BEGIN TRANSACTION

exec Testing.GarbageCollect_Invoices
	@RetentionPeriod = 365,
	@BatchSize = 100;

ROLLBACK TRANSACTION

GO 10

BEGIN TRANSACTION

exec Testing.GarbageCollect_InvoicesAdjacent
	@RetentionPeriod = 365,
	@BatchSize = 100;

ROLLBACK TRANSACTION

GO 10
