Use WideWorldImporters

Select t1.*,t2.OrderDate from sales.OrderLines as t1
left join sales.Orders as t2
on t1.OrderID=t2.OrderID



--Работать будем с исходником sales.OrderLines, для выведения даты (каждую строку
--sales.OrderLines мы снабдим датой из sales.Orders. 

--Шаг 1: 
--Создаем файловую группу
--создаем функцию партиционирования по годам 
--Создаем схему 
--Создаем Таблицы в которых юудем создавать секции

SELECT distinct year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate)) AS UniqueDate
FROM sales.OrderLines as t1
left join sales.Orders as t2
on t1.OrderID=t2.OrderID
order by UniqueDate

--попробую динамически создать колонки с годами:

DECLARE @DynamicSQL NVARCHAR(MAX)
DECLARE @Columns NVARCHAR(MAX)

--SELECT @Columns = 
--STRING_AGG('[' + CAST(year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate)) AS NVARCHAR(max)) + ']', ',' )
--FROM (select distinct year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate)) as OrderDate from sales.OrderLines as t1
--left join sales.Orders as t2
--on t1.OrderID=t2.OrderID
--GROUP BY year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate))

SELECT @Columns = 
STRING_AGG('[' + CAST(OrderDate AS NVARCHAR(max)) + ']', ',' )
FROM (
    select distinct year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate)) as OrderDate 
    from sales.OrderLines as t1
    left join sales.Orders as t2
    on t1.OrderID = t2.OrderID
    GROUP BY year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate))
) as Subquery



SET @DynamicSQL = '
SELECT ' + @Columns + '
FROM (
    SELECT distinct year(DATEADD(day, 1 - DATEPART(DAY, OrderDate), OrderDate)) AS UniqueDate
    FROM sales.OrderLines as t1
    left join sales.Orders as t2
    on t1.OrderID=t2.OrderID
) AS Source
PIVOT (
    max(UniqueDate)
    FOR UniqueDate IN (' + @Columns + ')
) AS PivotTable
'

EXEC sp_executesql @DynamicSQL


--1.
Alter database [WideWorldImporters] add filegroup [For_section];

ALTER DATABASE [WideWorldImporters] ADD FILE 
(
    NAME = N'Years',
    FILENAME = N'C:\BCP\For_section.ndf',
    SIZE = 1097152KB,
    FILEGROWTH = 65536KB
) TO FILEGROUP [For_section]

Alter database [WideWorldImporters] add file 
(name = N'Years' , FILENAME =N' C:\BCP\For_section.ndf',
size = 1097152KB , filegrowth = 65536 KB )  to filegroup [For_section]
GO
--2.

--Очень жаль, что автоматизировать момент с автоматическим заданием года, исходя из данных целевой таблицы - нельзя. 

create partition function [fnYearPertition](DATE) as range right for values
('20130101','20140101','20150101','20160101');
GO
--3.
create partition scheme [scmeYearPertition 1] as partition [fnYearPertition 1]
all to ([For_section])
GO

--drop table if exists [sales].[OrderLines_clustered]
create table [sales].[OrderLines_clustered]
(OrderLineID int not null
,OrderID int not null
,StockItemID int not null
,Description nvarchar(100) not null
,PackageTypeID int not null
,Quantity int not null
,UnitPrice decimal (18,2) null
,TaxRate decimal (18,3) null
,PickedQuantity int not null
,PickingCompletedWhen datetime2(7) null
,LastEditedBy  int not null
,LastEditedWhen datetime2(7) null
,date_for_section date not null
) ON [scmeYearPertition 1](date_for_section)
GO

Alter table [sales].[OrderLines_clustered] add constraint PK_OrderLines_clustered
primary key clustered (date_for_section,OrderID,OrderLineID)
on [scmeYearPertition 1] (date_for_section)

--ПРоверяем, что наша таблица теперь является секционированной--
Select distinct t.name 
from sys.partitions p
inner join sys.tables t
on p.object_id=t.object_id
where p.partition_number<>1


--Заливаем данные в нашу созданную таблицу--

Select * from [sales].[OrderLines_clustered]

delete from [sales].[OrderLines_clustered]
INSERT INTO [sales].[OrderLines_clustered] 
(OrderLineID, 
OrderID, 
StockItemID, 
Description, 
PackageTypeID, 
Quantity, 
UnitPrice, 
TaxRate, 
PickedQuantity, 
PickingCompletedWhen, 
LastEditedBy, 
LastEditedWhen, 
date_for_section)
SELECT t1.OrderLineID, t1.OrderID, t1.StockItemID, t1.Description, t1.PackageTypeID, t1.Quantity, t1.UnitPrice, t1.TaxRate, t1.PickedQuantity, t1.PickingCompletedWhen, t1.LastEditedBy, t1.LastEditedWhen, t2.OrderDate as [date_for_section]
FROM sales.OrderLines AS t1
LEFT JOIN sales.Orders AS t2 ON t1.OrderID = t2.OrderID




Select * from [sales].[OrderLines_clustered]

--Проверяем что получилось--
--к сожалению, тут у меня не получилось проверить свои партиции каак на уроке--
Select $PARTITION.fnYearPartition(date_for_section) as partition
,count(*) as [count]
,min(date_for_section) as min_date
,max(date_for_section) as max_date
from [sales].[OrderLines_clustered]
group by $PARTITION.fnYearPartition(date_for_section)
order by partition


--пришлось думать иной способ как посмотреть секции, что создал--
SELECT 
    OBJECT_NAME(p.object_id) AS TableName,
    i.name AS IndexName,
    p.partition_number AS PartitionNumber,
    fg.name AS FileGroupName,
    prv.value AS PartitionValue
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
INNER JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
LEFT JOIN sys.partition_range_values prv ON ps.function_id = prv.function_id AND p.partition_number = prv.boundary_id
WHERE OBJECT_NAME(p.object_id) = 'OrderLines_clustered'
ORDER BY TableName, PartitionNumber;