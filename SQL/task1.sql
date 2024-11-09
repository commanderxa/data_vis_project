-- SELECT
--     id_client,
--     COUNT(DISTINCT EXTRACT(DAY FROM date_new)) AS active_month
-- FROM
--     transactions
-- GROUP BY id_client;

-- Find clients with transactions for every month
WITH active_clients AS (
    SELECT
        id_client
    FROM
        transactions
    GROUP BY
        id_client
    HAVING
       COUNT(DISTINCT EXTRACT(DAY FROM date_new)) = 12
)

-- Calculate the required metrics for these clients
SELECT
    t.id_client,
    AVG(t.sum_payment) AS average_receipt,
    SUM(t.sum_payment) / 12 AS average_purchases_per_month,
    COUNT(*) AS total_transactions
FROM
    transactions t
JOIN
    active_clients c ON t.id_client = c.id_client
GROUP BY
    t.id_client;
