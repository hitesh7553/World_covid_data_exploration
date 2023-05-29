SELECT *
FROM PortfolioProject.dbo.COVID_deaths
WHERE continent is not null
ORDER BY 3,4

-- Selecting data 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVID_deaths
ORDER BY 1,2 

-- Looking at total_cases VS Total_deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Death_percentage
FROM PortfolioProject..COVID_deaths
WHERE location like '%India%'
ORDER BY 1,2 

-- Looking at total_cases VS Population
-- Shows what percentage of population got covid


SELECT location, date, total_cases, Population, (total_cases / population)*100 AS Precentage_of_people_affected
FROM PortfolioProject..COVID_deaths
WHERE location like '%India%'
ORDER BY 1,2 

-- Looking at countries with highest inffection rate compared to population
SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS Precentage_of_people_affected
FROM PortfolioProject..COVID_deaths
GROUP BY location, population
ORDER BY 4 DESC


-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) AS Total_death_counts
FROM PortfolioProject..COVID_deaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

-- Let's Break through CONTINENT
	
SELECT continent, MAX(total_deaths) AS Total_death_counts
FROM PortfolioProject..COVID_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- Showing the continents with highest death count per population
SELECT continent, MAX(total_deaths) AS Total_death_counts
FROM PortfolioProject..COVID_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--  Global numbers
SELECT  date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..COVID_deaths
--WHERE location like '%India%' AND new_deaths > 0
WHERE continent is not null  AND new_deaths > 0
GROUP BY date
ORDER BY 1,2

-- Joining table
SELECT *
FROM PortfolioProject..COVID_deaths AS dea
JOIN PortfolioProject..COVID_vaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date

-- Looking at total population VS vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Vaccination_across_countries
FROM PortfolioProject..COVID_deaths AS dea
JOIN PortfolioProject..COVID_vaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
   ORDER BY 2,3
 

-- Creating CTE
WITH PopVSVac (continent, location, date, population, new_vaccinations, Vaccination_across_countries)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Vaccination_across_countries
FROM PortfolioProject..COVID_deaths AS dea
JOIN PortfolioProject..COVID_vaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
  -- ORDER BY 2,3
)
SELECT *, (Vaccination_across_countries / population)*100 AS Per_of_people_vaccinated
FROM PopVSVac

-- Creating TEMP TABLE
DROP TABLE IF EXISTS #Clean_data
 CREATE TABLE #Clean_data 
(
 continent varchar(255),
 location varchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 Vaccination_across_countries numeric
)
INSERT INTO #Clean_data
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Vaccination_across_countries
FROM PortfolioProject..COVID_deaths AS dea
JOIN PortfolioProject..COVID_vaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
--WHERE dea.continent is not null
  -- ORDER BY 2,3
SELECT *, (Vaccination_across_countries / population)*100 AS Percent_people_vaccinated
FROM #Clean_data


-- Creating View for data visualization for later

CREATE VIEW Percent_pop_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float) ) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Vaccination_across_countries
FROM PortfolioProject..COVID_deaths AS dea
JOIN PortfolioProject..COVID_vaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
  -- ORDER BY 2,3

SELECT *
FROM Percent_pop_vaccinated
