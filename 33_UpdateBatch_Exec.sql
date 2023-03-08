USE WideWorldImporters
GO
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
GO
SET NOCOUNT ON;

DECLARE @OrderLineInput Sales.OrderLineTVP;

DECLARE
	@BatchSize INT = 20,
	@Seed FLOAT = 0.0, -- Precentage of rows changing
	@OrderChange BIT,
	@InsertCount INT = 0,
	@UserID INT = 1001;

-- SET @OrderChange = CASE WHEN (RAND() * 100) > @Seed THEN 1 ELSE 0 END;

--SELECT TOP (@BatchSize) 
--	sol.OrderLineID,
--	sol.Quantity,
--	sol.UnitPrice
--FROM Sales.OrderLines sol
--WHERE
--	sol.OrderLineID > 10000

WHILE @InsertCount < @BatchSize
BEGIN

	SET @OrderChange = CASE WHEN (RAND() * 100) < @Seed THEN 1 ELSE 0 END;

	-- Inserting 1 record into MOTV
	INSERT INTO @OrderLineInput
	SELECT TOP (@BatchSize) 
		sol.OrderLineID,
		sol.Quantity + @OrderChange,
		sol.Description + CASE WHEN @OrderChange = 1 THEN ' updated' ELSE '' END
	FROM Sales.OrderLines sol
	WHERE
		sol.OrderLineID = (10000+@InsertCount)

	SET @InsertCount += 1;
END;

--SELECT *
--FROM @OrderLineInput oli
--INNER JOIN Sales.OrderLines sol
--	ON sol.OrderLineID = oli.OrderLineID
--WHERE
--	oli.Quantity <> sol.Quantity;

BEGIN TRANSACTION
	
	EXEC Testing.UpdateContention_UpdateAll
		@OrderLineInput = @OrderLineInput,
		@UserID = @UserID;

ROLLBACK TRANSACTION

BEGIN TRANSACTION
	
	EXEC Testing.UpdateContention_Halloween
		@OrderLineInput = @OrderLineInput,
		@UserID = @UserID;

ROLLBACK TRANSACTION

BEGIN TRANSACTION
	
	EXEC Testing.UpdateContention_ManualHalloween
		@OrderLineInput = @OrderLineInput,
		@UserID = @UserID;

ROLLBACK TRANSACTION

--SELECT *
--FROM @OrderLineInput oli
--INNER JOIN Sales.OrderLines sol
--	ON sol.OrderLineID = oli.OrderLineID
--WHERE
--	oli.Quantity <> sol.Quantity;

GO 50