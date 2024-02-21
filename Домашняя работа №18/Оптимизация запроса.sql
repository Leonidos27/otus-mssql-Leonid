Use WideWorldImporters

--select * from  sys.dm_exec_query_stats
--order by last_execution_time  desc 


--SELECT
--  qs.creation_time,
--  qs.last_execution_time,
--    DB_NAME(st.dbid) AS database_name,
--    OBJECT_NAME(st.objectid, st.dbid) AS object_name,
--    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
--        ((CASE statement_end_offset
--            WHEN -1 THEN DATALENGTH(st.text)
--            ELSE qs.statement_end_offset END
--        - qs.statement_start_offset)/2) + 1) AS query_text,
--    qs.total_elapsed_time,
--    qs.total_logical_reads,
--    qs.total_logical_writes,
--	qs.total_rows,
--	qs.last_columnstore_segment_reads,
--	qs.total_worker_time,
--	qs.max_worker_time
--FROM sys.dm_exec_query_stats AS qs
--CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
--ORDER BY --qs.creation_time DESC, 
--qs.last_execution_time desc 


--ѕроверка скорости работы--
--SELECT
--    deqs.execution_count,
--    deqs.total_elapsed_time / deqs.execution_count AS avg_elapsed_time,
--    deqs.creation_time,
--    des.text,
--    deqs.total_rows,
--	deqs.last_rows,
--	deqs.last_execution_time,
--	deqs.max_worker_time
--FROM
--    sys.dm_exec_query_stats AS deqs
--CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS des
--ORDER BY
--    deqs.last_execution_time DESC

	--очистка статистики (дл¤ честного сражени¤ по скорости работы) 
DBCC FREEPROCCACHE 


--Изначальный код, который нужно обезвредить (оптимизировать) 
--комментари¤ми в строках опишу моменты, на которые обратил внимание
-- цп - 1156 мс, затраченное время = 1287 мс. 

--SET STATISTICS TIME ON
Select 
ord.CustomerID, 
det.StockItemID, 
SUM(det.UnitPrice), 
SUM(det.Quantity), 
COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
ON det.OrderID = ord.OrderID
jOIN Sales.Invoices AS Inv
ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
AND (Select SupplierId
FROM Warehouse.StockItems AS It
Where It.StockItemID = det.StockItemID) = 12
AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
FROM Sales.OrderLines AS Total --повторное использование таблицы, откуда берем данные
Join Sales.Orders AS ordTotal  --повторное использование таблицы, откуда берем данные
On ordTotal.OrderID = Total.OrderID
WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0  -- по сути, тут производитс¤ проверка на то ,что Inv.InvoiceDate = ord.OrderDate, вункцию ¤ бы убрал, это облегчит работу ÷ѕ. 
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
--SET STATISTICS TIME OFF



SELECT 
    ord.CustomerID, 
    det.StockItemID as [StockItemID], 
    SUM(det.UnitPrice) as [UnitPrice], 
    SUM(det.Quantity) as [Quantity] , 
    COUNT(ord.OrderID)
FROM Sales.Orders AS ord --WITH (INDEX(FK_Sales_Orders_CustomerID))
JOIN Sales.OrderLines AS det
    ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv WITH (INDEX(FK_Sales_Invoices_CustomerID)) -- дает хороший прирост 
    ON Inv.OrderID = ord.OrderID 
    AND Inv.BillToCustomerID != ord.CustomerID
    AND Inv.InvoiceDate = ord.OrderDate
--JOIN Sales.CustomerTransactions AS Trans --WITH (INDEX(FK_Sales_CustomerTransactions_CustomerID))
--    ON Trans.InvoiceID = Inv.InvoiceID
--JOIN Warehouse.StockItemTransactions AS ItemTrans 
--    ON ItemTrans.StockItemID = det.StockItemID
WHERE
    EXISTS (
        SELECT 1
        FROM Warehouse.StockItems AS It  WITH (INDEX(FK_Warehouse_StockItems_SupplierID)) --дает прирост
        WHERE It.StockItemID = det.StockItemID
        AND It.SupplierId = 12
    ) 
    AND (
        SELECT SUM(Total.UnitPrice * Total.Quantity)
        FROM Sales.OrderLines AS Total  
        JOIN Sales.Orders AS ordTotal  
            ON ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID
    ) > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
