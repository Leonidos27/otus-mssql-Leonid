/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO:

--Моё решение
;with temp1 (PersonID, FullName) as (select distinct PersonID, FullName from Application.People
where IsSalesperson = 1) 
Select t1.PersonID,t1.FullName from temp1 as t1
left join (select distinct SalespersonPersonID from Sales.Invoices where InvoiceDate = '20150704' ) as t2
on
t1.PersonID=t2.SalespersonPersonID
where t2.SalespersonPersonID is null





/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 

--Моё решение№1
with t1 as (
select top 10 StockItemID,Description, min(UnitPrice) as [Минимальная цена] from Sales.OrderLines
group by
StockItemID,
Description
order by
min(UnitPrice) asc)
Select * from t1

--Моё решение№2
select  distinct t1.StockItemID,t1.Description, t1.UnitPrice from Sales.OrderLines as t1
left join (select top 10 StockItemID, Description, min(UnitPrice) as [мингимальная цена] from Sales.OrderLines
group by
StockItemID, Description
order by
min(UnitPrice) asc
) as t2
on
t1.StockItemID=t2.StockItemID
where t2.StockItemID is not null






/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: 
--моё решение №1

;with t1 as (
Select 
CustomerID, 
CustomerTransactionID, 
TransactionAmount,
row_number() OVER (partition by CustomerID ORDER BY TransactionAmount DESC)  AS rating
from Sales.CustomerTransactions)
--order by 
--CustomerID asc ,
--TransactionAmount desc)
Select * from t1
where rating in (1,2,3,4,5)

--Моё решение №2

select 
t1.CustomerID, 
max(t1.TransactionAmount) as [Максимальный платеж],
t2.rating
from Sales.CustomerTransactions as t1
join (Select 
CustomerID, 
TransactionAmount,
row_number() OVER (partition by CustomerID ORDER BY TransactionAmount DESC)  AS rating
from Sales.CustomerTransactions) as t2
on
t1.CustomerID=t2.CustomerID
and
t1.TransactionAmount=t2.TransactionAmount
where 
t1.TransactionAmount > 0 and t2.rating in (1,2,3,4,5)
group by
t1.TransactionDate,
t1.CustomerID,
t2.rating
order by
t1.CustomerID asc,
max(t1.TransactionAmount) desc



/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO:
--моё решение

--Этап 1
Drop table if exists #temp_top3
;with t1 as (
Select 
Distinct StockItemID,
UnitPrice 
from Sales.OrderLines)
Select top 3 * into #temp_top3 from t1
order by 
UnitPrice desc 
--Этап 2
Select 
distinct t3.DeliveryCityID,
t4.CityName,
t5.CustomerName from Sales.OrderLines as t1
left join Sales.Orders as t2
on
t1.OrderID=t2.OrderID
left join Sales.Customers as t3
on
t2.CustomerID=t3.CustomerID
left join Application.Cities as t4
on
t3.DeliveryCityID=t4.CityID
left join Sales.Customers as t5
on
t3.CustomerID=t5.CustomerID
where StockItemID in (Select StockItemID from #temp_top3)
Drop table if exists #temp_top3


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SET STATISTICS IO, TIME ON
go
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm desc
SET STATISTICS IO, TIME off
go
-- --

TODO:

--1. Что возвращает данный запрос?
--Ответ: Данный скрипт возвращает перечень строк с информацию по ID заказа, 
--дате заказа, человека кто оформил заказ и Сумме всего заказа и сумме отобранного заказа , при этом выводится тольке та информация, 
--которая удовлетвряет условию SalesTotals > 27000. (то ест ьсумма заказа должна быть строго больше 27000), 
--при этом данные ранжируются от большего к меньшему по сумме заказа.

--К сожалению, никогда не сталкивался с оптимизацией запросов, 
--но имея в виду знания, что приобрел на занятиях, могу предпринять некоторые шаги:

--Моё решение: 

--with t1 as (
--SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems,
--OrderID
--FROM Sales.OrderLines
--group by
--OrderID )
--select * from t1
--;with t2 as (		
--SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
--	FROM Sales.InvoiceLines
--	GROUP BY InvoiceId)
--Select * from t2

--Используюя статистику клиента(то что смог найти, что бы хоть как-то отследить производительность), понял, что все мои попытки приводят только к усложнению запроса.

--предпринял попыту создать представление--
;CREATE VIEW dbo.Test_leo
as
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
--ORDER BY TotalSumm desc
go

SET STATISTICS IO, TIME ON
go
Select * from dbo.Test_leo
ORDER BY TotalSummByInvoice desc
SET STATISTICS IO, TIME off
go


--Результат от данных действий: 

--изначальный запрос отработал с показателями: 
 --Время работы SQL Server:
  --Время ЦП = 156 мс, затраченное время = 164 мс.

  --Запрос после добавления его в представление отработал быстее:
  --Время работы SQL Server:
   --Время ЦП = 156 мс, затраченное время = 152 мс.

-- если я правильно опнял, то в данном случа гонка осуществляется за показатель "затраченное время"", выгода составила 12 мс.
--Если говорить от лица простого пользователя, что первый вариант, что через "вьюху" запросы отрабатывают за 0 секунд на счетчике MS SQL внизу справа. 