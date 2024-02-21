/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "18 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

--Моё решение--


--Создаю функцию

--drop function if exists f_customer_with_the_highest_purchase_amount
Create function dbo.f_customer_with_the_highest_purchase_amount()
returns decimal (18,2) 
as begin 
declare @data_output decimal (18,2)
Select @data_output =
(Select top 1 sum(t1.UnitPrice * t1.Quantity) as [Сумма покупки]
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
group by
orderID
order by 
[Сумма покупки] desc)
return @data_output;
end;


Select  dbo.f_customer_with_the_highest_purchase_amount()  as [наибольшая сумма покупки]


--создаю процедуру
;Create proc p_customer_with_the_highest_purchase_amount
as 
Select top 1 sum(t1.UnitPrice * t1.Quantity) as [Сумма покупки],t2.OrderID 
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
group by
orderID
order by 
[Сумма покупки] desc 
;

--проверяю процедуру
EXEC p_customer_with_the_highest_purchase_amount

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

--Моё решение--

--Создаю функцию:

--drop function if exists dbo.f_sum_customer (@CustomerID int)
CREATE FUNCTION dbo.f_sum_customer (@CustomerID int)
RETURNS decimal(18,2)
AS
BEGIN
    DECLARE @TotalAmount decimal(18,2)

    SELECT @TotalAmount = SUM(t1.UnitPrice * t1.Quantity)
    FROM Sales.InvoiceLines AS t1
    LEFT JOIN Sales.Invoices AS t2 ON t1.InvoiceID = t2.InvoiceID
    WHERE t2.CustomerID = @CustomerID

    RETURN @TotalAmount
END

--Проверка функции--
Select dbo.f_sum_customer (21)

--Создаю процедуру:
drop proc if exists p_customer_with_the_highest_purchase_amount_2
;Create proc p_customer_with_the_highest_purchase_amount_2
@CustomerID  int
as
Select sum(t1.UnitPrice * t1.Quantity) as [Сумма покупки],t2.CustomerID
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
where t2.CustomerID = @CustomerID
group by
t2.CustomerID
order by 
[Сумма покупки] desc ;

--проверяем работу процедуры--
Exec p_customer_with_the_highest_purchase_amount_2 @CustomerID = 21


/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--создал процедуру--
drop proc if exists p_temp_proc
Create proc p_temp_proc
@OrderDate  date
as
Select top 1 sum(t1.UnitPrice * t1.Quantity) as [Сумма покупки]
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
left join sales.Orders as t3
on
t2.OrderID=t3.OrderID
where t3.OrderDate >= @OrderDate 
and 
t3.OrderDate < DATEADD(YEAR, -4, GETDATE()) and t3.OrderDate > DATEADD(YEAR, -15, GETDATE())
group by
t2.CustomerID,
t3.OrderDate
order by 
[Сумма покупки] asc ;
--провериол процедуру--
Exec p_temp_proc @OrderDate = '20140401'

--Создал функцию--
Drop FUNCTION if exists dbo.f_temp_proc
	

CREATE FUNCTION dbo.f_temp_proc (@OrderDate  date)
	

RETURNS decimal (18,2)

AS

BEGIN
    DECLARE @TotalAmount decimal(18,2)

SELECT @TotalAmount =  sum(t1.UnitPrice * t1.Quantity)
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
left join sales.Orders as t3
on
t2.OrderID=t3.OrderID
where t3.OrderDate >= @OrderDate 
and 
t3.OrderDate < DATEADD(YEAR, -4, GETDATE()) and t3.OrderDate > DATEADD(YEAR, -15, GETDATE())
group by
t2.CustomerID,
t3.OrderDate
order by 
sum(t1.UnitPrice * t1.Quantity) desc

    RETURN @TotalAmount
END;

Exec p_temp_proc @OrderDate = '20140401'
Select dbo.f_temp_proc('20140401')


--Процедура выполняется быстрее, так как план выполненя запроса записан (MS SQLне думает, при выполении а действует сразу) Функция работает немного дольше (так как данных не очень много просматривать), 
--но если данных было бы больше, то разница была бы более явной. 

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/



--Моё решение:
--созщдаю табличную функцию--
drop FUNCTION if exists dbo.testick  
 CREATE FUNCTION dbo.testick  
   (    
   
   @OrderID INT
   )
   
   RETURNS TABLE
   AS
   
   RETURN 
   (
        Select  sum(t1.UnitPrice * t1.Quantity) as [Сумма покупки],OrderID
from Sales.InvoiceLines as t1
left join Sales.Invoices as t2
on 
t1.InvoiceID=t2.InvoiceID
where t2.OrderID = @OrderID
group by
orderID
   )
   GO

--проверка табличной функции--
Select * from  dbo.testick (1)

--вывожу сумму всего заказа с помощью cross apply, без цикла. 
Select * from Sales.Invoices 
CROSS APPLY dbo.testick (OrderID)


--Дополнительное задание, указать уровень изоляции-- я очень плохо разбираюсь в этих нюансах, попробовал сам в какое-либо место вставить один из уровней ограничений ни чего не удалось.
--SQL Server имеет 4 уровня изоляции.

--1. READ UNCOMMITTED: означает, что транзакция в пределах текущей сессии может читать данные, которые модифицируются или удаляются другой транзакцией, но еще не зафиксированы. Этот уровень изоляции накладывает наименьшие ограничения, поскольку ядро базы данных не накладывает никаких разделяемых блокировок. В результате весьма вероятно, что транзакция прочитает данные, которые были вставлены, обновлены или удалены, но не будут зафиксированы в базе данных. Такой сценарий называется грязным чтением.

--2. READ COMMITTED: Это установка по умолчанию для большинства запросов SQL Server. Она определяет, что транзакция в текущем сеансе не может читать данные, которые были модифицированы другой транзакцией. Тем самым при этой установке предотвращается грязное чтение.

--3. REPEATABLE READ: С этой установкой транзакция не только может читать данные, которые зафиксированы другой модифицирующей транзакцией, но также накладывает ограничение, чтобы никакая другая транзакция не могла модифицировать данные, которые читаются, пока первая транзакция не завершит работу. Это устраняет проблему неповторяющихся чтений.

--4. SERIALIZABLE: Этим уровнем изоляции устанавливается множество свойств. Этот уровень изоляции является наиболее ограничительным по сравнению с другими, в результате чего могут возникнуть некоторые проблемы с производительностью при установке этого уровня. Вот упомянутые свойства:

--Текущая транзакция может читать только зафиксированные данные, модифицированные другой транзакцией данные.

--Другие транзакции ставятся в очередь ожидания пока первая транзакция не завершит выполнение.

--Никаким транзакциям не разрешается вставлять данные, которые отвечают условию текущей транзакции.
