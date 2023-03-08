USE WideWorldImporters
GO
DECLARE @OrderID INT = 99;

DECLARE @OrderTVP MemoryOptimized.IntegerUQTVP;

INSERT INTO @OrderTVP
VALUES (@OrderID);

SELECT *
FROM Sales.Orders so
WHERE
	so.OrderID = @OrderID;

SELECT *
FROM @OrderTVP tvp
INNER JOIN Sales.Orders so
	ON so.OrderID = tvp.IntValue;
-- WHERE
GO