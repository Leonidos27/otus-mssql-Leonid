use Educational_base_homework



Select * from dbo.header as t1
left join dbo.body as t2
on
t1.dwh_id=t2.primery_id
Where t2.Гражданство in ('Российская федерация')

Use Educational_base_homework
create CLUSTERED index index_1 on dbo.body (Гражданство,primery_id)
drop index index_1 on dbo.body

Select * from dbo.header as t1
left join dbo.body as t2
on
t1.dwh_id=t2.primery_id
Where t2.Гражданство in ('Российская федерация')

Select * from dbo.header
select * from dbo.body