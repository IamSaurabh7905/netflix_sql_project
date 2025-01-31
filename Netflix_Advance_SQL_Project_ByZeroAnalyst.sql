create table  netflix_data
(
show_id varchar(10),
type varchar(10),
title varchar(150),
director varchar(250),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int8,
rating varchar(20),
duration varchar(20),
listed_in varchar(150),
description varchar(250)
);
select count(*) from netflix_data;


--15 Business Problems & Solutions
--1. Count the number of Movies vs TV Shows
select 
	type,
	count(*) as total_Content
from netflix_data
group by type;

--2. Find the most common rating for movies and TV shows
select
	type,
	rating
from 
(
	select
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) desc) as Ranking
	from netflix_data
	group by 1,2 
) as t1
where Ranking =1;
--3. List all movies released in a specific year (e.g., 2020)
select * from netflix_data
	where
	type = 'Movie'
	and
	release_year =2020;
--4. Find the top 5 countries with the most content on Netflix
select 
	unnest (string_to_array(country, ',')) as new_country,
	count(show_id) as total_content
from netflix_data
group by 1
order by 2 desc
limit 5;
--5. Identify the longest movie
select * from netflix_data 
where 
	type = 'Movie'
	and duration = (select max(duration) from netflix_data);
--6. Find content added in the last 5 years
select 
	*
from netflix_data
where
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *FROM
(
SELECT *,UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM netflix_data
)
WHERE director_name = 'Rajiv Chilaka';
--8. List all TV shows with more than 5 seasons
select * from netflix_data
where type = 'TV Show'
and
SPLIT_PART(duration, ' ', 1)::numeric > 5;

--9. Count the number of content items in each genre
select 
	unnest (string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix_data
group by genre;
--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!
select 
	extract(year from TO_DATE(date_added, 'Month DD, YYYY')) as year ,
	count(*) as yearly_content,
	round(
	count(*)::numeric/(select count(*) from netflix_data where country = 'India')::numeric *100 ,2)
	as avg_content_per_year
from netflix_data
where country = 'India'
group by 1;
--11. List all movies that are documentaries
select * from netflix_data
where 
	listed_in ilike '%documentaries%';
--12. Find all content without a director
select * from netflix_data
where director IS NULL;
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_data
where 
	casts ilike '%Salman Khan%'
	and
	release_year > extract(year from current_date) - 10;
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select
unnest(string_to_array(casts, ',')) as actors,
count(*) as Total_content
from netflix_data
where country ilike '%india%'
group by 1
order by 2 desc
limit 10;
--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_data
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

--Thank You