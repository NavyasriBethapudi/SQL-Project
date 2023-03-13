--1. To Verify the Database and Datasets loaded correctly. 
----PULL ALL THE COVID DEATH AND VACCINATION DATA SORT BY LOCATION AND DATE.
SELECT * 
FROM CovidPortfolioProject..COVIDDEATHS
ORDER BY 3,4
SELECT *
FROM CovidPortfolioProject..COVIDVACCINATIONS
ORDER BY 3,4

--2. What is the total number of COVID-19 cases, deaths, and vaccinations administered in a India?
SELECT distinct A.continent
     , A.location
     , COUNT(A.total_cases)       AS total_cases
     , COUNT(A.total_deaths)      AS total_deaths
	 , COUNT(B.total_vaccinations)     AS total_vaccinations
	 , COUNT(B.total_boosters)    AS total_boosters
FROM CovidPortfolioProject..COVIDDEATHS    AS A
   , CovidPortfolioProject..COVIDVACCINATIONS    AS B
WHERE A.location = 'India' 
  AND B.location = 'India'
group by A.continent
       , A.location

--3. How many COVID-19 cases, deaths, and vaccinations took place in the Year 2021 - Q3  in USA?
select DISTINCT b.location
	 , a.date
     , a.total_cases  
     , a.total_deaths
	 , b.total_vaccinations
from CovidPortfolioProject..COVIDDEATHS    as a
   , CovidPortfolioProject..COVIDVACCINATIONS   as b
where a.date BETWEEN '2021-10-01' AND '2021-12-31'
  and b.date = a.date
  and a.iso_code = 'USA'
  and b.iso_code = a.iso_code
ORDER BY 1,2 asc 

--4. Which distinct locations that starts with "A" has the highest COVID-19 death rates?
SELECT DISTINCT a.location
     , MAX(cast(a.total_deaths as int))    as  total_deaths
FROM CovidPortfolioProject..COVIDDEATHS  as a
WHERE a.location like 'A%'
  and a.continent is not null  
--  and a.total_deaths is not null 
GROUP BY a.location 
ORDER BY 2 DESC

--5.What is the total percentage in the number of COVID-19 cases, deaths and Vaccinations all over the world?
----5.1. Get the total percentage in the number of covid cases per population all over the world using CTE Function.
------5.1.1. Create a Query that has sum of Covid Cases, Deaths and Vaccinations Over Partitioned by Location and Date.
select a.continent
     , a.iso_code
     , a.location 
	 , a.population
	 , max(isnull(a.total_cases,0))   as total_cases
	 --, sum(isnull(convert(bigint,a.total_cases),0))  over (Partition by a.location order by a.location) as TotalCovidCases

from CovidPortfolioProject..COVIDDEATHS    as a
   join CovidPortfolioProject..COVIDVACCINATIONS    as b
     on a.location = b.location
	 and a.date = b.date
where a.continent is not null
group by a.continent
     , a.iso_code
     , a.location 
	 --, a.date
	 , a.population
	--, a.total_cases
order by a.location

------5.1.2. Create a CTE Name - CovidData to get Percentage of Highly Infected CovidCases per Population all over the world.

with CovidCaseData (Continent, Iso_code, Location, Population, Total_cases)
as
(
select a.continent
     , a.iso_code
     , a.location 
	 , a.population
	 , max(isnull(a.total_cases,0))   as total_cases
	 --, sum(isnull(convert(bigint,a.total_cases),0))  over (Partition by a.location order by a.location) as TotalCovidCases

from CovidPortfolioProject..COVIDDEATHS    as a
   join CovidPortfolioProject..COVIDVACCINATIONS    as b
     on a.location = b.location
	 and a.date = b.date
where a.continent is not null
group by a.continent
     , a.iso_code
     , a.location 
	 --, a.date
	 , a.population
	--, a.total_cases
--order by a.location

)
select distinct Location
    , max((Total_cases/Population))*100   as HighlyInfectedPeople
from CovidCaseData
group by Location
order by 2 desc

----5.2. Get the total percentage in the number of covid vaccinations per population all over the world using Temp Table.
------5.2.1 First create a query using Partition by fucntion
select a.continent
     , a.location
	 , a.population
	 , max(isnull(b.new_vaccinations,0))          as  new_vaccinations
   --, sum(isnull(convert(bigint,new_vaccinations),0)) over (partition by a.location order by a.location, a.date)  as VaccinatedPeople

from CovidPortfolioProject..COVIDDEATHS  as a

join CovidPortfolioProject..COVIDVACCINATIONS  as b
   on b.location = a.location
  and b.date = a.date

where a.continent is not null 
group by a.continent
     , a.location 
	 , a.population
	 --, b.new_vaccinations
order by 4 desc

------5.2.2 Use Temp Table to perform calculation on total percentage of the number of covid vaccinations per population. 
--------Create Temp Table - CovidVaccinatedPeople
drop table if exists CovidVaccinatedPeople
create table CovidVaccinatedPeople
(
  continent   nvarchar(255) not null
, location  nvarchar(255) not null 
, population     numeric
, new_vaccinations  numeric
)
--------Insert Data from the above query we have used the OVER and Partition By Functions
insert into CovidVaccinatedPeople 
select a.continent
     , a.location
	 , a.population
	 , max(isnull(b.new_vaccinations,0))          as  new_vaccinations
   --, sum(isnull(convert(bigint,new_vaccinations),0)) over (partition by a.location order by a.location, a.date)  as VaccinatedPeople

from CovidPortfolioProject..COVIDDEATHS  as a

join CovidPortfolioProject..COVIDVACCINATIONS  as b
   on b.location = a.location
  and b.date = a.date

