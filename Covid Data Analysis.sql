SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location='India'
ORDER BY 1,2

-- Total Cases vs Population

Select Location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--WHERE location='India'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) AS HighlyInfected,MAX((total_cases/population) * 100) AS PopulationPercentageInfected
FROM CovidDeaths
--WHERE location='India'
GROUP BY location,population
ORDER BY PopulationPercentageInfected DESC

-- Countries with Highest Death Count per Population

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM CovidDeaths
--WHERE location='India'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC

-- GLOBAL NUMBERS BY DATE

SELECT date,SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location='India'
WHERE continent is NOT NULL
GROUP BY date
ORDER BY date

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location='India'
WHERE continent is NOT NULL

SELECT * FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 2,3

--CTE-- Using CTE to perform Calculation on Partition By in previous query

WITH POPVAC (continent,location,date,population,new_vaccinations,PeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT location,Max((PeopleVaccinated/population)*100) AS PeopleVaccinatedPercentage FROM POPVAC
GROUP BY location

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(continent nvarchar(255),location nvarchar(255),date datetime,population float,new_vaccinations numeric,PeopleVaccinated numeric)

INSERT INTO  #PercentagePeopleVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT location,Max((PeopleVaccinated/population)*100) AS PeopleVaccinatedPercentage FROM #PercentagePeopleVaccinated
GROUP BY location
ORDER BY location

-- Creating View to store data for later visualizations

CREATE VIEW PercentagePeopleVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as int)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS PeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentagePeopleVaccinated


