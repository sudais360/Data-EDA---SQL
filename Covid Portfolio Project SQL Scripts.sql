select * 
from CovidDeaths
order by 3,4

--select * 
--from CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using 
select Location,date,total_cases, new_cases,total_deaths,population
from CovidDeaths
order by 1,2

-- Looking at total cases and total Deaths 
-- Shows liklihood of dying if you contract covid in your country 
select Location,date,total_cases,total_deaths, (Total_Deaths/Total_cases)* 100 as [Death Percentage]
from CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
select Location,date,population,total_cases, (total_cases/population)* 100 as [Covid Patient Percentage]
from CovidDeaths
where location like '%States%'
order by 1,2

-- What country had highest infection rate compred to populations

select Location,population,Max(total_cases) as [Highest infection count per country],  (max(total_cases)/population)* 100 as [Covid Patient Percentage]
from CovidDeaths
group by Location, population
order by [Covid Patient Percentage] desc


-- Showing Countries with Highest death count per ppulation 
select * 
from CovidDeaths
where continent is not null
order by 3,4



select Location, MAX(cast(total_deaths as int)) as [total death count]
from CovidDeaths
where continent is not null
group by Location
order by [total death count] desc


-- LETS BREAK THINGS DOWN my CONTinent
select continent, MAX(cast(total_deaths as int)) as [total death count]
from CovidDeaths
where continent is not null
group by continent
order by [total death count] desc


--  Global Number s

select date, sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum (new_cases)* 100 as [Death Percentage]
from CovidDeaths
where continent is not null
group by date
order by 1,2


select  sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum (new_cases)* 100 as [Death Percentage]
from CovidDeaths
where continent is not null


--select * 
--from CovidDeaths dea 
--join CovidVaccinations vac on  
--dea.location =vac.location 
--and dea.date = vac.date


-- Use CTE 
with popvsVac 
(continent,location,date,population,new_vaccinations,[Rolling ppl Vaccinated])
as 
(
-- Total Population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location,dea.date)
as [Rolling ppl Vaccinated]   -- ,([Rolling ppl Vaccinated]/population) *100


from CovidDeaths dea 
join CovidVaccinations vac on  
	dea.location =vac.location 
	and dea.date = vac.date

where dea.continent is not null
-- order by 2,3
)

select *,  ([Rolling ppl Vaccinated] /population)*100
from popvsVac


Drop table #percentpopulationvaccinated
-- Temp Table 
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_ppl_Vaccinated numeric
)

insert into #percentpopulationvaccinated
-- Total Population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location,dea.date)
as [Rolling ppl Vaccinated]   -- ,([Rolling ppl Vaccinated]/population) *100


from CovidDeaths dea 
join CovidVaccinations vac on  
	dea.location =vac.location 
	and dea.date = vac.date

--where dea.continent is not null
-- order by 2,3

select *,  (Rolling_ppl_Vaccinated /population)*100
from #percentpopulationvaccinated

-- Creatong View to stpre data for later visualixzation

create View Percentpopulationvaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by dea.location,dea.date)
as [Rolling ppl Vaccinated]   -- ,([Rolling ppl Vaccinated]/population) *100


from CovidDeaths dea 
join CovidVaccinations vac on  
	dea.location =vac.location 
	and dea.date = vac.date

where dea.continent is not null
 --order by 2,3

 select * from Percentpopulationvaccinated
