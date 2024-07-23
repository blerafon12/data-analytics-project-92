--отчет по количеству уникальных покупателей и выручке, которую они принесли
with t1 as 
(
--приведение столбца sale_date к виду ГОД-МЕСЯЦ
--подсчет суммы выручки за этот месяц округленной до целого
select distinct to_char(sale_date,'YYYY-MM') as selling_month, customer_id
	,floor(sum(quantity*price) over(partition by date_trunc('month', sale_date))) as income
from sales s
inner join products p  on p.product_id = s.product_id
order by selling_month 
)
--запрос на получение итогового результата
select distinct selling_month
	,count(customer_id) over(partition by selling_month) as total_customers
	,income
from t1
order by selling_month