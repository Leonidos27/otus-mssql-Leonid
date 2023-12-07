/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

напишите здесь свое решение

Select SI.StockItemID  from Warehouse.StockItems as SI
where StockItemName like '%urgent%' or LEFT(StockItemName,6)='Animal'
order by
StockItemID


--with SI as (
--select StockItemID,StockItemName from Warehouse.StockItems
--where StockItemName like '%urgent%' or LEFT(StockItemName,6)='Animal')
--Select t1.StockItemID from SI  as t1
--inner join Warehouse.StockItems as t2
--on
--t1.StockItemID=t2.StockItemID
--order by
--StockItemID


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

напишите здесь свое решение

with PS as (
Select t1.SupplierID,t1.SupplierName, count(t2.PurchaseOrderID) as [кол-во заказов] from Purchasing.Suppliers as t1
left join Purchasing.PurchaseOrders as t2
on
t1.SupplierID=t2.SupplierID
group by
t1.SupplierID,
t1.SupplierName)
Select * from PS
where [кол-во заказов] = 0


/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

напишите здесь свое решение



with AAP as (
Select 
t1.OrderID,t2.UnitPrice,t2.Quantity,t2.PickingCompletedWhen from Sales.Orders as t1
left join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
left join  Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID
where t1.PickingCompletedWhen is not null and t2.UnitPrice > 100 or t2.Quantity > 20)
Select --row_number() OVER (ORDER BY t1.OrderId) as nom,
t1.OrderID,
t1.OrderDate,
Datepart(month,t1.OrderDate) as [Месяц],
Datepart(QUARTER,t1.OrderDate) as [Квартал], 
case when Datepart(month,t1.OrderDate) = 1 then 1
when Datepart(month,t1.OrderDate) = 2 then 1
when Datepart(month,t1.OrderDate) = 3 then 1 
when Datepart(month,t1.OrderDate) = 4 then 1 
when Datepart(month,t1.OrderDate) = 5 then 2 
when Datepart(month,t1.OrderDate) = 6 then 2 
when Datepart(month,t1.OrderDate) = 7 then 2 
when Datepart(month,t1.OrderDate) = 8 then 2 
when Datepart(month,t1.OrderDate) = 9 then 3 
when Datepart(month,t1.OrderDate) = 10 then 3 
when Datepart(month,t1.OrderDate) = 11 then 3 
when Datepart(month,t1.OrderDate) = 12 then 3 else 'Error' end as [1/3 Года],--увы, но иначе, как решить данный вопрос мне неведома.
t3.CustomerName --INTO #TEST_2 
from  Sales.Orders as t1 
left join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
left join  Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID
right join AAP as t4
on
t1.OrderID=t4.OrderID
order by
--row_number() OVER (ORDER BY t1.OrderId) asc,
Datepart(QUARTER,t1.OrderDate) asc,
case when Datepart(month,t1.OrderDate) = 1 then 1
when Datepart(month,t1.OrderDate) = 2 then 1
when Datepart(month,t1.OrderDate) = 3 then 1 
when Datepart(month,t1.OrderDate) = 4 then 1 
when Datepart(month,t1.OrderDate) = 5 then 2 
when Datepart(month,t1.OrderDate) = 6 then 2 
when Datepart(month,t1.OrderDate) = 7 then 2 
when Datepart(month,t1.OrderDate) = 8 then 2 
when Datepart(month,t1.OrderDate) = 9 then 3 
when Datepart(month,t1.OrderDate) = 10 then 3 
when Datepart(month,t1.OrderDate) = 11 then 3 
when Datepart(month,t1.OrderDate) = 12 then 3 else 'Error' end asc,
t1.OrderDate asc




--Вариант 2(второй пункт подзадания)

