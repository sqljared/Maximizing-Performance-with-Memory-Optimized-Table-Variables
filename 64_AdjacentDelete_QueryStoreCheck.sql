USE WideWorldImporters
GO
-- Focus on the duration of the two "DELETE ct" and "DELETE invl" statements.
-- These should be improved in GarbageCollect_InvoicesAdjacent, because we used
-- the local ID and removed a key lookup.

SELECT 
	qsq.query_id,
	OBJECT_NAME(object_id) AS ProcedureName,
	qt.query_sql_text,
	sum(qrs.avg_duration * qrs.count_executions) AS total_duration,
	sum(qrs.count_executions) AS total_executions,
	sum(qrs.avg_duration * qrs.count_executions)
		/ sum(qrs.count_executions) AS avg_duration,
	sum(qrs.avg_cpu_time * qrs.count_executions)
		/ sum(qrs.count_executions) AS avg_cpu_time,
	sum(qrs.avg_rowcount * qrs.count_executions)
		/ sum(qrs.count_executions) AS avg_rowcount,
	sum(CASE WHEN qrs.avg_rowcount = 0 THEN 0
		ELSE qrs.avg_duration END) / sum(qrs.avg_rowcount)  AS µsec_per_row
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
	qsq.object_id IN (OBJECT_ID('Testing.GarbageCollect_Invoices'),
		OBJECT_ID('Testing.GarbageCollect_InvoicesAdjacent'))
	AND qsi.start_time > DATEADD(day, -1, GETUTCDATE()) 
	--AND qt.query_sql_text like '%DELETE%'
GROUP BY
	qsq.query_id,
	OBJECT_NAME(object_id),
	qt.query_sql_text
ORDER BY
	qt.query_sql_text

	
--ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
--GO
