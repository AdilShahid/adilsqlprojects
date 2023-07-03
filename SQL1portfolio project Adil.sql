

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio project 2 ]..[covid deaths]
ORDER BY 1,2 

-- LOOKING at Total Cases vs DEATHS, show sprobability of death 
SELECT  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  AS DEATHPERCENTAGE 
FROM [portfolio project 2 ]..[covid deaths]
WHERE location LIKE '%pakistan%'
order by 1,2


-- looking at total cases vs population   
SELECT  Location, date, total_cases, population, (total_cases/ population)*100  AS populationPERCENTAGE 
FROM [portfolio project 2 ]..[covid deaths]
WHERE location LIKE '%pakistan%'
order by 1,2

-- countries with highest infection rate 
SELECT  Location, MAX(total_cases) AS maximuminfectioncount, population, MAX((total_cases/ population))*100  AS Populationpercenteffected 
FROM [portfolio project 2 ]..[covid deaths]
group by location, population
order by Populationpercenteffected desc; 

--countries with highest death count  
SELECT  Location, MAX(total_deaths) AS totaldeaths
FROM [portfolio project 2 ]..[covid deaths]
WHERE 'continent' is not null 
group by location
order by totaldeaths desc; 
-- breaking down by continents 
SELECT continent, MAX(total_deaths) AS totaldeaths
FROM [portfolio project 2 ]..[covid deaths]
WHERE 'continent' is not null 
Group by location
order by totaldeaths desc;

--showing continents with highest death rate 
SELECT continent, MAX(total_deaths) AS totaldeaths
FROM [portfolio project 2 ]..[covid deaths]
WHERE 'continent' is not null 
Group by continent 
order by totaldeaths desc;

--GLOBAL NUMBERS 
SELECT date, SUM(new_cases), SUM(CAST(new_deaths as int)) AS total_deaths,
(SUM(total_deaths)/SUM(total_cases))*100 as DEATHPERCENTAGE 
FROM [portfolio project 2 ]..[covid deaths]
WHERE continent IS NOT NULL
Group by date
order by 1,2;

--GLOBAL NUMBERS 
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 as DEATHPERCENTAGE  
FROM [portfolio project 2 ]..[covid deaths]
WHERE continent IS NOT NULL
order by 1,2;


SELECT *
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on  dea.location = vac.location and dea.date=vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
		where dea.continent is not null
		order by 2,3;

-- looking at vaccinations is pakistan against population after vacinations were started 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
		where dea.location = 'pakistan' and vac.new_vaccinations is not null 
		order by 2,3;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated 
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
		where dea.continent is not null
		order by 2,3;

--using cte 
with PopvsVac (continent, location, date, population, New_vaccinations, rollingpeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated 
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null

)
SELECT *, (rollingpeopleVaccinated/population)*100 as percentageofpeoplevaccinated FROM PopvsVac 
WHERE location = 'Pakistan' ;


--temp table 
Create table  percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)
Insert INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated 
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
		where dea.continent is not null
		order by 2,3
SELECT *, (rollingpeoplevaccinated/population)*100 from  percentpopulationvaccinated
-- use drop table 


Create view percentpopulationvaccinated_v as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as rollingpeoplevaccinated 
FROM  [portfolio project 2 ]..[covid deaths] dea
JOIN [portfolio project 2 ]..['vacinations-covid-data$'] vac
	on dea.location = vac.location and dea.date=vac.date
		where dea.continent is not null

SELECT * FROM percentpopulationvaccinated_v; 