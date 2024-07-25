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
    age_category,
    count(age) as age_count
from t1
group by age_category
order by age_category;
-------------------------------------------------------------------------
--отчет по количеству уникальных покупателей и выручке, которую они принесли
with t1 as (
--приведение столбца sale_date к виду ГОД-МЕСЯЦ
--подсчет суммы выручки за этот месяц округленной до целого
    select distinct
        s.customer_id,
        to_char(s.sale_date,'YYYY-MM') as selling_month,
        floor(sum(s.quantity * p.price) 
            over (partition by date_trunc('month', s.sale_date))) as income
    from sales s
    inner join products p on s.product_id = p.product_id
    order by to_char(s.sale_date,'YYYY-MM')
)

--запрос на получение итогового результата
select
    selling_month,
    count(customer_id) as total_customers,
    income
from t1
group by selling_month, income
order by selling_month;
