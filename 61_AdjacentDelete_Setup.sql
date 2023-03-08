USE WideWorldImporters
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'InvoiceIDList'
)
BEGIN
	CREATE TYPE MemoryOptimized.InvoiceIDList
	AS TABLE(
		InvoiceID INT,
		INDEX UQ_InvoiceIDList UNIQUE NONCLUSTERED (InvoiceID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'InvoiceLineIDList'
)
BEGIN
	CREATE TYPE MemoryOptimized.InvoiceLineIDList
	AS TABLE(
		InvoiceLineID INT,
		INDEX UQ_InvoiceLineIDList UNIQUE NONCLUSTERED (InvoiceLineID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'CustomerTransactionIDList'
)
BEGIN
	CREATE TYPE MemoryOptimized.CustomerTransactionIDList
	AS TABLE(
		CustomerTransactionID INT,
		INDEX UQ_CustomerTransactionIDList UNIQUE NONCLUSTERED (CustomerTransactionID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF EXISTS(
	SELECT 1
	FROM sys.foreign_keys fk
	WHERE
		fk.name = 'FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices'
)
BEGIN
	ALTER TABLE [Warehouse].[StockItemTransactions]  
		DROP CONSTRAINT [FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices];
END;
GO
