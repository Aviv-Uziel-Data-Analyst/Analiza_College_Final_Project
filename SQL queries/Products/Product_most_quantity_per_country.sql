WITH orders_merged AS(
	SELECT db1.*,
	db2.ProductID,
	db2.Quantity,
	db2.UnitPrice
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	ON db1.OrderID = db2.OrderID
),
product_volume_by_country AS(
select *, SUM(Quantity) over(partition by ShipCountry, ProductID) as total_sold 
from orders_merged
),
product_volume_ranked AS(
	select
	ShipCountry,
	ProductID,
	total_sold,
	ROW_NUMBER() over(partition by ShipCountry order by total_sold desc) as product_volume_rank
	from product_volume_by_country
	group by ShipCountry, ProductID, total_sold
)

select
ShipCountry,
db2.ProductName as most_sold_by_quantity,
db1.ProductID,
total_sold
from product_volume_ranked db1
JOIN
Northwind.Products db2
ON db1.ProductID = db2.ProductID
where product_volume_rank <= 1