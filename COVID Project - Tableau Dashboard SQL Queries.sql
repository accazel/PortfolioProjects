/*

Queries used for Tableau Project

*/


-- 1 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- 2

-- We take a few locations out in order to stay consistent with prior queries

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM coviddeaths
--Where location like '%states%'
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International', 'Low income', 'Lower middle income', 'Upper middle income', 'High income')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 100*MAX(total_cases/population) AS PercentPopulationInfected
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4 

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, 100*MAX(total_cases/population) AS PercentPopulationInfected
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc
