--считаем количиство ID пользователей из таблицы customers
select count(customer_id) as custamers_count from customers;
-----------------------------------------------------------------
--количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+
with t1 as (
--запрос для распределения возрастных груп относительно столбца age 
	select
    	age,
		case 
			when age between 16 and 25 then '16-25'
			when age between 26 and 40 then '26-40'
			when age > 40 then '40+'
		end as age_category
	from customers
)
--запрос на получение итогового результата
--определение выборки с уникальными значениями 
--и подсчет покупателей определенной возрастной группы
select 
	distinct age_category
	,count(age) as age_count
from t1
group by age_category
order by age_category;
