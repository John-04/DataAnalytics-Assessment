-- 3. Account Inactivity Alert
SELECT
    pp.id AS plan_id,
    pp.owner_id,
    CASE
        WHEN pp.plan_type_id = 1 THEN 'Savings'
        WHEN pp.plan_type_id = 2 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    (SELECT MAX(ssa.transaction_date) FROM savings_savingsaccount ssa WHERE ssa.plan_id = pp.id) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE(), (SELECT MAX(ssa.transaction_date) FROM savings_savingsaccount ssa WHERE ssa.plan_id = pp.id)) AS inactivity_days
FROM
    plans_plan pp
WHERE
    pp.is_deleted = 0 -- Assuming is_deleted = 0 means the account is active
    AND NOT EXISTS (SELECT 1 FROM savings_savingsaccount ssa WHERE ssa.plan_id = pp.id AND ssa.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR))
ORDER BY
    pp.id;