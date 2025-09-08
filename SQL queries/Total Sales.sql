select ROUND(SUM(sales_amount), 2) as total_sales
from(
	select OrderID ,ProductID,
	sales_pre_disc - (sales_pre_disc * Discount) as sales_amount
	from (
		Select *,
		(CAST(Quantity as float) * CAST(UnitPrice as float)) as sales_pre_disc
		from Northwind.[Order Details]
	) q1
) q2