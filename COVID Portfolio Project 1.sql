Select *
FROM PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4


--Select *
--FROM PortfolioProject1..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you are infected with covid in India
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
Where location like 'India'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percetnage of population got covid

Select Location, Date,  population, total_cases,(total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject1..CovidDeaths
--Where location like 'India'
order by 1,2


-- Looking at countries with highest infection rate vs population
Select Location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as InfectionPergentage
FROM PortfolioProject1..CovidDeaths
--Where location like 'India'
Group by Location, population
order by InfectionPergentage desc


--Showing countries with highest death count per population
Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--Where location like 'India'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- breaking things down by continent


--showing continents with highest death count

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--Where location like 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc vb


--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--Where location like 'India'
where continent is not null
--group by date
order by 1,2



--Total Population vs Vaccinations

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)

Select * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopVaccinated

--Creating view to store data for later data visualizations

Create View PercentPopVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopVaccinated