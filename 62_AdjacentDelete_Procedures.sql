USE WideWorldImporters
GO

CREATE OR ALTER PROCEDURE Testing.GarbageCollect_Invoices
	@RetentionPeriod INT = 365 , --days
	@BatchSize INT = 1000
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @InvoiceList MemoryOptimized.InvoiceIDList;

	INSERT INTO @InvoiceList
	SELECT TOP (@BatchSize) 
		inv.InvoiceID
	FROM Sales.Invoices inv
	WHERE
		inv.InvoiceDate < DATEADD(DAY, -@RetentionPeriod, GETUTCDATE());
		
	DELETE invl
	FROM @InvoiceList list
	INNER LOOP JOIN Sales.InvoiceLines invl
		ON invl.InvoiceID = list.InvoiceID;
		
	DELETE ct
	FROM @InvoiceList list
	INNER LOOP JOIN Sales.CustomerTransactions ct
		ON ct.InvoiceID = list.InvoiceID;

	DELETE inv
	FROM @InvoiceList list
	INNER LOOP JOIN Sales.Invoices inv
		ON inv.InvoiceID = list.InvoiceID;

END;
GO

CREATE OR ALTER PROCEDURE Testing.GarbageCollect_InvoicesAdjacent
	@RetentionPeriod INT = 365 , --days
	@BatchSize INT = 1000
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE @InvoiceLineList MemoryOptimized.InvoiceLineIDList;
	DECLARE @CustomerTransactionList MemoryOptimized.CustomerTransactionIDList;
	
	DECLARE @InvoiceList MemoryOptimized.InvoiceIDList;
	
	INSERT INTO @InvoiceList
	SELECT TOP (@BatchSize) 
		inv.InvoiceID
	FROM Sales.Invoices inv
	WHERE
		inv.InvoiceDate < DATEADD(DAY, -@RetentionPeriod, GETUTCDATE());
		
	INSERT INTO @InvoiceLineList
	SELECT --TOP (@BatchSize) 
		invl.InvoiceLineID
	FROM @InvoiceList list
	INNER JOIN Sales.InvoiceLines invl
		ON invl.InvoiceID = list.InvoiceID;
		
	INSERT INTO @CustomerTransactionList
	SELECT --TOP (@BatchSize) 
		ct.TransactionDate,
		ct.CustomerTransactionID
	FROM @InvoiceList list
	INNER LOOP JOIN Sales.CustomerTransactions ct
		ON ct.InvoiceID = list.InvoiceID;
		
	DELETE invl
	FROM @InvoiceLineList list
	INNER LOOP JOIN Sales.InvoiceLines invl
		ON invl.InvoiceLineID = list.InvoiceLineID;
		
	DELETE ct
	FROM @CustomerTransactionList list
	INNER LOOP JOIN Sales.CustomerTransactions ct
		ON ct.TransactionDate = list.TransactionDate
		AND ct.CustomerTransactionID = list.CustomerTransactionID;

	DELETE inv
	FROM @InvoiceList list
	INNER LOOP JOIN Sales.Invoices inv
		ON inv.InvoiceID = list.InvoiceID;

END;
GO
