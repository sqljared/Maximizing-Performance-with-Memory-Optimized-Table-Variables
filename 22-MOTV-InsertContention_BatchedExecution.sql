USE WideWorldImporters
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.schemas ssch
	WHERE 
		ssch.name = 'MemoryOptimized'
)
BEGIN
	EXEC('CREATE SCHEMA MemoryOptimized');
END;
GO 

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'InsertContentionTVP'
)
BEGIN
	CREATE TYPE MemoryOptimized.InsertContentionTVP
	AS TABLE(
		TransactionCode nvarchar(20) NOT NULL,
		InsertDateGMT datetime2(2) NOT NULL,
		Price money NOT NULL,
		Quantity int NOT NULL,
		INDEX IX_InsertContentionTVP NONCLUSTERED (TransactionCode)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

CREATE OR ALTER PROCEDURE Testing.InsertContention_TVPBatched
	@InsertContentionTVP MemoryOptimized.InsertContentionTVP READONLY
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	INSERT Testing.InsertContention
		(TransactionCode, InsertDateGMT, Price, Quantity)
	SELECT
		tvp.TransactionCode, 
		tvp.InsertDateGMT, 
		tvp.Price, 
		tvp.Quantity
	FROM @InsertContentionTVP tvp;

	RETURN @@RowCount;
END;
GO
