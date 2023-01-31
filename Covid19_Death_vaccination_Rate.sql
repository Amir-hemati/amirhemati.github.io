/* 
Covid 19 Data Exploration 
Analyzes of Corona Pandemic and the effect of vaccination on death rate
Data Cleaning Phase 
*/

--Deaths rate orderd by Location and Date
Select *
From PortfolioProject.dbo.coviddeats$
Where continent is not null 
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.coviddeats$
Where continent is not null 
order by 1,2

-- Computing Death Rate (Total Cases vs Total Deaths) in Italy

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.coviddeats$
Where location like '%italy%'
and continent is not null 
order by 1,2

-- Infection Rate( Total Cases/Population) in each country

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.coviddeats$
order by 1,2

-- Infection Rate( Total Cases/Population) in Italy

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.coviddeats$
Where location like '%Italy%'
order by 1,2


-- Countries ordered by Infection Rate compared to Population (Highest to Lowest)

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.coviddeats$
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries ordered by Death Rate per Population (Highest to Lowest)

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.coviddeats$
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--------------------------------------------------------------------

-- ANALYZING CONTINENTS

-- contintents with the highest Death Rate per capita
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.coviddeats$
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL DEATH RATE

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.coviddeats$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

---------------------------------------------------------------------------------
--ANALYZING THE EFFECT OF VACCINATION

-- Vaccination Rate
-- Vaccination Rate ordered by Country (at least One dose)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject.dbo.covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) Over (partition by dea.location)
From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject.dbo.covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject.dbo.covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject.dbo.covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject..covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.coviddeats$ dea
Join PortfolioProject.dbo.covidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

