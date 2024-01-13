/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

--Моё решение: 
--Select count(*) from sales.Invoices --70510
--Select count(*) from Application.People --1111
--Select count(*) from sales.OrderLines --231412
--Select count(*) from sales.Orders -- 73595

set statistics time, io on
;with t1 as (
SELECT  SI.InvoiceID as [id продажи], AP.Fullname as [Название клиента],
sum(SOL.Quantity * SOL.UnitPrice) as [Сумма_продажи],
--concat(datename(month,SI.InvoiceDate),' ',datename(YEAR,SI.InvoiceDate)) as [Месяц_Год],
SI.InvoiceDate as [дата продажи] 
FROM sales.OrderLines as SOL
right join sales.Invoices as SI
on
SOL.OrderID=SI.OrderID
left join Application.People as AP
on
SI.ContactPersonID = AP.PersonID
where SI.InvoiceDate >= '20150101'
Group by
SI.InvoiceDate,
AP.Fullname,
SI.InvoiceID--,
--concat(datename(month,SI.InvoiceDate),' ',datename(YEAR,SI.InvoiceDate))
)
Select s.*, (select coalesce(sum(t2.Сумма_продажи),0) as [Total]  from t1 t2
where t2.[дата продажи]<=s.[дата продажи]) as total
from t1 as s
order by s.[дата продажи]
set statistics time, io OFF


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
--Моё решение: 

set statistics time, io on
--drop table if exists #temp_1
SELECT  SI.InvoiceID as [id продажи], AP.Fullname as [Название клиента],
sum(SOL.Quantity * SOL.UnitPrice) as [Сумма_продажи],
SUM(sum(SOL.Quantity * SOL.UnitPrice)) over( ORDER BY SI.InvoiceDate) AS [Сумма_продажи_TOTAL],
SI.InvoiceDate as [дата продажи]
--into #temp_1
FROM sales.OrderLines as SOL
right join sales.Invoices as SI
on
SOL.OrderID=SI.OrderID
left join Application.People as AP
on
SI.ContactPersonID = AP.PersonID
where SI.InvoiceDate >= '20150101'
Group by
SI.InvoiceDate,
AP.Fullname,
SI.InvoiceID
set statistics time, io OFF


--Вывод: 
--В данном конкретном случае прирост производительности запроса - 100 раз, стоимость первого запроса 100% , 
--стоимость второго (через оконную функцию - 1%)
--Если говорить о производительности через set statistics time, io on, то:
--первый запрос затратил Время ЦП = 201594 мс, затраченное время = 236862 мс.
--второй запрос затратил  Время ЦП = 203 мс, затраченное время = 1297 мс.

--Прирост производитлельности налицо. 


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

--Моё решение:
;WITH T1 AS(
Select 
SOL.Description as [Название продукта],
month(SI.InvoiceDate) as [Месяц],
sum(SOL.Quantity) as [Кол-во проджанных штук],
row_number() over (partition by month(SI.InvoiceDate)
order by month(SI.InvoiceDate) asc,sum(SOL.Quantity)desc) as [rang]
from sales.OrderLines as SOL
right join sales.Invoices as SI
on 
SOL.OrderID=SI.OrderID
where year(SI.InvoiceDate) = '2016' 
group by
month(SI.InvoiceDate),
SOL.Description,
SOL.Quantity)
SELECT * FROM T1
WHERE 
RANG IN (1,2)
--order by
--month(SI.InvoiceDate) asc,
--sum(SOL.Quantity) desc 



/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
--Моё регшение: 
--select * from Warehouse.Colors
--Select * from Warehouse.StockItems
--Select * from sales.OrderLines

