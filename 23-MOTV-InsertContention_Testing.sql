USE WideWorldImporters
GO

-- So let's insert 500 rows into this on-disk table using a TVP
DECLARE 
	@Target INT = 500,
	@InsertContentionTVP MemoryOptimized.InsertContentionTVP;

DECLARE @Counter int = 0;
SET NOCOUNT ON;

WHILE @Counter < @Target
BEGIN
	-- Generating one random row at a time
	INSERT @InsertContentionTVP
		(TransactionCode, InsertDateGMT, Price, Quantity)
	SELECT
		RIGHT(CONVERT(varchar(255), NEWID()),20),
		GETUTCDATE(),
		RAND() * 100,
		FLOOR(RAND() * 10);

	SET @Counter += 1;
END;
	
EXEC Testing.InsertContention_TVPBatched @InsertContentionTVP;
GO

-- And let's insert 500 rows into the on-disk table using the singleton procedure

EXEC Testing.InsertContention_SingleInsertWrapper;
GO 500

-- But, this tests the singleton using serial calls. 
-- Let's test another way to allow multi-threading to cause some contention

