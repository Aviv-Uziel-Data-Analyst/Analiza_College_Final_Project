WITH deliveries AS(
	select OrderID, EmployeeID, ShipVia, Freight, ShipCity, ShipCountry,
	CAST(DATEDIFF(DAY, OrderDate, ShippedDate) as float) as days_until_delivery
	from Northwind.Orders
)

select ShipCountry,
ROUND(AVG(days_until_delivery), 2) as avg_days_to_ship
from deliveries
group by ShipCountry
order by avg_days_to_ship
