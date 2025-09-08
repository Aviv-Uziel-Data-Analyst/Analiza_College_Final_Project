WITH orders_merged AS (
	SELECT db1.*,
	db2.ProductID, db2.Quantity, db2.UnitPrice, db2.Discount
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	on db1.OrderID = db2.OrderID
)

select *
from orders_merged