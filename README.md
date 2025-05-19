# DataAnalytics-Assessment

# Cowrywise SQL Assessment – MySQL Version

This repository contains my responses to the SQL technical assessment from Cowrywise. The goal was to test real SQL skills across different business scenarios like customer segmentation, account activity tracking, and value estimation. I used **MySQL** for all queries.

All queries are saved in separate `.sql` files based on the questions provided, and I’ve explained the logic behind each one below just like I’d walk someone through my thought process.

---

### Assessment_Q1.sql: High-Value Customers with Multiple Products

**Objective:**

My primary goal with this query was to identify those customers who truly demonstrate high value by having both a funded savings plan AND an investment plan.  Then, I wanted to rank them by how much they've deposited in total.

**Approach:**

1.  **Joining the Necessary Tables:** To get a complete picture, I started by joining three key tables: `users_customuser`, `savings_savingsaccount`, and `plans_plan`. This gave me the ability to link customer details with their savings accounts and the specifics of their investment plans.  It's like connecting the dots to see the whole financial relationship.
2.  **Counting Plan Types with Precision:** This is where it got a bit tricky, but also interesting.  I needed to make sure I was accurately counting the number of savings and investment plans each customer held.  To do this, I used conditional `SUM` statements within the `SELECT` clause.  Essentially, I used `CASE WHEN pp.plan_type_id = 1 THEN 1 ELSE 0 END`  and  `CASE WHEN pp.plan_type_id = 2 THEN 1 ELSE 0 END` to add up the relevant plan types for each customer.  This approach allows for a very precise count.
3.  **Calculating Total Deposits:** Calculating the total deposits was straightforward, but crucial. I used the  `SUM(ss.amount)` function to get the sum of all deposits for each customer.  This gave me the key metric for determining "high-value."
4.  **Filtering for the Real Deal:** The `HAVING` clause was my friend here.  I used it to filter out any customers who didn't meet the criteria of having *both* a savings and an investment plan.  This ensured that I was only left with the customers who had diversified their holdings.
5.  **Sorting for Impact:** Finally, I used  `ORDER BY total_deposits DESC` to sort the results in descending order.  This put the customers with the highest total deposits at the top of the list, making it easy to see who the most valuable customers are.

**Challenges:**

* **Identifying Plan Types:** Honestly, the most challenging part of this query was figuring out exactly which `plan_type_id` values corresponded to "savings" and "investment" plans.  The database schema didn't explicitly state this, so I had to make some initial assumptions (like assuming 1 was for savings and 2 for investment).  To make the query as robust as possible, I made sure it was flexible and included a comment to highlight that the user may need to update the  `IN` clauses to ensure the correct plan type ids are used.

### Assessment_Q2.sql: Transaction Frequency Analysis

**Objective:**

For this query, I needed to analyze how often customers make transactions.  My aim was to calculate the average number of transactions per customer per month and then group them into categories based on this average.

**Approach:**

1.  **Calculating Monthly Transactions with a CTE:** I used a Common Table Expression (CTE) called `MonthlyTransactions` to break down the transaction data.  This CTE calculated the number of transactions for each customer in each month.  CTEs are super helpful for organizing complex queries, in my opinion.
2.  **Finding the Average:** Next, I used another CTE, `CustomerMonthlyAvg`, to take the results from the previous CTE and calculate the average number of monthly transactions for each customer.  This gave me a single, meaningful number to represent their transaction frequency.
3.  **Categorizing Customers:** I then created a third CTE, `FrequencyCategory`, to assign each customer to a category: "High Frequency," "Medium Frequency," or "Low Frequency."  This categorization was based on the average monthly transactions calculated in the previous step.  I used CASE statements here to define the thresholds for each category.
4.  **Aggregating and Counting:** In the final `SELECT` statement, I grouped the customers by their assigned category and counted how many customers fell into each one.  I also included the average transactions per month for each category, which I think provides a good summary of the data.
5.  **Formatting for Clarity:** To make the output look clean and match the expected format, I used the `TRUNCATE` function to format the  `avg_transactions_per_month` values to one decimal place.

**Challenges:**

