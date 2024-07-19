--отчет содержит информацию о продавцах, 
--чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
with t1 as
(
--запрос на нахождение суммы выручки по продукту и продавцу,
--подсчет количества сделок продавца
select sales_id, s.product_id, sales_person_id,concat(first_name,' ',last_name) as saler 
		,sum(quantity*price) over(partition by s.product_id, sales_person_id) as sumperson
		,count(sales_id) over(partition by sales_person_id) as c_saler
	from employees e 
		inner join sales s on e.employee_id = s.sales_person_id
		inner join products p on p.product_id = s.product_id
),
t2 as 
(
--запрос на нахождение среднего по продавцу и среднего по всем продажам
select distinct saler, c_saler
	,avg(sumperson) over(partition by saler) as avgsaler
	,avg(sumperson) over() as avgall
from t1
order by saler
)
--запрос на получение итогового результата
select saler, round(avgsaler) as average_income from t2
where avgsaler<avgall
order by avgsaler