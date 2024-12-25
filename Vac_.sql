SELECT * FROM
portfolio_ .coviddeaths
WHERE continent is not null
ORDER BY 3,4

SELECT location , date , total_cases , new_cases , total_deaths , population 
FROM portfolio_ .coviddeaths
ORDER BY 1,2

-- Looking at Total Cases v/s Total Deaths
-- Shows Likelihood Of Dying If You Contract Covid In Your Country
SELECT location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio_ .coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking At The Total Cases v/s population
-- Shows What Percentage Of Population Got Covid
SELECT location , date , population , total_cases , (total_cases/population)*100 AS PercentPopulationInfected
FROM portfolio_ .coviddeaths
WHERE location LIKE '%india%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT location , population , MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM portfolio_ .coviddeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected desc

-- Showing Countries With Death Counts Per Population
SELECT location , MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount 
FROM portfolio_ .coviddeaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount desc


-- Let's Break Things Down By Continent

SELECT location, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount 
FROM portfolio_ .coviddeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

select continent, sum(new_deaths)
from portfolio_ .coviddeaths
where continent!=''
group by continent;


-- Let's Break Things Down By Continent
-- Showing Continents With the Highest death Count per Population

SELECT continent, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount 
FROM portfolio_ .coviddeaths
WHERE continent != ''
GROUP BY  continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT date , SUM(new_cases) AS total_cases, SUM(cast(new_deaths as SIGNED)) AS total_deaths,SUM(cast(new_deaths as SIGNED))/SUM(new_cases) * 100 AS DeathPercentage
FROM portfolio_ .coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as SIGNED)) AS total_deaths,SUM(cast(new_deaths as SIGNED))/SUM(new_cases) * 100 AS DeathPercentage
FROM portfolio_ .coviddeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at the Total Population v/s Vaccination
With PopvsVac (continent, location , date , population , new_vaccinations , RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_ .coviddeaths dea JOIN
portfolio_ .covidvaccinationscsv vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent != ''
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) *100 AS PeopleVaccinated
FROM PopvsVac

-- Creating view to store data later for Visualization

USE portfolio_;
DROP VIEW IF EXISTS PercentpopulationVaccinated;
Create view PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population , vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_ .coviddeaths dea JOIN
portfolio_ .covidvaccinationscsv vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent != ''











