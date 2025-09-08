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
),

units_OOS_by_supplier AS (
select db2.SupplierID,
db2.CompanyName,
db1.ProductID,
db1.units_combined
from units_restock_flag as db1
JOIN Northwind.Suppliers as db2
on db1.SupplierID = db2.SupplierID
),

OOS_products_by_supplier AS ( 
SELECT *
	FROM (
	select SupplierID, CompanyName,
	SUM(
		CASE 
		WHEN units_combined < 50 THEN 1
		ELSE 0
		END
	) over(partition by supplierID) as OOS_product_count
	from units_OOS_by_supplier	
) q1
group by SupplierID, CompanyName, OOS_product_count
),

OOS_products_by_supplier_ranked AS ( 
select *,
ROW_NUMBER() over(order by OOS_product_count desc) as out_of_stock_severity_rank
from OOS_products_by_supplier
)

select *
from OOS_products_by_supplier_ranked
