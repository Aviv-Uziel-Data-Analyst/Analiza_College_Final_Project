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
),
products_revenue AS(
	select *,
	SUM(revenue) over(partition by productID) as product_revenue,
	SUM(revenue) over() as total_revenue,
	SUM(Quantity) over(partition by productID) as total_quantity
	from orders_revenue
),
product_revenue_percentage AS(
	SELECT ProductID,
	total_quantity,
	ROUND(product_revenue, 2) as product_revenue,
	ROUND(percentage_of_total_revenue, 2) as percentage_of_total_revenue
		from (
		select ProductID,
		product_revenue,
		total_revenue,
		total_quantity,
		(product_revenue / total_revenue) * 100 as percentage_of_total_revenue
		from products_revenue
	) q1
	group by ProductID, product_revenue, total_quantity, percentage_of_total_revenue
)

select db2.ProductName, db1.*
from product_revenue_percentage db1
LEFT JOIN Northwind.Products db2
on db1.ProductID = db2.ProductID
order by percentage_of_total_revenue desc