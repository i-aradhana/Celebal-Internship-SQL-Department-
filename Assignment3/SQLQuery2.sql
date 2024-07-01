--task1
create table projects(Task_Id int primary key,Start_Date Date,End_Date Date)
insert into projects values(1,'2015-10-01','2015-10-02')
select * from projects
insert into projects values(2,'2015-10-02','2015-10-03')
insert into projects values(3,'2015-10-03','2015-10-04')
insert into projects values(4,'2015-10-13','2015-10-14')
insert into projects values(5,'2015-10-14','2015-10-15')
insert into projects values(6,'2015-10-28','2015-10-29')
insert into projects values(7,'2015-10-30','2015-10-31')
select * from projects

WITH ProjectGroups AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY Start_Date), Start_Date) AS GroupIdentifier
    FROM Projects
),
GroupedProjects AS (
    SELECT
        MIN(Start_Date) AS ProjectStartDate,
        MAX(End_Date) AS ProjectEndDate,
        DATEDIFF(DAY, MIN(Start_Date), MAX(End_Date)) + 1 AS ProjectDuration
    FROM ProjectGroups
    GROUP BY GroupIdentifier
)

SELECT
    ProjectStartDate,
    ProjectEndDate
FROM GroupedProjects
ORDER BY
    ProjectDuration,
    ProjectStartDate;


--task3
create table Functions(X int,Y int)
insert into functions values(20,20)
insert into functions values(20,20)
insert into functions values(20,21)
insert into functions values(23,22)
insert into functions values(22,23)
insert into functions values(21,20)
select * from functions

SELECT DISTINCT
    f1.X AS X1,
    f1.Y AS Y1
FROM
    Functions f1
JOIN
    Functions f2
ON
    f1.X = f2.Y AND f1.Y = f2.X
WHERE
    f1.X < f1.Y OR f1.X=f1.Y
ORDER BY
    f1.X, f1.Y;

--task2
create table students(ID int primary key,Name nvarchar(20))

insert into students values(1,'Ashley')
insert into students values(2,'Samantha')
insert into students values(3,'Julia')
insert into students values(4,'Scarlet')
select * from students

create table friends (ID int primary key,Friend_ID int)
insert into friends values(1,2)
insert into friends values(2,3)
insert into friends values(3,4)
insert into friends values(4,1)
select * from friends

create table packages (ID int ,Salary float)
insert into packages values(1,15.20)
insert into packages values(2,10.06)
insert into packages values(3,11.55)
insert into packages values(4,12.12)
select * from packages

SELECT 
    s.Name AS Student_Name
   
FROM 
    Students s
JOIN 
    Friends fr ON s.ID = fr.ID
JOIN 
    Packages p1 ON s.ID = p1.ID
JOIN 
    Students f ON fr.Friend_ID = f.ID
JOIN 
    Packages p2 ON f.ID = p2.ID
WHERE 
    p2.Salary > p1.Salary
ORDER BY 
    p2.Salary;


--task4

SELECT
    c.contest_id,
    c.hacker_id,
    h.name,
    SUM(c.total_submissions) AS total_submissions,
    SUM(c.total_accepted_submissions) AS total_accepted_submissions,
    SUM(c.total_views) AS total_views,
    SUM(c.total_unique_views) AS total_unique_views
FROM
    Contests c
JOIN
    Hackers h ON c.hacker_id = h.hacker_id
GROUP BY
    c.contest_id, c.hacker_id, h.name
HAVING
    SUM(c.total_submissions) > 0
    OR SUM(c.total_accepted_submissions) > 0
    OR SUM(c.total_views) > 0
    OR SUM(c.total_unique_views) > 0
ORDER BY
    c.contest_id;

--task5
WITH ContestDates AS (
    SELECT DISTINCT submission_date
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-15'
),
DailySubmissions AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS submissions_count
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-15'
    GROUP BY submission_date, hacker_id
),
DailyStats AS (
    SELECT
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers,
        MAX(submissions_count) AS max_submissions
    FROM DailySubmissions
    GROUP BY submission_date
),
MaxHackers AS (
    SELECT
        ds.submission_date,
        ds.hacker_id,
        ds.submissions_count
    FROM DailySubmissions ds
    JOIN DailyStats ds2
    ON ds.submission_date = ds2.submission_date AND ds.submissions_count = ds2.max_submissions
),
RankedHackers AS (
    SELECT
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY hacker_id) AS rank
    FROM MaxHackers
)
SELECT
    cd.submission_date,
    ds.unique_hackers,
    rh.hacker_id,
    h.name
FROM
    ContestDates cd
JOIN
    DailyStats ds ON cd.submission_date = ds.submission_date
JOIN
    RankedHackers rh ON cd.submission_date = rh.submission_date AND rh.rank = 1
JOIN
    Hackers h ON rh.hacker_id = h.hacker_id
ORDER BY
    cd.submission_date;

--task6

SELECT
    ROUND(
        ABS(MIN(LAT_N) - MAX(LAT_N)) + ABS(MIN(LONG_W) - MAX(LONG_W)),
        4
    ) AS Manhattan_Distance
FROM
    STATION;


--task7
-- Create a temporary table to store numbers
CREATE TABLE #Numbers (n INT);

-- Insert numbers from 2 to 1000
DECLARE @i INT = 2;
WHILE @i <= 1000
BEGIN
    INSERT INTO #Numbers (n) VALUES (@i);
    SET @i = @i + 1;
END;

-- Create a temporary table to store prime numbers
CREATE TABLE #PrimeNumbers (n INT);

-- Find and insert prime numbers into the #PrimeNumbers table
DECLARE @n INT;
DECLARE @divisor INT;
DECLARE @is_prime BIT;

-- Cursor to iterate through each number in #Numbers
DECLARE prime_cursor CURSOR FOR 
SELECT n FROM #Numbers;

OPEN prime_cursor;
FETCH NEXT FROM prime_cursor INTO @n;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @is_prime = 1;
    SET @divisor = 2;

    WHILE @divisor * @divisor <= @n
    BEGIN
        IF @n % @divisor = 0
        BEGIN
            SET @is_prime = 0;
            BREAK;
        END;
        SET @divisor = @divisor + 1;
    END;

    IF @is_prime = 1
    BEGIN
        INSERT INTO #PrimeNumbers (n) VALUES (@n);
    END;

    FETCH NEXT FROM prime_cursor INTO @n;
END;

CLOSE prime_cursor;
DEALLOCATE prime_cursor;

-- Select and concatenate prime numbers with '&'
SELECT STRING_AGG(CAST(n AS VARCHAR), '&') AS PrimeNumbers
FROM #PrimeNumbers;

-- Drop temporary tables
DROP TABLE #Numbers;
DROP TABLE #PrimeNumbers;

--task8
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name ELSE NULL END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name ELSE NULL END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name ELSE NULL END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name ELSE NULL END) AS Actor
FROM
    OCCUPATIONS
GROUP BY
    Name
ORDER BY
    Name;

--task9
SELECT
    N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT P FROM IST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM
    IST
ORDER BY
    N;

--task11
SELECT 
    s.Name AS Student_Name
   
FROM 
    Students s
JOIN 
    Friends fr ON s.ID = fr.ID
JOIN 
    Packages p1 ON s.ID = p1.ID
JOIN 
    Students f ON fr.Friend_ID = f.ID
JOIN 
    Packages p2 ON f.ID = p2.ID
WHERE 
    p2.Salary > p1.Salary
ORDER BY 
    p2.Salary;

--using the hypothetical database
--task12
WITH TotalCost AS (
    SELECT
        country,
        SUM(cost) AS total_cost
    FROM JobFamilyCost
    GROUP BY country
),
CountryCost AS (
    SELECT
        country,
        job_family,
        SUM(cost) AS job_family_cost
    FROM JobFamilyCost
    GROUP BY country, job_family
)
SELECT
    c.job_family,
    c.country,
    (c.job_family_cost / t.total_cost) * 100 AS cost_ratio_percentage
FROM
    CountryCost c
JOIN
    TotalCost t
ON
    c.country = t.country;
--task13
SELECT
    business_unit,
    month,
    (cost / revenue) AS cost_revenue_ratio
FROM
    BUFinance;

--task14
WITH Headcount AS (
    SELECT
        sub_band,
        COUNT(employee_id) AS headcount
    FROM Employees
    GROUP BY sub_band
)
SELECT
    sub_band,
    headcount,
    (headcount * 100.0 / (SELECT COUNT(*) FROM Employees)) AS percentage_headcount
FROM Headcount;
--task15
SELECT TOP 5
    employee_id,
    salary
FROM
    EmployeeSalaries
WHERE
    salary IN (SELECT DISTINCT TOP 5 salary FROM EmployeeSalaries ORDER BY salary DESC);
--task16
UPDATE MyTable
SET col1 = col1 + col2,
    col2 = col1 - col2,
    col1 = col1 - col2;
--task17
-- Create a login
CREATE LOGIN MyLogin WITH PASSWORD = 'StrongPassword123!';

-- Create a user for the login in a specific database
USE MyDatabase;
CREATE USER MyUser FOR LOGIN MyLogin;

-- Grant DB_OWNER permissions to the user
ALTER ROLE db_owner ADD MEMBER MyUser;
--task18
WITH MonthlyCosts AS (
    SELECT
        business_unit,
        month,
        AVG(cost) AS average_cost,
        SUM(cost) AS total_cost,
        COUNT(employee_id) AS employee_count
    FROM EmployeeCosts
    GROUP BY business_unit, month
)
SELECT
    business_unit,
    month,
    (total_cost / employee_count) AS weighted_average_cost
FROM MonthlyCosts;
--task19
WITH ActualAvg AS (
    SELECT AVG(salary) AS actual_avg_salary
    FROM EMPLOYEES
),
MiscalculatedAvg AS (
    SELECT AVG(CAST(REPLACE(CAST(salary AS VARCHAR), '0', '') AS DECIMAL)) AS miscalculated_avg_salary
    FROM EMPLOYEES
)
SELECT 
    CEILING(a.actual_avg_salary - m.miscalculated_avg_salary) AS salary_error
FROM
    ActualAvg a,
    MiscalculatedAvg m;
--task20
INSERT INTO TargetTable (id, column1, column2, ...)
SELECT s.id, s.column1, s.column2, ...
FROM SourceTable s
LEFT JOIN TargetTable t ON s.id = t.id
WHERE t.id IS NULL;