Select 
t1.StockItemID as [ид товара], 
t1.StockItemName AS [название],
t1.Brand as [брэнд],
t1.UnitPrice AS [цена],
row_number() over( order by left(t1.StockItemName,1) asc ) as [*1],
ROWCOUNT_BIG() as [*2],
count((LEFT(trim(case 
when left(t1.StockItemName,8)='"The Gu"' then REPLACE(t1.StockItemName, '"The Gu"','') 
when left(t1.StockItemName,5)='10 mm ' then REPLACE(t1.StockItemName, '10 mm ','')
when left(t1.StockItemName,5)='20 mm ' then REPLACE(t1.StockItemName, '20 mm ','')
when left(t1.StockItemName,5)='32 mm ' then REPLACE(t1.StockItemName, '32 mm ','')
when left(t1.StockItemName,4)='3 kg ' then REPLACE(t1.StockItemName, '3 kg ','')
ELSE t1.StockItemName
end ),1) )) over( partition by (LEFT(trim(case 
when left(t1.StockItemName,8)='"The Gu"' then REPLACE(t1.StockItemName, '"The Gu"','') 
when left(t1.StockItemName,5)='10 mm ' then REPLACE(t1.StockItemName, '10 mm ','')
when left(t1.StockItemName,5)='20 mm ' then REPLACE(t1.StockItemName, '20 mm ','')
when left(t1.StockItemName,5)='32 mm ' then REPLACE(t1.StockItemName, '32 mm ','')
when left(t1.StockItemName,4)='3 kg ' then REPLACE(t1.StockItemName, '3 kg ','')
ELSE t1.StockItemName
end ),1) ) order by (LEFT(trim(case 
when left(t1.StockItemName,8)='"The Gu"' then REPLACE(t1.StockItemName, '"The Gu"','') 
when left(t1.StockItemName,5)='10 mm ' then REPLACE(t1.StockItemName, '10 mm ','')
when left(t1.StockItemName,5)='20 mm ' then REPLACE(t1.StockItemName, '20 mm ','')
when left(t1.StockItemName,5)='32 mm ' then REPLACE(t1.StockItemName, '32 mm ','')
when left(t1.StockItemName,4)='3 kg ' then REPLACE(t1.StockItemName, '3 kg ','')
ELSE t1.StockItemName
end ),1) )) as [*3],
lead(t1.StockItemID) over( order by t1.StockItemName asc ) as [*4],
lag(t1.StockItemID) over( order by t1.StockItemName asc ) as [*5],
lag(t1.StockItemName,2,'No items') over( order by t1.StockItemName asc ) as [*6], --туту я не понял как должно работать (в том виде, как написал я - не работает) 
NTILE(30) over ( order by TypicalWeightPerUnit desc) as [*7]
from Warehouse.StockItems as t1

--работа над ошибками от 12.01.2024

Select 
t1.StockItemID as [ид товара], 
t1.StockItemName AS [название],
t1.Brand as [брэнд],
t1.UnitPrice AS [цена],
row_number() over( order by left(t1.StockItemName,1) asc ) as [*1],
--ROWCOUNT_BIG() as [*2],
count(*) over( ) as [*2],
count(LEFT(t1.StockItemName,1)) over ( partition by LEFT(t1.StockItemName,1) order by LEFT(t1.StockItemName,1)) as [*3], -- исправлено
lead(t1.StockItemID) over( order by t1.StockItemName asc ) as [*4],
lag(t1.StockItemID) over( order by t1.StockItemName asc ) as [*5],
lag(t1.StockItemName,2,'No items') over( order by t1.StockItemName asc ) as [*6], --туту я не понял как должно работать (в том виде, как написал я - не работает) 
NTILE(30) over ( order by TypicalWeightPerUnit desc) as [*7]
from Warehouse.StockItems as t1


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

--Моё решение: 

--Select * from Application.People
--Select * from Purchasing.PurchaseOrders
--Select * from Sales.Customers
--Select * from Sales.Orders
--Select * from Sales.Invoices
--Select * from Sales.OrderLines

;with u1 as (
Select 
t1.CustomerID, 
t1.CustomerName, 
t3.ContactPersonID,
t4.FullName,
t3.InvoiceDate,
sum(t5.Quantity* t5.UnitPrice) as [сумму сделки],
row_number() over( partition by t1.CustomerID order by t3.InvoiceDate desc) as rang
from Sales.Customers as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.Invoices as t3
on
t2.CustomerID=t3.CustomerID
and 
t2.OrderID=t3.OrderID
left join Application.People as t4
on
t3.ContactPersonID=t4.PersonID
left join Sales.OrderLines as t5
on
t2.OrderID=t5.OrderID
where --t1.CustomerID = 807 and 
t3.ContactPersonID is not null
group by
t1.CustomerID, t1.CustomerName, t3.ContactPersonID,t4.FullName,t3.InvoiceDate
--order by 
--sum(t5.Quantity* t5.UnitPrice)  desc )
)
Select 
CustomerID,CustomerName,ContactPersonID,FullName,InvoiceDate,[сумму сделки]
from u1
where rang = 1


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

--Моё решение: 

--Select * from Application.People
--Select * from Purchasing.PurchaseOrders
--Select * from Sales.Orders
--Select * from Sales.Invoices
--Select * from Sales.OrderLines
--order by 
--OrderID,
--OrderLineID



;WITH u1 as (
Select 
t3.PersonID,
t3.FullName,
t2.StockItemID,
t2.Description,
t2.UnitPrice,
t4.InvoiceDate, 
t2.Ранг_стоимости_товара from Sales.Orders as t1 
left join  (Select 
OrderID,
StockItemID, 
Description ,
UnitPrice, 
row_number() over ( partition by  OrderID ORDER  by UnitPrice) as [Ранг_стоимости_товара] 
from Sales.OrderLines) as t2
on
t1.OrderID=t2.OrderID
left join Application.People as t3
on
t1.ContactPersonID=t3.PersonID
left join Sales.Invoices as t4
on 
t4.CustomerID=t1.CustomerID
and 
t4.OrderID=t1.OrderID)
Select PersonID as [ид клиета],
FullName AS [Имя клиента],
StockItemID as [ид товара],
Description as [Название товара],
UnitPrice as [Цена товара],
InvoiceDate as [Дата покупки] from u1
where Ранг_стоимости_товара in (1,2)


