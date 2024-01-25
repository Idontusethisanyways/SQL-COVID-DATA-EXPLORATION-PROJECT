SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4

--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

--Selecting data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Total case vs total deaths
Select Location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%Kazakhstan%'
order by 1,2

--Total cases vs population
Select Location, date, total_cases,population, (cast(total_cases as float)/population) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Kazakhstan%'
order by 1,2

--Adding Highest Infection count out of total population by countries
Select Location, Population, MAX(cast(total_cases as float)) as HighestInfectionCount, MAX((cast(total_cases as float)/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Total death count by location
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Total death count by continent (accurate)
Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location not like '%income%'
Group by Location
order by TotalDeathCount desc

--Total death count by continent (inaccurate data is incorect)
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc




--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated


--View to store data for later visualizations | создаю view чтобы хранить данные для последующих визуализаций

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
