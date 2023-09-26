select * from gdb0041.dim_customer
where customer like "%croma%" and market ="india";
select * from fact_sales_monthly
where customer_code=90002002 and
YEAR(date) =2021
order by date desc;