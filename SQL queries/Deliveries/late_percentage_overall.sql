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
		WHEN q1.late_days > 0 THEN 'Late'
		ELSE 'In Time' END
	AS late_bool
	from (
		select *, 
		CASE
			WHEN (days_until_delivery - late_threshold_days) < 0 THEN 0
			ELSE (days_until_delivery - late_threshold_days)
		END as late_days
		from deliveries
	) q1
)

select *, ROUND(((order_count / order_total_count)), 3) * 100 AS perc
from (
	select *
	from (
		select late_bool,
		CAST(COUNT(OrderID) over(partition by late_bool) AS float) as order_count,
		CAST(COUNT(OrderID) over() AS float) as order_total_count
		from (
			select OrderID,
			EmployeeID, ShipVia,
			Freight, ShipCity,
			ShipCountry, late_days,
			late_bool
			from deilveries_late
		) q1
	) q2
	group by late_bool, order_count, order_total_count
) q3