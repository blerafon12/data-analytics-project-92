--считаем количиство ID пользователей из таблицы customers
select count(customer_id) as custamers_count from customers;
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
	,count(age) as age_count
from t1
group by age_category
order by age_category;
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
	,count(customer_id) as total_customers
	,income
from t1
group by selling_month, income
order by selling_month;
------------------------------------------------------------------------------
--отчет содержит информацию о выручке по дням недели
with t1 as
(
--запрос на нахождение суммы выручки продовца по дате и продавцу
	select concat(first_name,' ',last_name) as seller 
		,sale_date
		,sum(quantity*price) as sumperson
	from employees e 
		inner join sales s on e.employee_id = s.sales_person_id
		inner join products p on p.product_id = s.product_id
	group by concat(first_name,' ',last_name), sale_date
),
sumday as 
(
--запрос на преобразование даты в день недели
--определение начала недели (1-понедельник, 2-вторник,...,7-воскресенье)
	select seller,  to_char(sale_date,'day') as day_of_week ,DATE_PART('isodow', sale_date) as nomday, sumperson from t1
)
select seller, day_of_week, floor(sum(sumperson)) as income from sumday
group by seller, day_of_week, nomday
order by nomday,seller;
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
where average_income<average_all;
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
order by income desc limit 10;
-----------------------------------------------------------------------------------------
--отчет о покупателях, первая покупка которых 
--была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
with t1 as
(
--запрос на объединение столбцов имя, фамилия для покупателей и продавцов
--и вывод всех строк для которых price = 0
select  s.customer_id as sc ,concat(c.first_name,' ',c.last_name) as customer, sale_date
	, concat(e.first_name,' ',e.last_name) as seller
from customers c 
inner join sales s on s.customer_id = c.customer_id
inner join employees e on s.sales_person_id = e.employee_id
inner join products p on s.product_id = p.product_id
where price = 0
),
t2 as 
(
--запрос на нумерацию строк для покупателей по дате, попавших в предыдущую выборку
select *
	,row_number() over(partition by customer order by sale_date) as row
from t1
order by sc
)
--запрос с итоговым результатом где row=1 является самой ранней датой покупки акционного товара
select customer,sale_date,seller from t2
where row = 1;