where a.continent is not null 
group by a.continent
     , a.location 
	 , a.population
	 --, b.new_vaccinations
--order by 4 desc

--------Verify if Temp Table is created successfully or not.
select * from CovidVaccinatedPeople

--------Now calculate the Percentage of Vaccinated People over Population all over the world.
select distinct location
    , max((new_vaccinations/Population)) *100  as VaccinatedPeoplePercentage
from CovidVaccinatedPeople
group by location
order by 2 desc

----5.3. Get the total percentage in the number of covid deaths per population all over the world using VIEW Function
------5.3.1 Create a query that is similar to the query used for Covid Cases over partition by location and date.
select a.continent
     , a.iso_code
     , a.location 
	 , a.date
	 , a.population
	 , max(isnull(a.total_deaths,0))   as total_deaths
	 , sum(isnull(convert(bigint,a.total_deaths),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidDeaths
	 , max(isnull(a.total_cases,0))   as total_cases
	 , sum(isnull(convert(bigint,a.total_cases),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidCases
	 , max(isnull(b.total_vaccinations,0))   as total_vaccinations
	 , sum(isnull(convert(bigint,b.total_vaccinations),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidVaccinations

from CovidPortfolioProject..COVIDDEATHS    as a
   join CovidPortfolioProject..COVIDVACCINATIONS    as b
     on a.location = b.location
	 and a.date = b.date
where a.continent is not null
group by a.continent
     , a.iso_code
     , a.location
	 , a.date
	 , a.population
	 , a.total_deaths
	 , a.total_cases
	 , b.total_vaccinations
order by a.location

------5.3.2 Create View Name as CovidDeathData 
DROP VIEW IF EXISTS CovidData
CREATE VIEW CovidData AS
select a.continent
     , a.iso_code
     , a.location 
	 , a.date
	 , a.population
	 , isnull(a.total_deaths,0)   as total_deaths
	 , sum(isnull(convert(bigint,a.total_deaths),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidDeaths
	 , isnull(a.total_cases,0)   as total_cases
	 , sum(isnull(convert(bigint,a.total_cases),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidCases
	 , isnull(b.total_vaccinations,0)   as total_vaccinations
	 , sum(isnull(convert(bigint,b.total_vaccinations),0))  over (Partition by a.location order by a.location, a.date) as TotalCovidVaccinations

from CovidPortfolioProject..COVIDDEATHS    as a
   join CovidPortfolioProject..COVIDVACCINATIONS    as b
     on a.location = b.location
	 and a.date = b.date
where a.continent is not null
--group by a.continent
--     , a.iso_code
--     , a.location 
--	 , a.date
--	 , a.population
--	 , a.total_deaths
--	 , a.total_cases
--	 , b.total_vaccinations
--order by a.location

--------Double Verify if VIEW is created successfully or not
select * from CovidData

--------Get the result of Total Deaths per population
select distinct location
    , max(total_deaths/Population)*100   as HighlyDeathPercentage
from CovidData
group by location
order by 2 desc

-- 6. What is the mortality rate and vaccination rate for age > 65 or older all over the world? 

select a.continent 
      , cast((sum(cast (a.total_deaths as bigint))/sum(population))*100  as decimal(10,2))   as mortality_rate
	  , cast((sum(cast (b.total_vaccinations as bigint))/sum(population))*100 as decimal(10,2)) as vaccination_rate
from CovidPortfolioProject..COVIDDEATHS  as a
join CovidPortfolioProject..COVIDVACCINATIONS  as b
on b.location = a.location
and b.date  = a.date 
where a.continent is not null
  and b.aged_65_older is not null
group by  a.continent

-- 7. what are the Top 10 Locations infected with Covid and died as of Cardiovascular Disease? 

select distinct top(10) a.location
      , max(isnull(b.cardiovasc_death_rate/cast(a.total_deaths as float),0))   as CardiovasuclarDeathRate
from CovidPortfolioProject..COVIDDEATHS  as a
join CovidPortfolioProject..COVIDVACCINATIONS  as b
on b.location = a.location
and b.date  = a.date 
where a.continent is not null
  and b.cardiovasc_death_rate is not null
group by  a.location
         , b.cardiovasc_death_rate
		 , a.total_deaths
order by 2 desc

-- 8. Which Country has low Infected Cases, Deaths in the Year of 2022 where Female and Male smoker rates is not blank ? 
----Created this Query using Sub queries -

select distinct a.continent
       , SUM(convert(bigint, a.total_cases)) as total_cases
	   , SUM(convert(bigint, a.total_deaths)) as total_deaths
from CovidPortfolioProject..COVIDDEATHS  as a
   , CovidPortfolioProject..COVIDVACCINATIONS  as b

where a.continent is not null
  and b.female_smokers is not null
  and b.male_smokers is not null
  and a.location = b.location
  and a.date = b.date
  and a.total_cases is not null
  and a.total_deaths is not null
  and a.total_cases = 
					(select min(convert(bigint,a1.total_cases))
					 from CovidPortfolioProject..COVIDDEATHS  as a1
					 where a1.location = a.location
					   and a1.date BETWEEN '2022-01-01' AND '2022-12-31'
					   and a1.total_cases > 0
					  ) 
  and a.total_deaths = 
					(select min(convert(bigint,a1.total_deaths))
					 from CovidPortfolioProject..COVIDDEATHS  as a1
					 where a1.location = a.location
					   and a1.date BETWEEN '2022-01-01' AND '2022-12-31'
					   and a1.total_deaths > 0
					 )
group by a.continent 
    --   , a.total_cases
	   --, a.total_deaths
order by 2,3 
