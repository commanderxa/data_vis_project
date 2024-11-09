-- Calculate total transactions and total sum_payment for the year
WITH totals AS (
    SELECT
        COUNT(*) AS total_transactions_year,
        SUM(sum_payment) AS total_sum_payment_year
    FROM
        transactions
),

-- Calculate monthly statistics
monthly AS (
    SELECT
        EXTRACT(YEAR FROM date_new) AS year,
        EXTRACT(DAY FROM date_new) AS month,
        COUNT(*) AS transactions_in_month,
        SUM(sum_payment) AS sum_payment_in_month,
        AVG(sum_payment) AS avg_check_amount_in_month,
        COUNT(DISTINCT id_client) AS clients_in_month
    FROM
        transactions
    GROUP BY
        EXTRACT(YEAR FROM date_new),
        EXTRACT(DAY FROM date_new)
),

-- Calculate average operations per client per month
monthly_client_ops AS (
    SELECT
        EXTRACT(YEAR FROM date_new) AS year,
        EXTRACT(DAY FROM date_new) AS month,
        id_client,
        COUNT(*) AS num_transactions
    FROM
        transactions
    GROUP BY
        EXTRACT(YEAR FROM date_new),
        EXTRACT(DAY FROM date_new),
        id_client
),

avg_ops_per_month AS (
    SELECT
        year,
        month,
        AVG(num_transactions) AS avg_operations_per_client_in_month
    FROM
        monthly_client_ops
    GROUP BY
        year,
        month
)

-- Combine all data
SELECT
    m.year,
    m.month,
    m.avg_check_amount_in_month,
    a.avg_operations_per_client_in_month,
    m.clients_in_month AS number_of_clients,
    (m.transactions_in_month::FLOAT / t.total_transactions_year) AS share_transactions,
    (m.sum_payment_in_month / t.total_sum_payment_year) AS share_sum_payment
FROM
    monthly m
JOIN
    avg_ops_per_month a ON m.year = a.year AND m.month = a.month
CROSS JOIN
    totals t
ORDER BY
    m.year,
    m.month;
