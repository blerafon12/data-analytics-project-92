--считаем количиство ID пользователей из таблицы customers
select count(customer_id) as custamers_count from customers
-----------------------------------------------------------------
--количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
with t1 as
(
--запрос для распределения возрастных груп относительно столбца age 
select age,
	case 
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category
from customers c 
)
--запрос на получение итогового результата
--определение выборки с уникальными значениями и подсчет покупателей определенной возрастной группы
select distinct age_category
	,count(age) over(partition by age_category) as age_count
from t1
order by age_category
 -------------------------------------------------------------------------
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
------------------------------------------------------------------------------
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
select distinct seller, day_of_week, floor(sum(sumperson) over(partition by day_of_week,seller)) as income
	,(case 
		when day_of_week like '%monday%' then 1
		when day_of_week like '%tuesday%' then 2
		when day_of_week like '%wednesday%' then 3
		when day_of_week like '%thursday%' then 4
		when day_of_week like '%friday%' then 5
		when day_of_week like '%saturday%' then 6
		when day_of_week like '%sunday%' then 7
	end) as nomday
	
from sumday
order by nomday, seller
)
--запрос на вывод итогового отчета
select seller, day_of_week, income from cas
----------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------------
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
select distinct seller, operations, floor(income) as income from total
order by income desc limit 10