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
orders_calculations AS (
	select *,
	sales_pre_disc - (sales_pre_disc * Discount) as sales_amount
	from (
		Select *,
		(Quantity * unit_sell_cost) as sales_pre_disc,
		(Quantity * unit_buy_cost) as costs_amount
		from orders_merged
	) q1
),
profit_margins AS (
select (total_sales - total_costs) / total_sales * 100 as profit_margin
from (
	select SUM(sales_amount) as total_sales,
	SUM(costs_amount) as total_costs
	from orders_calculations
	) q1
)

select *
from profit_margins