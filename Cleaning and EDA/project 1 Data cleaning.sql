SELECT *
FROM layoffs;

-- 1. Remove duplicates
-- 2. Standardize the Data
-- 3. Null values or blank values
-- 4. Remove Any columns

-- make a draft 
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- 1. Remove duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

-- create CTE with the code above
WITH duplicate_cte AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
-- detect duplicate rows
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- check duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'iFit';
-- create table layoffs_staging2
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- check new table
SELECT *
FROM layoffs_staging2;
-- insert information like in our CTE into new table
INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging;
--  delete duplicates from new table
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;
-- check if it worked 
SELECT *
FROM layoffs_staging2
WHERE row_num >1;




-- 2. Standardize Data
-- check company
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- trim company name
UPDATE layoffs_staging2
SET company = TRIM(company);

-- check industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- change Crypto currency to crypto
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- check country
SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- update country 
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- date column is TEXT, change it
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
-- update date column 
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- change it to the DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;




-- 3. NULL values
-- identify rows with null in both columns total_laid_off and percentage_laid_off = they can be deleted, because they are not useful for further analysis
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
-- delete 
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
    
-- NULL of blank in industry 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
	OR industry = '';
-- identify another row, which is not null - use this row to fill the data  
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';
-- use this row to fill the data (identify rows first)
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;
-- change blank into NULL
UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '';
-- fill 
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;



-- 4. Remove Any columns
-- delete column that we created for duplicate identification 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- final check
SELECT *
FROM layoffs_staging2;


