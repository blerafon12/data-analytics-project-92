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
),
cas as
(
--запрос на округление итогового результата, нумерация дней от 1-7 начиная с понедельника, 
--сортировка результата по итоговым значениям
select distinct seller, day_of_week, round(sum(sumperson) over(partition by day_of_week,seller)) as income
	,(case 
		when day_of_week like '%monday%' then 1
		when day_of_week like '%tuesday%' then 2
		when day_of_week like '%wednesday%' then 3
		when day_of_week like '%thursday%' then 4
		when day_of_week like '%friday%' then 4
		when day_of_week like '%saturday%' then 5
		when day_of_week like '%sunday%' then 6
	end) as nomday
	
from sumday
order by nomday, seller
)
--запрос на вывод итогового отчета
select seller, day_of_week, income from cas



