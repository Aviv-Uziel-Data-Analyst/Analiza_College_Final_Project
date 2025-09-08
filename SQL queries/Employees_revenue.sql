WITH orders_merged AS (
	SELECT 
	db2.ProductID,
	CAST(db2.Quantity as float) as Quantity,
	CAST(db2.UnitPrice as float) as unit_sell_price,
	CAST(db4.UnitPrice as float) as unit_buy_price,
	db2.Discount, db3.*
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	on db1.OrderID = db2.OrderID
	JOIN Northwind.Employees as db3
	on db1.EmployeeID = db3.EmployeeID
	JOIN Northwind.Products as db4
	on db2.ProductID = db4.ProductID
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
emp_sales AS (
select *,
SUM(revenue) over(partition by EmployeeID) as emp_revenue
from orders_revenue
),
employees_ranked AS (
select *, DENSE_RANK() OVER(order by emp_revenue desc) as emp_rank
from emp_sales
)

select EmployeeID, FirstName, LastName, Title, Country, ReportsTo, emp_revenue, emp_rank
from employees_ranked
group by EmployeeID, FirstName, LastName, Title, Country, ReportsTo, emp_revenue, emp_rank
order by emp_rank