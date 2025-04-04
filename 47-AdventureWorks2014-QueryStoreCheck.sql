USE AdventureWorks2014
GO
-- Compare statements from sp_DetailUpdate with the IF EXISTS statements 
-- from sp_DetailUpdate_Modified that correspond. So, compare the UPDATE statement
-- to the IF EXISTS where dc.OrderQty_Current <> dc.OrderQty_New. If the values
-- aren't the same, we would need to UPDATE them.

SELECT 
	qsq.query_id,
	qsq.query_hash,
	OBJECT_NAME(object_id),
	CAST(qsp.query_plan AS XML) as query_plan,
	qt.query_sql_text,
	--qt.statement_sql_handle,
	qsp.plan_id,
	qrs.avg_duration,
	qrs.avg_cpu_time,
	qrs.avg_logical_io_reads,
	qrs.count_executions,
	avg_rowcount
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qt
	ON qt.query_text_id = qsq.query_text_id
JOIN sys.query_store_plan qsp
	ON qsp.query_id = qsq.query_id
JOIN sys.query_store_runtime_stats qrs
	ON qrs.plan_id = qsp.plan_id
JOIN sys.query_store_runtime_stats_interval qsi
	ON qsi.runtime_stats_interval_id = qrs.runtime_stats_interval_id
WHERE
	qsq.object_id IN (OBJECT_ID('dbo.sp_DetailUpdate'), OBJECT_ID('dbo.sp_DetailUpdate_Modified'))
	--AND qt.query_sql_text like '%UPDATE%'
	AND qsi.start_time > DATEADD(MINUTE, -30, GETUTCDATE())
ORDER BY start_time,
	OBJECT_NAME(object_id),
	query_hash

-- 	qsq.object_id IN (OBJECT_ID('dbo.sp_DetailUpdate'), OBJECT_ID('dbo.sp_DetailUpdate_Modified'))