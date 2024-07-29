--считаем количиство ID пользователей из таблицы customers
select count(customer_id) as custamers_count from customers;
-----------------------------------------------------------------
--запрос на получение итогового результата
--определение выборки с уникальными значениями 
--и подсчет покупателей определенной возрастной группы
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        when age > 40 then '40+'
    end as age_category,
    count(age) as age_count
from customers
group by age_category
order by age_category;
-------------------------------------------------------------------------
--отчет по количеству уникальных покупателей и выручке, которую они принесли
--запрос на получение итогового результата
--приведение столбца sale_date к виду ГОД-МЕСЯЦ
--подсчет суммы выручки за этот месяц округленной до целого
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    floor(
        sum(s.quantity * p.price)
    ) as income,
    count(distinct s.customer_id) as total_customers
from sales as s
inner join products as p on s.product_id = p.product_id
group by to_char(s.sale_date, 'YYYY-MM')
order by selling_month;
------------------------------------------------------------------------------
--отчет содержит информацию о выручке по дням недели
--запрос на получение итогового результата
--отсортировать по дням не получается
select
    concat(e.first_name, ' ', e.last_name) as seller,
    to_char(s.sale_date, 'day') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller, day_of_week, date_part('isodow', s.sale_date)
order by date_part('isodow', s.sale_date), seller;
-----------------------------------------------------------------
--отчет содержит информацию о продавцах, 
--чья средняя выручка за сделку меньше средней выручки за сделку 
--по всем продавцам
--запрос на получение итоговых значений
select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(s.quantity * p.price)) as avg
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller, s.sales_person_id
having
    floor(avg(s.quantity * p.price)) < (
        select avg(s.quantity * p.price)
        from sales as s
        inner join products as p on s.product_id = p.product_id
    )
order by avg;
------------------------------------------------------------------
--отчет о десятке лучших продавцов
--запрос на получение итогового результата
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s on e.employee_id = s.sales_person_id
inner join products as p on s.product_id = p.product_id
group by seller
order by income desc limit 10;
-----------------------------------------------------------------------
--отчет о покупателях, первая покупка которых 
--была в ходе проведения акций 
--(акционные товары отпускали со стоимостью равной 0)
--запрос с итоговым результатом
select distinct on (concat(c.first_name, ' ', c.last_name))
    s.sale_date,
    concat(c.first_name, ' ', c.last_name) as customer,
    concat(e.first_name, ' ', e.last_name) as seller
from customers as c
inner join sales as s on c.customer_id = s.customer_id
inner join employees as e on s.sales_person_id = e.employee_id
inner join products as p on s.product_id = p.product_id
where p.price = 0
order by customer, s.sale_date;
