Select * from dbo.header as t1
left join dbo.body as t2
on
t1.dwh_id=t2.primery_id
Where t2.Гражданство in ('Российская федерация')





Use Educational_base_homework
create Unique CLUSTERED index index_1 on dbo.header (dwh_id) -- данный индекс поностью идентичен тому, который сейчас уже действует у меня между двумя таблицами.

--index_name	                columns	index_type	    unique	table_view	   object_type
--PK__header__F713634D6E13620B	dwh_id	Clustered index	Unique	 dbo.header	   Table

--drop index index_1 on dbo.body


--Но, я попробую создать индекс в body на dwh_id

Use Educational_base_homework
create Unique CLUSTERED index index_1 on dbo.body (dwh_id)  --индекс создался, но толку от него будет мало, так как dwh_id это все строки в body , он просто по нима пробегается без полезной нагрузки.
--drop index index_1 on dbo.body