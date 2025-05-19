-- 4. Customer Lifetime Value (CLV) Estimation
WITH CustomerTenure AS (
    SELECT
        id AS customer_id,
        name,
        TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) AS tenure_months
    FROM
        users_customuser
),
TransactionSummary AS (
    SELECT
        owner_id AS customer_id,
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_transaction_value
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id
)
SELECT
    ct.customer_id,
    ct.name,
    ct.tenure_months,
    COALESCE(ts.total_transactions, 0) AS total_transactions,
    TRUNCATE((COALESCE(ts.total_transaction_value, 0) * 0.001 / NULLIF(ct.tenure_months, 0)) * 12, 2) AS estimated_clv
FROM
    CustomerTenure ct
LEFT JOIN
    TransactionSummary ts ON ct.customer_id = ts.customer_id
ORDER BY
    estimated_clv DESC;