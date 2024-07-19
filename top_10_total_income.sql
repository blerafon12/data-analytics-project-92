--отчет о десятке лучших продавцов
with total as
(
--запрос на подсчет количества сделок продовца
-- нахождение суммы продаж для продавца
select distinct sales_person_id ,concat(first_name,' ',last_name) as seller ,sales_id
	,count(sales_id) over(partition by sales_person_id) as operations
	,sum(price*quantity) over(partition by sales_person_id) as income
from employees e 
inner join sales s on e.employee_id = s.sales_person_id
inner join products p on p.product_id = s.product_id
order by sales_id
)
--запрос на получение итогового результата
select distinct seller, operations, income from total
order by income desc limit 10