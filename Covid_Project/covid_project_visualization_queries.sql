USE portfolioproject;
-- Scripts to be used for Tableau visualizations.
#1. 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

#2. 
SELECT location, SUM(new_deaths) AS Total_Death_Count
FROM covid_deaths
WHERE continent = '' AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count DESC;

#3. 
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)) * 100 AS Percent_Population_Infected
FROM covid_deaths
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC;


#4. 
SELECT location, population, date, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)) * 100 AS Percent_Population_Infected
FROM covid_deaths
GROUP BY location, population, date
ORDER BY Percent_Population_Infected DESC;


