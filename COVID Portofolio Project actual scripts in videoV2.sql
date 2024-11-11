select * 
from PortofolioProject.[dbo].[CovidDeaths]
where continent is not null
order by 3,4

--select *
--from [PortofolioProject].[dbo].[CovidVaccination]

select location,date,total_cases,new_cases,total_deaths,population
from PortofolioProject.[dbo].[CovidDeaths]
order by 1,2

--Looking at total cases Vs Total Deaths
--shows lielyhood of dying in tyour country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as totaldeathpercentage
from PortofolioProject.[dbo].[CovidDeaths]
where location like '%states%'
order by 1,2

--Looking a total cases Vs Population 
-- Shows what perentage of population got Covid
select location,date,total_cases,population, (total_cases/population)*100 as PercentPoplationInfected
from PortofolioProject.[dbo].[CovidDeaths]
where location= 'United States'
order by 1,2

--Looking at Countries with the highest infection rate compared to Population 
select location,population, Max(total_cases), Max((total_cases/population))*100 as PercentPoplationInfected
from PortofolioProject.[dbo].[CovidDeaths]
Group by location,population
order by PercentPoplationInfected desc

--Showing countries with Highest death Count Per pupulation 

select location,population, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 as PercentPopulationDeath
from PortofolioProject.[dbo].[CovidDeaths]
where continent is not null
Group by location,population
order by TotalDeathCount Desc

--Let's break things down by contininent 

select  continent, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 as PercentPopulationDeath
from PortofolioProject.[dbo].[CovidDeaths]
where continent is not null
Group by continent
order by TotalDeathCount Desc


--Showing continenets with the highest  death count per population 

select  continent, MAX(cast(total_deaths as int)) as TotalDeathCount,MAX((total_deaths/population))*100 as PercentPopulationDeath
from PortofolioProject.[dbo].[CovidDeaths]
where continent is not null
Group by continent
order by TotalDeathCount Desc


--Global Numbers--

select SUM(new_cases) as total_cases,SUM(cast (new_deaths as int)) as total_deaths,SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortofolioProject.[dbo].[CovidDeaths]
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population Vs Vaccinations

Select [CovidDeaths].continent,[CovidDeaths].location,[CovidDeaths].date,[CovidDeaths].population,[CovidVaccination].new_vaccinations
,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by [CovidDeaths].location Order by [CovidDeaths].location,[CovidDeaths].date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [PortofolioProject].[dbo].[CovidVaccination]
Join
[PortofolioProject].[dbo].[CovidDeaths]
on [CovidVaccination].location=[CovidDeaths].location 
and [CovidVaccination].date=[CovidDeaths].date
where [CovidDeaths].continent is not null
order by 2,3

--Use CTE
With PopvsVac ( 
continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as  
(
Select [CovidDeaths].continent,[CovidDeaths].location,[CovidDeaths].date,[CovidDeaths].population,[CovidVaccination].new_vaccinations
,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by [CovidDeaths].location Order by [CovidDeaths].location,[CovidDeaths].date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [PortofolioProject].[dbo].[CovidVaccination]
Join
[PortofolioProject].[dbo].[CovidDeaths]
on [CovidVaccination].location=[CovidDeaths].location 
and [CovidVaccination].date=[CovidDeaths].date
where [CovidDeaths].continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinated

Select [CovidDeaths].continent,[CovidDeaths].location,[CovidDeaths].date,[CovidDeaths].population,[CovidVaccination].new_vaccinations
,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by [CovidDeaths].location Order by [CovidDeaths].location,[CovidDeaths].date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [PortofolioProject].[dbo].[CovidVaccination]
Join
[PortofolioProject].[dbo].[CovidDeaths]
on [CovidVaccination].location=[CovidDeaths].location 
and [CovidVaccination].date=[CovidDeaths].date
where [CovidDeaths].continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
from #

--createing View to store data for later viualizations

drop view PercentPopulationVaccinated
Create View PercentPopulationVaccinated as

Select [CovidDeaths].continent,[CovidDeaths].location,[CovidDeaths].date,[CovidDeaths].population,[CovidVaccination].new_vaccinations
,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by [CovidDeaths].location Order by [CovidDeaths].location,[CovidDeaths].date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [PortofolioProject].[dbo].[CovidVaccination]
Join
[PortofolioProject].[dbo].[CovidDeaths]
on [CovidVaccination].location=[CovidDeaths].location 
and [CovidVaccination].date=[CovidDeaths].date
where [CovidDeaths].continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
