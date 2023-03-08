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
		st.name = 'IntegerUQTVP'
)
BEGIN
	CREATE TYPE MemoryOptimized.IntegerUQTVP 
	AS TABLE(
		IntValue INT,
		INDEX IX_IntegerUQTVP UNIQUE NONCLUSTERED (IntValue)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'IntIntTVP'
)
BEGIN
	CREATE TYPE MemoryOptimized.IntIntTVP 
	AS TABLE(
		IntValue1 INT,
		IntValue2 INT,
		INDEX IX_IntegerUQTVP  NONCLUSTERED (IntValue1)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO
