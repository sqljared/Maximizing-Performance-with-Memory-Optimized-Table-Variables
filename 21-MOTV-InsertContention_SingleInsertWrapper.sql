USE WideWorldImporters
GO

CREATE OR ALTER PROCEDURE Testing.InsertContention_SingleInsertWrapper
AS
BEGIN
	DECLARE 
		@TransactionCode nvarchar(20),
		@InsertDateGMT datetime2(2),
		@Price money,
		@Quantity int;
	
	SET NOCOUNT ON;
	
	-- Inserting 1 record into InsertContention
	SET @TransactionCode = RIGHT(CONVERT(varchar(255), NEWID()),20);
	SET @InsertDateGMT = DATEADD(DAY, -FLOOR(RAND() * 1000),GETUTCDATE());
	SET @Price = RAND() * 100;
	SET @Quantity = FLOOR(RAND() * 10);
	
	EXEC Testing.InsertContention_SingleInsert 
		@TransactionCode = @TransactionCode, 
		@InsertDateGMT = @InsertDateGMT, 
		@Price = @Price, 
		@Quantity = @Quantity;

END;
GO

ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
