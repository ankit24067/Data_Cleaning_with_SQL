# World Layoffs Data Cleaning Project

This project involves creating a clean and structured database of layoff data from around the world. The goal is to preprocess the dataset by removing duplicates, standardizing data formats, handling null values, and dropping unnecessary columns, making it ready for analysis and further exploration.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Database Schema](#database-schema)
3. [Data Cleaning Process](#data-cleaning-process)
4. [Setup Instructions](#setup-instructions)
5. [Future Enhancements](#future-enhancements)

## Project Overview
This project uses SQL scripts to clean and transform layoff data into a consistent and reliable format. By handling duplicates, null values, and standardizing fields, we aim to provide a clean data source for data analysis and visualization.

## Database Schema
We create the following tables in the `world_layoffs` schema:
- `layoffs`: The original data with details on layoffs.
- `layoffs_staging`: A staging table used for data transformation and cleaning.
- `layoffs_staging2`: A refined version of `layoffs_staging`, used to apply additional data cleaning operations.

### Table Structure
| Column               | Data Type  | Description                      |
|----------------------|------------|----------------------------------|
| `company`            | TEXT       | Name of the company              |
| `location`           | TEXT       | Location of the company          |
| `industry`           | TEXT       | Industry type                    |
| `total_laid_off`     | INT        | Total number of employees laid off |
| `percentage_laid_off`| TEXT       | Percentage of employees laid off |
| `date`               | DATE       | Date of the layoff               |
| `stage`              | TEXT       | Stage of the company             |
| `country`            | TEXT       | Country of the company           |
| `funds_raised_millions` | INT    | Funds raised by the company (in millions) |

## Data Cleaning Process
The data cleaning process involves the following steps:

1. **Removing Duplicates**  
   Using a CTE with `ROW_NUMBER()` to identify duplicate rows based on specific columns and delete them from the staging table.

2. **Standardizing Data**  
   - Updating inconsistent values (e.g., standardizing 'Crypto Currency' and 'CryptoCurrency' to 'Crypto').
   - Trimming unnecessary characters in `country` values (e.g., removing trailing periods in "United States.").

3. **Handling Null Values**  
   - Updating rows with missing `industry` data by filling in values based on existing rows with the same `company`.
   - Retaining `null` values in columns like `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions` where appropriate.

4. **Converting Data Types**  
   - Converting the `date` column from text to a proper `DATE` format.

5. **Dropping Unnecessary Columns**  
   - Removing helper columns such as `row_num` after they have served their purpose.

6. **Deleting Rows with Incomplete Data**  
   - Deleting rows where both `total_laid_off` and `percentage_laid_off` are `null`.

