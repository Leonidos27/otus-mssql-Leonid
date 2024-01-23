--Описание/Пошаговая инструкция выполнения домашнего задания:
--1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers
--2. Удалите одну запись из Customers, которая была вами добавлена
--3. Изменить одну запись, из добавленных через UPDATE
--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert

--Решение домашней работы:

--1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers
--1. Моё решение 

Use WideWorldImporters

Select * into sales.Customers_v2 from sales.Customers --создаю дуль таблицы (для решения задания)

--SET IDENTITY_INSERT sales.Customers ON

insert into sales.Customers_v2 
(CustomerID,
CustomerName,
BillToCustomerID,
CustomerCategoryID,
BuyingGroupID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
CreditLimit,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
DeliveryRun,
RunPosition,
WebsiteURL,
DeliveryAddressLine1,
DeliveryAddressLine2,
DeliveryPostalCode,
DeliveryLocation,
PostalAddressLine1,
PostalAddressLine2,
PostalPostalCode,
LastEditedBy,
ValidFrom,
ValidTo
)
values 
(1062, N'Маслов Леонид', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1063, N'Егоров Станислав', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1064, N'Травкин Денис', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1065, N'Фон Штирлиц', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1066, N'Капитан Америка', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE())


--2. Удалите одну запись из Customers, которая была вами добавлена
--2. Моё решение 

Delete from sales.Customers_v2 
where CustomerID in (1062,1063,1064,1065,1066) --удаляю строки, что добавил в первом пункте задания. 
Select @@ROWCOUNT AS [Сколько удалилось строк]

