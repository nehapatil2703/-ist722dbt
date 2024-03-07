with stg_orders as 
(
    select
        OrderID,  
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey, 
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey, 
        replace(to_date(orderdate)::varchar,'-','')::int as orderdatekey,
    from {{source('northwind','Orders')}}    
),
stg_order_details as
(
    select 
        orderid,
        {{ dbt_utils.generate_surrogate_key(['productid']) }} as productkey,
        Quantity,
        (Quantity * UnitPrice) as extendedpriceamount, 
        (Quantity * UnitPrice * Discount) as discountamount,
        (Quantity * UnitPrice * (1-Discount)) as soldamount
    from {{source('northwind','Order_Details')}}
)
select o.*, 
    od.productkey, od.quantity, 
    od.extendedpriceamount, od.discountamount, od.soldamount
from stg_orders o 
    join stg_order_details od on o.OrderID = od.orderid