# Chapter:- SQL Advanced: Top Customers, Products, Markets



### Module: Problem Statement and Pre-Invoice Discount Report

-- Include pre-invoice deductions in Croma detailed report
	SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
            
	JOIN fact_gross_price g
    	    ON g.fiscal_year=get_fiscal_year(s.date)
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=get_fiscal_year(s.date)
	WHERE 
	    s.customer_code=90002002 AND 
    	    get_fiscal_year(s.date)=2021     
	LIMIT 1000000;
    
    
    # Chapter:- SQL Advanced: Top Customers, Products, Markets



### Module: Problem Statement and Pre-Invoice Discount Report

-- Include pre-invoice deductions in Croma detailed report
	SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
            JOIN dim_date dt
            ON dt.calendar_date =s.date
	JOIN fact_gross_price g
    	    ON g.fiscal_year=dt.fiscal_year
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=dt.fiscal_year
	WHERE 
	    s.customer_code=90002002 AND 
    	    dt.fiscal_year=2021     
	LIMIT 1000000;
    
    
    
    
   with CTE1 AS( SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
            
	JOIN fact_gross_price g
    	    ON g.fiscal_year=s.fiscal_year
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=s.fiscal_year
	WHERE 
	    
    	    s.fiscal_year=2021)
            select *, round( (gross_price_total - gross_price_total*pre_invoice_discount_pct),2)as net_invoice_sale
            from CTE1;
            
            SELECT 
    *,
    (1 - pre_invoice_discount_pct) * gross_price_total AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) AS post_invoice_discount_pct
FROM
    sales_preinv_discount s
        JOIN
    fact_post_invoice_deductions po ON s.date = po.date
        AND s.product_code = po.product_code
        AND s.customer_code = po.customer_code;
        
        SELECT * FROM sales_postinv_discount;
        
        
       # top 5 market
       SELECT 
    market, ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales
WHERE
    fiscal_year = 2021
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;

# TOP 5 customer by net sales
   SELECT 
    customer,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales n
        JOIN
    dim_customer c ON n.customer_code = c.customer_code
WHERE
    fiscal_year = 2021
GROUP BY customer
ORDER BY net_sales_mln DESC
LIMIT 5 ;

# A stored procedure to get the top n products by net sales for a given year

SELECT 
     Product,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales n
        JOIN
    dim_customer c ON n.customer_code = c.customer_code
WHERE
    fiscal_year = 2021
GROUP BY product
ORDER BY net_sales_mln DESC
LIMIT 5 ;
# Top customet by % net sales using windos function and cumulative sum
with cte1 as (
SELECT 
    customer,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales s
        JOIN
    dim_customer c ON s.customer_code = c.customer_code
WHERE
    s.fiscal_year = 2021
GROUP BY customer)
select *,
net_sales_mln*100/sum(net_sales_mln) over() as pct
 from cte1
order by net_sales_mln;
with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc;

# Top customer by region by net sales %


with cte1 as (
SELECT 
    customer,
    ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales s
        JOIN
    dim_customer c ON s.customer_code = c.customer_code
WHERE
    s.fiscal_year = 2021
GROUP BY customer)
select *,
net_sales_mln*100/sum(net_sales_mln) over() as pct
 from cte1
order by net_sales_mln;

# top customer by net sales over region

with cte1 as (
		select 
                   c.region, c.customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by c.customer, c.region)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over(partition by region) as pct_net_sales
	from cte1
	order by region,net_sales_mln desc;
    
    
    # Write a stored process for getting  TOP n products in each divison by their quantity sold in  a given finacial year. For example below would be  the result for FY=2021
    SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
    with cte1 as
    (select
    p.division, p.product, sum(sold_quantity) as total_qty
    from fact_sales_monthly s
    join gdb0041.dim_product p
    ON p.product_code=s.product_code
    where fiscal_year=2021
   group by p.product ),
   cte2 as (select*,
   dense_rank() over(partition by division order by total_qty) as drnk
   from cte1)
   select * from cte2 where drnk<=3;
   
   /*Retrieve the top 2 markets in every region by their gross sales amount in FY=2021.
   i.e. result should look something like this,*/
  
	with cte1 as (
		select
			c.market,
			c.region,
			round(sum(gross_price_total)/1000000,2) as gross_sales_mln
			from gdb0041.`gross sales` s
			join dim_customer c
			on c.customer_code=s.customer_code
			where fiscal_year=2021
			group by market
			order by gross_sales_mln desc
		),
		cte2 as (
			select *,
			dense_rank() over(partition by region order by gross_sales_mln desc) as drnk
			from cte1
		)
	select * from cte2 where drnk<=2
		