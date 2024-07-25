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
        s.sale_date,
        concat(e.first_name, ' ', e.last_name) as seller,
        sum(s.quantity * p.price) as sumperson
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
    group by concat(e.first_name, ' ', e.last_name), s.sale_date
),

sumday as (
--запрос на преобразование даты в день недели
--определение начала недели (1-понедельник, 2-вторник,...,7-воскресенье)
    select
        seller,
        sumperson,
        to_char(sale_date, 'day') as day_of_week,
        date_part('isodow', sale_date) as nomday
    from t1
)

select
    seller,
    day_of_week,
    floor(sum(sumperson)) as income
from sumday
group by seller, day_of_week, nomday
order by nomday, seller;
-----------------------------------------------------------------
--отчет содержит информацию о продавцах, 
--чья средняя выручка за сделку меньше средней выручки за сделку 
--по всем продавцам
with t1 as (
--запрос на получение имени, фамилии продавца; количиства сделок; 
--выручки продавца за все сделки
    select
        s.sales_id,
        s.product_id,
        s.sales_person_id,
        concat(e.first_name, ' ', e.last_name) as seller,
        count(s.sales_id)
            over (partition by s.sales_person_id) as c_saler,
        sum(s.quantity * p.price)
            over (partition by s.sales_person_id) as s_saler,
        count(s.sales_id)
            over () as all_c,
        sum(s.quantity * p.price)
            over () as all_s
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
),

t2 as (
--запрос на получение среднего по продовцу и по всем продавцам
    select distinct
        seller,
        floor(s_saler / c_saler) as average_income,
        floor(all_s / all_c) as average_all
    from t1
    order by average_income
)

--запрос на получение итоговых значений
select
    seller,
    average_income
from t2
where average_income < average_all;
