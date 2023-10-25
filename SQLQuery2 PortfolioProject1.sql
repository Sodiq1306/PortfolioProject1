
Select *
from PortfolioProject1..CovidDeaths 
where continent is not null
order by 3,4

--Select *
--from PortfolioProject1..CovidVaccinations 
--order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject1..CovidDeaths 
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_cases/total_deaths) as DeathPercentage 
from PortfolioProject1..CovidDeaths 
where location like '%states%'
order by 1,2


-- Looking at total cases  vs population
-- Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths 
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc



-- Showing countries with Highest Death Count per population

select location, MAX(Cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject1..CovidDeaths
where continent is not Null
Group by location
order by TotalDeathsCount desc




-- LETS BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc



-- Showing The continent with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
WHERE continent is not null
Group by date
order by 1,2

-- Totalcases vs TotalDeaths
Select  sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths 
--where location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2



select Sum(new_cases) as tota_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2




-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



	-- USE CTE

	with PopvsVac (continent, location, date, population, New_Vaccinations,  RollingPeopleVaccinated)
	as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *, (RollingPeopleVaccinated/population)* 100
from PopvsVac




--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	-- where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/population)* 100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualisations

Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	-- order by 2,3

	select *
	from PercentPopulationVaccinated