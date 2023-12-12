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

--проблема "задвойки заказа, точнее затройка" в итоговом ответе, появляется она из таблицы Sales.OrderLines, так как под условия подпадают 3 товара находящиеся в заказе. Ищем решение.... 
Select * from Sales.Orders --тут заказы
where CustomerID = 105 and orderID = 47
Select * from Sales.OrderLines --тут цена тоавара
where orderID = 47
Select * from Sales.Customers
where CustomerID = 105
--------------------------
--Само решение по заданию №3

Select 
distinct t1.OrderID,
convert(nvarchar,t1.OrderDate, 103) as OrderDate,
datename(month,t1.OrderDate) as [Месяц],
Datepart(QUARTER,t1.OrderDate) as [Квартал], 
case when Datepart(month,t1.OrderDate) in (1,2,3,4) then 1
when Datepart(month,t1.OrderDate) in (5,6,7,8) then 2
when Datepart(month,t1.OrderDate) in (9,10,11,12) then 3 else 'Error' end as [1/3 Года],
t3.CustomerName 
from  Sales.Orders as t1 
right join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
inner join Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID 
where (t2.UnitPrice > 100 or t2.Quantity > 20) and t1.PickingCompletedWhen is not null
order by
t1.OrderID,
convert(nvarchar,t1.OrderDate, 103) asc,
datename(month,t1.OrderDate),
Datepart(QUARTER,t1.OrderDate) asc,
case when Datepart(month,t1.OrderDate) in (1,2,3,4) then 1
when Datepart(month,t1.OrderDate) in (5,6,7,8) then 2
when Datepart(month,t1.OrderDate) in (9,10,11,12) then 3 
else 'Error' end asc

--проблема с задвойками заказов по вышеуказанной причине решена (проверяя все элементы тыблицы Sales.OrderLines на удовлетворение 
--условию where (t2.UnitPrice > 100 or t2.Quantity > 20) and t1.PickingCompletedWhen is not null автоматически приводит к задвойке.
--Данная проблема решается distinct, я ставлю уникальность в разерез OrderID , все остальное подтягивается релевантное. 

--Вариант запроса 2 (с постраничной выборкой)


Declare 
@pagesize bigint = 100,
@pagenum bigint = 11

Select 
distinct t1.OrderID,
convert(nvarchar,t1.OrderDate, 103) as OrderDate,
datename(month,t1.OrderDate) as [Месяц],
Datepart(QUARTER,t1.OrderDate) as [Квартал], 
case when Datepart(month,t1.OrderDate) in (1,2,3,4) then 1
when Datepart(month,t1.OrderDate) in (5,6,7,8) then 2
when Datepart(month,t1.OrderDate) in (9,10,11,12) then 3 else 'Error' end as [1/3 Года],
t3.CustomerName 
from  Sales.Orders as t1 
right join Sales.OrderLines as t2 
on
t1.OrderID=t2.OrderID
inner join Sales.Customers as t3
on
t1.CustomerID=t3.CustomerID 
where (t2.UnitPrice > 100 or t2.Quantity > 20) and t1.PickingCompletedWhen is not null
order by
t1.OrderID,
convert(nvarchar,t1.OrderDate, 103) asc,
datename(month,t1.OrderDate),
Datepart(QUARTER,t1.OrderDate) asc,
case when Datepart(month,t1.OrderDate) in (1,2,3,4) then 1
when Datepart(month,t1.OrderDate) in (5,6,7,8) then 2
when Datepart(month,t1.OrderDate) in (9,10,11,12) then 3 
else 'Error' end asc
OFFSET (@pagenum - 1) * @pagesize rows fetch next @pagesize rows only




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

--Имя коиента CustomerName
--Имя сотрудника SalespersonPerson


Select top 10 t1.InvoiceID, t2.CustomerName , t4.FullName  from Sales.Invoices as t1
left join Sales.Customers as t2 
on
t1.CustomerID=t2.CustomerID
left join Sales.Orders as t3
on
t1.OrderID=t3.OrderID
left join Application.People as t4
on t2.PrimaryContactPersonID=t4.PersonID
group by
t2.CustomerName, t4.FullName,t1.InvoiceID
order by
min(t3.OrderDate) DESC





/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

--select * from Sales.Customers
--select * from Warehouse.StockItems -- тут лежит товар
--select * from Application.People -- тут то, что нужно вытащить по условию
--select * from Sales.Invoices -- ID покупки и OrderID
--select * from sales.OrderLines -- nen OrderID + StockItemId чтобы связаться с Warehouse.StockItems

Select distinct t1.PersonID, t1.FullName, t1.PhoneNumber from Application.People as t1
left join Sales.Invoices as t2
on
t1.PersonID=t2.ContactPersonID
left join sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
left join Warehouse.StockItems as t4
on
t3.StockItemID=t4.StockItemID
where t4.StockItemName = 'Chocolate frogs 250g'
