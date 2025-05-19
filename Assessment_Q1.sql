
-- 1. High-Value Customers with Multiple Products
SELECT
    uc.id AS owner_id,
    uc.name,
    COUNT(CASE WHEN pp.plan_type_id IN (1, 2) THEN ss.id END) AS savings_count,
    COUNT(CASE WHEN pp.plan_type_id IN (3, 4) THEN ss.id END) AS investment_count,
    SUM(ss.amount) AS total_deposits
FROM
    users_customuser uc
JOIN
    savings_savingsaccount ss ON uc.id = ss.owner_id
JOIN
    plans_plan pp ON ss.plan_id = pp.id
WHERE
    pp.plan_type_id IN ( 1, 2, 3, 4)
GROUP BY
    uc.id, uc.name
HAVING
    savings_count > 0 AND investment_count > 0
ORDER BY
    total_deposits DESC;