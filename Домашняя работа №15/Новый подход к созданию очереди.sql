--Новая попытка создания очереди в ms sql--

--поседние вводные (пояснение при проверке ДЗ):

--Леонид, еще раз перечитала ваше первое сообщение - вижу, что задание не понятно.
--вам еще нужны:
--таблица для хранения отчетов
--и 3 хп для реализации через очередь разговора об отчете:
--хп1 - отправляем сообщение - создайте нам отчет за такой-то период
--хп2 - получаем сообщение, создаем отчет за требуемый период и отправляем его инициатору разговора
--хп3 - инициатор получает отчет и записывает в таблицу инфу о получении

USE [WideWorldImporters];


select name, is_broker_enabled
from sys.databases;


ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT 


ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];


ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;


--alter table sales.Invoices add InvoiceConfirmedForProcessing datetime2  

--Создаем типы сообщений для reply and request сообщений

CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип)
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; --служит исключительно для проверки, что данные соответствуют типу XML(но можно любой тип) 

--Создаем контракт(определяем какие сообщения в рамках этого контракта допустимы)
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );


--Создаем очередь, как физический объект в БД--

--Создаем ОЧЕРЕДЬ таргета + создаем сервис для отправки и получения сообщений--

CREATE QUEUE TargetQueueWWI;
--и сервис таргета
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);

--то же для ИНИЦИАТОРА
CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);




--Блок создания процедур--

--1.
--Процедура которая кладет в очередь InvoiceID--
Create proc sales.SendNewInvoice
@invoiceID INT
as
begin 
set nocount on
Declare @1 uniqueidentifier
Declare @RequestMessage NVARCHAR(4000)

begin tran 

Select @RequestMessage = (Select * from sales.Invoices as Inv
where InvoiceID=@invoiceID for XML auto, root ('RequestMessage'));

--Select InvoiceID = (Select * from sales.Invoices as Inv
--where InvoiceID=2 for XML auto, root ('RequestMessage'));


