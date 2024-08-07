--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 1,2

--total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like 'ph%'
ORDER BY 1,2;

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths$
WHERE location like 'ph%'
ORDER BY 1,2;

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'ph%'
GROUP BY location, population
ORDER BY  percent_population_infected DESC;

SELECT location, MAX(cast(total_deaths AS int )) AS total_death_count
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'ph%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

SELECT continent, MAX(cast(total_deaths AS int )) AS total_death_count
FROM PortfolioProject..CovidDeaths$
--WHERE location like 'ph%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST (new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

WITH PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

DROP TABLE IF EXISTS  #percentage_population_vaccinated
CREATE TABLE #percentage_population_vaccinated
(
Continent nvarchar (255), 
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percentage_population_vaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percentage_population_vaccinated

CREATE VIEW	percentage_population_vaccinated AS 

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *
FROM percentage_population_vaccinated