# COVID-19 Data Exploration 

**Description**

This script aims to explore the COVID-19 data by performing various analysis tasks. It utilizes SQL queries and employs skills such as joins, CTEs, temporary tables, window functions, aggregate functions, creating views, and converting data types. The script provides insights into different aspects of the COVID-19 data, including cases, deaths, vaccination coverage, and population statistics.

## Prerequisites
To use this script, you need the following:
- SQL Server
- Access to the [COVID-19 data source](https://ourworldindata.org/covid-deaths)

## Script Structure
The script is structured into several sections, each focusing on a specific analysis task. Here's an overview of the sections:
1. Selecting Initial Data: Retrieves the initial data from the COVID-19 dataset, filtering out records with missing continent information.
2. Total Cases vs Total Deaths: Calculates the death rate by dividing the total deaths by the total cases in Brazil, providing insights into the probability of dying from COVID-19 in the country.
3. Infection Rate by Country: Identifies the countries with the highest infection rate relative to their population, giving an indication of the impact of COVID-19 in different regions.
4. Highest Death Count by Country: Lists the countries with the highest death count per population, highlighting the severity of the pandemic in these areas.
5. Death Count by Continent: Analyzes the death count by continent, identifying the continents with the highest death count per population.
6. Global COVID-19 Numbers: Provides the total number of cases, deaths, and the death percentage on a global scale.
7. Daily Cases and Deaths: Examines the daily cases and deaths, calculating the death percentage for each date.
8. Total Population vs Vaccinations: Explores the relationship between the total population and the rolling vaccination coverage by location and date.
9. Peak Death Count in Brazil: Identifies the days with the highest death count in Brazil.
10. Days with Highest New Cases in Brazil: Identifies the days with the highest number of new COVID-19 cases in Brazil.

**Authorship and Contributions**

This COVID-19 data exploration script was adapted from a [tutorial](https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=1) and further customized to meet the specific requirements of this project. The base structure of the script follows the original tutorial, but modifications were made to address specific conditions and project needs.
