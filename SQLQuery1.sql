--Select the data to use
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;

--Total cases vs Total Deaths
--Likelihood of dying if you get covid in perticular country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2;

--Total cases vs Total Population 
--Percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location = 'India'
order by 2;

--Infection rate compared to population
Select location, population, Max(total_cases)as InfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
Group by location, population
order by PercentagePopulationInfected desc;

--Countries wih highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
Group by location
order by TotalDeaths desc;

--Countinent wih highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeaths desc;

--Total population vs Total Population	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Total population vs Total Population	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PopulationVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'Canada';
 
-- Using CTE
with popvsvac
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PopulationVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'Canada')
select *, (PopulationVaccinated/population)*100 as PercentagePeopleVaccinted
from popvsvac;

--Using Temp Table
Drop Table if exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(200),
Location nvarchar(200),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PopulationVaccinated numeric
)

Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PopulationVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *, (PopulationVaccinated/Population)*100
from #PercentagePeopleVaccinated;

--Create view for visualisation 
Create view PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as PopulationVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *
from PopulationVaccinated;