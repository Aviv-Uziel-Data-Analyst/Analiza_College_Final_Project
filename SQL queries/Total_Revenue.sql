WITH orders_merged AS (
	SELECT db1.*, db2.ProductID,
	CAST(db2.Quantity as float) as Quantity,
	CAST(db2.UnitPrice as float) as unit_sell_cost,
	db2.Discount,
	CAST(db3.UnitPrice AS float) as unit_buy_cost
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	on db1.OrderID = db2.OrderID
	JOIN Northwind.Products as db3
	ON db2.ProductID = db3.ProductID
),
orders_revenue AS (
	select *,
	sales_pre_disc - (Quantity * unit_buy_cost) - (sales_pre_disc * Discount) as revenue
	from (
		Select *,
		(Quantity * unit_sell_cost) as sales_pre_disc
		from orders_merged
	) q1
)

select SUM(revenue) as total_revenue
from orders_revenue
