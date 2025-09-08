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
revenue_by_month AS (
	select order_month, SUM(revenue) as total_revenue
		from(
		select *,
		DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS order_month
		from orders_revenue
		) q1
	group by order_month
),
revenue_with_lag AS (
    select *,
	LAG(total_revenue) over (order by order_month asc) as prev_month_revenue
	FROM revenue_by_month
),
revenue_lag_perc AS (
	select *, (((total_revenue / prev_month_revenue) - 1) * 100) AS revenue_growth
	FROM revenue_with_lag
),
revenue_growth AS (
	select order_month, total_revenue as sales, revenue_growth
	from revenue_lag_perc
)

select *
from (
	select sales_year, sales_quarter,
	CAST(ROUND(AVG(revenue_growth)
	over(partition by sales_year,sales_quarter), 2) as nvarchar) + '%' as growth
	from(
		SELECT CAST(YEAR(order_month) AS VARCHAR(4)) as sales_year,
		' Q' + CAST(DATEPART(QUARTER, order_month) AS VARCHAR(1)) AS sales_quarter, *
		from revenue_growth
	) q1
) q2
group by sales_year, sales_quarter, growth
order by sales_year, sales_quarter
