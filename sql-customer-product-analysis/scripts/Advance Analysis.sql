select YEAR(order_date) AS order_year,Sum(sales_amount),
count(distinct customer_key)as total_customers,
sum(quantity) as Total_quantitites
 from fact_sales where order_date is not null 
group by year(order_date)
order by year(order_date) asc;


SELECT 
    DATE_FORMAT(order_date, '%Y-%m-01') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantities
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY DATE_FORMAT(order_date, '%Y-%m-01') ASC;

select sales_amount,sum(sales_amount) over(partition by DATE_FORMAT(order_date, '%Y-%m-01')) as total_sales from fact_sales
;
  select order_date,
  total_sales,
  Sum(total_sales) over( order by order_date) as running_total,
 round ( avg(avg_price) over (
  
  order by order_date)) as average_price
  
  from(
  
  select  DATE_FORMAT(order_date, '%Y-01-01') AS order_date,
    SUM(sales_amount) AS total_sales,
    avg(price) as avg_price
    from fact_sales where order_date is not null 
    GROUP BY DATE_FORMAT(order_date, '%Y-01-01')
    ) t;
 
 
 
 with yearly_sales as(
 select year(f.order_date) as order_year,
 p.product_name,
 sum(f.sales_amount) as current_sales
 from fact_sales f 
 left join dim_products p on f.product_key=p.product_key
 where f.order_date is not null
 group by year(f.order_date),
 p.product_name order by order_year)
 select order_year,
 product_name,
 current_sales,
 avg(current_sales) over(partition by product_name) as average_sales,
 current_sales- avg(current_sales) over(partition by product_name) as diff_sales,
 case when current_sales- avg(current_sales) over(partition by product_name)>0 then 'Above Average'
	  when current_sales- avg(current_sales) over(partition by product_name)<0 then'Below Average'
 else 'average'
 end avg_change,
 -- yoy analysis
 lag(current_sales) over (partition by product_name order by order_year ) as previous_sales,
 current_sales-lag(current_sales) over (partition by product_name order by order_year ) as diff_prev,
 case when current_sales- lag(current_sales) over (partition by product_name order by order_year)>0 then 'increase'
	  when current_sales- lag(current_sales) over (partition by product_name order by order_year )<0 then'Decrease'
 else 'No change'
 end as diff_flag
 from yearly_sales
 order by product_name ,order_year ;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
    