--3. Изменить одну запись, из добавленных через UPDATE
--3. Моё решение 
--Для проверки задани (нужно выполнить insert из первого задания (я удалил все строки, что добавил) 

update sales.Customers_v2
set 
CustomerName = N'Маслов Леонид Михайлович'
where CustomerID = 1062

sELECT * FROM sales.Customers_v2
WHERE CustomerID = 1062


--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
--4. Моё решение 

--План действи: 
--1. Сделаю дополнительную табличку с 5-ю уже придуманными мной строками + 
--добавлю туда нову, которой нет в табличке sales.Customers_v2, но при этом изменю  одной уже существующую строку 
--2. Далее сделаю мердж, где добавится 1строка а остальные просто сравнятся и останутся таковыми. 

--Создаю табличку sourse (как источник для мерджа)

Select * into sales.Customers_sourse from sales.Customers_v2
where CustomerID in (1062,1063,1064,1065,1066)

Select * from sales.Customers_sourse -- проверили, что все нормально
--проведу некоторые изменения (поправлю customerID = 1062 ( Назову себя просто Маслов Леонид), но в таблице target ничего не поменяю, это должно будет измениться в результате мерджа.

update sales.Customers_sourse
set 
CustomerName = N'Маслов Леонид'
where CustomerID = 1062

--добавлю строчку в sourse

--insert into sales.Customers_sourse
--(CustomerID,
--CustomerName,
--BillToCustomerID,
--CustomerCategoryID,
--BuyingGroupID,
--PrimaryContactPersonID,
--AlternateContactPersonID,
--DeliveryMethodID,
--DeliveryCityID,
--PostalCityID,
--CreditLimit,
--AccountOpenedDate,
--StandardDiscountPercentage,
--IsStatementSent,
--IsOnCreditHold,
--PaymentDays,
--PhoneNumber,
--FaxNumber,
--DeliveryRun,
--RunPosition,
--WebsiteURL,
--DeliveryAddressLine1,
--DeliveryAddressLine2,
--DeliveryPostalCode,
--DeliveryLocation,
--PostalAddressLine1,
--PostalAddressLine2,
--PostalPostalCode,
--LastEditedBy,
--ValidFrom,
--ValidTo
--)
--values 
--(1067, N'Гениальный пёсель', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE())

--непосредственно мердж --

;Merge sales.Customers_v2 as target
using 
(select 
CustomerID,
CustomerName,
BillToCustomerID,
CustomerCategoryID,
BuyingGroupID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
CreditLimit,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
DeliveryRun,
RunPosition,
WebsiteURL,
DeliveryAddressLine1,
DeliveryAddressLine2,
DeliveryPostalCode,
DeliveryLocation,
PostalAddressLine1,
PostalAddressLine2,
PostalPostalCode,
LastEditedBy,
ValidFrom,
ValidTo from sales.Customers_sourse) as sourse 
on
target.CustomerID = sourse.CustomerID
when matched 
THEN UPDATE set
target.CustomerID = sourse.CustomerID,
target.CustomerName = sourse.CustomerName,
target.BillToCustomerID = sourse.BillToCustomerID,
target.CustomerCategoryID=sourse.CustomerCategoryID,
target.BuyingGroupID=sourse.BuyingGroupID,
target.PrimaryContactPersonID=sourse.PrimaryContactPersonID,
target.AlternateContactPersonID=sourse.AlternateContactPersonID,
target.DeliveryMethodID=sourse.DeliveryMethodID,
target.DeliveryCityID=sourse.DeliveryCityID,
target.PostalCityID=sourse.PostalCityID,
target.CreditLimit=sourse.CreditLimit,
target.AccountOpenedDate=sourse.AccountOpenedDate,
target.StandardDiscountPercentage=sourse.StandardDiscountPercentage,
target.IsStatementSent=sourse.IsStatementSent,
target.IsOnCreditHold=sourse.IsOnCreditHold,
target.PaymentDays=sourse.PaymentDays,
target.PhoneNumber=sourse.PhoneNumber,
target.FaxNumber=sourse.FaxNumber,
target.DeliveryRun=sourse.DeliveryRun,
target.RunPosition=sourse.RunPosition,
target.WebsiteURL=sourse.WebsiteURL,
target.DeliveryAddressLine1=sourse.DeliveryAddressLine1,
target.DeliveryAddressLine2=sourse.DeliveryAddressLine2,
target.DeliveryPostalCode=sourse.DeliveryPostalCode,
target.DeliveryLocation=sourse.DeliveryLocation,
target.PostalAddressLine1=sourse.PostalAddressLine1,
target.PostalAddressLine2=sourse.PostalAddressLine2,
target.PostalPostalCode=sourse.PostalPostalCode,
target.LastEditedBy=sourse.LastEditedBy,
target.ValidFrom=sourse.ValidFrom,
target.ValidTo=sourse.ValidTo
when not matched 
then insert 
(CustomerID,
CustomerName,
BillToCustomerID,
CustomerCategoryID,
BuyingGroupID,
PrimaryContactPersonID,
AlternateContactPersonID,
DeliveryMethodID,
DeliveryCityID,
PostalCityID,
CreditLimit,
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
FaxNumber,
DeliveryRun,
RunPosition,
WebsiteURL,
DeliveryAddressLine1,
DeliveryAddressLine2,
DeliveryPostalCode,
DeliveryLocation,
PostalAddressLine1,
PostalAddressLine2,
PostalPostalCode,
LastEditedBy,
ValidFrom,
ValidTo)
values (sourse.CustomerID,
sourse.CustomerName,
sourse.BillToCustomerID,
sourse.CustomerCategoryID,
sourse.BuyingGroupID,
sourse.PrimaryContactPersonID,
sourse.AlternateContactPersonID,
sourse.DeliveryMethodID,
sourse.DeliveryCityID,
sourse.PostalCityID,
sourse.CreditLimit,
sourse.AccountOpenedDate,
sourse.StandardDiscountPercentage,
sourse.IsStatementSent,
sourse.IsOnCreditHold,
sourse.PaymentDays,
sourse.PhoneNumber,
sourse.FaxNumber,
sourse.DeliveryRun,
sourse.RunPosition,
sourse.WebsiteURL,
sourse.DeliveryAddressLine1,
sourse.DeliveryAddressLine2,
sourse.DeliveryPostalCode,
sourse.DeliveryLocation,
sourse.PostalAddressLine1,
sourse.PostalAddressLine2,
sourse.PostalPostalCode,
sourse.LastEditedBy,
sourse.ValidFrom,
sourse.ValidTo);


--Итог:
--достигнутые изменения:
--CustomerID =  1062 изменино значение строки
--CustomerID = 1067 добавлена несуществующая ранее строка в target. 


Select * from sales.Customers_v2
--where CustomerID = 1067
order by CustomerID asc



--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
--5. Моё решение 

--данный скррип выполняется в командной строке
bcp [WideWorldImporters].[sales].[Customers_v2] out "C:\BCP\datafile.csv" -T -S  -F2 -c -t"~" -C ACP –k --выгрузил данные в формате csv.


--вариант копирования  данных через sql 
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME


exec master..xp_cmdshell 'bcp "[WideWorldImporters].[sales].[Customers_v2]" out "C:\BCP\datafile.csv" -T -S  -F2 -c -t"~" -C ACP ' --выгрузил данные в формате csv.



--Загружаю данные обратно
BULK INSERT [WideWorldImporters].[Sales].[Customers_v2]
				   FROM "C:\BCP\datafile.csv"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '~',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

					  Select * from [WideWorldImporters].[Sales].[Customers_v2]