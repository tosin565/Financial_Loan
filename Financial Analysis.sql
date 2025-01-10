CREATE DATABASE Financial_Loan;

USE Financial_Loan;

SELECT *
FROM loan

--Total Loan Pay out
SELECT SUM(loan_Amount) Total_Loan_Disbursment
FROM loan

--Total Loan Received
SELECT SUM(total_payment) Total_Repayment
FROM loan

--Gross Profit
SELECT SUM(total_payment - loan_Amount) Gross_Profit
FROM loan

--Avg Interest Rate
SELECT ROUND(AVG(int_rate),4) * 100 Avg_Interest
FROM loan

--Purpose by Total_Loan_Applicants, Total_Loan_Disbursment and Total_Repayment
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applicants,
	SUM(loan_amount) AS Total_Loan_Disbursment,
	SUM(total_payment) AS Total_Repayment
FROM Loan
GROUP BY purpose
ORDER BY Total_Loan_Applicants DESC

SELECT 
    term, 
    COUNT(*) AS total_loans, 
    ROUND(AVG(int_rate),4) * 100 AS avg_interest_rate,
    ROUND(MIN(int_rate),4) * 100 AS min_interest_rate,
    ROUND(MAX(int_rate),4) * 100 AS max_interest_rate
FROM 
    Loan
GROUP BY 
    term
ORDER BY 
    term ASC;

--Grade by Total_Loan_Applicants, Total_Loan_Disbursment and Total_Repayment
SELECT 
	Grade AS Grade, 
	COUNT(id) AS Total_Loan_Applicants,
	SUM(loan_amount) AS Total_Loan_Disbursment,
	SUM(total_payment) AS Total_Repayment
FROM Loan
GROUP BY grade
ORDER BY Total_Loan_Applicants DESC

--Term by Total_Loan_Applicants, Total_Loan_Disbursment and Total_Repayment
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applicants,
	SUM(loan_amount) AS Total_Loan_Disbursment,
	SUM(total_payment) AS Total_Repayment
FROM Loan
GROUP BY term
ORDER BY Total_Loan_Applicants DESC

--Employment_Length by Total_Loan_Applicants, Total_Loan_Disbursment and Total_Repayment
SELECT 
	emp_length AS Employment_Length, 
	COUNT(id) AS Total_Loan_Applicants,
	SUM(loan_amount) Total_Loan_Disbursment,
	SUM(total_payment) Total_Repayment
FROM Loan
GROUP BY emp_length
ORDER BY Total_Loan_Applicants DESC

-- Home_Ownership by Total_Loan_Applicants, Total_Loan_Disbursment and Total_Repayment
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applicants,
	SUM(loan_amount) Total_Loan_Disbursment,
	SUM(total_payment) Total_Repayment
FROM Loan
GROUP BY home_ownership
ORDER BY Total_Loan_Applicants DESC

--Percentage of Loan Status by Total Num of Applicant, Total Payment, Total_Loan_Disbursment, Avg_Interest
SELECT 
	CASE
	WHEN loan_status = 'Fully Paid' or loan_status = 'Current' THEN 'Good Loan'
	ELSE 'Written-Off Loan'
	END AS Loan_Status,
 COUNT(id) Total_Applicant,
CAST(CAST(COUNT(id) AS DECIMAL(18,2)) * 100/
(SELECT CAST(COUNT(id) AS DECIMAL(18,2))  FROM loan) AS DECIMAL(10,2)) PCT,
SUM(total_payment) Total_Loan_Recovered,
SUM(loan_amount)  Total_Loan_Paid_Out
FROM loan
GROUP BY CASE
	WHEN loan_status = 'Fully Paid' or loan_status = 'Current' THEN 'Good Loan'
	ELSE 'Written-Off Loan'
	END
ORDER BY Total_Loan_Recovered DESC

--Annual Income Category
SELECT
CASE
	WHEN annual_income <= 50000 THEN 'Low Income'
	WHEN annual_income <= 200000 THEN 'Lower-Middle Income'
	WHEN annual_income <= 500000 THEN 'Average Income'
	WHEN annual_income <= 1000000 THEN 'High Income'
	ELSE 'Very High'
	END Income_Category,
CAST(CAST(COUNT(id) AS DECIMAL(18,2)) * 100/
(SELECT CAST(COUNT(id) AS DECIMAL(18,2))  FROM loan) AS DECIMAL(10,2)) PCT,
COUNT(id) Total_Loan_Applicants,
SUM(annual_income) Annual_Income
FROM loan
GROUP BY 
CASE
	WHEN annual_income <= 50000 THEN 'Low Income'
	WHEN annual_income <= 200000 THEN 'Lower-Middle Income'
	WHEN annual_income <= 500000 THEN 'Average Income'
	WHEN annual_income <= 1000000 THEN 'High Income'
	ELSE 'Very High'
	END
