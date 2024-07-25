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
        to_char(s.sale_date, 'YYYY-MM') as selling_month,
        floor(
            sum(s.quantity * p.price)
                over (partition by date_trunc('month', s.sale_date))
        ) as income
    from sales as s
    inner join products as p on s.product_id = p.product_id
    order by to_char(s.sale_date, 'YYYY-MM')
)

--запрос на получение итогового результата
select
    selling_month,
    income,
    count(customer_id) as total_customers
from t1
group by selling_month, income
order by selling_month;
------------------------------------------------------------------------------
--отчет содержит информацию о выручке по дням недели
with t1 as (
--запрос на нахождение суммы выручки продовца по дате и продавцу
    select
        sale_date,
        concat(first_name, ' ', last_name) as seller,
        sum(quantity*price) as sumperson
    from employees as e 
    inner join sales s on e.employee_id = s.sales_person_id
    inner join products p on p.product_id = s.product_id
    group by concat(first_name, ' ', last_name), sale_date
),
sumday as (
--запрос на преобразование даты в день недели
--определение начала недели (1-понедельник, 2-вторник,...,7-воскресенье)
    select
        seller,
        sumperson,
        to_char(sale_date,'day') as day_of_week,
        DATE_PART('isodow', sale_date) as nomday
    from t1
)
select
    seller,
    day_of_week,
    floor(sum(sumperson)) as income 
from sumday
group by seller, day_of_week, nomday
order by nomday,seller;
