/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

.mode column
.headers ON


/*---------------SQL Movie-Rating Query Excercises ------------*/
--Q1. Find the titles of all movies directed by Steven Spielberg.
select title from Movie where director="Steven Spielberg”;


--Q2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
select distinct year 
from Movie
where mID in (select mID from Rating where stars = 4 or stars = 5)
ORDER BY year;


--Q3. Find the titles of all movies that have no ratings. 
select title from Movie where mID in (select mID from Movie 
EXCEPT
select distinct mID from Rating);

--Q4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
select name from Reviewer where rID in (select rID from Rating where ratingDate is null);

--Q5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
select name, title, stars, ratingDate
from
(Movie join (select name, mID, stars, ratingDate 
from Reviewer join Rating using(rID)) using(mID))
order by name, title, stars;

--Q6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
select T1.name, T1.title
from (Select name, title, stars, ratingDate
from
(Movie join (select name, mID, stars, ratingDate 
from Reviewer join Rating using(rID)) using(mID))
order by name, title, stars) T1,
(Select name, title, stars, ratingDate
from
(Movie join (select name, mID, stars, ratingDate 
from Reviewer join Rating using(rID)) using(mID))
order by name, title, stars) T2
where T1.name = T2.name and T1.title = T2.title and T1.stars > T2.stars 
and T1.ratingDate > T2.ratingDate;

--Q7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
select title, stars
from 
(select M.mID, M.title, R.stars
from Movie M, Rating R
where M.mID = R.mID) 
group by title;

--Q8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select title, max(stars)-min(stars) as rangestar
from 
(select title, stars
from Movie, Rating 
where Movie.mID = Rating.mID) as MR
group by title
order by rangestar desc,title;

--Q9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
select avg(starbefore.avestar) - avg(starafter.avestar) from
(select avestar
from 
((select title, avg(stars) as avestar, year
from 
(select title, stars, year
from Movie, Rating 
where Movie.mID = Rating.mID) as MR
group by title)) 
where year < 1980) as starbefore,
(select avestar
from 
((select title, avg(stars) as avestar, year
from 
(select title, stars, year
from Movie, Rating 
where Movie.mID = Rating.mID) as MR
group by title)) 
where year > 1980) as star after;

/*---------------SQL Movie-Rating Query Excercises Extras------------*/
--Q1. Find the names of all reviewers who rated Gone with the Wind. 
select name from Reviewer
where rID in (
select distinct rID 
from Rating
where
mID = (select mID 
from Movie
where title = 'Gone with the Wind’));

--Q2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
select name,title,stars
from(
select title,mID,stars,name,director
from
(select name,mID,stars
from Reviewer natural join Rating) natural join Movie) as NT
where NT.name = NT.director;

--Q3. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
select * 
from
(select distinct name 
from 
Reviewer
union
select distinct title 
from 
Movie);

--Q4. Find the titles of all movies not reviewed by Chris Jackson.
select title
from Movie
where mID not in (select mID from
(select mID,title,rID
from Movie join Rating using(mID))
where rID = 
(select rID from Reviewer where name = 'Chris Jackson’));

--Q5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
select distinct name1, name2
from
(select R1.rID, Re1.name as name1, R2.rID, Re2.name as name2, R1.mID
from Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
where R1.mID = R2.mID
and R1.rID = Re1.rID
and R2.rID = Re2.rID
and Re1.name <> Re2.name
order by Re1.name)
where name1 < name2;

--Q6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select name, title, stars
from Reviewer, Movie, Rating
where Reviewer.rID=Rating.rID
and Movie.mID=Rating.mID
and Rating.stars=(select MIN(stars) from Rating);

--Q7. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 
select title, avg(stars) as avgstars
from Movie, Rating
where Movie.mID = Rating.mID
group by title
order by avgstars desc;

--Q8. Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 
select name
from Reviewer, Rating
where Reviewer.rID=Rating.rID
group by name 
having count(stars) >= 3;

--Q9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
select title, director
from Movie
where director in 
(select director
from Movie
group by director
having count(title)>1) 
order by director, title;

--Q10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 
select T0.title, T0.avgstars0
from
(select title,avg(stars) as avgstars0
from Movie, Rating
where Movie.mID = Rating.mID
group by title) as T0
where T0.avgstars0 = 
(select max(avgstars)
from 
(select title, avg(stars) as avgstars
from Movie, Rating
where Movie.mID = Rating.mID
group by title));

--Q11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 
select T0.title, T0.avgstars0
from
(select title,avg(stars) as avgstars0
from Movie, Rating
where Movie.mID = Rating.mID
group by title) as T0
where T0.avgstars0 = 
(select min(avgstars)
from 
(select title, avg(stars) as avgstars
from Movie, Rating
where Movie.mID = Rating.mID
group by title));

--Q12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 
select director,title,max(stars)
from Movie, Rating
where Movie.mID = Rating.mID
and Movie.director is not null
group by director;

/*---------------SQL Movie-Rating Modification Excercises ------------*/
--Q1. Add the reviewer Roger Ebert to your database, with an rID of 209. 
insert into Reviewer values(209, 'Roger Ebert'); 

--Q2. Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 
insert into Rating ( rID, mID, stars, ratingDate ) 
select Reviewer.rID , Movie.mID, 5, null
from
Reviewer left join Movie
where Reviewer.name = 'James Cameron’;

--Q3. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.) 
update Movie
set year=year+25
where mID in (select mID
from 
Rating
group by mID
having avg(stars) >=4);

--Q4. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from Rating
where mID in (select mID from Movie where year <1970 or year >2000) 
and stars < 4;