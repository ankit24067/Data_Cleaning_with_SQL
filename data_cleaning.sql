SELECT * 
FROM world_layoffs.layoffs;

-- 1. Removing the Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

create table world_layoffs.layoffs_staging
like world_layoffs.layoffs;

select *
from world_layoffs.layoffs_staging;

insert into world_layoffs.layoffs_staging
select *
from world_layoffs.layoffs;

select *
from world_layoffs.layoffs_staging;

with duplicate_cte as(
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off,
`date`, stage, country, funds_raised_millions) as row_num
from world_layoffs.layoffs_staging
)
select * 
from duplicate_cte
where row_num>1;

select * 
from world_layoffs.layoffs_staging
where company = 'Oda';

WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;



-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- so let's do it!!

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;


SELECT *
FROM world_layoffs.layoffs_staging
;

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;
        
        
	
-- now that we have this we can delete rows were row_num is greater than 2
SET SQL_SAFE_UPDATES = 0;

delete from world_layoffs.layoffs_staging2
where row_num >=2;


select * from world_layoffs.layoffs_staging2
where row_num >=2;

 
 -- 2. Standardize Data
 
 select *
 from world_layoffs.layoffs_staging2;
 
 select distinct industry
 from world_layoffs.layoffs_staging2
 order by industry;
 
 -- there are some null values in industry column
 
 select *
 from world_layoffs.layoffs_staging2
 where industry is null
 or industry = ' '
 order by industry;
 
 
 -- let's take a look at this
 
select * from
world_layoffs.layoffs_staging2
where company like 'Bally%';

select * from
world_layoffs.layoffs_staging2
where company like 'airbnb%';


-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
update world_layoffs.layoffs_staging2
set industry = null
where industry = '';


-- Check if all those are null
select *
from world_layoffs.layoffs_staging2
where industry is null
or industry = ''
order by industry; 

-- now we need to poplate those nulls if possible-- 
update world_layoffs.layoffs_staging2  as t1
join world_layoffs.layoffs_staging2 as t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;


-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
select *
from world_layoffs.layoffs_staging2
where industry is null
or industry = ''
order by industry; 


-- as of the data crypto has multiple different variations. We need to
-- standardize that - let's say all to crypto-- 

select distinct industry
from world_layoffs.layoffs_staging2
order by industry;

update world_layoffs.layoffs_staging2
set industry = 'Crypto'
where industry in ('Crypto Currency', 'CryptoCurrency');

-- now the problem has been solved
select distinct industry
from world_layoffs.layoffs_staging2
order by industry;


select distinct country
from world_layoffs.layoffs_staging2
order by country;

-- in country column we have some 'United States' and some
-- 'United States.' column which may lead a problem so let's
--  solve it first

update world_layoffs.layoffs_staging2
set country = trim(trailing '.' from country);

-- let's see if it is solved or not
-- yes it is solved
select distinct country
from world_layoffs.layoffs_staging2
order by country;

select `date`
from world_layoffs.layoffs_staging2;

-- the date column is in text format so let's fix that-- 
-- update world_layoffs.layoffs_staging2
-- set `date` = str_to_date(`date`, '%m/%d/%Y');

UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` LIKE '%/%/%';

-- Now we can convert data type properly
alter table world_layoffs.layoffs_staging2
modify column `date` date;

describe world_layoffs.layoffs_staging2;


-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


-- 4. remove any columns and rows we need to

select *
from world_layoffs.layoffs_staging2
where total_laid_off is null;

select *
from world_layoffs.layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- as this two columns have null values together it really is not
-- making any sense at all to have them in table so let's delete these

delete
from world_layoffs.layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from world_layoffs.layoffs_staging2;

alter table world_layoffs.layoffs_staging2
drop column row_num;
select * 
from world_layoffs.layoffs_staging2;