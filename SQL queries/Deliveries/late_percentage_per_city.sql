WITH deliveries AS(
	select *
	from (
		select OrderID, EmployeeID, ShipVia, Freight, ShipCity, ShipCountry,
		CAST(DATEDIFF(DAY, OrderDate, ShippedDate) as float) as days_until_delivery,
		CAST(DATEDIFF(DAY, OrderDate, RequiredDate) as float) as late_threshold_days
		from Northwind.Orders
	) q1
),
deilveries_late AS(
	select *, 
	CASE
		WHEN (days_until_delivery - late_threshold_days) < 0 THEN 0
		ELSE (days_until_delivery - late_threshold_days)
	END as late_days
	from deliveries
),
deliveries_late_tagged AS (
select *,
	CASE 
		WHEN late_days > 0 THEN 'Late'
		ELSE 'In Time' END
	AS late_bool
from deilveries_late
),
aggregated AS (
    SELECT 
        ShipCountry,
        ShipCity,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN late_bool = 'Late' THEN 1 ELSE 0 END) AS late_orders
    FROM deliveries_late_tagged
    GROUP BY ShipCountry, ShipCity
)

SELECT *
FROM ( 
	SELECT 
		ShipCountry,
		ShipCity,
		total_orders,
		ROUND(CAST(late_orders AS FLOAT) / NULLIF(total_orders, 0), 3) * 100 AS late_percentage
	FROM aggregated

	
) q1
-- ATTENTION!
-- This filter can be removed to view the full city list.
-- Right now we filter to remove unsignificant
-- cities with no delivery volume
-- AND cities with no late deliveries.
where total_orders >= 5 AND late_percentage > 0
order by late_percentage desc
