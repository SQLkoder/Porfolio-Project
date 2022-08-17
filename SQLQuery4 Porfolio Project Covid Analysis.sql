
--Looking at totalcases and totaldeaths in India
 --Shows likelihood of dying of covid deaths in India 
 --Shows gradual increase in % of covid deaths in India
 
 select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.[dbo].[CovidDeaths]
where location like 'india'
order by 'date' 

--Looking at totalcases vs population 
--Shows what percentage of population got covid

select location, date, total_deaths, population, (total_cases/population)*100 as 
from PortfolioProject.[dbo].[CovidDeaths]
where location like 'india'
order by 'date' desc 

--Looking at Countries with Highest Infection rate compared to population

select location,  population, Max(total_cases)as HigestInfectionRate, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject.[dbo].[CovidDeaths]
group by location, population
order by HigestInfectionRate desc

--Showing Countries with Highest Death Count per Population
--Also shows % of population dead in each country

select location,  population, Max(cast (total_deaths as int))as 'Total Death count', Max((total_deaths/population))*100 as 'Percentage Population dead'
from PortfolioProject.[dbo].[CovidDeaths]
Where continent is not null
group by location, population
order by 'Total Death Count' desc

--Showing Continents with Higest Death Count per Population
--Also showing % of population dead in each continent

select continent, population, Max(cast (total_deaths as int))as 'Total Death count', Max((total_deaths/population))*100 as 'Percentage Population dead'
from PortfolioProject.[dbo].[CovidDeaths]
Where continent is not null
group by population, continent
order by 'Total Death Count' desc

--Global Numbers
--Showing TotalCases vs TotalDeaths 
--Also % of Total Cases to Total Deaths

select sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int)) as 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'
from PortfolioProject.[dbo].[CovidDeaths]
where continent is not null
--group by date
order by  'Death Percentage' 


--Looking at Total Population vs Vaccinations
--Ordered by Location
--Also shows Sumof New People Vaccinated each day

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date) RollingPeopleVaccinated
from PortfolioProject..[CovidDeaths ] cd
join PortfolioProject..[CovidDeaths ] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by cd.location

--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date) RollingPeopleVaccinated
from PortfolioProject..[CovidDeaths ] cd
join PortfolioProject..[CovidDeaths ] cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
--order by cd.location
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (Partition by cd.location order by cd.location,cd.date) RollingPeopleVaccinated
from PortfolioProject..[CovidDeaths ] cd
join PortfolioProject..[CovidDeaths ] cv
on cd.location = cv.location and cd.date = cv.date
--where cd.continent is not null
--order by cd.location

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization


Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 