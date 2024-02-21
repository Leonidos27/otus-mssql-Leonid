Select * from dbo.header
select * from dbo.body

0




DECLARE @FromDate SMALLDATETIME, @ToDate SMALLDATETIME;
SELECT @FromDate = '20000101', @ToDate = getdate();
WITH Days(D) AS
(
 SELECT @FromDate WHERE @FromDate <= @ToDate
 UNION ALL
 SELECT DATEADD(DAY,1,D) FROM Days WHERE D < @ToDate
)
SELECT cast(D as date) as [day],month(D) as [month],year(D) as [year] into dbo.[time] FROM Days ORDER BY D desc
OPTION (MAXRECURSION 0);


