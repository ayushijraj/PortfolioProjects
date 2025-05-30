-- Explore Covid Data Project
-- Author: Ayushi Jaiswal
-- Data Sources: CovidDeaths & CovidVaccinations from ProjectPortfolio database


Select *
From ProjectPortfolio..CovidDeaths
order by 3, 4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3, 4

--Select Data that we are going to using
Select Location, Date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1, 2

-- Lookong at Total Cases VS. Total Deaths
-- Show  likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at total Cases Vs. Population
-- Shows what percentage of population got Covid
Select Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
order by 1, 2

-- Looking at Countries with Higher Infection Rate compared to Population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Group by location, population,
order by PercentPopulationInfected desc

Select Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Group by location, population, date
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per population
Select Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS BY CONTINENT
-- Showing the continents with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
Where continent is null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBEFRS
Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int
))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Displaying total cases, total deaths, and death percentage
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int
))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
-- Where location like '%states%'
where continent is not null
--group by date
order by 1,2


Select * 
from ProjectPortfolio..CovidVaccinations

--Use CTE 
With PopvsVac ( Continent, Date, Location, Population, New_Vaccitaions, Rollingpeoplevaccinated)
AS
(
-- Looking at total population vs. total vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations, 0)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select * ,(Rollingpeoplevaccinated/population)*100
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations, 0)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select * ,(Rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations, 0)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select * 
From PercentPopulationVaccinated


--We take these out as they are not included in the above queries and want to stay consistent
--European Union is a part of Europe
Select location, SUM(Cast(new_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc