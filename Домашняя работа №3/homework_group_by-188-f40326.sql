/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


Select 
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
datename(month,t1.InvoiceDate) as [Месяц продажи], 
convert(int,avg(t3.UnitPrice)) as [Средняя цена за месяц по всем товарам], 
convert(int,sum(t3.UnitPrice)) as [Общая сумма продаж за месяц] from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
--where Datepart(YEAR,t1.InvoiceDate) = 2015 and Datepart(month,t1.InvoiceDate)=4 --можно включить данную опцию
group by
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)
order by
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)



/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


Select 
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
Datename(month,t1.InvoiceDate) as [Месяц продажи], 
convert(int,sum(t3.UnitPrice)) as [Общая сумма продаж за месяц] from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
--where Datepart(YEAR,t1.InvoiceDate) = 2015 and Datepart(month,t1.InvoiceDate)=4 --можно включить данную опцию
group by
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)
having sum(t3.UnitPrice) > '4600000'
order by
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/


Select 
t3.Description as [Наименование товара],
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
Datename(month,t1.InvoiceDate) as [Месяц продажи], 
t3.UnitPrice as [Общая сумма продаж за месяц],
t1.InvoiceDate as [Дата первой продажи],
t3.Quantity as [Кол-во продонного товара] into #test_1 from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
group by 
t3.Description,
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate),
t3.UnitPrice,
t1.InvoiceDate,
t3.Quantity

Select 
distinct [Наименование товара], 
[Год продажи],
[Месяц продажи], 
sum([Общая сумма продаж за месяц]) as [Общая сумма продаж за месяц],
min([Дата первой продажи]) [дата первой рподажи],
[Кол-во продонного товара] as [Кол-во продонного товара]  from #test_1
where [Кол-во продонного товара] < 50
group by
[Наименование товара], 
[Год продажи],
[Месяц продажи],
[Кол-во продонного товара]
order by
[Год продажи] asc,
[Месяц продажи] asc


--Попытка сделать задание правильно (согласо требований)--

--3. Вывести сумму продаж, дату первой продажи
--и количество проданного по месяцам, по товарам,
--продажи которых менее 50 ед в месяц.
--Группировка должна быть по году,  месяцу, товару.

--Вывести:
--* Год продажи
--* Месяц продажи
--* Наименование товара
--* Сумма продаж
--* Дата первой продажи
--* Количество проданного

--Продажи смотреть в таблице Sales.Invoices и связанных таблицах.

--Select 
--t3.Description as [Наименование товара],
--Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
--Datename(month,t1.InvoiceDate) as [Месяц продажи], 
--sum(t3.UnitPrice) as [Общая сумма продаж за месяц],
--min(t1.InvoiceDate) as [Дата первой продажи],
--sum(t3.Quantity) as [Кол-во продонного товара] from Sales.Invoices as t1
--left join Sales.Orders as t2
--on
--t1.CustomerID=t2.CustomerID
--left join Sales.OrderLines as t3
--on
--t2.OrderID=t3.OrderID
--group by 
--t3.Description,
--Datepart(YEAR,t1.InvoiceDate),
--Datename(month,t1.InvoiceDate)
--having (case when sum(t3.Quantity) < 50 then 1 else 0 end) = 1
--order by
--Datepart(YEAR,t1.InvoiceDate) asc,
--Datename(month,t1.InvoiceDate) asc

--Select * from Sales.Invoices
--Select * from Sales.Orders
--Select * from Sales.OrderLines

--Моё решение:

Select 
t3.Description as [Наименование товара],
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
Datename(month,t1.InvoiceDate) as [Месяц продажи], 
sum(t3.UnitPrice) as [Общая сумма продаж за месяц],
min(t1.InvoiceDate) as [Дата первой продажи],
sum(t3.Quantity) as [Кол-во продонного товара] from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
and t1.OrderID=t2.OrderID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
--where sum(t3.Quantity) < 50 
group by 
t3.Description,
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)--,
--t3.Quantity--,
--t3.UnitPrice 
having sum(t3.Quantity) < 50 
order by
t3.Description,
Datepart(YEAR,t1.InvoiceDate) asc,
Datename(month,t1.InvoiceDate) asc


-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

--повторяю запрос задани№3 (с нулями)
Select 
t3.Description as [Наименование товара],
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
Datename(month,t1.InvoiceDate) as [Месяц продажи], 
t3.UnitPrice as [Общая сумма продаж за месяц],
MIN(t1.InvoiceDate) as [Дата первой продажи],
t3.Quantity as [Кол-во продонного товара] into #test_2 
from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
group by 
t3.Description,
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate),
t3.UnitPrice,
t1.InvoiceDate,
t3.Quantity


Select 
distinct [Наименование товара], 
[Год продажи],
[Месяц продажи], 
sum([Общая сумма продаж за месяц]) as [Общая сумма продаж за месяц],
min([Дата первой продажи]) [дата первой рподажи],
[Кол-во продонного товара] as [Кол-во продонного товара]  from #test_2
where [Кол-во продонного товара] < 50
group by rollup
([Наименование товара], 
[Год продажи],
[Месяц продажи],
[Кол-во продонного товара])



--повторяю запрос задани№2 (с нулями)


Select 
Datepart(YEAR,t1.InvoiceDate) as [Год продажи],
Datename(month,t1.InvoiceDate) as [Месяц продажи], 
convert(int,sum(t3.UnitPrice)) as [Общая сумма продаж за месяц] from Sales.Invoices as t1
left join Sales.Orders as t2
on
t1.CustomerID=t2.CustomerID
left join Sales.OrderLines as t3
on
t2.OrderID=t3.OrderID
--where Datepart(YEAR,t1.InvoiceDate) = 2015 and Datepart(month,t1.InvoiceDate)=4 --можно включить данную опцию
group by rollup (
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate))
having sum(t3.UnitPrice) > '4600000'
order by
Datepart(YEAR,t1.InvoiceDate),
Datename(month,t1.InvoiceDate)