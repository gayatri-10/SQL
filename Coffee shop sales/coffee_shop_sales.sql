create database coffee_shop_sales_db;
use coffee_shop_sales_db;
select * from coffee_shop_sales;

describe coffee_shop_sales;

SET SQL_SAFE_UPDATES = 0;

update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date date;

describe coffee_shop_sales; 

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

describe coffee_shop_sales;

select * from coffee_shop_sales;

alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id int;

describe coffee_shop_sales;

select * from coffee_shop_sales;

-- Total Sales :-
select sum(unit_price * transaction_qty) as Total_Sales 
from coffee_shop_sales;

-- Sales for the month of May :- 
select sum(unit_price * transaction_qty) as Sales_of_May 
from coffee_shop_sales
where month(transaction_date) = 5;

-- Sales for March :-
select sum(unit_price * transaction_qty) as Sales_of_March
from coffee_shop_sales
where month(transaction_date) = 3;

-- Total Sales KPI - month difference and month growth :-
select month(transaction_date) as month,
    round(sum(unit_price * transaction_qty)) as total_sales,
    (sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty), 1)
    over(order by month(transaction_date))) / lag(sum(unit_price * transaction_qty), 1) 
    over(order by month(transaction_date)) * 100 as mon_increase_percentage
from coffee_shop_sales
where month(transaction_date) IN (4, 5) -- for months of April and May
group by month(transaction_date)
order by month(transaction_date);

-- Total Orders in May:-
select count(transaction_id) as Total_Orders
from coffee_shop_sales 
where month(transaction_date)= 5; -- for month of (CM-May)

-- Total orders KPI - Month Difference and Month Growth :- 
select month(transaction_date) as month,
    round(count(transaction_id)) as total_orders,
    (count(transaction_id) - lag(count(transaction_id), 1) 
    over(order by month(transaction_date))) / lag(count(transaction_id), 1) 
    over(order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4, 5) -- for April and May
group by month(transaction_date)
order by month(transaction_date);

-- Total Quantity Sold :-
select sum(transaction_qty) as Total_Quantity_Sold
from coffee_shop_sales 
where month(transaction_date) = 5; -- for month of (CM-May)

-- Total Quantity Sold KPI - Month Difference and Month Growth :- 
select month(transaction_date) as month,
    round(sum(transaction_qty)) as total_quantity_sold,
    (sum(transaction_qty) - lag(sum(transaction_qty), 1) 
    over(order by month(transaction_date))) / lag(sum(transaction_qty), 1) 
    over(order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4, 5)   -- for April and May
group by month(transaction_date)
order by month(transaction_date);

-- Calendar Table – Daily Sales, Quantity and Total Orders :-
select sum(unit_price * transaction_qty) as total_sales,
    sum(transaction_qty) as total_quantity_sold,
    count(transaction_id) as total_orders
from coffee_shop_sales
where transaction_date = '2023-05-18'; -- For 18 May 2023

-- Rounded off values :-
select concat(round(sum(unit_price * transaction_qty) / 1000, 1),'K') as total_sales,
    concat(round(count(transaction_id) / 1000, 1),'K') as total_orders,
    concat(round(sum(transaction_qty) / 1000, 1),'K') as total_quantity_sold
from coffee_shop_sales
where transaction_date = '2023-05-18'; -- For 18 May 2023
 
-- Sales Trend Over Period :- 
select avg(total_sales) as average_sales
from(
	select 
        sum(unit_price * transaction_qty) as total_sales
    from coffee_shop_sales
	where month(transaction_date) = 5  -- Filter for May
    group by transaction_date
) as internal_query;

-- Daily Sales for Month Selected :-
select day(transaction_date) as day_of_month,
    round(sum(unit_price * transaction_qty),1) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5  -- Filter for May
group by day(transaction_date)
order by day(transaction_date);

-- Comparing Daily Sales with Average Sales :-
select 
    day_of_month,
    case 
        when total_sales > avg_sales then 'Above Average'
        when total_sales < avg_sales then 'Below Average'
        else 'Average'
    end as sales_status,
    total_sales
from (
    select day(transaction_date) as day_of_month,
        sum(unit_price * transaction_qty) as total_sales,
        avg(sum(unit_price * transaction_qty)) over() as avg_sales
    from coffee_shop_sales
    where month(transaction_date) = 5  -- Filter for May
    group by day(transaction_date)
) as sales_data
order by day_of_month;

-- Sales by Weekday / Weekend :-
select 
    case 
        when dayofweek(transaction_date) in (1, 7) then 'Weekends'
        else 'Weekdays'
    end as day_type,
    round(sum(unit_price * transaction_qty),2) as total_sales
from 
    coffee_shop_sales
where 
    month(transaction_date) = 5  -- Filter for May
group by 
    case 
        when dayofweek(transaction_date) in (1, 7) then 'Weekends'
        else 'Weekdays'
    end;
    
-- Sales by Store location :- 
select 
	store_location,
	sum(unit_price * transaction_qty) as Total_Sales
from coffee_shop_sales
where
	month(transaction_date) = 5 
group by store_location
order by sum(unit_price * transaction_qty) desc;
 
-- Sales by Product Category :- 
select product_category,
	round(sum(unit_price * transaction_qty),1) as Total_Sales
from coffee_shop_sales
where month (transaction_date) = 5 
group by product_category
order by sum(unit_price * transaction_qty) desc;

-- Sales by Products (Top 10) :-
select product_type,
	round(sum(unit_price * transaction_qty),1) as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5 
group by product_type
order by sum(unit_price * transaction_qty) desc
limit 10;

-- Sales by Day / Hour :-
select round(sum(unit_price * transaction_qty)) as Total_Sales,
    sum(transaction_qty) as Total_Quantity,
    count(*) as Total_Orders
from coffee_shop_sales
where dayofweek(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    and hour(transaction_time) = 8 -- Filter for hour number 8
    and month(transaction_date) = 5; -- Filter for May (month number 5)
    
-- To get the sales for all Hours for the month of May ;-
select hour(transaction_time) as Hour_of_Day,
    round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5 -- Filter for May (month number 5)
group by hour(transaction_time)
order by hour(transaction_time);