--отчет содержит информацию о продавцах, 
--чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
with t1 as 
(
--запрос на получение имени, фамилии продавца; количиства сделок; выручки продавца за все сделки
select sales_id, s.product_id, sales_person_id,concat(first_name,' ',last_name) as seller 
	,count(sales_id) over(partition by sales_person_id) as c_saler
	,sum(quantity*price) over(partition by sales_person_id) as s_saler
	,count(sales_id) over() as all_c
	,sum(quantity*price) over() as all_s
from employees e 
	inner join sales s on e.employee_id = s.sales_person_id
	inner join products p on p.product_id = s.product_id
),
t2 as 
(
--запрос на получение среднего по продовцу и по всем продавцам
select distinct seller
	,floor(s_saler/c_saler) as average_income
	,floor(all_s/all_c) as average_all
from t1
order by average_income
)
--запрос на получение итоговых значений
select seller,average_income from t2
where average_income<average_all

















