/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

.mode column
.headers ON

/*---------- 1. SQL Social-Network Query Exercises ----------*/
--Q1. Find the names of all students who are friends with someone named Gabriel. 
select H.name
from Highschooler H
where H.id in (select F.ID1 from Friend F where F.ID2 in (select H2.ID from 
Highschooler H2 where H2.name='Gabriel'));

--Q2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select *
from
(select H1.name name1,H1.grade grade1,H2.name name2,H2.grade grade2
from Highschooler H1,Highschooler H2,Likes
where H1.ID = Likes.ID1 and H2.ID = Likes.ID2)
where (grade1 - grade2) >=2;

--Q3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 
select L1.name1,L1.grade1,L1.name2,L1.grade2 
from
(select H1.name name1,H1.grade grade1,H2.name name2,H2.grade grade2
from Likes,Highschooler H1,Highschooler H2
where H1.ID=Likes.ID1 and H2.ID=Likes.ID2) as L1,
(select H1.name name1,H1.grade grade1,H2.name name2,H2.grade grade2
from Likes,Highschooler H1,Highschooler H2
where H1.ID=Likes.ID1 and H2.ID=Likes.ID2) as L2
where L1.name1=L2.name2 and L1.name2=L2.name1 and L1.name1<L1.name2;

--Q4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 
select name,grade
from Highschooler
where ID not in 
(select distinct *
from
(select ID1
from Likes
union
select ID2
from Likes)) 
order by grade,name;

--Q5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
select H1.name,H1.grade,H2.name,H2.grade
from Likes,Highschooler H1,Highschooler H2
where H1.ID=Likes.ID1 and H2.ID=Likes.ID2 and H2.ID not in (select ID1 from Likes);

--Q6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
select N1,G1
from 
(select I1, N1, G1, min(G2) ming,max(G2) maxg
from 
(select H1.ID I1, H1.name N1, H1.grade G1, H2.ID I2, H2.name N2, H2.grade G2
from Highschooler H1,Highschooler H2, Friend
where H1.ID = Friend.ID1 and H2.ID = Friend.ID2) as L
group by L.I1)
where G1=ming and G1=maxg
order by G1, N1;

--Q7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1,Highschooler H2, Highschooler H3, Friend F1, Friend F2,
(select *
from Likes
except 
select Likes.ID1, Likes.ID2
from Likes, Friend
where Likes.ID1=Friend.ID1 and Likes.ID2=Friend.ID2) as LNF
where F1.ID1 = LNF.ID1 and F2.ID1 = LNF.ID2 and F1.ID2 = F2.ID2 
and H1.ID = LNF.ID1 and H2.ID = LNF.ID2 and H3.ID = F1.ID2;

--Q8. Find the difference between the number of students in the school and the number of different first names. 
select count(ID)-count(distinct name)
from Highschooler;

--Q9. Find the name and grade of all students who are liked by more than one other student. select H1.name, H1.grade
from Highschooler H1,
(select ID2 LID, count(ID1) LN
from Likes
group by ID2) Likedby
where H1.ID=Likedby.LID and Likedby.LN > 1;

/*---------- 1. SQL Social-Network Query Exercises Extras----------*/
--Q1. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1, Highschooler H2, Highschooler H3, 
(select TR1 A, TR2 B , TR3 C
from (select L1.ID1 TR1,L1.ID2 TR2, Likes.ID2 TR3
from Likes, (select *
from Likes
where ID2 in (select ID1 from Likes)) as L1
where Likes.ID1=L1.ID2) as TR
where TR1 <> TR3) as TriRelation
where H1.ID=TriRelation.A and H2.ID=TriRelation.B and H3.ID=TriRelation.C;

--Q2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.
select name, grade 
from Highschooler
where ID not in (select F.ID1
from 
(select H1.ID ID1, H1.name name1, H1.grade grade1, H2.ID ID2, H2.name name2, H2.grade grade2
from Friend, Highschooler H1,Highschooler H2
where H1.ID=Friend.ID1 and H2.ID=Friend.ID2) as F
where F.grade1 = F.grade2);

--Q3. What is the average number of friends per student? (Your result should be just one number.) 
select avg(fnum)
from
(select ID1, count(ID2) fnum
from Friend
group by ID1);

--Q4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.
select COUNT(Friend.ID1)
from Friend,
(select ID1 as ID from Friend where ID2=(select ID from Highschooler where name='Cassandra')) 
as FOFC
where Friend.ID1 = FOFC.ID;

--Q5. Find the name and grade of the student(s) with the greatest number of friends. 
select Highschooler.name, Highschooler.grade
from Highschooler,
(select ID1 ID
from Friend
group by ID1
having count(ID2) = (select max(F.NUMF) from
(select count(ID2) NUMF
from Friend
group by ID1) as F)) as GNF
where Highschooler.ID=GNF.ID;

/*---------- 1. SQL Social-Network Modification Exercises----------*/
--Q1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler. 
delete from Highschooler where grade = 12;

--Q2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. 
delete from Likes
where exists (select * from Friend
where Friend.ID1=Likes.ID1 and Friend.ID2=Likes.ID2)
and not exists (select * from Likes L1
where L1.ID2=Likes.ID1 and L1.ID1=Likes.ID2);

--Q3. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.)
insert into Friend(ID1,ID2)
select A ID1, C ID2
from 
(select F1.ID1 A, F1.ID2 B, F2.ID2 C
from Friend F1, Friend F2
where F1.ID2 = F2.ID1 and F2.ID2 <> F1.ID1)
except 
select * from Friend F