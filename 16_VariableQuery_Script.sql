USE WideWorldImporters
GO
DECLARE @OrderList MemoryOptimized.IntegerUQTVP;

DECLARE @CustomerID INT = 0;

-- Here's a pattern to avoid

SELECT 
	so.*
FROM @OrderList list
INNER JOIN Sales.Orders so
	ON so.OrderID = list.IntValue
WHERE
	so.CustomerID = @CustomerID;

-- The SQL Server optimizer can use @CustomerID to seek Sales.Orders first, 
-- rather than using the OrderIDs from the motv, which would be more precise.
--		And what if that customer has a million orders?

GO

DECLARE @OrderList MemoryOptimized.IntIntTVP;

SELECT 
	so.*
FROM @OrderList list
INNER LOOP JOIN Sales.Orders so
	ON so.OrderID = list.IntValue1
	AND	so.CustomerID = list.IntValue2;

-- Here, there really isn't a filter to apply besides the motv. 
-- But the hint also ensures our join order and type.

GO