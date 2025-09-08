WITH orders_merged AS (
	SELECT db1.OrderDate,
	db1.ShipCountry,
	db1.ShipCity,
	db2.ProductID,
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
),
revenue_by_city AS (
	select ShipCountry,
	ShipCity,
	ROUND(SUM(revenue) over(partition by ShipCountry, Shipcity),2) as total_revenue
	from orders_revenue
)

select *
	from (
	select *,
	ROW_NUMBER() over(order by total_revenue desc) as revenue_rank
	from revenue_by_city
	group by ShipCountry, ShipCity, total_revenue
) q1
where revenue_rank <= 10