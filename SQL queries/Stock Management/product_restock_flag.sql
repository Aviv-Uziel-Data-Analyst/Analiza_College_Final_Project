WITH units_db AS (
	select *,
	UnitsInStock + UnitsOnOrder as units_combined
	from Northwind.Products
),
units_restock_flag AS (
select *,
CASE 
    WHEN units_combined < 50 AND Discontinued = 0 THEN 1
    ELSE 0
END AS restock_flag
from units_db
)

select ProductID,
ProductName,
units_combined,
restock_flag
from units_restock_flag
where restock_flag = 1
order by units_combined asc
