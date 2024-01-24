--��������/��������� ���������� ���������� ��������� �������:
--1. ����������� � ���� ���� ������� ��������� insert � ������� Customers ��� Suppliers
--2. ������� ���� ������ �� Customers, ������� ���� ���� ���������
--3. �������� ���� ������, �� ����������� ����� UPDATE
--4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
--5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert

--������� �������� ������:

--1. ����������� � ���� ���� ������� ��������� insert � ������� Customers ��� Suppliers
--1. �� ������� 

Use WideWorldImporters

Select * into sales.Customers_v2 from sales.Customers --������ ���� ������� (��� ������� �������)

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
(1062, N'������ ������', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1063, N'������ ���������', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1064, N'������� �����', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1065, N'��� �������', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE()),
(1066, N'������� �������', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE())


--2. ������� ���� ������ �� Customers, ������� ���� ���� ���������
--2. �� ������� 

Delete from sales.Customers_v2 
where CustomerID in (1062,1063,1064,1065,1066) --������ ������, ��� ������� � ������ ������ �������. 
Select @@ROWCOUNT AS [������� ��������� �����]

--3. �������� ���� ������, �� ����������� ����� UPDATE
--3. �� ������� 
--��� �������� ������ (����� ��������� insert �� ������� ������� (� ������ ��� ������, ��� �������) 

update sales.Customers_v2
set 
CustomerName = N'������ ������ ����������'
where CustomerID = 1062

sELECT * FROM sales.Customers_v2
WHERE CustomerID = 1062


--4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
--4. �� ������� 

--���� �������: 
--1. ������ �������������� �������� � 5-� ��� ������������ ���� �������� + 
--������� ���� ����, ������� ��� � �������� sales.Customers_v2, �� ��� ���� ������ � ����� ��� ������������ 
--2. ����������� �����, ��� ��������� 1������ � ��������� ������ ���������� � ���������� ��������. 

--������ �������� sourse (��� �������� ��� ������)

Select * into sales.Customers_sourse from sales.Customers_v2
where CustomerID in (1062,1063,1064,1065,1066)

Select * from sales.Customers_sourse -- ���������, ��� ��� ���������
--������� ��������� ��������� (�������� customerID = 1062 ( ������ ���� ������ ������ ������), �� � ������� target ������ �� �������, ��� ������ ����� ���������� � ���������� ������.

update sales.Customers_sourse
set 
CustomerName = N'������ ������'
where CustomerID = 1062

--������� ������� � sourse

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
--(1067, N'���������� �����', 123, 123, 123,	123,	123,	123,	123,	123,	123,	getdate(),	123,	0x00,	0x00,	123,	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	'null',	123,	GETDATE(),	GETDATE())

--��������������� ����� --

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


--����:
--����������� ���������:
--CustomerID =  1062 �������� �������� ������
--CustomerID = 1067 ��������� �������������� ����� ������ � target. 


Select * from sales.Customers_v2
--where CustomerID = 1067
order by CustomerID asc



--5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert
--5. �� ������� 

--������ ������ ����������� � ��������� ������
bcp [WideWorldImporters].[sales].[Customers_v2] out "C:\BCP\datafile.csv" -T -S  -F2 -c -t"~" -C ACP �k --�������� ������ � ������� csv.


--������� �����������  ������ ����� sql 
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


exec master..xp_cmdshell 'bcp "[WideWorldImporters].[sales].[Customers_v2]" out "C:\BCP\datafile.csv" -T -S  -F2 -c -t"~" -C ACP ' --�������� ������ � ������� csv.



--�������� ������ �������
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