ORDER BY PCT DESC

-- Monthly Trend of Defaulted Loans
SELECT 
    MONTH(issue_date) AS origination_Month,
    COUNT(*) AS total_loans,
    COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) AS defaulted_loans,
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) * 100.0 / COUNT(*)) AS default_rate
FROM 
    Loan
GROUP BY 
    MONTH(issue_date)
ORDER BY 
    origination_Month ASC;

--Mothly Trend
SELECT 
	MONTH(issue_date) AS Month_Number, 
	DATENAME(MONTH, issue_date) AS Month_name, 
	COUNT(id) AS Total_Num,
	SUM(loan_amount) AS Total_Loan_Disbursment,
	SUM(total_payment) AS Total_Repayment
FROM Loan
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)

--Top and Bottom 5 states by Total_Loan_Applicants, Total_Loan_Disbursment, Total_Repayment
SELECT address_state, 
       Total_Loan_Applicants,
       Total_Loan_Disbursment,
       Total_Repayment
FROM (
    SELECT address_state,
           COUNT(id) AS Total_Loan_Applicants,
           SUM(loan_amount) AS Total_Loan_Disbursment,
           SUM(total_payment) AS Total_Repayment,
           ROW_NUMBER() OVER (ORDER BY COUNT(id) DESC) AS rn_desc,
           ROW_NUMBER() OVER (ORDER BY COUNT(id) ASC) AS rn_asc
    FROM Loan
    GROUP BY address_state
) AS LoanData
WHERE rn_desc <= 5 OR rn_asc <= 5
ORDER BY rn_desc, rn_asc;

--Debt-to-Income by Avg Income, Avg Dti & Total_Loan_Applicants
SELECT 
    CASE 
        WHEN (dti) <= 0.15 THEN '0-15% (Low Risk)'
        WHEN (dti ) <= 0.30 THEN '15-30% (Moderate Risk)'
        WHEN (dti ) <= 0.45 THEN '30-45% (High Risk)'
        ELSE '45+% (Very High Risk)'
    END AS Dti_Category,
    ROUND(AVG(annual_income),4) AS Avg_Income,
    ROUND(AVG(dti),4) * 100 AS Avg_Dti,
    COUNT(*) AS Total_Loan_Applicants
FROM 
    Loan
GROUP BY 
    CASE 
        WHEN (dti) <= 0.15 THEN '0-15% (Low Risk)'
        WHEN (dti) <= 0.30 THEN '15-30% (Moderate Risk)'
        WHEN (dti) <= 0.45 THEN '30-45% (High Risk)'
        ELSE '45+% (Very High Risk)'
    END
ORDER BY 
    Dti_Category;


-- Correlation Coefficient Between Income and Loan
WITH CorrelationData AS (
    SELECT
        COUNT(*) AS N,
        SUM(CAST(annual_income AS DECIMAL(38,10))) AS Total_Income,
        SUM(CAST(loan_amount AS DECIMAL(38,10))) AS Total_Loan,
        SUM(CAST(annual_income AS DECIMAL(38,10)) * CAST(loan_amount AS DECIMAL(38,10))) AS Total_Income_and_Loan,
        SUM(CAST(annual_income AS DECIMAL(38,10)) * CAST(annual_income AS DECIMAL(38,10))) AS Sum_Income_Square,
        SUM(CAST(loan_amount AS DECIMAL(38,10)) * CAST(loan_amount AS DECIMAL(38,10))) AS Sum_Loan_Square
    FROM Loan
),
IntermediateValues AS (
    SELECT
        N,
        Total_Income,
        Total_Loan,
        Total_Income_and_Loan,
        Sum_Income_Square,
        Sum_Loan_Square,
        CAST((N * Total_Income_and_Loan - Total_Income * Total_Loan) AS DECIMAL(38,10)) AS Numerator,
        CAST(SQRT(N * Sum_Income_Square - Total_Income * Total_Income) AS DECIMAL(38,10)) AS Denominator_Income,
        CAST(SQRT(N * Sum_Loan_Square - Total_Loan * Total_Loan) AS DECIMAL(38,10)) AS Denominator_Loan
    FROM CorrelationData
)
SELECT 
    Numerator / (Denominator_Income * Denominator_Loan) AS Correlation_Coefficient
FROM IntermediateValues;
