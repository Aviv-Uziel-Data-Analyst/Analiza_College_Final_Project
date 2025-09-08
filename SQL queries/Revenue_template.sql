WITH orders_merged AS (
	SELECT db1.*, db2.ProductID,
	CAST(db2.Quantity as float) as Quantity,
	CAST(db2.UnitPrice as float) as unit_sell_price,
	db2.Discount,
	CAST(db3.UnitPrice AS float) as unit_buy_price
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	on db1.OrderID = db2.OrderID
	JOIN Northwind.Products as db3
	ON db2.ProductID = db3.ProductID
),
orders_revenue AS (
	select *,
	sales_raw - (Quantity * unit_buy_price) - (sales_raw * Discount) as revenue
	from (
		Select *,
		(Quantity * unit_sell_price) as sales_raw
		from orders_merged
	) q1
)

select *
from orders_revenue