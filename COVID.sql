-- Create table

CREATE TABLE CovidDeaths(  
	iso_code VARCHAR(20),  
	continent VARCHAR(20),  
	location VARCHAR(50),  
	date DATE,  
	population BIGINT,  
	total_cases DECIMAL(12,3),  
	new_cases DECIMAL(10,3),  
	new_cases_smoothed DECIMAL(10,3),  
	total_deaths DECIMAL(12,3),  
	new_deaths INT,  
	new_deaths_smoothed DECIMAL(10,3),  
	total_cases_per_million DECIMAL(10,3),  
	new_cases_per_million DECIMAL(10,3),  
	new_cases_smoothed_per_million DECIMAL(10,3),  
	total_deaths_per_million DECIMAL(10,3),  
	new_deaths_per_million DECIMAL(10,3),  
	new_deaths_smoothed_per_million DECIMAL(10,3),  
	reproduction_rate DECIMAL(10,3),  
	icu_patients DECIMAL(10,3),  
	icu_patients_per_million DECIMAL(10,3),  
	hosp_patients DECIMAL(10,3),  
	hosp_patients_per_million DECIMAL(10,3),  
	weekly_icu_admissions DECIMAL(10,3),  
	weekly_icu_admissions_per_million DECIMAL(10,3),  
	weekly_hosp_admissions DECIMAL(10,3),  
	weekly_hosp_admissions_per_million DECIMAL(10,3)  
);  


-- View entire table

SELECT *
FROM coviddeaths


-- Create table

CREATE TABLE CovidVaccinations(  
	iso_code VARCHAR(20),  
	continent VARCHAR(20),  
	location VARCHAR(50),  
	date DATE, 
	total_tests BIGINT,
	new_tests BIGINT,
	total_tests_per_thousand DECIMAL(10,3),
	new_tests_per_thousand DECIMAL(10,3),
	new_tests_smoothed BIGINT,
	new_tests_smoothed_per_thousand DECIMAL(10,3),
	positive_rate DECIMAL(10,4),
	tests_per_case DECIMAL(10,1),
	tests_units VARCHAR(20),
	total_vaccinations BIGINT,
	people_vaccinated BIGINT,
	people_fully_vaccinated BIGINT,
	total_boosters BIGINT,
	new_vaccinations BIGINT,
	new_vaccinations_smoothed BIGINT,
	total_vaccinations_per_hundred DECIMAL(10,2),
	people_vaccinated_per_hundred DECIMAL(10,2),
	people_fully_vaccinated_per_hundred DECIMAL(10,2),
	total_boosters_per_hundred DECIMAL(10,2),
	new_vaccinations_smoothed_per_million BIGINT,
	new_people_vaccinated_smoothed BIGINT,
	new_people_vaccinated_smoothed_per_hundred DECIMAL(10,3),
	stringency_index DECIMAL(10,2),
	population_density DECIMAL(10,3),
	median_age DECIMAL(10,1),
	aged_65_older DECIMAL(10,4),
	aged_70_older DECIMAL(10,3),
	gdp_per_capita DECIMAL(10,3),
	extreme_poverty DECIMAL(10,3),
	cardiovasc_death_rate DECIMAL(10,3),
	diabetes_prevalence DECIMAL(10,2),
	female_smokers DECIMAL(10,2),
	male_smokers  DECIMAL(10,2),
	handwashing_facilities DECIMAL(10,3),
	hospital_beds_per_thousand DECIMAL(10,2),
	life_expectancy DECIMAL(10,2),
	human_development_index DECIMAL(10,3),
	excess_mortality_cumulative_absolute DECIMAL(14,5),
	excess_mortality_cumulative DECIMAL(14,2),
	excess_mortality DECIMAL(14,2),
	excess_mortality_cumulative_per_million DECIMAL(14,3)
);  


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location,date


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 100*(total_deaths/total_cases) AS DeathPercentage
FROM coviddeaths
WHERE location = 'United States'
WHERE continent IS NOT NULL
ORDER BY location,date


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, 100*(total_cases/population)  AS PercentPopulationInfected
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
ORDER BY location,date


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 100*MAX(total_cases/population) AS PercentPopulationInfected
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- BREAKING EVERYTHING DOWN BY CONTINENT
-- Showing continents with the hightest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM coviddeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--


SELECT *
FROM covidvaccinations


-- Let's join these two tables together

SELECT *
FROM coviddeaths
JOIN covidvaccinations
ON coviddeaths.location = covidvaccinations.location
AND coviddeaths.date = covidvaccinations.date


-- Looking at Total Population vs Vaccination

SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(covidvaccinations.new_vaccinations) OVER (PARTITION BY coviddeaths.location ORDER BY coviddeaths.location,coviddeaths.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM coviddeaths
JOIN covidvaccinations
ON coviddeaths.location = covidvaccinations.location
AND coviddeaths.date = covidvaccinations.date
WHERE coviddeaths.continent IS NOT NULL
ORDER BY 2,3


-- Using a Common Table Expression (CTE)

WITH PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(covidvaccinations.new_vaccinations) OVER (PARTITION BY coviddeaths.location ORDER BY coviddeaths.location,coviddeaths.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM coviddeaths
JOIN covidvaccinations
ON coviddeaths.location = covidvaccinations.location
AND coviddeaths.date = covidvaccinations.date
WHERE coviddeaths.continent IS NOT NULL
--ORDER BY 2,3
 )
 
 SELECT *, (RollingPeopleVaccinated/Population)*100 as total_vaccinated
 FROM PopulationVsVaccinations
 
 
 -- TEMP TABLE
 
 DROP Table if exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime, 
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 
INSERT INTO #PercentPopulationVaccinated

SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(covidvaccinations.new_vaccinations) OVER (PARTITION BY coviddeaths.location ORDER BY coviddeaths.location,coviddeaths.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM coviddeaths
JOIN covidvaccinations
ON coviddeaths.location = covidvaccinations.location
AND coviddeaths.date = covidvaccinations.date
--WHERE coviddeaths.continent IS NOT NULL
--ORDER BY 2,3
 )
 
 SELECT *, (RollingPeopleVaccinated/Population)*100 as total_vaccinated
 FROM PopulationVsVaccinations
 
 
 -- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as
SELECT coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(covidvaccinations.new_vaccinations) OVER (PARTITION BY coviddeaths.location ORDER BY coviddeaths.location,coviddeaths.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM coviddeaths
JOIN covidvaccinations
	ON coviddeaths.location = covidvaccinations.location
	AND coviddeaths.date = covidvaccinations.date
WHERE coviddeaths.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
