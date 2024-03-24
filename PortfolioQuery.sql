SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- This shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent !=''

--Looking at Total Cases vs Population
-- This show what percentage of population got Covid
SELECT Location, date, total_cases, total_deaths, population, (CONVERT(float, total_cases)/NULLIF(CONVERT(float, population),0)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Hungary'
order by 1,2

--Looking at Countries with highest infection rate compared to Population
SELECT Location, population, Max(CONVERT(float,total_cases)) as HighestInfectionCount,MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float, population),0))) * 100 AS InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
order by 4 DESC

--Looking at Countries with highest death rate compared to Population
SELECT Location, Max(CONVERT(float,total_deaths)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent !=''
GROUP BY Location
order by HighestDeathCount DESC



--Breaking things down by continent
SELECT continent, Max(CONVERT(float,total_deaths)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent !=''
GROUP BY continent
order by TotalDeathCount DESC


--Showing the continents with the highest death count per population
SELECT continent, Max(CONVERT(float,total_deaths)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent !=''
GROUP BY continent
order by HighestDeathCount DESC


-- Global numbers
SELECT SUM(CONVERT(float,new_cases)) AS total_cases, SUM(CONVERT(float,new_deaths)) AS new_deaths, SUM(CONVERT(float,new_deaths))/NULLIF(SUM(CONVERT(float,new_cases)),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null and continent !=''
--GROUP BY date
ORDER BY 1,2


----


-- Looking at Total Population vs Vaccinations, increasing with each vaccination
--CT VERSION:

WITH PopVsVac(Continent, Location,Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location and dea.date= vac.date
	WHERE dea.continent !=''
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPopulation
FROM PopVsVac

--TEMP TABLE VERSION
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
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
	SELECT dea.continent, dea.location, dea.date, CONVERT(float,dea.population), CONVERT(float,vac.new_vaccinations),
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location and dea.date= vac.date
	WHERE dea.continent !=''

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPopulation
FROM #PercentPopulationVaccinated


--VIEW VERSION
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location and dea.date= vac.date
WHERE dea.continent !=''


SELECT *
FROM PercentagePopulationVaccinated