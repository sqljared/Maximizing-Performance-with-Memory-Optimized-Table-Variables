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
	SELECT 1
	FROM sys.indexes si
	WHERE
		si.name = 'IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen'
)
BEGIN
	CREATE INDEX IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen
		ON Sales.OrderLines (OrderLineID, Quantity, Description)
		INCLUDE (LastEditedBy, LastEditedWhen);
END;
GO

CREATE OR ALTER PROCEDURE Testing.UpdateContention_UpdateAll
	@OrderLineInput Sales.OrderLineTVP READONLY,
	@UserID INT = 0
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	UPDATE sol	
	SET
		sol.Quantity = oli.Quantity,
		sol.Description = oli.Description,
		sol.LastEditedBy = @UserID,
		sol.LastEditedWhen = GETUTCDATE()
	FROM @OrderLineInput oli
	INNER JOIN Sales.OrderLines sol WITH(INDEX(IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen))
		ON sol.OrderLineID = oli.OrderLineID;

END;
GO

CREATE OR ALTER PROCEDURE Testing.UpdateContention_Selective
	@OrderLineInput Sales.OrderLineTVP READONLY,
	@UserID INT = 0
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	UPDATE sol	
	SET
		sol.Quantity = oli.Quantity,
		sol.Description = oli.Description,
		sol.LastEditedBy = @UserID,
		sol.LastEditedWhen = GETUTCDATE()
	FROM @OrderLineInput oli
	INNER JOIN Sales.OrderLines sol WITH(INDEX(IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen))
		ON sol.OrderLineID = oli.OrderLineID
	WHERE 
		(sol.Quantity <> oli.Quantity OR
		sol.Description <> oli.Description);

END;
GO

CREATE OR ALTER PROCEDURE Testing.UpdateContention_ManualHalloween
	@OrderLineInput Sales.OrderLineTVP READONLY,
	@UserID INT = 0
	WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @OrderLineMod Sales.OrderLineModTVP;

	INSERT INTO @OrderLineMod
		(OrderLineID,
		Quantity,
		Description,
		Quantity_New,
		Description_New)
	SELECT 
		sol.OrderLineID,
		sol.Quantity,
		sol.Description,
		oli.Quantity,
		oli.Description
	FROM @OrderLineInput oli
	INNER JOIN Sales.OrderLines sol WITH(INDEX(IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen))
		ON sol.OrderLineID = oli.OrderLineID;

	-- You could choose not to include rows with no change in the MOTV
	--WHERE
	--	(sol.Quantity <> oli.Quantity OR
	--	sol.Description <> oli.Description_New);

	IF EXISTS(
		SELECT 1 
		FROM @OrderLineMod olm
		WHERE
			(olm.Quantity <> olm.Quantity_New OR
			olm.Description <> olm.Description_New)
	)
	BEGIN
		UPDATE sol	
		SET
			sol.Quantity = olm.Quantity_New,
			sol.Description = olm.Description_New,
			sol.LastEditedBy = @UserID,
			sol.LastEditedWhen = GETUTCDATE()
		FROM @OrderLineMod olm
		INNER JOIN Sales.OrderLines sol WITH(INDEX(IX_OrderLines_OrderLineID_StockItemID_PickingCompletedWhen))
			ON sol.OrderLineID = olm.OrderLineID
		WHERE
			(olm.Quantity <> olm.Quantity_New OR
			olm.Description <> olm.Description_New);
	END;

END;
GO
