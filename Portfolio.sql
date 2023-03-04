--Checking tables imported ordered by location and date

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not null
ORDER BY 3, 4

--Choose data to be used ordered by location and date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Deaths against Total Cases
--Shows the probability of dying if contracted Covid

SELECT location, date, total_deaths, total_cases
, (total_deaths*1.0)/(total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Malaysia' AND continent is not null
ORDER BY 1,2

--Total Cases against Population
--Shows the percentage of population that got Covid

SELECT location, date, total_cases, population
,(total_cases*1.0)/(population)*100 AS percentage_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Malaysia' AND
WHERE continent is not null
ORDER BY 1,2

--Highest Infection Rate against Population

SELECT location, population, MAX(total_cases) AS highest_infection_count
,MAX((total_cases*1.0)/(population))*100 AS percentage_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Malaysia' AND
WHERE continent is not null
GROUP BY location, population
ORDER BY percentage_population_infected DESC

--Highest Infection Count based on continent

SELECT location, MAX(total_cases) AS total_infected_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location <> 'High income' AND location <> 'Upper middle income'
AND location <> 'Lower middle income' AND location <> 'Low income' AND location <> 'European Union'
GROUP BY location

--Highest Death Count based on location

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Malaysia' AND
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--Highest Death Count based on continent

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location <> 'High income' AND location <> 'Upper middle income'
AND location <> 'Lower middle income' AND location <> 'Low income' AND location <> 'European Union'
GROUP BY location
ORDER BY total_death_count DESC

--Total cases and Total deaths globally per day

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, (SUM(new_deaths)*1.0)/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Group By date
ORDER BY 1,2

--Total cases and Total deaths globally altogeter as of 27/2/2023

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, (SUM(new_deaths)*1.0)/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 

--Population against New Vaccinations

With PoptoVac (continent, location, date, population, new_vaccinations, cumulative_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS cumulative_vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, ((cumulative_vaccinated*1.0)/population)*100 AS percentage_vaccinated_population
From PoptoVac
ORDER BY 2,3

--Creating view for visualization

Create View Death_Percentage AS
SELECT location, date, total_deaths, total_cases
, (total_deaths*1.0)/(total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

Create View Total_Case_Population AS
SELECT location, date, total_cases, population
,(total_cases*1.0)/(population)*100 AS percentage_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

Create View Highest_Infection AS
SELECT location, population, MAX(total_cases) AS highest_infection_count
,MAX((total_cases*1.0)/(population))*100 AS percentage_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population

Create View Highest_Death_Location AS
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location

Create View Highest_Infected_Continent	AS
SELECT location, MAX(total_cases) AS total_infected_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location <> 'High income' AND location <> 'Upper middle income'
AND location <> 'Lower middle income' AND location <> 'Low income' AND location <> 'European Union'
GROUP BY location

Create View Highest_Death_Continent	AS
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location <> 'High income' AND location <> 'Upper middle income'
AND location <> 'Lower middle income' AND location <> 'Low income' AND location <> 'European Union'
GROUP BY location

Create View Total_Cases_Deaths_Global AS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, (SUM(new_deaths)*1.0)/SUM(new_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Group By date

SELECT *
FROM Death_Percentage

SELECT *
FROM Total_Case_Population

SELECT *
FROM Highest_Infection
ORDER BY percentage_population_infected DESC

SELECT *
FROM Highest_Death_Location
ORDER BY total_death_count DESC

SELECT *
FROM Highest_Infected_Continent
ORDER BY total_infected_count DESC

SELECT *
FROM Highest_Death_Continent
ORDER BY total_death_count DESC

SELECT *
FROM Total_Cases_Deaths_Global
