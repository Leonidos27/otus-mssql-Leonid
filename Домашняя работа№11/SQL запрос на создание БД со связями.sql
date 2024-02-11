
--Drop database Educational_base_homework

create database 
Educational_base_homework
GO

create schema EBH_1;

use Educational_base_homework

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

drop table if exists EBH_1.[Clients]
CREATE TABLE EBH_1.[Clients] (
    [Client_Id] int  identity (1,1) NOT NULL ,
    [family_name] varchar  NOT NULL ,
    [Name] varchar  NOT NULL ,
    [Surname] varchar  NOT NULL ,
    [Year_of_birth] date  NOT NULL ,
    [Citizenship] varchar  NOT NULL ,
    CONSTRAINT [PK_Clients]  PRIMARY KEY CLUSTERED (
        [Client_Id]  ASC  
    )
)

drop table if exists EBH_1.[Employees]
CREATE TABLE EBH_1.[Employees] (
    [Id_Employees] int  NOT NULL ,
    [family_name] nvarchar  NOT NULL ,
    [Name] nvarchar  NOT NULL ,
    [Surname] nvarchar  NOT NULL ,
    [Job_title] nvarchar  NOT NULL ,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED (
        [Id_Employees] ASC
    )
)

drop table if exists EBH_1.[Treaty]
CREATE TABLE EBH_1.[Treaty] (
    [Id_Treaty] int  NOT NULL ,
    [Id_Employees] int  NOT NULL ,
    [Client_Id] int  NOT NULL ,
    [insurance_sum] BIGINT  NOT NULL ,
    [contract_start_date] Date  NOT NULL 
)

drop table if exists EBH_1.[Insurance_type]
CREATE TABLE EBH_1.[Insurance_type] (
    [ID_type_of_insurance] int  NOT NULL ,
    [Insurance_type] nvarchar  NOT NULL ,
    CONSTRAINT [PK_Insurance_type] PRIMARY KEY CLUSTERED (
        [ID_type_of_insurance] ASC
    )
)

drop table if exists EBH_1.[Insurance_companies_conditions]
CREATE TABLE EBH_1.[Insurance_companies_conditions] (
    [Id_Treaty] int  NOT NULL ,
    [ID_type_of_insurance] int  NOT NULL ,
    [Name_of_insurance_company] nvarchar  NOT NULL ,
    [City] nvarchar  NOT NULL ,
    [Address] nvarchar  NOT NULL ,
    [Region] nvarchar  NOT NULL ,
    CONSTRAINT [PK_Insurance_companies_conditions] PRIMARY KEY CLUSTERED (
    [Id_Treaty] ASC
    )
)


ALTER TABLE EBH_1.[Clients] 
	ADD CONSTRAINT constr_dr_Clients
		CHECK ([Citizenship] like 'Российская федерация')

ALTER TABLE EBH_1.[Employees] 
	ADD CONSTRAINT constr_dr_Employees
		CHECK ([Job_title] like '%Управляющий%')

ALTER TABLE EBH_1.[Treaty] 
	ADD CONSTRAINT constr_dr_Treaty 
		CHECK ([insurance_sum] >= 10000)

ALTER TABLE EBH_1.[Insurance_type] 
	ADD CONSTRAINT constr_dr_Insurance_type
		CHECK ([Insurance_type] like '%Страхование жизни%')

ALTER TABLE EBH_1.[Insurance_companies_conditions] 
	ADD CONSTRAINT constr_dr_Insurance_companies_conditions
		CHECK ([Region] like '%Хабаровский край%')


create index Id_Employees_index on EBH_1.[Employees] (Id_Employees);
