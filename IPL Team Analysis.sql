use[SQL_Practice]
select * from[dbo].[IPLPlayers]

-- Q1 Find the total spending on players for each team
select Team,SUM(Price_in_cr) as Total_Spending
from IPLPlayers
group by Team
order by Total_Spending desc;

-- Q2 Find the top 3 highest-paid 'All-rounders' across all teams ; 
select top 3 Player,Team,Price_in_cr
from IPLPlayers 
where Role='All-rounder' 
order by Price_in_cr desc;

-- Q3 Find the highest - priced player in each team
--Way1
with cte1 as (
select *,ROW_NUMBER() over (partition by Team order by price_in_cr desc) as rnk
from IPLPlayers)
select * from cte1 where rnk=1 order by Price_in_cr desc;


--Way2
with cte2 as
			(select Team,max(Price_in_cr) as max_price
			from IPLPlayers
			group by Team)

select t1.Player,t1.Price_in_cr,t1.Team
from IPLPlayers t1
join cte2 t2
on t1.Team=t2.Team
where t1.Price_in_cr = t2.max_price
order by Price_in_cr desc;

-- Q4 Rank Players by their price within each team and list the top 2 from every team
with CTE as
			(select Player,Team,Price_in_cr,row_number()over(partition by team order by price_in_cr desc) as rankwithinteam
			from IPLPlayers)
select *
from CTE
where rankwithinteam<=2;

-- Q5 Find the most expensive player from each team, along with second - most expensive player's name and price
with CTE as
			(select Player,Team,Price_in_cr,row_number()over(partition by team order by price_in_cr desc) as rankwithinteam
			from IPLPlayers)
select Team,
	MAX(Case when rankwithinteam = 1 then player end) as Mostexpensiveplayer,
	MAX(Case when rankwithinteam = 1 then Price_in_cr end) as Mostexpensiveplayer_price,
	MAX(Case when rankwithinteam = 2 then Player end) as "Second-Mostexpensiveplayer",
	MAX(Case when rankwithinteam = 2 then Price_in_cr end) as "Second-Mostexpensiveplayer_price"
from CTE
group by Team;

--use Max as aggregate bcz we use group by

-- Q6 Calculate the % contribution of each player's price to their team's total spending
 
SELECT 
    Player,
    Team,
    cast((Price_in_cr  / SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 as decimal(4,2) )as Contribution_Percentage
FROM IPLPlayers;

/* Q7 Clasify players as 'High' ,'Medium', or 'Low' priced based on the following rules:
      High : Price > ₹15 Crore
	  Medium : Price between ₹5 Crore and ₹15 Crore
	  Low : Price < ₹5 Crore
	  and find the numbers of players in each bucket
*/

with CTE as 
(select player,team,price_in_cr,
	Case when Price_in_cr > 15 then 'High'
		 When Price_in_cr between 5 and 15 then 'Mediun'
		 else'Low' 
		 end as Classification
from IPLPlayers)

select Classification,team,COUNT(1) as Number_of_player
from CTE
group by Classification,Team
order by Team,Classification;


/* Q8 Find the average price of indian players and compare it with overseas players using subquery
*/
select 'Indian' as PlayerType,(select cast (AVG(Price_in_cr)as decimal(4,2))) as Avg_player_price from IPLPlayers where Type like 'Indian%'
Union All
select 'Overseas' as PlayerType,(select cast(AVG(Price_in_cr)as decimal(4,2))) as Avg_Overseas_player_price from IPLPlayers where Type like 'Overseas%';

-- Q9 Identify players who earn more than the average price in their team
With CTE1 as (select team,AVG(Price_in_cr) as avg_team_price from IPLPlayers group by Team)

select IP.Player,IP.Price_in_cr,IP.Team,CT1.avg_team_price
from IPLPlayers IP 
join CTE1 CT1 
on IP.Team= CT1.Team
where ip.Price_in_cr>ct1.avg_team_price
order by IP.team ;

select Player,Team,Price_in_cr
from IPLPlayers IPlp
where Price_in_cr >
(
select AVG(Price_in_cr)
from IPLPlayers
where Team = IPlp.Team);

--Correlated Query : A correlated subquery is a subquery that depends on values from the outer query and is executed once for each row of the outer query.
--👉 It cannot run independently because it references a column from the outer query.


-- Q10 For each role, find the most expensive player and their price using a correlated subquery
select Role,Player,Price_in_cr,Team
from IPLPlayers IPL
where Price_in_cr = (select MAX(Price_in_cr) from IPLPlayers where role = IPL.Role);