* **Formatting Averages Precisely:** The biggest hurdle I encountered was making sure the average transactions per month was displayed with the exact precision specified.  I needed it to be to one decimal place, and  `TRUNCATE`  helped me achieve that.

### Assessment_Q3.sql: Account Inactivity Alert

**Objective:**

This was an interesting one.  I had to identify active accounts (both savings and investments) that hadn't had any transaction activity in the past year.  The goal was to find those accounts that might need attention due to inactivity.

**Approach:**

1.  **Joining Plan and Savings Data:** I joined the  `plans_plan`  and  `savings_savingsaccount`  tables.  This allowed me to combine plan information with the associated transaction data.
2.  **Filtering for Active Accounts:** I used a  `WHERE`  clause to select only active accounts.  For this, I assumed that  `pp.is_deleted = 0`  meant an account was active.
3.  **Identifying Inactive Accounts with NOT EXISTS:** To find the accounts with *no* transactions in the last year, I used the  `WHERE NOT EXISTS`  clause.  This, in my opinion, is a very reliable way to identify records that *don't* have a corresponding entry in another table (in this case, transactions within the last year).
4.  **Calculating Inactivity Days:** I used the  `DATEDIFF`  function to calculate how many days it had been since the last transaction for each account.  I also made sure to handle cases where a plan might not have *any* transactions at all.
5.  **Determining Plan Type:** Finally, I used a  `CASE`  statement to label each plan as either "Savings" or "Investment" based on its  `plan_type_id`.

**Challenges:**

* **Handling Plans with No Transactions:** Calculating the  `inactivity_days`  for plans that had never had a transaction was a bit of a brain-teaser.  I needed to make sure my query didn't break in these cases and that it correctly identified these plans as inactive.  The `NOT EXISTS` clause was crucial here.
* **Assumptions:** This query relies on a couple of assumptions, and I think it's important to be upfront about them.  First, I'm assuming that  `pp.is_deleted = 0`  indicates an active account.  Second, I'm assuming that specific  `plan_type_id`  values represent "Savings" and "Investment."  If these assumptions turn out to be incorrect, the query would need to be adjusted.

### Assessment_Q4.sql: Customer Lifetime Value (CLV) Estimation

**Objective:**

This was a really interesting task: estimating the Customer Lifetime Value (CLV) for each customer.  The idea was to get a sense of how valuable each customer is likely to be in the long run, based on their account history.

**Approach:**

1.  **Calculating Customer Tenure:** I used a CTE called  `CustomerTenure`  to calculate how long each customer had been with the institution.  I measured this in months using the  `TIMESTAMPDIFF`  function.
2.  **Summarizing Transactions:** I created another CTE,  `TransactionSummary`, to calculate the total number of transactions and the total value of those transactions for each customer.
3.  **Calculating CLV:** In the main  `SELECT`  statement, I joined the  `CustomerTenure`  and  `TransactionSummary`  CTEs.  Then, I applied the CLV formula:  `CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction`.  For  `avg_profit_per_transaction`, I made an assumption of 0.1% of the transaction value.
4.  **Handling Zero Tenure to Avoid Errors:** To prevent any "division by zero" errors, I used the  `NULLIF`  function.  This ensures that if a customer has a tenure of 0 months, the CLV calculation doesn't result in an error.
5.  **Formatting for Consistency:** To make sure the output looked clean and matched the requirements, I used the  `TRUNCATE`  function to format the CLV values to two decimal places.
6.  **Ordering by Value:** Finally, I sorted the results in descending order of  `estimated_clv`  so that the highest-value customers are listed first.

**Challenges:**

* **Handling the Zero Tenure Issue:** The biggest challenge was definitely making sure the query didn't crash or produce incorrect results when calculating CLV for customers with a tenure of 0 months.  The  `NULLIF`  function was key to solving this.
* **Matching the Required Output Format:** It was also important to me that the CLV values were formatted exactly as specified (two decimal places).  `TRUNCATE`  helped me achieve this and ensure the output was consistent.

## Important Notes

* I want to emphasize that all the work here is my own original creation.
* I haven't shared my solutions with any other candidates.
* The repository only contains SQL files; there are no database dumps or other extraneous files included.
