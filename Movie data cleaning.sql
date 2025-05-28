
-- Q1. find the total number of rows in each of the schema?
-- 2 ways
-- 1) we can take count of the table individully
-- 2) or fetch the names from the information schema and sum the table row to get count



select count(*) from director_mapping;
-- no of rows 3867
select count(*) from genre;
-- no of rows 14662
select count(*) from movie;
-- no of rows 7997
select count(*) from names;
-- no of rows 25735
select count(*) from role_mapping;
-- no of rows 15615
select count(*) from ratings;
-- no of rows 7997


-- Q2 which columns in the movie table have null values?
-- country (20), wgincome(3724), languages(194),production(528)
select
(select count(*) from movie where id is null) as id,
(select count(*) from movie where title is null) as title,
(select count(*) from movie where year is null) as year,
(select count(*) from movie where date_published is null) as date_published,
(select count(*) from movie where duration is null) as duration,
(select count(*) from movie where country is null) as country,
(select count(*) from movie where worldwide_gross_income is null) as worldwide_gross_income,
(select count(*) from movie where languages is null) as languages,
(select count(*) from movie where production_company is null) as production_company;


-- Q3 find total numbers of movies released each year? how does the trend look month wise
select 
	year,
	count(title) as number_of_movies
from
	movie
group by year;


-- year 2017 had the highest movie released with 3052
select
	month(date_published) as month_num,
    count(*) as number_of_movies
from
	movie
group by month_num
order by month_num;


-- march has the highest and december has the lowest films released



-- Q4 how many movies were produced in the USA or India in the year 2019?
select
	count(distinct id) as no_movies,
	year
from
	movie
where (country like '%india%'
		or country like '%USA%')
	and year = 2019
group by 	
	year;
    
select
	count(distinct id) as no_of_movies,
    year
from
	movie
where (country like '%india%' or country like '%USA%')
and year = 2019
group by year;

-- 1059 were produced in year 2019


-- Q5 find the unique list of the genres present in the dataset?

select
	distinct genre
from 
	genre;
    
    
-- Q6 which genre had the highest number of movies produced overall?
select
	g.genre,
    count(m.id) as no_of_movies
from 
	movie m
join 
	genre g on g.movie_id = m.id
group by g.genre
order by no_of_movies desc;
-- drama produced the most movies (4285)




-- Q7 how many movies belong to only one genre?
    
select
	genre_count,
    count(movie_id)
from
	(select
		movie_id,
		count(genre) as genre_count
	from
		genre
	group by movie_id
	order by genre_count desc) genre_counts
where
	genre_count = 1
group by 
	genre_count;
-- 3289 movies have exactly one genre.
    





-- Q8 what is the average duration of movies in each genre.

select
	g.genre,
	round(avg(m.duration),2) as avg_duration
from
	movie m 
join
	genre g on g.movie_id = m.id
group by genre
order by avg_duration desc;
-- action has the longest avg_duration with 112.88 minutes and horror movies with the least duration with 92.72 minutes





-- Q9 what is the rank of the thriller genre of movies among all the genre in terms of movies produced

with genre_summary as
	(select
		genre,
		count(movie_id) as movie_count,
		rank() over(order by count(movie_id) desc) as genre_rank
	from
		genre
	group by
		genre)
select
	*
from
	genre_summary;
-- or 
select
	genre,
	count(movie_id) as movie_count,
	rank() over(order by count(movie_id) desc) as genre_rank
from
	genre
group by
	genre;
-- thriller is rank 3rd






-- Q10 find the min and max values in each column of the ratings table except the movie_id column?

select
	min(avg_rating) as min_avg_rating,
	max(avg_rating) as max_avg_rating,
	min(total_votes) as min_total_votes,
	max(total_votes) as max_total_votes,
	min(median_rating) as min_median_rating,
	max(median_rating) as max_median_rating
from
	ratings;



-- Q11 which are the top 10 movies based on average rating
select
	m.title,
    r.avg_rating,
    dense_rank() over (order by r.avg_rating desc)
from
	movie m
join
	ratings r on r.movie_id = m.id
limit 10;

-- Q12 summarise the ratings table based on the movie counts by median rating
select * from ratings;


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)
select
	production_company,
    count(id),
    dense_rank() over (order by count(id)desc)
from
	movie m
join ratings r on r.movie_id = m.id
where r.avg_rating > 8
	and production_company is not null
group by production_company;
-- dream warrior pictures and national theater live both have the most hit movies with 3 movies


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
SELECT * FROM imdb.movie;

select
	g.genre,
	count(m.id) as movie
from
	movie m
join 
	genre g on g.movie_id = m.id
join
	ratings r on r.movie_id = g.movie_id
where month(date_published) = 3
	and country like '%USA%'
	and total_votes > 1000
    and year = 2017	
group by g.genre
order by movie desc;
-- drama had 24 movies
    
    
    

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
select
	m.title,
    r.avg_rating,
    g.genre
from
	movie m
join
	ratings r on r.movie_id = m.id
join
	genre g on g.movie_id = r.movie_id
where avg_rating > 8
	and title like 'THE%'
order by avg_rating desc;



-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
select
    median_rating,
    count(*) as movie_count
from
	movie m
join
	ratings r on r.movie_id = m.id
where
	m.date_published between '2017-04-01' and '2019-04-01'
	and median_rating = 8
group by median_rating;
-- 703 movies




-- Q17. Do German movies get more votes than Italian movies?
SELECT * FROM imdb.movie; 
select
	m.country,
    sum(r.total_votes) as total_votes
from
	movie m
