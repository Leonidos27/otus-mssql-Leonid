-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/Ub7lvT
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE TABLE [Клиенты] (
    [Client_Id] int  NOT NULL ,
    [family_name] varchar  NOT NULL ,
    [Name] varchar  NOT NULL ,
    [Surname] varchar  NOT NULL ,
    [Year_of_birth] date  NOT NULL ,
    [Citizenship] varchar  NOT NULL ,
    CONSTRAINT [PK_Клиенты] PRIMARY KEY CLUSTERED (
        [Client_Id] ASC
    )
)

CREATE TABLE [Employees] (
    [Id_Employees] int  NOT NULL ,
    [family_name] nvarchar  NOT NULL ,
    [Name] nvarchar  NOT NULL ,
    [Surname] nvarchar  NOT NULL ,
    [Job_title] nvarchar  NOT NULL ,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED (
        [Id_Employees] ASC
    )
)

CREATE TABLE [Treaty] (
    [Id_Treaty] int  NOT NULL ,
    [Id_Employees] int  NOT NULL ,
    [Client_Id] int  NOT NULL ,
    [insurance_sum] BIGINT  NOT NULL ,
    [contract_start_date] Date  NOT NULL 
)

CREATE TABLE [Insurance_type] (
    [ID_type_of_insurance] int  NOT NULL ,
    [Insurance_type] nvarchar  NOT NULL ,
    CONSTRAINT [PK_Insurance_type] PRIMARY KEY CLUSTERED (
        [ID_type_of_insurance] ASC
    )
)

CREATE TABLE [Insurance_companies_conditions] (
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

ALTER TABLE [Клиенты] WITH CHECK ADD CONSTRAINT [FK_Клиенты_Client_Id] FOREIGN KEY([Client_Id])
REFERENCES [Treaty] ([Client_Id])

ALTER TABLE [Клиенты] CHECK CONSTRAINT [FK_Клиенты_Client_Id]

ALTER TABLE [Employees] WITH CHECK ADD CONSTRAINT [FK_Employees_Id_Employees] FOREIGN KEY([Id_Employees])
REFERENCES [Treaty] ([Id_Employees])

ALTER TABLE [Employees] CHECK CONSTRAINT [FK_Employees_Id_Employees]

ALTER TABLE [Treaty] WITH CHECK ADD CONSTRAINT [FK_Treaty_Id_Treaty] FOREIGN KEY([Id_Treaty])
REFERENCES [Insurance_companies_conditions] ([Id_Treaty])

ALTER TABLE [Treaty] CHECK CONSTRAINT [FK_Treaty_Id_Treaty]

ALTER TABLE [Insurance_companies_conditions] WITH CHECK ADD CONSTRAINT [FK_Insurance_companies_conditions_ID_type_of_insurance] FOREIGN KEY([ID_type_of_insurance])
REFERENCES [Insurance_type] ([ID_type_of_insurance])

ALTER TABLE [Insurance_companies_conditions] CHECK CONSTRAINT [FK_Insurance_companies_conditions_ID_type_of_insurance]

COMMIT TRANSACTION QUICKDBD