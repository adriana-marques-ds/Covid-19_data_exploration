----COVID Portfolio Project - Data Exploration.sql

--Skills used: Joins, CTE's, Temp Tables, Windows functions, Aggregate Functions, Creating views, Converting Data types

SELECT*
FROM ProjetoPortfolio..covid_mortes
WHERE continent is not null 
ORDER BY 3,4



--Select Data that I am going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
FROM ProjetoPortfolio..covid_mortes
WHERE continent is not null 
ORDER BY 1,2



--Total number of cases versus the total number of deaths
---Indicates the probability of dying if one contracts COVID in Brazil

SELECT location, date, new_cases, total_cases, total_deaths, 
CASE WHEN total_cases = 0 THEN 0 ELSE (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 END as death_rate
FROM ProjetoPortfolio..covid_mortes
WHERE location = 'Brazil' 
ORDER BY 1, 2 


--Looking at Total Cases vs Population
---Shows what percentage of population got infected with covid

SELECT 
     location, 
	 date, 
	 population, 
	 total_cases,
     CASE WHEN total_cases = 0 THEN 0 ELSE (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 END as death_rate
FROM ProjetoPortfolio..covid_mortes
WHERE location = 'Brazil'
ORDER BY 1, 2 



--Looking at Countries with highest Infection Rate compared to population

SELECT 
     location, 
	 population, 
     MAX(total_cases) as HighestInfectionCount,
     Max(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 as death_rate
FROM ProjetoPortfolio..covid_mortes
GROUP BY location, population
ORDER BY death_rate DESC



--Countries with Highest Death Count per Population

SELECT 
     location, 
	 MAX(cast(total_deaths as int)) as total_death_count
FROM ProjetoPortfolio..covid_mortes
WHERE continent is not null
GROUP BY location
HAVING location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union')
ORDER BY total_death_count DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT 
     location, 
	 SUM(cast(new_deaths as int)) as TotalDeathCount
FROM ProjetoPortfolio..covid_mortes
WHERE continent is not null 
GROUP BY location
HAVING location IN ('Asia', 'Europe', 'Africa', 'North America', 'South America', 'Oceania')
ORDER BY TotalDeathCount DESC



--Global numbers

SELECT 
     --date, 
	 SUM(CAST(new_cases AS bigint)) AS total_cases, 
	 SUM(CAST(new_deaths AS bigint)) AS total_deaths, 
     CASE WHEN SUM(CAST(new_cases AS bigint)) = 0 THEN 0 
          ELSE SUM(CAST(new_deaths AS bigint))/CAST(SUM(CAST(new_cases AS bigint)) AS float)* 100 End AS death_percentage 
FROM ProjetoPortfolio..covid_mortes
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



--COVID-19 Daily Cases and Deaths by Percentage: Analysis by Date

SELECT 
     date, 
	 SUM(CAST(new_cases AS bigint)) AS total_cases, 
	 SUM(CAST(new_deaths AS bigint)) AS total_deaths, 
     CASE WHEN SUM(CAST(new_cases AS bigint)) = 0 THEN 0 
          ELSE SUM(CAST(new_deaths AS bigint))/CAST(SUM(CAST(new_cases AS bigint)) AS float)* 100 End AS death_percentage 
FROM ProjetoPortfolio..covid_mortes
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2



-- Total Population vs Vaccinations
---Rolling Vaccination Coverage by Location and Date

Select 
     deaths.continent, 
	 deaths.location, 
	 deaths.date, 
	 deaths.population, 
	 vac.new_vaccinations, 
	 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) AS rolling_vaccinations
FROM ProjetoPortfolio..covid_mortes AS deaths
JOIN ProjetoPortfolio..covid_vacinados AS vac
ON deaths.location = vac.location
AND deaths.date = vac.date
WHERE deaths.continent is not null
ORDER BY 2,3



--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
as
(
SELECT 
     deaths.continent, 
	 deaths.location, 
	 deaths.date, 
	 deaths.population, 
	 vac.new_vaccinations,
     SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as rolling_people_vaccinated
FROM ProjetoPortfolio..covid_mortes AS deaths
Join ProjetoPortfolio..covid_vacinados AS vac
	On deaths.location = vac.location
	and deaths.date = vac.date
WHERE deaths.continent is not null 
)
SELECT 
     *, 
	 (rolling_people_vaccinated*100/Population) AS rolling_vaccination_percentage
FROM PopvsVac
WHERE Location = 'Brazil'


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations nvarchar(255),
  rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
  deaths.continent, 
  deaths.location, 
  deaths.date, 
  deaths.population, 
  vac.new_vaccinations,
  SUM(TRY_CONVERT(bigint, TRY_CONVERT(nvarchar(255), vac.new_vaccinations))) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.Date) as rolling_people_vaccinated
FROM ProjetoPortfolio..covid_mortes AS deaths
JOIN ProjetoPortfolio..covid_vacinados AS vac
  ON deaths.location = vac.location
  AND deaths.date = vac.date

SELECT 
  *, 
  ISNULL((rolling_people_vaccinated/Population)*100, 0) AS rolling_vaccination_percentage
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

-- First, execute this statement to drop the existing view, if it already exists.
IF OBJECT_ID('PercentPopulationVaccinated', 'view') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated
GO


CREATE VIEW PercentPopulationVaccinated AS
SELECT 
     deaths.continent, 
	 deaths.location, 
	 deaths.date, 
	 deaths.population, 
	 vac.new_vaccinations, 
	 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM ProjetoPortfolio..covid_mortes AS deaths 
JOIN ProjetoPortfolio..covid_vacinados AS vac
    ON deaths.location = vac.location
    AND deaths.date = vac.date
WHERE deaths.continent IS NOT NULL 
GO

SELECT *
FROM PercentPopulationVaccinated

-----I've added a "GO" statement after "drop the view" and the " create view" statements to separate them into separate batches as I was getting an error.


--Identifying peak COVID-19 death count days in Brazil

SELECT 
    location, 
    date, 
    MAX(CAST(new_deaths as int)) as max_deaths 
FROM ProjetoPortfolio..covid_mortes 
WHERE location = 'Brazil'
GROUP BY location, date 
ORDER BY location, max_deaths DESC



--Identifying days with highest number of new COVID-19 cases in Brazil
SELECT 
     location,
	 date,
	 MAX(CAST(new_cases AS int)) AS max_new_cases
FROM ProjetoPortfolio..covid_mortes
WHERE location = 'Brazil'
GROUP BY location, date
ORDER BY location, max_new_cases DESC


 







