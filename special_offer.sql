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
where row = 1