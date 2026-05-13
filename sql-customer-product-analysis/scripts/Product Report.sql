
-- base query
create view product_report as
with base_query as (
select f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
from fact_sales f left join dim_products p on
f.product_key=p.product_key where order_date is not null


),
product_aggregations as (
select product_key,
product_name,
category,
subcategory,
cost,
TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
Max(order_date) as last_order,
Count(distinct order_number) as total_orders,
Count(distinct customer_key) as total_customers,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
round(SUM(sales_amount) / NULLIF(SUM(quantity), 0)) AS avg_selling_price
from base_query
group by product_key,
product_name,
category,
subcategory,
cost)
select product_key,
product_name,
category,subcategory,
cost,
last_order,
TIMESTAMPDIFF(MONTH, last_order, CURDATE()) AS recency,
case
  when total_sales>50000 then 'High-Performer'
  when total_sales>=10000 then 'Mid-Performer'
  else 'Low-Performer'
  end as product_segment,
  lifespan,total_orders,
  total_sales,
  total_quantity,
  total_customers,
  avg_selling_price,
-- average order revenue
case when
total_orders=0 then 0
else round(total_sales/total_orders) 
end as avg_order_revenue,
case 
when lifespan=0  then total_sales
else  round(total_sales/lifespan) 
end as avg_monthly_revenue
from product_aggregations;