# DataAnalytics-Assessment

# Cowrywise SQL Assessment – MySQL Version

This repository contains my responses to the SQL technical assessment from Cowrywise. The goal was to test real SQL skills across different business scenarios like customer segmentation, account activity tracking, and value estimation. I used **MySQL** for all queries.

All queries are saved in separate `.sql` files based on the questions provided, and I’ve explained the logic behind each one below just like I’d walk someone through my thought process.

---

## Question 1: Customers with Both Savings and Investment Plans

The task was to get users who have at least one funded savings plan and one funded investment plan. I used the `plans_plan` table for this, checking for `is_regular_savings = 1` and `is_a_fund = 1`. I filtered to only those plans that had a `confirmed_amount` greater than 0 — which I understood as “funded.”

Each user is also joined to the `savings_savingsaccount` table to get the total deposit amount. I converted the amounts from kobo to naira by dividing by 100. Then I grouped by user and made sure to count savings and investment plans separately using `COUNT(DISTINCT ...)`, so I only include users who have both types.

Finally, I ordered the result by total deposits so the most valuable customers appear first.

---

## Question 2: Transaction Frequency Categories

Here I needed to categorize customers into High, Medium, or Low frequency based on how often they make transactions per month. I worked with the `savings_savingsaccount` table and grouped transactions by both `owner_id` and the transaction month using `DATE_FORMAT`.

Once I had monthly totals per user, I averaged those monthly values across all months for each customer. Then I used a CASE statement to label users:

- **High Frequency** (≥ 10 transactions/month)
- **Medium Frequency** (3–9 transactions/month)
- **Low Frequency** (≤ 2 transactions/month)

Finally, I grouped by these frequency categories to get the customer count and the average transactions per month for each group.

---

## Question 3: Accounts with No Inflows for Over a Year

This question focused on identifying active accounts (both savings and investment) that haven't had any transactions for the past 365 days.

For savings, I selected from `savings_savingsaccount` and got the latest transaction date per account using `MAX(transaction_date)`.

For investment plans, I assumed they can also be tracked via the same `savings_savingsaccount` table using `owner_id`. I joined it with the `plans_plan` table to identify investment plans and then calculated the last transaction date the same way.

I combined both into one query using `UNION ALL` and used `DATEDIFF(CURDATE(), last_transaction_date)` to get the number of days since the last transaction. Any account over 365 days was included in the result.

---

## Question 4: Estimating Customer Lifetime Value (CLV)

The goal here was to estimate CLV using a simple formula:

```sql
CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
```
Where avg_profit_per_transaction is 0.1% of transaction value.

First, I calculated the total number of transactions and the total transaction value per user from the savings_savingsaccount table. Then I calculated the customer’s tenure in months using TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) from the users_customuser table.

With those pieces, I calculated the average profit per transaction and applied the formula provided. Finally, I ordered the result by CLV from highest to lowest.

