USE Project;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
   WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
End;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

 UPDATE hr
SET hire_date = CASE
   WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
   WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
   ELSE NULL
End;

Select hire_date from hr;

Select termdate from hr;

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER table hr ADD Column age INT;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;



UPDATE hr 
SET age = timestampdiff(YEAR,birthdate,CURDATE());

SELECT birthdate, age FROM hr;

SELECT 
  min(age) AS youngest,
  max(age) AS oldest
FROM hr;

SELECT Count(*) FROM hr WHERE age < 18;


-- 1) What is the gender breakdown of employees in the company?
SELECT gender, Count(*) AS count
FROM hr
WHERE age>=18 AND termdate = ''
GROUP BY gender;

-- 2)  What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr
WHERE age >=18 AND termdate = ''
GROUP BY race
ORDER BY Count(*) DESC;
 
-- 3) What is the age distribution of employees in the company?
SELECT 
   Min(age) AS Youngest,
   Max(age) AS oldest
FROM hr
WHERE age>=18 AND termdate = '';
SELECT 
 CASE
   WHEN age>=18 AND age<=24 THEN '10-24'
   When age>=25 AND age<=34 THEN '25-34'
   When age>=35 AND age<=44 THEN '35-44'
   When age>=45 AND age<=54 THEN '45-54'
   ELSE '65+'
End AS age_group,
Count(*) AS count
FROM hr
WHERE age >=18 AND termdate= ''
GROUP BY age_group
ORDER BY age_group;


-- 4) How many employees work at headquarters vs remote locations?
SELECT location,count(*) AS count
FROM hr
WHERE age >=18 AND termdate= ''
GROUP BY location;

-- 5) What is ths average length of employment for employees who have been terminated?
SELECT 
    round(AVG(datediff(termdate,hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate<=curdate() AND termdate <> '0000-00-00' AND age >= 18;

-- 6) How does the gender distribution varies across departments and job titles?
SELECT Department, gender, Count(*) AS count
FROM hr
WHERE age >=18 AND termdate= ''
GROUP BY department, gender
ORDER BY department;

-- 7)What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = ''
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8)Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
FROM
(
  SELECT department,
  Count(*) AS total_count,
  Sum( CASE WHEN termdate <> '' AND termdate <= curdate() THEN 1 ELSE 0 END)
  FROM hr
  WHERE age >= 18
  GROUP BY department
  ) AS subquery
  ORDER BY termination_rate DESC;
  
  -- 9) What is the distribution of employees across locations by city and state?
  SELECT location_state, Count(*)  AS count
  FROM hr
  WHERE age >= 18 AND termdate = ''
  GROUP BY location_state
  ORDER BY count DESC;
  
  -- 10) How has company's employee count changed overtime based on hire and term dates?
  SELECT
    YEAR, hires, terminations, hires-terminations AS net_change,
    round((hires-terminations)/hires*100,2) AS net_change_percent
 From
    (
    SELECT YEAR(hire_date) AS YEAR,
    Count(*) as hires,
    Sum(CASE WHEN termdate <> '' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
 WHERE age >= 18
 GROUP BY YEAR(hire_date)
 ) AS subquery
 ORDER BY year ASC;
 
 -- 11) What is the tenure distribution for each department?
 Select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
 From hr
 Where termdate <= curdate() and  termdate <> '' and age >= 18
 Group by department;
 
 