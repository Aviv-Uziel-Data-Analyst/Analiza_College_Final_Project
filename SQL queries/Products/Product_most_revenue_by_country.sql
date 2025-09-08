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
orders_product_sales_by_country AS(
select *, SUM(revenue) over(partition by ShipCountry, ProductId) as product_revenue_by_country
from orders_revenue
),
products_sales_ranked AS(
	select ShipCountry,
	ProductID,
	product_revenue_by_country,
	DENSE_RANK() over(partition by ShipCountry order by product_revenue_by_country desc) as revenue_rank
	from orders_product_sales_by_country
	group by ShipCountry, ProductID, product_revenue_by_country
)

select ShipCountry, db2.ProductName as top_product,
db1.ProductID,
ROUND(product_revenue_by_country, 2) as product_revenue
from products_sales_ranked db1
JOIN
Northwind.Products db2
ON db1.ProductID = db2.ProductID
where revenue_rank = 1
order by product_revenue desc
