/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--Моё решение 
--1. Смотрю что есть в файлике, что дан к домашнему заданию.
drop table if exists dbo.StockItems_v2
Declare @xml_data XML;

Select @xml_data = Bulkcolumn 
FROM OPENROWSET 
(BULK 'C:\Users\Учебный ПК\otus-mssql-Leonid\Домашняя работа №9\StockItems-188-1fb5df.xml', single_clob) 
as date;

select @xml_data as [@xml_data]

Declare @temp int;
exec sp_xml_preparedocument @temp output, @xml_data;

Select @temp as temp

Select * into dbo.StockItems_v2
from 
openxml (@temp, N'/StockItems/Item')
with  (

[StockItemName] nvarchar(max) '@Name',
[SupplierID] int 'SupplierID',
[UnitPackageID] int 'Package/UnitPackageID',
[OuterPackageID] int 'Package/OuterPackageID',
[QuantityPerOuter] int 'Package/QuantityPerOuter',
[TypicalWeightPerUnit] decimal (18,3) 'Package/TypicalWeightPerUnit',
[LeadTimeDays] int 'LeadTimeDays',
[IsChillerStock] bit 'IsChillerStock',
[TaxRate] decimal (18,2) 'TaxRate',
[UnitPrice] decimal (18,2) 'UnitPrice')

exec sp_xml_removedocument @temp



Select * from dbo.StockItems_v2

Create table dbo.StockItems_v4
(
[StockItemID] int identity,
[StockItemName] nvarchar(max) ,
[SupplierID] int ,
[UnitPackageID] int ,
[OuterPackageID] int ,
[QuantityPerOuter] int ,
[TypicalWeightPerUnit] decimal (18,3) ,
[LeadTimeDays] int ,
[IsChillerStock] bit ,
[TaxRate] decimal (18,2) ,
[UnitPrice] decimal (18,2) )


insert into dbo.StockItems_v4
select * from  dbo.StockItems_v2

Select * from dbo.StockItems_v4

Select * from dbo.StockItems_v3
--Теперь сделаем копию основной таблицы и в  нее попробуем произвевасти мердж получившихся данных
--Select * into dbo.StockItems_v3 from Warehouse.StockItems
Select * from dbo.StockItems_v3




;Merge dbo.StockItems_v3 as target
using 
(select 
StockItemID,
StockItemName,
SupplierID,
null as ColorID,
UnitPackageID,
OuterPackageID,
null as Brand,
null as Size,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
null as Barcode,
TaxRate,
UnitPrice,
null as RecommendedRetailPrice,
TypicalWeightPerUnit,
null as MarketingComments,
null as InternalComments,
null as Photo,
null as CustomFields,
null as Tags,
concat([StockItemName],N' ') as SearchDetails,
1 as LastEditedBy,
getdate() as ValidFrom,
getdate() as ValidTo
from dbo.StockItems_v4) as sourse 
on
target.StockItemName = sourse.StockItemName
when matched 
THEN UPDATE set
target.StockItemID = sourse.StockItemID,
target.StockItemName = sourse.StockItemName,
target.SupplierID = sourse.SupplierID,
target.ColorID = sourse.ColorID,
target.UnitPackageID = sourse.UnitPackageID,
target.OuterPackageID = sourse.OuterPackageID,
target.Brand = sourse.Brand,
target.Size = sourse.Size,
target.LeadTimeDays = sourse.LeadTimeDays,
target.QuantityPerOuter = sourse.QuantityPerOuter,
target.IsChillerStock = sourse.IsChillerStock,
target.Barcode = sourse.Barcode,
target.TaxRate = sourse.TaxRate,
target.UnitPrice = sourse.UnitPrice,
target.RecommendedRetailPrice = sourse.RecommendedRetailPrice,
target.TypicalWeightPerUnit = sourse.TypicalWeightPerUnit,
target.MarketingComments = sourse.MarketingComments,
target.InternalComments = sourse.InternalComments,
target.Photo = sourse.Photo,
target.CustomFields = sourse.CustomFields,
target.Tags = sourse.Tags,
target.SearchDetails = sourse.SearchDetails,
target.LastEditedBy = sourse.LastEditedBy,
target.ValidFrom = sourse.ValidFrom,
target.ValidTo = sourse.ValidTo
when not matched 
then insert 
(StockItemID,
StockItemName,
SupplierID,
ColorID,
UnitPackageID,
OuterPackageID,
Brand,
Size,
LeadTimeDays,
QuantityPerOuter,
IsChillerStock,
Barcode,
TaxRate,
UnitPrice,
RecommendedRetailPrice,
TypicalWeightPerUnit,
MarketingComments,
InternalComments,
Photo,
CustomFields,
Tags,
SearchDetails,
LastEditedBy,
ValidFrom,
ValidTo
)
values (sourse.StockItemID,
sourse.StockItemName,
sourse.SupplierID,
sourse.ColorID,
sourse.UnitPackageID,
sourse.OuterPackageID,
sourse.Brand,
sourse.Size,
sourse.LeadTimeDays,
sourse.QuantityPerOuter,
sourse.IsChillerStock,
sourse.Barcode,
sourse.TaxRate,
sourse.UnitPrice,
sourse.RecommendedRetailPrice,
sourse.TypicalWeightPerUnit,
sourse.MarketingComments,
sourse.InternalComments,
sourse.Photo,
sourse.CustomFields,
sourse.Tags,
sourse.SearchDetails,
sourse.LastEditedBy,
sourse.ValidFrom,
sourse.ValidTo
);

