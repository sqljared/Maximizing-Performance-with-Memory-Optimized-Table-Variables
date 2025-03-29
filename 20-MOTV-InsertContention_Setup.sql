USE WideWorldImporters
GO
IF NOT EXISTS(
	SELECT 1 
	FROM sys.schemas ssch
	WHERE 
		ssch.name = 'Testing'
)
BEGIN
	EXEC('CREATE SCHEMA Testing');
END;
GO
IF NOT EXISTS(
	SELECT 1 FROM sys.tables st
	WHERE
		st.name = 'InsertContention'
)
BEGIN
	CREATE TABLE Testing.InsertContention
	(
		RowID bigint IDENTITY(1,1) PRIMARY KEY,
		TransactionCode nvarchar(20) NOT NULL,
		InsertDateGMT datetime2(2) NOT NULL,
		Price money NOT NULL,
		Quantity int NOT NULL
	);
END;
GO

CREATE OR ALTER PROCEDURE Testing.InsertContention_SingleInsert
	@TransactionCode nvarchar(20),
	@InsertDateGMT datetime2(2),
	@Price money,
	@Quantity int
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	INSERT Testing.InsertContention
		(TransactionCode, InsertDateGMT, Price, Quantity)
	VALUES
		(@TransactionCode, @InsertDateGMT, @Price, @Quantity);
	RETURN 0;
END;
GO

DECLARE 
	@TransactionCode NVARCHAR(20),
	@InsertDateGMT DATETIME2(2),
	@Price MONEY,
	@Quantity INT;

--DECLARE 
--	@InsertCount INT = 0,
--	@InsertLimit INT = 100000;

--SET NOCOUNT ON;

--WHILE @InsertCount < @InsertLimit
--BEGIN
--	-- Inserting 1 record into InsertContention
--	SET @TransactionCode = RIGHT(CONVERT(varchar(255), NEWID()),20);
--	SET @InsertDateGMT = DATEADD(DAY, -FLOOR(RAND() * 1000),GETUTCDATE());
--	SET @Price = RAND() * 100;
--	SET @Quantity = FLOOR(RAND() * 10);

--	EXEC Testing.InsertContention_SingleInsert 
--		@TransactionCode = @TransactionCode, 
--		@InsertDateGMT = @InsertDateGMT, 
--		@Price = @Price, 
--		@Quantity = @Quantity;

--	SET @InsertCount += 1;
--END;
--GO
