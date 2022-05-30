USE portfolioproject;
-- Unchecked 2000 row limit in edit -> preferences.
SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Likelihood of dying if contracted with Covid in a given country.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid_deaths
WHERE Location LIKE '%states%' -- includes virgin islands.
ORDER BY 1,2;

-- Returns 851 results without using the 'LIKE' keyword, doesn't include virgin islands.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM covid_deaths
WHERE Location = 'United States'
ORDER BY 1,2;

-- Total cases vs Population
-- Percentage of population that contracted Covid-19.
SELECT Location, date, Population, total_cases, (total_cases/Population) * 100 AS ContractPercentage
FROM covid_deaths
WHERE Location LIKE '%states%'
ORDER BY 1,2;


-- Highest infection rates per country
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) * 100 AS Contract_Percentage
FROM covid_deaths
GROUP BY Location, Population
ORDER BY Contract_Percentage DESC;

-- Highest death rates per country
SELECT Location, MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC;

-- Highest death rates by location, where continent includes empty values.
SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent = '' -- if continent has an empty/null value.
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Highest death rates by continent (includes other factors such as lower, middle, and upper income columns).
SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Total cases & total deaths daily globally.
SELECT date, SUM(new_cases) AS total_daily_cases, SUM(new_deaths) AS total_deaths_daily, SUM(new_deaths)/SUM(new_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date WITH ROLLUP -- shows the global total and global death percentage.
ORDER BY 1,2;

-- Inner join both covid deaths & covid vaccinations table on the thing they share.
SELECT *
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date;

-- Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

-- Total Population vs Vaccinations: partitions the location, and only adds new vaccinations until the next country is selected. 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (partition by cd.location ORDER BY cd.location, date) AS RollingPeopleVaccinated
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

/*
-- Using CTE 
WITH PopvsVac AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (partition by cd.location ORDER BY cd.location, date) AS RollingPeopleVaccinated
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT * 
FROM PopvsVac;
*/

-- Temp Table alternative, issues in creation of CTE. Accomplishes the same thing.
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated(
continent VARCHAR(500),
location VARCHAR(100),
date datetime,
population INT,
new_vaccinations INT,
RollingPeopleVaccinated INT
);

ALTER TABLE PercentPopulationVaccinated
MODIFY RollingPeopleVaccinated BIGINT; -- allows us to store values beyond what INT can store.

-- insert total popluation vs vaccinations data, and add calculations to RollingPeopleVaccinated column.
INSERT INTO PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (partition by cd.location ORDER BY cd.location, date) AS RollingPeopleVaccinated
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PercentPopulationVaccinated;

-- Creating view for visual data in Tableau using the previously made temp table.
DROP VIEW IF EXISTS PercentPopulationVaccinatedView;
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (partition by cd.location ORDER BY cd.location, date) AS RollingPeopleVaccinated
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
-- ORDER BY 2,3;
 
SELECT * 
FROM PercentPopulationVaccinatedView;