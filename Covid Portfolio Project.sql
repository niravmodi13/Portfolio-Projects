Select * 
From [Portfolio Projects]..['COVID DEATHS$']
where continent is not null
order by 3,4

--Select * 
--From [Portfolio Projects]..['COVID Vaccinations$']
--order by 3,4


Select location, date, total_cases, new_cases,total_deaths, population
From [Portfolio Projects]..['COVID DEATHS$']
where continent is not null
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From [Portfolio Projects]..['COVID DEATHS$']
Where location like '%India%'
and where continent is not null
ORDER BY 1,2

--Looking at Percentage of People Infected

Select location, date, total_cases, population, (total_cases / population)*100 as PopulationInfected
From [Portfolio Projects]..['COVID DEATHS$']
--Where location like '%India%'
where continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infectious rate compared to Population

Select location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 as PercentPopulationInfected
From [Portfolio Projects]..['COVID DEATHS$']
--Where location like '%India%'
where continent is not null
Group By location, population
ORDER BY PercentPopulationInfected desc


--Showing Countries with highest death count per population

Select location,MAX(cast(total_deaths as int)) as TotalDeaths
From [Portfolio Projects]..['COVID DEATHS$']
where continent is not null
group by location
ORDER BY TotalDeaths desc

-- Global Numbers

Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int))as totaldeaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From [Portfolio Projects]..['COVID DEATHS$']
--Where location like '%India%'
where continent is not null
GROUP BY date
ORDER BY 1,2  



--Looking at Total Population vs Vaccination

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations )) OVER(Partition by dea.location Order By dea. location,
 dea.date) as RollingPeopleCount
From [Portfolio Projects]..['COVID DEATHS$'] dea 
Join [Portfolio Projects]..['COVID Vaccinations$'] vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte

With PopvsVac(continent,location, date, Population, new_vaccinations,RollingPeopleCount)
as
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations )) OVER(Partition by dea.location Order By dea. location,
 dea.date) as RollingPeopleCount
From [Portfolio Projects]..['COVID DEATHS$'] dea 
Join [Portfolio Projects]..['COVID Vaccinations$'] vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleCount/Population)*100
From PopvsVac


--Using Temp Table
Drop table if exists #PercentpeopleVaccinate
Create table #PercentpeopleVaccinate
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleCount numeric
)

Insert into #PercentpeopleVaccinate
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations )) OVER(Partition by dea.location Order By dea. location,
 dea.date) as RollingPeopleCount
From [Portfolio Projects]..['COVID DEATHS$'] dea 
Join [Portfolio Projects]..['COVID Vaccinations$'] vac
On dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
order by 2,3

Select *, (RollingPeopleCount/Population)*100
From #PercentpeopleVaccinate

--Creating View to store data for later Visualization
Drop View PopvsVac
Create View PopvsVac  as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(convert(int, vac.new_vaccinations )) OVER(Partition by dea.location Order By dea. location,
 dea.date) as RollingPeopleCount
From [Portfolio Projects]..['COVID DEATHS$'] dea 
Join [Portfolio Projects]..['COVID Vaccinations$'] vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * From PopvsVac