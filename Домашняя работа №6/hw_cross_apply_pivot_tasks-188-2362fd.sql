/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

--Моё решение


;select 
convert(varchar(10),InvoiceMonth, 105) as InvoiceMonth,
[Peeples Valley, AZ],
[Medicine Lodge, KS],
[Gasport, NY],	
[Sylvanite, MT],
[Jessie, ND]		
from
(Select 
--T1.CustomerName,
t2.OrderID,
REPLACE(left(stuff(T1.CustomerName,1,CHARINDEX(' (',T1.CustomerName)+1,''),CHARINDEX(')',stuff(T1.CustomerName,1,CHARINDEX(' (',T1.CustomerName)+1,''))-1),'','') as [CustomerName],
CAST(dateadd(mm,datediff(mm,0,T2.InvoiceDate),0) AS date) AS [InvoiceMonth],
YEAR(T2.InvoiceDate) AS [InvoiceYEAR]
from sales.Customers as t1
left join sales.Invoices as t2
on
t1.CustomerID=t2.CustomerID
where t1.CustomerID in (2,3,4,5,6)
group by
T1.CustomerName,T2.InvoiceDate,t2.OrderID) as target
pivot 
(COUNT(OrderID) for [CustomerName] in ([Peeples Valley, AZ],[Medicine Lodge, KS], [Gasport, NY],[Sylvanite, MT],	[Jessie, ND]))
as Pivot_king
order by
InvoiceYEAR,
InvoiceMonth


--Вопрос: 
--в моменте где мне нужно было вытащить название (в скобках) ....[CustomerName].... я прошел через боль и унижение. есть ли способ легче? (ибо длям на писание только этого момента я потратил минимум 1 час)
--Заранее спасибо! 






/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

--Моё решение
;select CustomerName,Customer_Name AS AddressLine from(
Select CustomerName,DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2    from sales.Customers
where CustomerName like '%Tailspin Toys%') as people
unpivot 
(Customer_Name for all_address in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2)) as unpiv


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

--Моё решение
SELECT CountryID,CountryName,Country_ID AS Code   FROM (
Select t1.CountryID, cast(t1.IsoAlpha3Code as varchar) AS IsoAlpha3Code,cast(t1.IsoNumericCode as varchar) AS IsoNumericCode, CountryName  from Application.Countries t1) as target
UNPIVOT 
(Country_ID FOR names IN (IsoAlpha3Code,IsoNumericCode)) as unpoiv

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--Моё решение

Select * from sales.Orders
Select * from sales.OrderLines
Select * from sales.Customers
Select * from sales.Invoices



--Неправильная попытка--
;with t1 as(
Select ORDERID, row_number() over ( partition by OrderID order by OrderID,StockItemID,UnitPrice desc ) as Rang, UnitPrice ,StockItemID,Description   from sales.OrderLines)
--Select * from t1
--where rang in (1,2) 
Select  t2.CustomerID,t2.CustomerName,o.StockItemID, o.Description, o.UnitPrice,t3.InvoiceDate from sales.Orders as t1
left join sales.Customers as t2
on
t1.CustomerID=t2.CustomerID
cross apply (select TOP 2 *  from  t1
where rang in (1,2) ) as o
LEFT JOIN sales.Invoices AS T3
on 
t1.OrderId=t3.OrderID
and
t2.CustomerID=t3.CustomerID




--Правильная попытка--
-- Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.

--Данное задание требует исключительного понимания join (что0бы правильно применить cross apply), я таковым на данный моемнт не обладаю, поэтому решено выполнить задание через временную таблицу.


drop table if exists  #temp_leo
Select 
T1.StockItemID,
t3.CustomerID,
t1.OrderID, 
T1.Description,
t1.UnitPrice,
t2.InvoiceDate, 
t3.CustomerName, 
concat(dense_rank() over( partition by t2.CustomerID order by t1.UnitPrice DESC ),
row_number()  over(partition by t1.OrderID,t2.CustomerID  order by t2.CustomerID,t1.OrderID, t2.InvoiceDate desc ) ) as [Агрегированный_ранг]
into #temp_leo from Sales.OrderLines AS T1
left JOIN Sales.Invoices  AS T2 
on
t1.OrderID=t2.OrderID
left join Sales.Customers as t3
on
t2.CustomerID=t3.CustomerID
where 
t2.InvoiceDate is not null 
select
CustomerID, 
CustomerName, 
StockItemID,
Description,
UnitPrice,
InvoiceDate
from  #temp_leo 
where 
Агрегированный_ранг in  (12 ,21)
order by 
CustomerID ASC