--отчет содержит информацию о выручке по дням недели
with t1 as
(
--запрос на нахождение суммы выручки продовца по дате и продавцу
	select distinct concat(first_name,' ',last_name) as seller 
		,sale_date
		,sum(quantity*price) over(partition by sale_date, sales_person_id) as sumperson
	from employees e 
		inner join sales s on e.employee_id = s.sales_person_id
		inner join products p on p.product_id = s.product_id
),
sumday as 
(
--запрос на преобразование даты в день недели
	select seller,  to_char(sale_date,'day') as day_of_week ,sumperson from t1
)
select distinct seller, day_of_week, floor(sum(sumperson) over(partition by day_of_week,seller)) as income
from sumday
order by day_of_week, seller




