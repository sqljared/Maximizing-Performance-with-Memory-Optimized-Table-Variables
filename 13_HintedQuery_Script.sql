USE WideWorldImporters
GO
DECLARE @OrderTVP MemoryOptimized.IntegerUQTVP;

DECLARE @SeedID INT = 0;

INSERT @OrderTVP
SELECT TOP 100
	so.OrderID
FROM Sales.Orders so
WHERE so.OrderID > @SeedID;

	
--SELECT *
--FROM Sales.Orders so
--INNER JOIN @OrderTVP tvp
--	ON so.OrderID = tvp.IntValue
--OPTION(FORCE ORDER);

SELECT *
FROM @OrderTVP tvp
INNER JOIN Sales.Orders so
	ON so.OrderID = tvp.IntValue
OPTION(FORCE ORDER);

SELECT *
FROM @OrderTVP tvp
INNER LOOP JOIN Sales.Orders so
	ON so.OrderID = tvp.IntValue;

GO
