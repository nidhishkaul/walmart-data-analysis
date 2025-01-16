### EDA

select * from walmart limit 10;

select payment_method,count(invoice_id) 
from walmart
group by payment_method;

select count(distinct branch) from walmart;

select count(distinct city) from walmart;

select distinct category from walmart;

select min(`date`) as start_date,
max(`date`) as end_date
from walmart;

## Create another table like walmart for analysis

create table walmart_2 like walmart;

insert into walmart_2
select * from walmart;

select * from walmart_2 limit 10;

### BUSINESS PROBLEM
## 1. Find the different payment method and number of transactions, number of qty sold

select payment_method,count(*) as `number of transactions`,sum(quantity) `number of qty sold`
from walmart_2
group by payment_method
order by sum(quantity) desc;

## 2. Identify the highest rated category in each branch, displaying the branch, category and average rating

with CTE as ( 
select branch, category,round(avg(rating),2) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as `rank`
from walmart_2
group by branch,category
)
select * from CTE where `rank` = 1;

## 3. Identify the busiest day for each branch based on the number of transactions.

with CTE as (
select branch,dayname(`date`) as day_name,count(*) `total_transaction`,
rank() over(partition by branch order by count(*) desc ) as `rank`
from walmart_2
group by branch,dayname(`date`)
)
select branch,day_name,total_transaction from CTE where `rank` = 1;

## 4. Identify which was the most busiest day overall for walmart

with CTE as (
select branch,dayname(`date`) as day_name,count(*) `total_transaction`,
rank() over(partition by branch order by count(*) desc ) as `rank`
from walmart_2
group by branch,dayname(`date`)
)
select day_name,sum(total_transaction) as transactions
from CTE
group by day_name
order by sum(total_transaction) desc;

## 5.Determine the average, minimum and maximum rating of category for each city. List the city, average_rating, min_rating, max_rating

select city,category,round(avg(rating),2) `average_rating`,min(rating) `min_rating`,max(rating) `max_rating`
from walmart_2 
group by city,category
order by city;

## 6. Calculate total profit for each category considering total profit as
##(unit_price * quantity * profit_margin). List category and total_profits, ordered in descending order.

select category,round(sum(unit_price * quantity * profit_margin),2) `total_profit`
from walmart_2
group by category
order by 2 desc;

## 7. Determine the most common payment method for each branch. Display branch and the preferred payment method.

with CTE as
(
select branch,payment_method,count(payment_method) as total,
rank() over(partition by branch order by count(payment_method) desc) `rank`
from walmart_2
group by branch,payment_method
)
select branch,payment_method
from CTE where `rank` = 1;

## 8. Categorize sales into 3 group MORNING, AFTERNOON, EVENING
## Find out total number of invoices in each shift

with CTE as
(
select `time`,
case
when `time` < '12:00:00' then 'MORNING'
when `time` >= '12:00:00' and `time` < '18:00:00' then 'AFTERNOON'
when `time` >= '18:00:00' then 'EVENING'
end as `Groups`
from walmart_2
)
select `Groups`,count(*) `Invoices` from CTE
group by `Groups` order by count(*);


