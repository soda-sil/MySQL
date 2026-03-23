-- Data Cleaning

SELECT * 
FROM world_layoffs.layoffs;

-- When we are data cleaning we usually follow a few steps
-- 1. Check for duplicates and remove any
-- 2. Standardize data and fix errors
-- 3. Look at null values
-- 4. Remove any columns and rows that are not necessary

-- The first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Check for duplicates and remove any
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- To see the duplicates rows
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Checking if one random of these rows is in fact a duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Creating another table but with the row_num so we can delete those who have the row_num 2

CREATE TABLE `layoffs_staging2` (                -- we need to change the name
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int                                    -- we need to add this row
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardize data and fix errors

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

-- Update the name of the company without spaces before or after
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- I noticed the Crypto has multiple different variations. We need to standardize that - let's change all to Crypto
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- I noticed the DÃ¼sseldorf meant Dusseldorf. We need to standardize that - let's change it to Dusseldorf
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE location LIKE '%dorf';

UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location LIKE 'DÃ¼sseldorf';

-- Everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- To see the most common format
SELECT *   
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

-- We delete the '.' from the country and compare the before and after
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Let's also fix the date columns that are in text format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- But the date format is still a text so we need to change it
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Look at Null Values
SELECT *   
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Here we can see that we can update the null in industry on the first Airbnb to Travel
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Change the blanks to Nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Here we change the null industry to the correct industry based on other entries of the same company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- 4. Remove any columns and rows we don't need to
-- We are going to delete these rows because they are unuseful for us 
SELECT *   
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- We are going to delete the column row_num because we don't need it anymore
SELECT *   
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;