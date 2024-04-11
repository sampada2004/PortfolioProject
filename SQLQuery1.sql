select *from PortfolioProject..CovidDeaths$
order by 3,4
--select *from PortfolioProject..CovidVaccinations$
--order by 3,4
select location,date,total_cases,total_deaths,total_deaths/total_cases
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2
--showing countries with highest nfection rate
select location,population,max(total_cases) as highestCount,max((total_cases/population))*100 as percentageInfected
from PortfolioProject..CovidDeaths$
group by location,population
order by percentageInfected desc

--showing highest death count per population
select location,max(cast(total_deaths as int)) as maxTotalDeaths
from PortfolioProject..CovidDeaths$
where continent is  null
group by location
order by maxTotalDeaths desc

select continent,max(cast(total_deaths as int)) as maxTotalDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by maxTotalDeaths desc

--global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases )*100 as death_percent
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--total vaccinations
select dea.continent,dea.location,dea.date,vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent,dea.location,dea.date,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolloing from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (continent,location,date,population,new_vaccinations,rolloing)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolloing from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select*,(rolloing/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolloing numeric)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolloing from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select*,(rolloing/population)*100
from #percentpopulationvaccinated

--view

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rolloing from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select*from dbo.percentpopulationvaccinated