-- Работан над ошибками 
-- предпринимаю попытку полного перестроения запроса, так как то, что сделал в первый раз никак не потдается исправлению. не работает окно--

--Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.

Select * from Sales.Orders
Select * from Sales.OrderLines
order by
OrderID asc ,
OrderLineID
Select * from Sales.Invoices
Select * from Application.People


;with t1 as (
Select 
DISTINCT t1.OrderLineID, 
t2.CustomerID,
t1.OrderID, 
T1.StockItemID,
T1.Description,
t1.UnitPrice,
t2.InvoiceDate,
row_number() over( partition by t2.CustomerID order by t1.UnitPrice DESC  ) as [Ранг_1]
from Sales.OrderLines AS T1
left JOIN Sales.Invoices  AS T2 
on
t1.OrderID=t2.OrderID
)
--select * from t1 as u1
--left join  (select PersonID, FullName from Application.People) as t3
--on PersonID=t3.PersonID
--LEFT JOIN (select OrderID,CustomerID from Sales.Orders) AS T4
--ON
--U1.OrderID =T4.OrderID
--and t4.CustomerID=u1.CustomerID
--where Ранг_1 in  (1, 2) and t4.CustomerID = 832
--order by UnitPrice desc




--Первая часть
;with t1 as (
Select 
--t1.OrderID, 
--t1.OrderLineID, 
T1.StockItemID,
T1.Description,
t1.UnitPrice,
t3.InvoiceDate,
t3.CustomerID,
max(t1.UnitPrice)over (order by t3.CustomerID )  as [ранг_1],
case 
when max(t1.UnitPrice) over (order by t3.CustomerID) = t1.UnitPrice then  1 else 0 end as Проверка
from Sales.OrderLines AS T1
left join Sales.Orders as t2
on
t1.OrderID=t2.OrderID
left JOIN Sales.Invoices  AS T3
on
t1.OrderID=t3.OrderID
and
t2.CustomerID=t3.CustomerID
left join Application.People as t4
on
t3.ContactPersonID=t4.PersonID
where t3.CustomerID = 832
group by
T1.StockItemID,
T1.Description,
t1.UnitPrice,
t3.InvoiceDate,
t3.CustomerID)
--order by UnitPrice desc
select  * from t1
where Проверка = 1 


--работа над ошибками от 12.01.2024

--Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.

;with t1 as (
Select 
--t1.OrderLineID, 
T1.StockItemID,
t2.CustomerID,
t1.OrderID, 
T1.Description,
t1.UnitPrice,
t2.InvoiceDate,
t3.PersonID, 
t3.FullName, 
--row_number() over( partition by t2.CustomerID order by t1.UnitPrice DESC  ) as [Ранг_1],
dense_rank() over( partition by t2.CustomerID order by t1.UnitPrice DESC ) as [Ранг_ценовой],
row_number()  over(partition by t1.OrderID,t2.CustomerID  order by t2.CustomerID,t1.OrderID, t2.InvoiceDate desc ) as [Ранг_даты],
--row_number() over( partition by t1.OrderID order by t1.UnitPrice DESC ) as [Ранг_заказ]--,
concat(dense_rank() over( partition by t2.CustomerID order by t1.UnitPrice DESC ),row_number()  over(partition by t1.OrderID,t2.CustomerID  order by t2.CustomerID,t1.OrderID, t2.InvoiceDate desc ) ) as [Агрегированный_ранг]
from Sales.OrderLines AS T1
left JOIN Sales.Invoices  AS T2 
on
t1.OrderID=t2.OrderID
left join Application.People as t3
on
t2.ContactPersonID=t3.PersonID
where 
t2.InvoiceDate is not null -- своего рода нормализация данных
--and CustomerID = 832 
)
select
PersonID, 
FullName, 
StockItemID,
Description,
UnitPrice,
CustomerID
from t1 
where 
Агрегированный_ранг in  (12 ,21)
--and CustomerID = 832


--работа над ошибками от 14.01.2024
--до изменений возвращается 941 строка

;with t1 as 
(
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
from Sales.OrderLines AS T1
left JOIN Sales.Invoices  AS T2 
on
t1.OrderID=t2.OrderID
left join Sales.Customers as t3
on
t2.CustomerID=t3.CustomerID
where 
t2.InvoiceDate is not null -- своего рода нормализация данных
--and t3.CustomerID = 832 
)
select
CustomerID, 
CustomerName, 
StockItemID,
Description,
UnitPrice,
InvoiceDate
from t1 
where 
Агрегированный_ранг in  (12 ,21)
--and CustomerID = 832
order by 
CustomerID asc 

--после изменений возвращается 941 строка
--Мой комментарий, в отношении join я описал на сайте, где мы с Вами переписываемся. 