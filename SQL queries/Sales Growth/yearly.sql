WITH orders_merged AS (
	SELECT db1.OrderDate, db2.ProductID,
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
revenue_by_year AS (
	select order_year,
	SUM(revenue) total_revenue
		from (
		select *,
		DATEPART(YEAR,OrderDate) AS order_year
		from orders_revenue
		) q1
	group by order_year
),
revenue_with_lag_yearly AS (
    select *,
	LAG(total_revenue) over (order by order_year asc) as prev_year_sales
	FROM revenue_by_year
),
revenue_lag_perc_yearly AS (
	select *, (((total_revenue / prev_year_sales) - 1) * 100) AS growth_perc
	FROM revenue_with_lag_yearly
),
revenue_growth_yearly AS (
	select order_year, ROUND(total_revenue, 2) as yearly_revenue, CAST(ROUND(growth_perc, 2) as nvarchar) + '%' as growth
	from revenue_lag_perc_yearly
)
SELECT *
from revenue_growth_yearly
