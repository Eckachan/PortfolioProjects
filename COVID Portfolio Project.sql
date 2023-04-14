select *
from [PortfolioProject]..CovidDeaths
where continent is not null
order by 3,4

select *
from [PortfolioProject]..CovidVaccination
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihoood of dying if you contract covid in your country

Select Location, date, total_cases,new_cases ,total_deaths, population
From [PortfolioProject]..CovidDeaths
Order By 2,3


--This is how you do when you encounter "Operand data type nvarchar is invalid for divide operator."

Select Location, date, total_cases,total_deaths, cast(total_deaths as float)/ CAST(total_cases as float)*100 as DeathPercentage
From [PortfolioProject]..CovidDeaths
Where location like '%Philippines%'
Order By 1,2

-- looking at Total Cases vs Population
-- Shows wgar percentage of population got Covid


Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [PortfolioProject]..CovidDeaths
Where location like '%Philippines%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
as PercentPopulationInfected
From [PortfolioProject]..CovidDeaths
--Where location like '%Philippines%'
Group By Location, population
Order By PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
--Where location like '%Philippines%'
where continent is not null
Group By Location
Order By TotalDeathCount desc

-- LET'S BREALK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
--Where location like '%Philippines%'
where continent is NOT null
Group By continent
Order By TotalDeathCount desc



-- GLOBAL NUMBERS


Select DATE,
	SUM(new_cases),
	SUM(cast(new_deaths AS int)) AS total_deaths,
	Case when SUM(new_cases) > 0
		then SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100
		else 0
	End as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Philippines%'
--Where continent is not null
Group by DATE
Order by 1,2


--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac 
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated

