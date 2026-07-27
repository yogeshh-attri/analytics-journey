CREATE TABLE bank_churn (
    RowNumber INT PRIMARY KEY,
    CustomerId BIGINT,
    Surname VARCHAR(50),
    CreditScore INT,
    Geography VARCHAR(30),
    Gender VARCHAR(10),L
    Age INT,
    Tenure INT,
    Balance NUMERIC(12,2),
    NumOfProducts INT,
    HasCrCard INT,
    IsActiveMember INT,
    EstimatedSalary NUMERIC(12,2),
    Exited INT
);

COPY bank_churn (
    RowNumber,
    CustomerId,
    Surname,
    CreditScore,
    Geography,
    Gender,
    Age,
    Tenure,
    Balance,
    NumOfProducts,
    HasCrCard,
    IsActiveMember,
    EstimatedSalary,
    Exited
)
FROM 'C:\sampledb\Bank_Churn_Dataset.csv'
DELIMITER ','
CSV HEADER;

select * from bank_churn ;

**total Customers**

SELECT COUNT(*) AS Total_Customers
FROM bank_churn;

**Overall churn overview**
SELECT
  COUNT(*) AS total_customers,
  SUM(Exited) AS churned,
  COUNT(*) - SUM(Exited) AS retained,
  ROUND(SUM(Exited)*100.0/COUNT(*), 2) AS churn_rate_pct
FROM bank_churn;



**Churn by Geography**
SELECT Geography, COUNT(*) AS total,
  SUM(Exited) AS churned,
  ROUND(AVG(Exited)*100, 2) AS churn_rate_pct
FROM bank_churn
GROUP BY Geography ORDER BY churn_rate_pct DESC;


**Average Age of Churned Customers**
SELECT AVG(Age) AS Average_Age_of_Churned
FROM bank_churn
WHERE Exited = 1;

**churn by geography & gender**
SELECT Geography, Gender,
  COUNT(*) AS total,
  SUM(Exited) AS churned,
  ROUND(AVG(Exited)*100, 2) AS churn_rate_pct
FROM bank_churn
GROUP BY Geography, Gender
ORDER BY churn_rate_pct DESC;



***churn by gender & activity status***
SELECT
  Gender,
  CASE WHEN IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END AS member_status,
  COUNT(*) AS total,
  ROUND(AVG(Exited)*100, 2) AS churn_rate_pct
FROM bank_churn
GROUP BY Gender, IsActiveMember
ORDER BY churn_rate_pct DESC;


**Churn by Number of Products**
SELECT NumOfProducts, COUNT(*) AS total,
  SUM(Exited) AS churned,
  ROUND(AVG(Exited)*100, 2) AS churn_rate_pct
FROM bank_churn
GROUP BY NumOfProducts ORDER BY NumOfProducts;


**Average Balance**
SELECT
AVG(Balance) AS Average_Balance
FROM bank_churn;

**Average Balance by Geography**
SELECT
Geography,
AVG(Balance) AS Average_Balance
FROM bank_churn
GROUP BY Geography;

**Top 10 Customers by Balance**
SELECT
CustomerId,
Surname,
Balance
FROM bank_churn
ORDER BY Balance DESC
LIMIT 10;

**Customers with Credit Score Above 700**
SELECT *
FROM bank_churn
WHERE CreditScore > 700;



***Summary Statistics for Credit Score***
SELECT
    COUNT(*) AS Total_Customers,
    MIN(CreditScore) AS Minimum,
    MAX(CreditScore) AS Maximum,
    ROUND(AVG(CreditScore),2) AS Mean,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CreditScore) AS Median,
    ROUND(STDDEV(CreditScore),2) AS Std_Deviation
FROM bank_churn;

***Summary Statistics for Balance***
SELECT
    COUNT(*) AS Total_Customers,
    MIN(Balance) AS Minimum,
    MAX(Balance) AS Maximum,
    ROUND(AVG(Balance),2) AS Mean,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Balance) AS Median,
    ROUND(STDDEV(Balance),2) AS Std_Deviation
FROM bank_churn;

***Summary Statistics for All Numerical Variables***
SELECT
    ROUND(AVG(CreditScore),2) AS Avg_CreditScore,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CreditScore) AS Median_CreditScore,

    ROUND(AVG(Age),2) AS Avg_Age,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Age) AS Median_Age,

    ROUND(AVG(Balance),2) AS Avg_Balance,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Balance) AS Median_Balance,

    ROUND(AVG(EstimatedSalary),2) AS Avg_Salary,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EstimatedSalary) AS Median_Salary
FROM bank_churn;



****SQL Queries for Churn Metrics****

**Overall Customer Churn Rate (Most Important KPI)**
SELECT
    COUNT(*) AS Total_Customers,
    SUM(Exited) AS Churned_Customers,
    ROUND(SUM(Exited)::numeric * 100 / COUNT(*),2) AS Churn_Rate
FROM bank_churn;

**Churn Rate by Age Group**

SELECT
  CASE
    WHEN Age BETWEEN 18 AND 30 THEN '18–30'
    WHEN Age BETWEEN 31 AND 40 THEN '31–40'
    WHEN Age BETWEEN 41 AND 50 THEN '41–50'
    WHEN Age BETWEEN 51 AND 60 THEN '51–60'
    ELSE '60+'
  END AS age_band,
  COUNT(*) AS total,
  SUM(Exited) AS churned,
  ROUND(AVG(Exited)*100, 2) AS churn_rate_pct
FROM bank_churn
GROUP BY age_band
ORDER BY age_band;


***Churn Rate by Credit Score Category***
SELECT
CASE
    WHEN CreditScore < 600 THEN 'Poor'
    WHEN CreditScore BETWEEN 600 AND 700 THEN 'Average'
    ELSE 'Good'
END AS Credit_Category,

COUNT(*) AS Customers,
SUM(Exited) AS Churned,
ROUND(SUM(Exited)::numeric*100/COUNT(*),2) AS Churn_Rate

FROM bank_churn
GROUP BY Credit_Category;


**Churn by Balance Category**

SELECT
CASE
    WHEN Balance = 0 THEN 'Zero Balance'
    WHEN Balance < 50000 THEN 'Low Balance'
    WHEN Balance < 100000 THEN 'Medium Balance'
    ELSE 'High Balance'
END AS Balance_Category,

COUNT(*) AS Customers,
SUM(Exited) AS Churned,
ROUND(SUM(Exited)::numeric*100/COUNT(*),2) AS Churn_Rate

FROM bank_churn
GROUP BY Balance_Category;

**Top-Risk Customer Segment**
SELECT
Geography,
Gender,
AVG(Age) AS Avg_Age,
COUNT(*) AS Customers,
ROUND(SUM(Exited)::numeric*100/COUNT(*),2) AS Churn_Rate

FROM bank_churn

GROUP BY Geography, Gender

ORDER BY Churn_Rate DESC
LIMIT 10;


**Churn by Tenure**
SELECT
Tenure,
COUNT(*) AS Customers,
SUM(Exited) AS Churned,
ROUND(SUM(Exited)::numeric*100/COUNT(*),2) AS Churn_Rate

FROM bank_churn

GROUP BY Tenure

ORDER BY Tenure;


SELECT
    CustomerId,
    Surname,
    Geography,
    Gender,
    Age,
    Balance,
    NumOfProducts,
    IsActiveMember,
    CASE
        WHEN Exited = 1 THEN 'Churned'
        ELSE 'Not Churned'
    END AS Customer_Status
FROM bank_churn
ORDER BY Exited DESC;

##to check pattern

SELECT
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Not Churned' END AS Customer_Status,
    COUNT(*)                                        AS Total_Customers,
    ROUND(AVG(Age), 1)                             AS Avg_Age,
    ROUND(AVG(CreditScore), 1)                     AS Avg_CreditScore,
    ROUND(AVG(Balance), 2)                         AS Avg_Balance,
    ROUND(AVG(NumOfProducts), 2)                   AS Avg_Products,
    ROUND(AVG(Tenure), 1)                          AS Avg_Tenure,
    ROUND(AVG(EstimatedSalary), 2)                 AS Avg_Salary,
    ROUND(AVG(IsActiveMember) * 100, 1)            AS Pct_Active,
    ROUND(AVG(HasCrCard) * 100, 1)                 AS Pct_HasCreditCard
FROM bank_churn
GROUP BY Exited
ORDER BY Exited DESC;


