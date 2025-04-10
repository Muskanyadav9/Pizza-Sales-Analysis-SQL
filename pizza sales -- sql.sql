create database pizza_sales;
use pizza_sales;

create table orders(
			order_id int not null,
            order_date date not null,
            order_time time not null,
            primary key(order_id)
			); 
            
            
create table order_details(
			order_details_id int not null,
			order_id int not null,
            pizza_id text not null,
            quantity int not null,
            primary key(order_details_id)
			);
 
 
 select * from order_details;
 select * from orders;
 select * from pizza_types;


-- total no. of orders placed
select count(order_id) as total_orders from orders;

-- total revenue genertaed from pizza sales
select round(sum(od.quantity*p.price),2) as total_sales
from order_details as od join pizzas as p
on od.pizza_id=p.pizza_id;

-- highest priced pizza
select pt.name, p.price 
from pizza_types as pt join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
order by p.price desc limit 1;

-- most common pizza size ordered
select p.size, count(od.order_details_id) as order_count
from pizzas as p join order_details as od
on p.pizza_id =  od.pizza_id
group by p.size order by order_count desc;

-- 5 most ordered pizza types along with their quantites
select pt.name , sum(od.quantity) as quantity
from pizza_types as pt join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.name
order by quantity desc limit 5;

-- total quantity of each pizza category ordered
select pt.category , sum(od.quantity) as quantity
from pizza_types as pt join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category
order by quantity desc ;

-- distribution of orders by hours of the day
select hour(order_time), count(order_id)
from orders
group by hour(order_time);

-- category wise distribution of pizza
select category, count(name)
from pizza_types
group by category;

-- grouping the orders by date and finding the average no. of pizzas delivered all day
select round(avg(quantity),0) as avg_pizza_ordered_per_day
from (select o.order_date, sum(od.quantity) as quantity 
from orders as o join order_details as od
on o.order_id = od.order_id
group by o.order_date) as order_quantity;

-- top 3 most ordered pizza based on revenue
select pt.name , sum(p.price*od.quantity) as revenue
from pizza_types as pt join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.name
order by revenue desc limit 3;

-- percentage contribution of each pizza type to total revenue
select pt.category , round(sum(p.price*od.quantity)/(select round(sum(od.quantity*p.price),2) as total_sales
														from order_details as od join pizzas as p
														on od.pizza_id=p.pizza_id)*100,2) as revenue
    from pizza_types as pt join pizzas as p
	on pt.pizza_type_id = p.pizza_type_id
	join order_details as od
	on p.pizza_id = od.pizza_id
	group by pt.category
	order by revenue desc ;
    
-- cumulative revenue generated over time
select order_date , sum(total_revenue) over(order by order_date) as cum_revenue
from (select o.order_date , sum(od.quantity*p.price) as total_revenue
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id
join orders as o  
on o.order_id = od.order_id
group by o.order_date) as sales;

-- top 3 most ordered pizza types based on revenue for each category
select name, revenue
from (select category, name, revenue, rank() over(partition by category order by revenue desc) as ranking
from (select pt.category , pt.name , sum(od.quantity*p.price) as revenue
from pizza_types as pt join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by pt.category , pt.name) as a) as b
where ranking<=3;


