USE WideWorldImporters
GO
SELECT 
	qsq.query_id,
	OBJECT_NAME(object_id) AS ProcedureName,
	qt.query_sql_text,
	qsp.plan_id,
	qrs.avg_duration * qrs.count_executions AS total_duration,
	qrs.avg_duration,
	qrs.avg_cpu_time,
	qrs.count_executions,
	qrs.avg_rowcount,
	qrs.avg_duration / qrs.avg_rowcount AS µsec_per_row,
	ws.avg_query_wait_time_ms,
	ws.wait_category_desc,
	ws.total_query_wait_time_ms,
	qrs.min_duration,
	qrs.max_duration
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
	qsq.object_id IN( OBJECT_ID('Testing.InsertContention_TVPBatched'), 
		OBJECT_ID('Testing.InsertContention_SingleInsert'), 
			OBJECT_ID('Testing.InsertContention_SingleInsertWrapper'))
	AND qsi.start_time > DATEADD(day, -1, GETUTCDATE()) 
	--AND qt.query_sql_text like '%Something%'
ORDER BY
	query_hash