with AAP as (
Select 
t1.OrderID,t2.UnitPrice,t2.Quantity,t2.PickingCompletedWhen from Sales.Orders as t1
left join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
left join  Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID
where t1.PickingCompletedWhen is not null and t2.UnitPrice > 100 or t2.Quantity > 20)
Select row_number() OVER (ORDER BY t1.OrderId) as nom,
t1.OrderID,
t1.OrderDate,
Datepart(month,t1.OrderDate) as [Месяц],
Datepart(QUARTER,t1.OrderDate) as [Квартал], 
case when Datepart(month,t1.OrderDate) = 1 then 1
when Datepart(month,t1.OrderDate) = 2 then 1
when Datepart(month,t1.OrderDate) = 3 then 1 
when Datepart(month,t1.OrderDate) = 4 then 1 
when Datepart(month,t1.OrderDate) = 5 then 2 
when Datepart(month,t1.OrderDate) = 6 then 2 
when Datepart(month,t1.OrderDate) = 7 then 2 
when Datepart(month,t1.OrderDate) = 8 then 2 
when Datepart(month,t1.OrderDate) = 9 then 3 
when Datepart(month,t1.OrderDate) = 10 then 3 
when Datepart(month,t1.OrderDate) = 11 then 3 
when Datepart(month,t1.OrderDate) = 12 then 3 else 'Error' end as [1/3 Года],--увы, но иначе, как решить данный вопрос мне неведома.
t3.CustomerName INTO #TEST_2 
from  Sales.Orders as t1 
left join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
left join  Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID
right join AAP as t4
on
t1.OrderID=t4.OrderID
order by
row_number() OVER (ORDER BY t1.OrderId) asc,
Datepart(QUARTER,t1.OrderDate) asc,
case when Datepart(month,t1.OrderDate) = 1 then 1
when Datepart(month,t1.OrderDate) = 2 then 1
when Datepart(month,t1.OrderDate) = 3 then 1 
when Datepart(month,t1.OrderDate) = 4 then 1 
when Datepart(month,t1.OrderDate) = 5 then 2 
when Datepart(month,t1.OrderDate) = 6 then 2 
when Datepart(month,t1.OrderDate) = 7 then 2 
when Datepart(month,t1.OrderDate) = 8 then 2 
when Datepart(month,t1.OrderDate) = 9 then 3 
when Datepart(month,t1.OrderDate) = 10 then 3 
when Datepart(month,t1.OrderDate) = 11 then 3 
when Datepart(month,t1.OrderDate) = 12 then 3 else 'Error' end asc,
t1.OrderDate asc


SELECT TOP 100 * FROM #TEST_2
WHERE nom  NOT between 1 AND 1000
ORDER BY 
nom ASC,
OrderID ASC,
OrderDate ASC,
Квартал ASC,
[1/3 Года] asc



/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

напишите здесь свое решение

--select t1.name,t2.name from sys.all_columns as t1
--left join sys.all_objects as t2
--on
--t1.object_id=t2.object_id
--where t1.name like '%PersonID%'

--К сожалению тут мне требуется помощь. Нет ясности по какому ключу соединять таблицы, чтобы получить релевантное значение ContactPerson.
--Данное задание не сделал(((

select t3.DeliveryMethodName,t2.ExpectedDeliveryDate, t1.SupplierName, t4.FullName from Purchasing.Suppliers as t1 
left join Purchasing.PurchaseOrders as t2
on
t1.SupplierID=t2.SupplierID
left join Application.DeliveryMethods as t3
on
t2.DeliveryMethodID=t3.DeliveryMethodID 
left join Application.People as t4
on
t2.ContactPersonID = t4.PersonID
and
t2.ContactPersonID=t4.PersonID
where datepart(month,t2.ExpectedDeliveryDate) = 1 and datepart(YEAR,t2.ExpectedDeliveryDate) = 2013
and t3.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight') and t2.IsOrderFinalized = 1
order by
t3.DeliveryMethodName,
t2.ExpectedDeliveryDate asc 


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

напишите здесь свое решение
--Имя коиента CustomerName
--Имя сотрудника SalespersonPerson

--Чувствую, что у меня проблема, я не понимаю как сделать задание (не зная в каких таблицах лежит информация и какой у них ключ соединения)
--Задание не сделал.

select t1.name,t2.name from sys.all_columns as t1
left join sys.all_objects as t2
on
t1.object_id=t2.object_id
where t1.name like '%SalespersonPerson%'

Select * from Sales.Orders
Select * from Sales.Invoices
Select * from Sales.InvoiceLines
Select * from Sales.Customers

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

напишите здесь свое решение

--Не понимаю от чего отталкиваться при решении, когда известны не все источники данных. 


