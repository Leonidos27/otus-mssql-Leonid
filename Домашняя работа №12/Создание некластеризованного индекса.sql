Use Educational_base_homework

Select * from dbo.Directory_of_types_of_insurance
Select * from dbo.header
Select * from dbo.body




Select * from dbo.body as t1
left join dbo.Directory_of_types_of_insurance as t2
on
t1.ID_страхования=t2.ID
where t2.[Вид страхования] = ' Медицинское страхование'


--CREATE UNIQUE INDEX index1 ON dbo.body (primery_id asc);
--Drop index index1 ON dbo.body



Select * from dbo.body as t1
left join dbo.Directory_of_types_of_insurance as t2
on
t1.ID_страхования=t2.ID
where t2.[Вид страхования] = ' Медицинское страхование'