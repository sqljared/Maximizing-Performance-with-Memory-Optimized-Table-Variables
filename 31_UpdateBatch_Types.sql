USE WideWorldImporters
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderLineTVP'
)
BEGIN
	CREATE TYPE Sales.OrderLineTVP
	AS TABLE(
		OrderLineID INT,
		Quantity INT,
		Description NVARCHAR(100),
		INDEX UQ_OrderLineTVP UNIQUE NONCLUSTERED (OrderLineID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderLineModTVP'
)
BEGIN
	CREATE TYPE Sales.OrderLineModTVP
	AS TABLE(
		OrderLineID INT,
		Quantity INT,
		Description NVARCHAR(100),
		Quantity_New INT,
		Description_New NVARCHAR(100),
		INDEX UQ_OrderLineModTVP UNIQUE NONCLUSTERED (OrderLineID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO
