-- Split by age group
WITH age_groups AS (
    SELECT
        CASE
            WHEN c.age IS NULL THEN 'None'
			WHEN c.age BETWEEN 0 and 9 THEN '0-9'
			WHEN c.age BETWEEN 10 and 19 THEN '10-19'
			WHEN c.age BETWEEN 20 and 29 THEN '20-29'
			WHEN c.age BETWEEN 30 and 39 THEN '30-39'
			WHEN c.age BETWEEN 40 and 49 THEN '40-49'
			WHEN c.age BETWEEN 50 and 59 THEN '50-59'
			WHEN c.age BETWEEN 60 and 69 THEN '60-69'
			WHEN c.age BETWEEN 70 and 79 THEN '70-79'
			WHEN c.age BETWEEN 80 and 89 THEN '80-89'
			WHEN c.age BETWEEN 90 and 99 THEN '90-99'
			ELSE '100+'
        END AS age_group,
        EXTRACT(YEAR FROM t.date_new) AS year,
        EXTRACT(QUARTER FROM MAKE_DATE((EXTRACT (YEAR FROM t.date_new))::integer, (EXTRACT (DAY FROM t.date_new))::integer, (EXTRACT (MONTH FROM t.date_new))::integer)) AS quarter,
        SUM(t.sum_payment) AS total_amount,
        COUNT(*) AS number_of_transactions,
        AVG(t.sum_payment) AS average_amount_per_transaction
    FROM
        customers c
    JOIN
        transactions t ON c.id = t.id_client
    GROUP BY
        age_group, year, quarter
),

-- Find info per quarter: Total amount and Number of transaction per each quarter
per_quarter AS (
    SELECT
        EXTRACT(YEAR FROM t.date_new) AS year,
        EXTRACT(QUARTER FROM MAKE_DATE((EXTRACT (YEAR FROM t.date_new))::integer, (EXTRACT (DAY FROM t.date_new))::integer, (EXTRACT (MONTH FROM t.date_new))::integer)) AS quarter,
        SUM(t.sum_payment) AS total_amount_quarter,
        COUNT(*) AS total_transactions_quarter
    FROM
        customers c
    JOIN
        transactions t ON c.id = t.id_client
    GROUP BY
        year, quarter
),

-- Calculate percentage of total amount and transactions per quarter
age_group_quarterly_metrics AS (
    SELECT
        a.age_group,
        a.year,
        a.quarter,
        a.total_amount,
        a.number_of_transactions,
        a.average_amount_per_transaction,
        (a.total_amount / q.total_amount_quarter) AS percentage_of_total_amount,
        (a.number_of_transactions::FLOAT / q.total_transactions_quarter) AS percentage_of_transactions
    FROM
        age_groups a
    JOIN
        per_quarter q ON a.year = q.year AND a.quarter = q.quarter
)

-- Take the average over quarters
SELECT
	age_group,
	AVG(total_amount) AS avg_total_amount_per_quarter,
	AVG(number_of_transactions) AS avg_number_of_transactions_per_quarter,
	AVG(average_amount_per_transaction) AS avg_transaction_amount_per_quarter,
	AVG(percentage_of_total_amount) AS avg_percentage_of_total_amount,
	AVG(percentage_of_transactions) AS avg_percentage_of_transactions
FROM
	age_group_quarterly_metrics
GROUP BY
	age_group;