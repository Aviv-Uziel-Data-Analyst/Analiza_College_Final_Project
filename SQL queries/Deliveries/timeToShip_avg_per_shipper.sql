WITH deliveries AS(
	select OrderID, EmployeeID, ShipVia, Freight, ShipCity, ShipCountry,
	CAST(DATEDIFF(DAY, OrderDate, ShippedDate) as float) as days_until_delivery
	from Northwind.Orders
),
shippers_deliveris AS(
select *
from deliveries db1
left join Northwind.Shippers db2
on db1.ShipVia = db2.ShipperID
)

select *
from(
	select ShipperID,
	CompanyName,
	ROUND(AVG(days_until_delivery), 2) as avg_days_to_ship
	from shippers_deliveris
	group by ShipperID, CompanyName
	) q1
order by avg_days_to_ship