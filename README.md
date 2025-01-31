# Netflix Movies and TV Shows Data Analysis using SQL
![logo](https://github.com/IamSaurabh7905/netflix_sql_project/blob/main/logo.png)
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objective
* Analyze the distribution of content types (movies vs TV shows).
* Identify the most common ratings for movies and TV shows.
* List and analyze content based on release years, countries, and durations.
* Explore and categorize content based on specific criteria and keywords

## Dataset
The data for this project is sourced from the Kaggle dataset:

* Dataset Link-->> [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)


## Schema


```DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions
1. Count the Number of Movies vs TV Shows
```
select 
type,
count(*) as total_Content
from netflix_data
group by type;
```
* Objective: Determine the distribution of content types on Netflix.

2. Find the most common rating for movies and TV shows
 ```
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
```
* Objective: Identify the most frequently occurring rating for each type of content.

3. List all movies released in a specific year (e.g., 2020)
```
select * from netflix_data
	where
	type = 'Movie'
	and
	release_year =2020;
```
* Objective: Retrieve all movies released in a specific year.

4. Find the top 5 countries with the most content on Netflix
```
select 
	unnest (string_to_array(country, ',')) as new_country,
	count(show_id) as total_content
from netflix_data
group by 1
order by 2 desc
limit 5;
```
* Objective: Identify the top 5 countries with the highest number of content items.
  
5. Identify the longest movie
```
select * from netflix_data 
where 
	type = 'Movie'
	and duration = (select max(duration) from netflix_data);
```
* Objective: Find the movie with the longest duration.

6. Find content added in the last 5 years
```
select 
	*
from netflix_data
where
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```
* Objective: Retrieve content added to Netflix in the last 5 years.
  
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
```
SELECT *FROM
(
SELECT *,UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM netflix_data
)
WHERE director_name = 'Rajiv Chilaka';
```
* Objective: List all content directed by 'Rajiv Chilaka'.
  
8. List all TV shows with more than 5 seasons
```
select * from netflix_data
where type = 'TV Show'
and
SPLIT_PART(duration, ' ', 1)::numeric > 5;
```
* Objective: Identify TV shows with more than 5 seasons.
  
9. Count the number of content items in each genre
```
select 
	unnest (string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix_data
group by genre;
```
* Objective: Count the number of content items in each genre.
  
10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!
```
select 
	extract(year from TO_DATE(date_added, 'Month DD, YYYY')) as year ,
	count(*) as yearly_content,
	round(
	count(*)::numeric/(select count(*) from netflix_data where country = 'India')::numeric *100 ,2)
	as avg_content_per_year
from netflix_data
where country = 'India'
group by 1;
```
* Objective: Calculate and rank years by the average number of content releases by India.


11. List all movies that are documentaries
```
select * from netflix_data
where 
	listed_in ilike '%documentaries%';
```
* Objective: Retrieve all movies classified as documentaries.

12. Find all content without a director
```
select * from netflix_data
where director IS NULL;
```
* Objective: List content that does not have a director.
  
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
```
select * from netflix_data
where 
	casts ilike '%Salman Khan%'
	and
	release_year > extract(year from current_date) - 10;
```
* Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
```
select
unnest(string_to_array(casts, ',')) as actors,
count(*) as Total_content
from netflix_data
where country ilike '%india%'
group by 1
order by 2 desc
limit 10;
```
* Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

```
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
```
* Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion
* Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
* Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
* Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
* Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

  
## This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

