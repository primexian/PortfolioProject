--Select *
--From PortfolioProject..CovidDeaths
--order by 3,4

--Select *
--From PortfolioProject..CovidVax
--order by 3,4

--Select Data that we are going to be using

--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2  --doing 1,2 because we want based on location and date.

--Looking at total cases vs total deaths.
--Want to know percentage of people dying if you get the virus

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatePerInfected
From PortfolioProject..CovidDeaths
Where location like 'New Zealand'
order by 1,2


--Look at total cases versus the population. 
--Shows what percentage of populations has gotten covid
Select location, date, total_cases,population, total_deaths, (total_cases/population)*100 as PopulationToInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
order by 1,2

--what country have the highest infection rate compare to population.
Select location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Group by location, Population
order by PercentPopInfected DESC

--What country with the highest death count per population

Select location,  Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location
order by HighestDeathCount DESC

--We can examine this by looking at Continent 
--SHowing continents with highest death count per population

Select location,  Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is null
Group by location
order by TotalDeathCount DESC

--Global numbers of new cases everyday
-- new death is label as varchar so we have to cast it into int
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as TotalDeathsToTotalInfectedRatio
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Global data of total cases and total deaths
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as TotalDeathsToTotalInfectedRatio
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--CovidVax datasheet
--Looking at total population vs Vaccination
--Since this data is created we cannot use it stright away, need to put it into
--a temp_table or CTE




Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Cast(vax.new_vaccinations as int)) over (Partition by dea.location order by
dea.location, dea.date) as TotalVaxx
From PortfolioProject..CovidDeaths as dea Join PortfolioProject..CovidVax as vax
	On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null and dea.location = 'Canada'
order by 2,3
--Temp_table is used because we just got total vax from Canada but we cannot
--use the value stright away as it needs to be stored in a temp table or CTE
Drop table if EXISTS #PercentVaxxedFromPopulation
Create table #PercentVaxxedFromPopulation(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric ,
New_vaccinations numeric ,
TotalVaxx numeric
)

Insert into #PercentVaxxedFromPopulation
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Cast(vax.new_vaccinations as int)) over (Partition by dea.location order by
dea.location, dea.date) as TotalVaxx
From PortfolioProject..CovidDeaths as dea Join PortfolioProject..CovidVax as vax
	On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null and dea.location = 'New Zealand'
--order by 2,3

Select *, (TotalVaxx/Population)*100
From #PercentVaxxedFromPopulation

--Lets create a view to store data in visualization
Create view PercentVaxxedFromPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(Cast(vax.new_vaccinations as int)) over (Partition by dea.location order by
dea.location, dea.date) as TotalVaxx
From PortfolioProject..CovidDeaths as dea Join PortfolioProject..CovidVax as vax
	On dea.location = vax.location and dea.date = vax.date
Where dea.continent is not null and dea.location = 'New Zealand'



--Now we call the view
Select location,  MAX(CAST(new_vaccinations as int)) as MaxVaxxPerDay
From PercentVaxxedFromPopulation
group by location
Order by MaxVaxxPerDay

Select *
From PercentVaxxedFromPopulation