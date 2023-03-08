USE WideWorldImporters
GO

--DROP PROCEDURE IF EXISTS Testing.OrderLines_WipeAndReplaceWrapper;
--DROP PROCEDURE IF EXISTS Testing.OrderLines_WipeAndReplace;
--DROP TYPE IF EXISTS MemoryOptimized.OrderLineInsertModTVP;

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderLineInsertModTVP'
)
BEGIN
	CREATE TYPE MemoryOptimized.OrderLineInsertModTVP
	AS TABLE(
		OrderLineID int NOT NULL,
		OrderID int NOT NULL,
		StockItemID int NOT NULL,
		Description nvarchar(100) NOT NULL,
		PackageTypeID int NOT NULL,
		Quantity int NOT NULL,
		UnitPrice decimal(18, 2) NULL,
		TaxRate decimal(18, 3) NOT NULL,
		PickedQuantity int NOT NULL,
		INDEX UQ_OrderLineTVP UNIQUE NONCLUSTERED (StockItemID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

IF NOT EXISTS(
	SELECT 1 
	FROM sys.types st
	WHERE 
		st.name = 'OrderLineInsertOrderedTVP'
)
BEGIN
	CREATE TYPE MemoryOptimized.OrderLineInsertOrderedTVP
	AS TABLE(
		OrderLineID int NOT NULL,
		OrderID int NOT NULL,
		StockItemID int NOT NULL,
		Description nvarchar(100) NOT NULL,
		PackageTypeID int NOT NULL,
		Quantity int NOT NULL,
		UnitPrice decimal(18, 2) NULL,
		TaxRate decimal(18, 3) NOT NULL,
		PickedQuantity int NOT NULL,
		INDEX UQ_OrderLineTVP UNIQUE NONCLUSTERED (OrderLineID)
	)WITH(MEMORY_OPTIMIZED = ON); 
END;
GO

CREATE OR ALTER PROCEDURE Testing.OrderLines_WipeAndReplacev2
	@OrderID INT,
	@OrderLineInput MemoryOptimized.OrderLineInsertOrderedTVP READONLY,
	@UserID INT
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DELETE sol
	FROM @OrderLineInput oli
	LEFT JOIN Sales.OrderLines sol
		ON sol.OrderLineID = oli.OrderLineID
	WHERE
		sol.LastEditedBy <> @UserID;
	
	INSERT INTO Sales.OrderLines(
		OrderID,
		StockItemID,
		Description,
		PackageTypeID,
		Quantity,
		UnitPrice,
		TaxRate,
		PickedQuantity,
		PickingCompletedWhen,
		LastEditedBy,
		LastEditedWhen
	)
	SELECT 
		@OrderID,
		oli.StockItemID,
		oli.Description,
		oli.PackageTypeID,
		oli.Quantity,
		oli.UnitPrice,
		oli.TaxRate,
		oli.PickedQuantity,
		GETUTCDATE(),
		@UserID,
		GETUTCDATE()
	FROM @OrderLineInput oli
	INNER LOOP JOIN Sales.OrderLines sol
		ON sol.OrderID = @OrderID
		AND sol.StockItemID = oli.StockItemID
	WHERE
		sol.OrderID IS NULL;

END;
GO

CREATE OR ALTER PROCEDURE Testing.OrderLines_WipeAndReplaceWrapperv2
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@Base INT = 155000, -- Base range for OrderID
		@Seed FLOAT = 100.0, -- Random element for OrderID
		@UserID INT = 1001,
		@OrderID INT;
		
	DECLARE @OrderLineInput MemoryOptimized.OrderLineInsertOrderedTVP;

	SET @OrderID = @Base + RAND()*@Seed;

	INSERT INTO @OrderLineInput(
		OrderLineID,
		OrderID,
		StockItemID,
		Description,
		PackageTypeID,
		Quantity,
		UnitPrice,
		TaxRate,
		PickedQuantity
	)
	SELECT 
		sol.OrderLineID,
		sol.OrderID,
		sol.StockItemID,
		sol.Description,
		sol.PackageTypeID,
		sol.Quantity,
		sol.UnitPrice,
		sol.TaxRate,
		sol.PickedQuantity
	FROM Sales.OrderLines sol
	WHERE
		sol.OrderID = @OrderID;

	EXEC Testing.OrderLines_WipeAndReplacev2
		@OrderID = @OrderID,
		@OrderLineInput = @OrderLineInput,
		@UserID = @UserID;

END;
GO
