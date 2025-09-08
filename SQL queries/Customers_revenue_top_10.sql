WITH orders_merged AS (
	SELECT db1.*,
	db2.ProductID, CAST(db2.Quantity as float) as Quantity,
	CAST(db2.UnitPrice as float) as unit_sell_price,
	db2.Discount, CAST(db4.UnitPrice as float) as unit_buy_price,
	db3.CompanyName, db3.ContactTitle, db3.ContactName,
	db3.Phone, db3.Fax, db3.Country, db3.PostalCode,
	db3.Address, db3.City
	FROM Northwind.Orders as db1
	JOIN Northwind.[Order Details] as db2
	on db1.OrderID = db2.OrderID
	JOIN Northwind.Customers as db3
	on db1.CustomerID = db3.CustomerID
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
customers_sales AS (
select *,
SUM(revenue) over(partition by customerID) as customer_revenue
from orders_revenue
),
customers_ranked AS ( 
select *,
DENSE_RANK() over(order by customer_revenue desc) as customer_rank
from customers_sales
)

select customer_rank, ContactName,ContactTitle,
	customer_revenue, CustomerID, Phone,
	Fax, Country, City,
    Address, PostalCode
from customers_ranked
where customer_rank <= 10
group by CustomerID, ContactName, customer_revenue, customer_rank,
	Phone, Fax,ContactTitle, Country, PostalCode,
	Address, City
order by customer_rank asc