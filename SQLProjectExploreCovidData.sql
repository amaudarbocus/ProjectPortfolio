/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProjectExplore.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

/*
SELECT *
FROM PortfolioProjectExplore..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;
*/
/*
-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, Total_deaths, population
FROM PortfolioProjectExplore..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;
*/

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectExplore..CovidDeaths
WHERE location LIKE 'Mauritius' AND continent IS NOT NULL

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProjectExplore..CovidDeaths
-- WHERE location LIKE 'Mauritius'
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProjectExplore..CovidDeaths
-- WHERE location LIKE 'Mauritius'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectExplore..CovidDeaths
-- WHERE location LIKE 'Mauritius'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent

-- Showing continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectExplore..CovidDeaths
-- WHERE location LIKE 'Mauritius'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjectExplore..CovidDeaths
-- WHERE location LIKE 'Mauritius'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage--total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectExplore..CovidDeaths
--WHERE location LIKE 'Mauritius' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 DESC

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage--total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjectExplore..CovidDeaths
--WHERE location LIKE 'Mauritius' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC

--Looking at Total Population VS Vaccinations

-- duplicates in this query
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProjectExplore..CovidDeaths dea
JOIN PortfolioProjectExplore..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectExplore..CovidDeaths dea
JOIN PortfolioProjectExplore..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectExplore..CovidDeaths dea
JOIN PortfolioProjectExplore..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualizations
--DROP View PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectExplore..CovidDeaths dea
JOIN PortfolioProjectExplore..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
--ORDER BY 2,3
