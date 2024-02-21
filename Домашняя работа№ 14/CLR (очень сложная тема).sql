Use master

--включаю CLR

EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

Exec sp_configure 'clr enabled', 1;
Exec sp_configure 'clr strict security', 0;
GO

--возникли проблемы с владельцем базы данных
--DB Nam                     Owner
--master                     sa
--tempdb                     sa
--model	                     sa
--msdb	                     sa
--WideWorldImporters	     HOME-PC\Учебный ПК
--Educational_base_homework	 HOME-PC\Учебный ПК

SELECT name as [DB Name],
    suser_sname(owner_sid) as [Owner] 
FROM sys.databases


ALTER AUTHORIZATION ON DATABASE::WideWorldImporters TO sa; --HOME-PC\Учебный ПК

---порешали легкое недоразумение---

Use WideWorldImporters
alter database WideWorldImporters set trustworthy on

--загрузили то, что создали на VS--
Create assembly Home_work
from N'C:\Users\Учебный ПК\source\repos\Домашняя работа (CLR)\bin\Debug\Домашняя работа (CLR).dll'
with permission_set = SAFE;

Select * from sys.assemblies
go

EXEC sp_configure



--подключаем функцию из dll

--sp_configure 'show advanced options', 1;  
--RECONFIGURE;
--GO 
--sp_configure 'Ad Hoc Distributed Queries', 1;  
--RECONFIGURE;  
--GO  
drop function dbo.home_work_CLR
;create function dbo.home_work_CLR (@name nvarchar(100))
returns nvarchar(100)
as external name [Home_work].[Домашняя_работа__CLR_.Class1].HalloFunctione

Select dbo.home_work_CLR( N'Люди') as [Выводимое значение];
GO