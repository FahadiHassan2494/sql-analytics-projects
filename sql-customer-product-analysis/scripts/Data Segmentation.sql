-- PART TO WHOLE ANALYSIS
with category_sales as(
SELECT category,
sum(sales_amount) as total_sales from fact_sales f 
left join dim_products p on f.product_key=p.product_key
group by category)
select category,
total_sales,
sum(total_sales) over() overall_sales,
concat(round((total_sales/sum(total_sales) over())*100,2),'%') as percentage_sales from category_sales
ORDER  BY total_sales desc;
-- DATA SEGMENTATION

with cost_range as(
Select product_key,product_name,cost ,

Case when cost<100 then 'below 100'
     when cost between 100 and 1000 then 'b/w 100-1000'
	when cost between 1000 and 1500 then 'b/w 1000-1500'
    when cost between 1500 and 2000 then 'b/w 1500-2000'
    when cost >2000 then 'above 2000'
    end as cost_segment

from dim_products )
select cost_segment,count(product_name) as total_products 
 from cost_range
 group by cost_segment order by total_products  asc;
 
 
 
 
WITH category_cust AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_purchase,
        MAX(f.order_date) AS last_purchase,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM fact_sales f
    LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key order by lifespan desc
)
select customer_category,
count(customer_key)As total_customers
from(
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000  THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000  THEN 'Regular'
            ELSE 'New'
        END AS customer_category
    FROM category_cust) t
    group by customer_category order by total_customers desc;
 