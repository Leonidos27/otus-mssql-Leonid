

--Задание 1: 
--Определить номера договоров и вид страхового продукта, заключенных заданным
--работником

Create  PROCEDURE [numbers_of_contracts_and_insurance_types_by_employee]
    @employee_name nvarchar(100)
AS
BEGIN
    SELECT 
        CONCAT(t1.Surname, ' ', t1.Name, ' ', t1.middle_name) AS [Кто оформил],
        t2.[№_договора],
        t3.[Вид страхования]
    FROM dbo.header AS t1
    LEFT JOIN dbo.body AS t2 ON t1.dwh_id = t2.primery_id
    LEFT JOIN dbo.Directory_of_types_of_insurance AS t3 ON t2.ID_страхования = t3.ID
    WHERE CONCAT(t1.Surname, ' ', t1.Name, ' ', t1.middle_name) = @employee_name
	END

	--Выберем уникальных из Header--

	Select distinct CONCAT(Surname, ' ', Name, ' ', middle_name) AS [Кто оформил] from dbo.header


	--проверка работы процедуры--
	EXEC [numbers_of_contracts_and_insurance_types_by_employee] @employee_name = 'Кирилов Андрей Владимирович'


--Задание 2:
--Составить список клиентов, у которых срок действия договора истекает в указанную дату.

--Примем за истину то, что все договора заключены ровно на 1 год (так как я забыл сделать отдельную колонку для отражения периода дейставия договора) 

;Create PROCEDURE [Compile a list of clients whose contract expires on a specified date]
    @deadline date
AS
BEGIN
SELECT 
        distinct (Concat(t.Фамилия,'',t.Имя,'',t.Отчество)) as [Клиент],--t2.Дата_начала_действия_договора,
		DATEADD(year,1,t.Дата_начала_действия_договора) as [Дата окончания договора]
    FROM dbo.body AS t 
	where DATEADD(year,1,t.Дата_начала_действия_договора) = @deadline
	END


--Создаем перечень дат (дедлайнов)--
Select DATEADD(year,1,Дата_начала_действия_договора) [Окончание действия договора],count(*) as [Дата окончания договора]
    FROM dbo.body
	group by DATEADD(year,1,Дата_начала_действия_договора)
	order by count(*) desc

Exec [Compile a list of clients whose contract expires on a specified date] @deadline = '20240503'




--Задание 3. 
--Составить список клиентов, сумма страхования у которых меньше указанной величины.

Create PROCEDURE [list of clients whose insurance amount is less than the specified amount]
    @Sum int
AS
BEGIN
Select distinct (Concat(t.Фамилия,'',t.Имя,'',t.Отчество)) as [Клиент],
		DATEADD(year,1,t.Дата_начала_действия_договора) as [Дата окончания договора],t.Страховая_сумма
    FROM dbo.body as t
	where t.Страховая_сумма < @Sum
	END

--Проверяем работу процедуры--
Exec [list of clients whose insurance amount is less than the specified amount] @sum = 100000

--Задание 4. 
--Составить список клиентов, договоры с которыми заключил заданный сотрудник.

Create PROCEDURE [a list of clients with whom a given employee has concluded contracts.]
    @employee_name nvarchar(100)
AS
BEGIN
    SELECT 
        distinct (CONCAT(t2.Фамилия,'',t2.Имя,'',t2.Отчество)) AS [Клиенты]
    FROM dbo.header AS t1
    LEFT JOIN dbo.body AS t2 ON t1.dwh_id = t2.primery_id
    LEFT JOIN dbo.Directory_of_types_of_insurance AS t3 ON t2.ID_страхования = t3.ID
    WHERE CONCAT(t1.Surname, ' ', t1.Name, ' ', t1.middle_name) = @employee_name
	END

EXEC [a list of clients with whom a given employee has concluded contracts.] @employee_name = 'Кирилов Андрей Владимирович'


--Задание 5. 
--Уменьшить на 5% стоимость данного страхового продукта. (Как я понял, тут не просто нужно взять данные, а уменьшить их в целевой даблице)

--Смотрим какие страховые продукты у нас есть--
Select * from dbo.Directory_of_types_of_insurance
--Будем менять стоимость медецинского страхования--
--Для теста, сделаем копию таблицы dbo.body
Select * --into dbo.body_test 
from dbo.body 

----------------------------------
;ALTER PROCEDURE [Reduce the cost of this insurance product by 5%]
@Insurance_product nvarchar(1000)
AS
BEGIN
BEGIN TRY
    BEGIN TRANSACTION;
    drop table if exists #temp;
    Select t1.dwh_id, t2.[Вид страхования],
    t1.Страховая_сумма as [Страховая_сумма (руб.)],
    t1.Страховая_сумма - (t1.Страховая_сумма / 100) * 5 as [Меньше на 5%] 
    into #temp 
    from dbo.body_test as t1 
    left join dbo.Directory_of_types_of_insurance as t2
    on t1.ID_страхования = t2.ID
    where t2.[Вид страхования] = @Insurance_product;

    SELECT @@ROWCOUNT as [Обработано кол-во строк];

    Merge dbo.body_test as target
    using 
    (
        select 
            t1.dwh_id,
            t1.[Вид страхования],
            t1.[Меньше на 5%]
        from #temp as t1
    ) as source 
    on target.dwh_id = source.dwh_id 
    when matched and target.[Страховая_сумма] <> source.[Меньше на 5%]
    then update set
        target.etl_date = getdate(),
        target.[Страховая_сумма] = source.[Меньше на 5%]
    when not matched 
    then insert 
    (
        [Страховая_сумма]
    )
    values 
    (
        source.[Меньше на 5%]
    );

    drop table if exists #temp;

    Print 'Количество затронутых строк: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
END


Exec [Reduce the cost of this insurance product by 5%] @Insurance_product=' Медицинское страхование'

--Проверяем--

Select dwh_id,Страховая_сумма from dbo.body as t1
left join dbo.Directory_of_types_of_insurance as t2
on 
t1.ID_страхования=t2.ID
where t2.[Вид страхования] = ' Медицинское страхование'
order by dwh_id

Select dwh_id,Страховая_сумма from dbo.body_test as t1
left join dbo.Directory_of_types_of_insurance as t2
on 
t1.ID_страхования=t2.ID
where t2.[Вид страхования] = ' Медицинское страхование'
order by dwh_id
