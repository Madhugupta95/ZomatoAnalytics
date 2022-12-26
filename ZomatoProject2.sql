CREATE TABLE goldusers_signup(user_id integer,gold_signup_date date);

INSERT INTO goldusers_signup(user_id,gold_signup_date)VALUES(1,'09-22-2017'),(3,'04-21-2017');

CREATE TABLE users(user_id integer,signup_date date);

INSERT INTO users(user_id,signup_date)VALUES(1,'09-02-2014'),(2,'01-15-2015'),(3,'04-11-2014');

CREATE TABLE sales(user_id integer,created_date date,product_id integer);

INSERT INTO sales(user_id,created_date,product_id)VALUES(1,'04-19-2017',2),(3,'12-18-2019',1),(2,'07-20-2020',3),(1,'10-23-2019',2),(1,'03-19-2018',3),(3,'12-20-2016',2),(1,'11-09-2016',1),(1,'05-20-2016',3),(2,'09-24-2017',1),(1,'03-11-2016',1),(3,'11-10-2016',1),(3,'12-07-2017',2),(3,'12-15-2016',2),(2,'11-08-2017',2),(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price)VALUES(1,'p1',980),(2,'p2',870),(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select a.user_id,sum(b.price) total_amt_spent from sales a inner join product b on a.product_id=b.product_id
group by a.user_id


select user_id,count(distinct created_date) from sales group by user_id


select * from
(select  *,rank() over (partition by user_id order by created_date ) rank from sales) a where rank = 1


select user_id,count(product_id) cmt from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by user_id


select * from
(select *,rank() over (partition by user_id order by cmt desc) rnk from 
(select user_id,product_id,count(product_id) cmt from sales group by user_id,product_id)a)b
where rnk = 1


select * from
(select c.*,rank() over(partition by user_id order by created_date ) rnk from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on  a.user_id = b.user_id and created_date >= gold_signup_date) c)d where rnk = 1;


select * from
(select c.*,rank() over(partition by user_id order by created_date desc ) rnk from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on  a.user_id = b.user_id and created_date <= gold_signup_date) c)d where rnk = 1;



select user_id,count(created_date) order_puchased,sum(price) total_amt_spend from
(select c.*,d.price from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on  a.user_id = b.user_id and created_date <= gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by user_id;



select user_id,sum(total_points)*2.5 total_money_earned from
(select e.*,amt/points total_points from
(select d.*,case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(price) amt  from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id)d)e)f group by user_id;



select * from
(select *,rank() over (order by total_points_earned desc) rnk from
(select product_id,sum(total_points) total_points_earned from
(select e.*,amt/points total_points from
(select d.*,case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select c.user_id,c.product_id,sum(price) amt  from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by user_id,product_id)d)e)f group by product_id)f)g where rnk = 1;



select c.*,d.price*0.5 total_points_earned from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on  a.user_id = b.user_id and created_date >= gold_signup_date and created_date<=DATEADD(year,1,gold_signup_date))c
inner join product d on c.product_id = d.product_id;


select *,rank() over(partition by user_id order by created_date) rnk from sales;


select e.*,case when rnk = 0 then 'na' else rnk end as rnkk from
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by user_id order by created_date desc) end) as varchar)rnk from
(select a.user_id,a.created_date,a.product_id,b.gold_signup_date from sales a left join
goldusers_signup b on a.user_id=b.user_id and created_date >= gold_signup_date)c)e