join ratings r on r.movie_id = m.id
where m.country = 'Germany' or m.country = 'Italy'
group by m.country;
-- germans get more total votes with 106710 while italy has 77965




-- Q18. Which columns in the names table have null values??
select * from names;

select
	sum(case 
			when name is null then 1
            else 0 end) as name_null,
	sum(case
			when height is null then 1
            else 0 end) as height_null,
	sum(case
			when date_of_birth is null then 1
            else 0 end) as date_of_birth_null,
	sum(case
			when known_for_movies is null then 1
            else 0 end) as known_for_movie_null
from
	names;


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
with top_3_genre
as (
	select 
		genre,
		count(m.id) as movie_count,
        rank() over (order by count(m.id) desc) as genre_rank
	from
		movie m
	join
		genre as g on g.movie_id = m.id
	join 
		ratings as r on r.movie_id = m.id
	where avg_rating > 8
    group by genre limit 3) 
select
	n.name as director_name,
    count(dm.movie_id) as movie_count
from
	director_mapping as dm
join
	genre g using(movie_id)
join 
	names as n on n.id = dm.name_id
join 
	top_3_genre using (genre)
join
	ratings using (movie_id)
where avg_rating > 8
group by name
order by movie_count desc limit 3;
-- James mangold (4)
-- Anthony russo (3)
-- Soubin shahir (3)





-- Q20. Who are the top two actors whose movies have a median rating >= 8?
select
	n.name as actor_name,
    count(movie_id) as movie_count
from
	role_mapping rm
join
	movie m on m.id = rm.movie_id
join
	ratings r using(movie_id)
join 
	names n on n.id = rm.name_id
where 
	r.median_rating >= 8
	and category = 'actor'
group by
	actor_name
order by 
	movie_count desc limit 2;
-- mammoothy (8)
-- mohanial (5)





-- Q21 Which are the top three production houses based on the number of votes received by their movies?
select
	m.production_company,
    sum(r.total_votes) as vote_count,
    rank() over(order by sum(r.total_votes) desc) as rank_by_votes
from
	movie m
join
	ratings r on r.movie_id = m.id
group by
	m.production_company
limit 3;
-- Marvel studios
-- Twentieth Century fox
-- Warner Bros


-- Q22 Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- actor should have acted in at least 5 films



with actor_summary as (SELECT
    n.name, 
    SUM(r.total_votes) AS total_votes,
    COUNT(r.movie_id) AS movie_count,
    ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actor_avg_rating
FROM 
    movie m
JOIN
    ratings r ON r.movie_id = m.id
JOIN
    role_mapping rm ON rm.movie_id = m.id
JOIN 
    names n ON n.id = rm.name_id
WHERE rm.category = 'actor'
    AND m.country = 'india'
GROUP BY n.name
HAVING movie_count >= 5)
select
	*,
    dense_rank () over(order by actor_avg_rating desc)
from
	actor_summary;




select * from director_mapping;
select * from movie;
select * from genre;
select * from names;
select * from ratings;
select * from role_mapping;

-- Q23 Find out the top five actresses in Hindi movies released in India based on their average ratings? 

select
	n.name,
    sum(r.total_votes),
    count(r.movie_id) as movie_count,
    round(sum(r.avg_rating*r.total_votes)/sum(r.total_votes),2) as actress_avg_rating
from
	movie m
join
	ratings r on r.movie_id = m.id
join
	role_mapping rm on rm.movie_id = m.id
join
	names n on n.id= rm.name_id
where
	upper(m.country) = 'india' 
    and upper(m.languages) = '%hindi%'
    and upper(rm.category) = 'actress'
group by n.name
having movie_count >=3;
    
    
	
	



select * from director_mapping;
select * from movie;
select * from genre;
select * from names;
select * from ratings;
select * from role_mapping;

-- Q24. Select thriller movies as per avg rating and classify them in the following category: 
with thriller_movie as(
	select
		distinct(title),
        avg_rating
	from
		movie m
	join
		ratings r on r.movie_id = m.id
	join
		genre g on g.movie_id = m.id
	where 
		g.genre like 'Thriller')
select
	*,
    case when avg_rating > 8 then 'superhit movie'
	when avg_rating between 7 and 8 then 'hit movie'
    when avg_rating between 5 and 7 then 'one time watch'
    else 'flop movie'
    end as avg_rating_category
from
	thriller_movie
order by avg_rating desc;





select * from director_mapping;
select * from movie;
select * from genre;
select * from names;
select * from ratings;
select * from role_mapping;

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 


select * from director_mapping;
select * from movie;
select * from genre;
select * from names;
select * from ratings;
select * from role_mapping;
-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 

select
	title,
	CAST(replace(replace(ifnull(worldwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income,
    year
from
	movie
order by worldwide_gross_income desc;

 SELECT genre,
                Count(m.id) AS movie_count ,
                Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
         FROM movie AS m
              INNER JOIN genre AS g
                     ON g.movie_id = m.id
              INNER JOIN ratings AS r
                     ON r.movie_id = m.id
         GROUP BY genre limit 3 , movie_summary;
         
      SELECT genre, year,
                title AS movie_name,
                CAST(replace(replace(ifnull(worldwide_gross_income,0),'INR',''),'$','') AS decimal(10)) AS worlwide_gross_income ,
                DENSE_RANK() OVER(partition BY year ORDER BY CAST(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') AS decimal(10))  DESC ) AS movie_rank
         FROM movie AS m
              INNER JOIN genre AS g
                    ON m.id = g.movie_id
         GROUP BY   movie_name;



-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?










