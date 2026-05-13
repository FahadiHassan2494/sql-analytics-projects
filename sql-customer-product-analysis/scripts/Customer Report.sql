
create view report_customers AS  
with base_query as (
-- Retreival of Core Columns
select 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name,' ',c.last_name) as customer_name,
timestampdiff(year,c.birthdate,curdate()) as age
 from fact_sales f left join 
dim_customers c on c.customer_key=f.customer_key
where order_date is not null and timestampdiff(year,c.birthdate,curdate()) is not null)



,customer_aggregations as(
-- Aggregations summorizing at customer Level
select customer_key,customer_number,customer_name,age,
count(distinct order_number) as total_orders,
Sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order,
timestampdiff(month,min(order_date),max(order_date))as lifespan

 from base_query
 group by 
 customer_key,
 customer_number,
 customer_name,
 age)
 
 select
customer_key,
customer_number,
 customer_name,
 age,
 case 
     when age<20 then 'Under 20'
     when age between 20 and 29 then '20-29'
     when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
       else '50 and above'
       end as age_group,
 case 
     when lifespan>=12 and total_sales >5000 then 'VIP'
      when lifespan>=12 and total_sales <=5000 then 'Regular'
      else 'New'
      end as customer_segment,
total_orders,
 total_sales,
 total_quantity,
total_products,
TIMESTAMPDIFF(MONTH, last_order, CURDATE()) AS recency,
 lifespan,
 -- Average order values
 case when total_orders=0 then 0
 else
 round(total_sales/total_orders) end  as Average_order_value,
 -- Average Month Spent
 case when lifespan =0 then total_sales 
 else 
 round(total_sales/lifespan)end as average_monthly_spent
 from customer_aggregations;
SELECT * FROM report_customers