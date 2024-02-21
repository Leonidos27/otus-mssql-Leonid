Use Educational_base_homework
--Drop table if exists dbo.Directory_of_cities
--Drop table if exists dbo.Directory_of_types_of_insurance

Select * from dbo.header_temp
Select * from dbo.body_temp

drop table if exists dbo.header_temp
drop table if exists dbo.body_temp 

Select * from dbo.Directory_of_cities
Select * from dbo.Directory_of_types_of_insurance
Select * from dbo.header
Select * from dbo.body

--Нужно создать уникальный справочник компаний--



drop table if exists dbo.header_temp

Create table dbo.header_temp (
[dwh_id] [bigint] not null identity (1,1) primary key,
[FileName] nvarchar(max),
[Company] nvarchar(max),
[City] nvarchar(max),
[Surname] nvarchar(max),
[Name] nvarchar(max),
[middle_name] nvarchar(max),
[Job_title] nvarchar(max))



drop table if exists dbo.body_temp 
Create table dbo.body_temp (
[dwh_id] [bigint] not null identity (1,1),
[№_договора] nvarchar(max),	
[Фамилия] nvarchar(max),	
[Имя] nvarchar(max),	
[Отчество] nvarchar(max),	
[Дата_рождения]	date,
[Гражданство] nvarchar(max),	
[Страховая_сумма] bigint,	
[Дата_начала_действия_договора]	date,
[ID_страхования] nvarchar(max),
[FileName] nvarchar(max))




Drop table if exists dbo.header
Create table dbo.header (
[dwh_id] [bigint] not null identity (1,1) primary key,
[Company] nvarchar(max),
[City] nvarchar(max),
[Surname] nvarchar(max),
[Name] nvarchar(max),
[middle_name] nvarchar(max),
[Job_title] nvarchar(max),
[FileName] nvarchar(max),
[etl_date] [datetime] default (getdate()))



drop table if exists dbo.body
Create table dbo.body (
[dwh_id] [bigint] not null identity (1,1),
[№_договора] nvarchar(max),	
[Фамилия] nvarchar(max),	
[Имя] nvarchar(max),	
[Отчество] nvarchar(max),	
[Дата_рождения]	date,
[Гражданство] nvarchar(max),	
[Страховая_сумма] bigint,	
[Дата_начала_действия_договора]	date,
[ID_страхования] nvarchar(max),
[etl_date] [datetime] default (getdate()),
[FileName] nvarchar(max),
primery_id [bigint] references dbo.header (dwh_id) on delete cascade on update cascade )



--Мердж header-----
;Merge dbo.header target
using 
(
select 
t1.[Company],
t1.[City],
t1.[Surname],
t1.[Name],
t1.[middle_Name],
t1.[Job_title],
t1.[FileName]
from dbo.header_temp t1
Union 
Select 
t2.[Company],
t2.[City],
t2.[Surname],
t2.[Name],
t2.[middle_Name],
t2.[Job_title],
t2.[FileName]
from dbo.header t2
) source 
on
target.[Company]=source.[Company] and
target.[City]=source.[City] and
target.[Surname]=source.[Surname] and
target.[Name]=source.[Name] and
target.[middle_Name]=source.[middle_Name] and
target.[Job_title]=source.[Job_title] and
target.[FileName]=source.[FileName] 
when matched 
and (

target.[FileName]<>source.[FileName] )

then update set
target.etl_date=getdate(),
target.[Surname]=source.[Surname],
target.[Name]=source.[Name],
target.[middle_Name]=source.[middle_Name],
target.[Company]=source.[Company],
target.[Job_title]=source.[Job_title],
target.[City]=source.[City],
target.[FileName]=source.[FileName]
when not matched 
then insert 
(
[Company],
[City],
[Surname],
[Name],
[middle_Name],
[Job_title],
[FileName]
)
values 
(source.[Company], source.[City], source.[Surname], source.[Name], source.[middle_Name], source.[Job_title], source.[FileName]);






--Мердж body--

;Merge dbo.body target
using 
(
select 
t1.[№_договора],
t1.[Фамилия],
t1.[Имя],
t1.[Отчество],
t1.[Дата_рождения],
t1.[Гражданство],
t1.[Страховая_сумма],
t1.[Дата_начала_действия_договора],
t1.[ID_страхования],
t1.[FileName],
h.dwh_id as primery_id
from dbo.body_temp  t1
join dbo.header  h
on
t1.[FileName]=h.[FileName]
Union 
Select 
t2.[№_договора],
t2.[Фамилия],
t2.[Имя],
t2.[Отчество],
t2.[Дата_рождения],
t2.[Гражданство],
t2.[Страховая_сумма],
t2.[Дата_начала_действия_договора],
t2.[ID_страхования],
t2.[FileName],
h1.dwh_id as primery_id
from dbo.body as t2
join dbo.header as h1
on
t2.[FileName]=h1.[FileName]
) source 
on
target.[FileName]=source.[FileName]
and target.[№_договора]=source.[№_договора]
when matched 
and (
target.[FileName]<>source.[FileName] or
target.[№_договора]<>source.[№_договора] or
target.[Фамилия]<>source.[Фамилия] or
target.[Имя]<>source.[Имя] or
target.[Отчество]<>source.[Отчество] or
target.[Дата_рождения]<>source.[Дата_рождения] or
target.[Гражданство]<>source.[Гражданство] or
target.[Страховая_сумма]<>source.[Страховая_сумма] or
target.[Дата_начала_действия_договора]<>source.[Дата_начала_действия_договора] or
target.[ID_страхования]<>source.[ID_страхования])
then update set
target.etl_date  =getdate(),
target.[№_договора]=source.[№_договора],
target.[Фамилия]=source.[Фамилия],
target.[Имя]=source.[Имя],
target.[Отчество]=source.[Отчество],
target.[Дата_рождения]=source.[Дата_рождения],
target.[Гражданство]=source.[Гражданство],
target.[Страховая_сумма]=source.[Страховая_сумма],
target.[Дата_начала_действия_договора]=source.[Дата_начала_действия_договора],
target.[ID_страхования]=source.[ID_страхования],
target.[FileName]=source.[FileName],
target.primery_id=source.primery_id
when not matched 
then insert 
(
[№_договора],
[Фамилия],
[Имя],
[Отчество],
[Дата_рождения],
[Гражданство],
[Страховая_сумма],
[Дата_начала_действия_договора],
[ID_страхования],
[FileName],
[primery_id]
)
values 
(source.[№_договора], 
source.[Фамилия], 
source.[Имя], 
source.[Отчество], 
source.[Дата_рождения], 
source.[Гражданство], 
source.[Страховая_сумма], 
source.[Дата_начала_действия_договора], 
source.[ID_страхования], 
source.[FileName],
source.[primery_id]);