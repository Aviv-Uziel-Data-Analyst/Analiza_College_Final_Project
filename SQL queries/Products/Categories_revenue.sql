WITH orders_merged AS(
	SELECT db1.*,
	db2.ProductID,
	CAST(db2.Quantity as float) as Quantity,
	CAST(db2.UnitPrice as float) as unit_sell_price,
	CAST(db3.UnitPrice as float) as unit_buy_price,
 	CAST(db2.Discount as float) as Discount,
	db3.CategoryID,
	db4.CategoryName,
	db4.[Description]
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	ON db1.OrderID = db2.OrderID
	JOIN Northwind.Products as db3
	on db2.ProductID = db3.ProductID
	JOIN Northwind.Categories as db4
	on db3.CategoryID = db4.CategoryID
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
	SUM(revenue) over(partition by categoryID) as cat_revenue,
	SUM(revenue) over() as total_revenue,
	SUM(Quantity) over(partition by categoryID) as cat_quantity
	from orders_revenue
),
category_profit_percentage AS(
	SELECT CategoryID,
	CategoryName,
	CAST(q1.Description as nvarchar) as 'description',
	cat_quantity,
	ROUND(cat_revenue, 2) as cat_revenue,
	ROUND(percentage_of_total_revenue, 2) as percentage_of_total_revenue
		from (
		select *,
		(cat_revenue / total_revenue) * 100 as percentage_of_total_revenue
		from products_revenue
	) q1
	group by CategoryID, CategoryName,
	CAST(q1.Description as nvarchar),
	cat_revenue, cat_quantity, percentage_of_total_revenue
),
category_profit_ranked AS (
select *, 
ROW_NUMBER() over(order by cat_revenue desc) as cat_rank
from category_profit_percentage
)

select *
from category_profit_ranked