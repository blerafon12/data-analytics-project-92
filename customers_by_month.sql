--отчет по количеству уникальных покупателей и выручке, которую они принесли
--запрос на получение итогового результата
--приведение столбца sale_date к виду ГОД-МЕСЯЦ
--подсчет количества покупателей в месяц
--подсчет суммы выручки за этот месяц округленной до целого
select distinct to_char(sale_date,'YYYY-MM') as selling_month
	,count(customer_id) over(partition by date_trunc('month', sale_date)) as total_customers
	,round(sum(quantity*price) over(partition by date_trunc('month', sale_date))) as income
from sales s
inner join products p  on p.product_id = s.product_id 
order by selling_month
