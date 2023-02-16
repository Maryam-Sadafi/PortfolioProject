
--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--The Data I am going to use:

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Calculating Death Percentage in Canada


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
WHERE location='Canada'
ORDER BY 1,2 

--Calculating what percentage of population got covid

SELECT location,date,total_cases,population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE location='Canada'
ORDER BY 1,2 

--Looking at countries with highest infection compare to population

SELECT location,population,MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS InfectionPercent
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE location='Canada'
GROUP BY location,population
ORDER BY InfectionPercent DESC

--Show countries with highest death rate per population

SELECT location,MAX(cast(total_deaths as int)) AS HighestDeathCases
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE location='Canada'
GROUP BY location
ORDER BY HighestDeathCases DESC

--Showing continents with highest death cases

SELECT continent,MAX(cast(total_deaths as int)) AS HighestDeathCases
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--WHERE location='Canada'
GROUP BY continent
ORDER BY HighestDeathCases DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--WHERE location ='Canada'
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Total Vaccination
---CTE

WITH POPvsVAC (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY Dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vac
    ON Dea.location=Vac.location
	AND Dea.date= Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 
FROM POPvsVAC

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccination
CREATE Table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccination
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY Dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vac
    ON Dea.location=Vac.location
	AND Dea.date= Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccination

--Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccination AS
SELECT Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY Dea.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vac
    ON Dea.location=Vac.location
	AND Dea.date= Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccination