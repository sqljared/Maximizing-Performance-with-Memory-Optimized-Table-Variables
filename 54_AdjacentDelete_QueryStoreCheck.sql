USE WideWorldImporters
GO
SELECT 
	qsq.query_id,
	OBJECT_NAME(object_id) AS ProcedureName,
	CAST(qsp.query_plan AS XML) as query_plan,
	qt.query_sql_text,
	qsp.plan_id,
	qrs.avg_duration,
	qrs.avg_cpu_time,
	qrs.count_executions,
	qrs.avg_rowcount,
	CASE WHEN qrs.avg_rowcount = 0 THEN 0
		ELSE qrs.avg_duration / qrs.avg_rowcount END AS µsec_per_row,
	ws.avg_query_wait_time_ms,
	ws.wait_category_desc,
	ws.total_query_wait_time_ms,
	qrs.avg_duration * qrs.count_executions AS total_duration,
	qrs.min_duration,
	qrs.max_duration,
	avg_physical_io_reads,
	avg_logical_io_reads
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qt
	ON qt.query_text_id = qsq.query_text_id
JOIN sys.query_store_plan qsp
	ON qsp.query_id = qsq.query_id
JOIN sys.query_store_runtime_stats qrs
	ON qrs.plan_id = qsp.plan_id
JOIN sys.query_store_runtime_stats_interval qsi
	ON qsi.runtime_stats_interval_id = qrs.runtime_stats_interval_id
LEFT JOIN sys.query_store_wait_stats ws
	ON ws.runtime_stats_interval_id = qsi.runtime_stats_interval_id
	AND ws.plan_id = qrs.plan_id
WHERE
	qsq.object_id IN (OBJECT_ID('Testing.OrderLines_WipeAndReplace'),
		OBJECT_ID('Testing.OrderLines_WipeAndReplacev2'))
	AND qsi.start_time > DATEADD(MINUTE, -15, GETUTCDATE()) 
	AND qt.query_sql_text like '%DELETE%'
ORDER BY
	ProcedureName,
	avg_duration

	
--ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR;
--GO
