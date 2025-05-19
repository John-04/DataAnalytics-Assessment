-- 2. Transaction Frequency Analysis
WITH MonthlyTransactions AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS monthly_transaction_count
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id,
        transaction_month
),
CustomerMonthlyAvg AS (
    SELECT
        owner_id,
        AVG(monthly_transaction_count) AS avg_transactions_per_month
    FROM
        MonthlyTransactions
    GROUP BY
        owner_id
),
FrequencyCategory AS (
    SELECT
        cma.owner_id,
        CASE
            WHEN cma.avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN cma.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        cma.avg_transactions_per_month
    FROM
        CustomerMonthlyAvg cma
)
SELECT
    fc.frequency_category,
    COUNT(DISTINCT uc.id) AS customer_count,
    TRUNCATE(AVG(fc.avg_transactions_per_month), 1) AS avg_transactions_per_month -- Truncate to 1 decimal place
FROM
    FrequencyCategory fc
JOIN
    users_customuser uc ON fc.owner_id = uc.id
GROUP BY
    fc.frequency_category
ORDER BY
    CASE fc.frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;