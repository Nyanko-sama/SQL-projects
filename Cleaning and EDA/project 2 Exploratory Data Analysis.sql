SELECT *
FROM layoffs_staging2;

-- check the greatest laid off and greates percentage of laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- check which companies were laid off completely
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
Order by total_laid_off DESC;

-- which companies had greatest total laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- data period of our dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- in which industry there was the greatest laid off
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- in which country there was the greatest laid off
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- when was the greatest laid off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- stage and laid off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- progression of laid off during time (rolling sum of total_laid_off) 
WITH rolling_total AS 
( 
SELECT SUBSTRING(`date`, 1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`)
FROM rolling_total;

-- 
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- look at top 5 companies each year that laid off
WITH company_year (companym, years, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *, 
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE ranking <= 5;