Select * from dbo.StockItems_v3
--На этом решение задание №1 завершено.

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

--Моё решение 
--использую таблицу, которую создал из файла xml 
Select * from dbo.StockItems_v4

exec master..xp_cmdshell 'bcp "[WideWorldImporters].[dbo].[StockItems_v4]" out "C:\BCP\StockItems_hm.xml" -T -S  -F2 -c -t"~" -C ACP '

--EXEC sp_configure 'xp_cmdshell', 1;
--   RECONFIGURE;

--   EXEC sp_configure 'show advanced options', 1;
--   RECONFIGURE;
--   EXEC sp_configure 'xp_cmdshell', 1;
--   RECONFIGURE;

--DECLARE @sql NVARCHAR(4000), @filename NVARCHAR(200)

--SET @filename = '"C:\BCP\StockItems_hm.xml"'

--SET @sql = 
--'SELECT StockItemID,
--StockItemName,
--SupplierID,
--UnitPackageID,
--OuterPackageID,
--LeadTimeDays,
--QuantityPerOuter,
--IsChillerStock,
--TaxRate,
--UnitPrice,
--TypicalWeightPerUnit

--FROM dbo.StockItems_v4
--FOR XML AUTO, ELEMENTS, ROOT(''StockItemName'')'

--SET @sql = CONCAT('bcp "', @sql, '" queryout "', @filename, '" -S ' + @@servername )

--EXEC xp_cmdshell @sql

--SELECT N'Таблица успешно выгружена в файл XML: ' + @filename AS 'Результат'





/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

--Моё решение: 
Select * from Warehouse.StockItems --убедился что да, данные в CustomFields похожи на json.

--попытка взять что могу взять (моё основное решение)--
Select 
row_number () over (order by JSON_VALUE(CustomFields,'$.Tags[0]') asc) as [Порядковый номер],
JSON_VALUE(CustomFields,'$.CountryOfManufacture') as CountryOfManufacture,
JSON_VALUE(CustomFields,'$.Tags[0]') as Tags, -- тут я беру первое значение
JSON_VALUE(CustomFields,'$.Range') as Range
from Warehouse.StockItems
-------------------------------------------------------------------------------------------------
--нашел в интернете вариант сделать похожий запрос но с использованием openjson, пришлось немного "наколхозить"
SELECT 
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS value_1,
    tag.value AS value_2,
    JSON_VALUE(CustomFields, '$.Range') AS value_3
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') WITH (value NVARCHAR(100) '$') AS tag

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

-- моё решение:

Select * from Warehouse.StockItems

SELECT 
StockItemID,
StockItemName,
	STRING_AGG(Tags,',') as tags
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') WITH (value NVARCHAR(100) '$') AS tag
where Tag.value = 'Vintage'
group by
StockItemID,
StockItemName,
CustomFields,
value