BEGIN DIALOG @1
from service 
[//WWI/SB/InitiatorService]
to service 
'//WWI/SB/TargetService'
ON contract 
[//WWI/SB/Contract]
with encryption = OFF;

Send on  conversation @1
message TYPE 
[//WWI/SB/RequestMessage]
(@RequestMessage);

Select @RequestMessage as RequestMessage

Commit tran 

end 
GO 


--2. 

--Процедура получения сообщения--
create proc sales.GetNewInvoice
as
begin 

Declare 
@1 uniqueidentifier,
@Message NVARCHAR(4000),
@MessageType SysName,
@ReplyMessage NVARCHAR(4000),
@ReplyMessageName SysName,
@InvoiceID INT,
@xml XML;

Begin tran; 

Receive top (1)
@1 = conversation_handle,
@Message = Message_Body,
@MessageType = Message_Type_Name
from dbo.TargetQueueWWI;

Select @Message 

Set @XML = cast(@Message as XML)

Select @InvoiceID = R.Iv.value('@InvoiceID','INT') from @XML.nodes('/RequestMessage/Inv') as R(Iv)

If exists  (Select * from sales.Invoices where	InvoiceID = @InvoiceID)
Begin 

update sales.Invoices 
set InvoiceConfirmedForProcessing = getdate()
where InvoiceID=@InvoiceID;
End

Select @Message as ReceivedRequestMessage, @MessageType; 

If @MessageType = N'//WWI/SB/RequestMessage'
begin 
set 
@ReplyMessage = N'<ReplyMessage> Massege recived </ReplyMessage>';

Send on conversation @1
Message type 
[//WWI/SB/ReplyMessage]
(@ReplyMessage);
End conversation @1;
End

Select @ReplyMessage as SentReplyMessage ;

Commit tran;
End

--3.

create proc sales.ConfirmInvoice
as 
begin 

Begin tran 

declare @1 uniqueidentifier,
@ReplyReceivedMessage NVARCHAR(1000);

Receive  top (1) 
  @1 = conversation_handle
  , @ReplyReceivedMessage = Message_Body
   from dbo.InitiatorQueueWWI

   END conversation @1

   Select @ReplyReceivedMessage as ReplyReceivedMessage;
   commit tran 
   end;  
   GO


--Далее работаем с очередью--

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON --OFF=очередь НЕ доступна
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = on --OFF=очередь не активирует ХП(в PROCEDURE_NAME)(ставим на время исправления ХП, но с потерей сообщений)  
										              ,PROCEDURE_NAME = Sales.ConfirmInvoice
													  ,MAX_QUEUE_READERS = 0 --количество потоков(ХП одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП, без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = on 
									               ,PROCEDURE_NAME =  sales.GetcountOrders --Sales.GetNewInvoice
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO


--Тестируемся на примерах--

update sales.Invoices set InvoiceConfirmedForProcessing = null 

Select InvoiceID,InvoiceConfirmedForProcessing, * from sales.Invoices
where InvoiceID in (61210,61211,61212,61213)

--Отправляем сообщение--
Exec sales.SendNewInvoice
@invoiceID = 61211




Select InvoiceID from sales.Invoices as Inv
where InvoiceID = 61210
for XML auto , root ('RequestMessage')


--Смотрим, что в очередях--

Select cast(message_body as XML),* from dbo.TargetQueueWWI

Select cast(message_body as XML),* from dbo.InitiatorQueueWWI



--Теперь основная задача-- 

--Посчитать кол-во заказов orders по InvoiceID, который мы выполняем в Exec sales.SendNewInvoice.

--нужна процедура, которая будет работать в паре с Exec sales.SendNewInvoice.

--Создать процедуру для расчета кол-во заказов: + создаем табличку, куда это все будет складываться.

Create table dbo.HomeWork
(CustumerID int,
[Кол-во заказов] int
)


create proc sales.GetcountOrders
as
begin 

Declare 
@1 uniqueidentifier,
@Message NVARCHAR(4000),
@MessageType SysName,
@ReplyMessage NVARCHAR(4000),
@ReplyMessageName SysName,
@InvoiceID INT,
@xml XML;

Begin tran; 

Receive top (1)
@1 = conversation_handle,
@Message = Message_Body,
@MessageType = Message_Type_Name
from dbo.TargetQueueWWI;

Select @Message 

Set @XML = cast(@Message as XML)

Select @InvoiceID = R.Iv.value('@InvoiceID','INT') from @XML.nodes('/RequestMessage/Inv') as R(Iv)

if exists (Select count(t1.OrderID) as [Кол-во заказов]  from sales.Orders as t1 full join sales.Invoices as t2 on t1.CustomerID=t2.CustomerID where t2.InvoiceID = @InvoiceID )
Begin 

INSERT INTO dbo.HomeWork 
(CustumerID, [Кол-во заказов])
SELECT t1.CustomerID, COUNT(t1.OrderID) AS [Кол-во заказов]
FROM sales.Orders AS t1
FULL JOIN sales.Invoices AS t2 ON t1.CustomerID = t2.CustomerID
WHERE t2.InvoiceID = @InvoiceID
GROUP BY t1.CustomerID
End

Select @Message as ReceivedRequestMessage, @MessageType; 

If @MessageType = N'//WWI/SB/RequestMessage'
begin 
set 
@ReplyMessage = N'<ReplyMessage> Massege recived </ReplyMessage>'
;
Send on conversation @1
Message type 
[//WWI/SB/ReplyMessage]
(@ReplyMessage);
End conversation @1

Commit tran
end; 

Select @ReplyMessage as SentReplyMessage ;

Commit tran;
End


--Таблица в которую сохраняются результаты -- (через insert) 
Select * from  dbo.HomeWork


--Отправляем сообщение--
Exec sales.SendNewInvoice
@invoiceID = 61211


