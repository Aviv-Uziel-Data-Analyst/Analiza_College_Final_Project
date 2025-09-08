WITH orders_merged AS(
	SELECT db1.*,
	db2.ProductID,
	db2.Quantity,
	db2.UnitPrice
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	ON db1.OrderID = db2.OrderID
),
orders_volume AS(
	select ShipCountry, ShipCity,
	COUNT(distinct OrderID) as order_volume
	from orders_merged
	group by ShipCountry, ShipCity
)
select *
from (
	select *,
	ROW_NUMBER() over(order by order_volume desc) as volume_rank
	from orders_volume
) q1