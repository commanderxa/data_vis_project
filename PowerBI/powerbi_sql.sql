SELECT 
	DISTINCT o.user_id
FROM 
	orders o
JOIN order_list ol ON o.order_id = ol.order_id
JOIN products p ON ol.product_id = p.product_id
WHERE p.category = 'Продукция для животных'
	AND p.product != 'Корм Kitekat для кошек, с говядиной в соусе, 85 г'
	AND o.order_date BETWEEN '2017-08-01' AND '2017-08-15';


SELECT
	p.product, 
	COUNT(ol.product_id) AS order_count
FROM
	orders o
JOIN order_list ol ON o.order_id = ol.order_id
JOIN products p ON ol.product_id = p.product_id
JOIN wirehouses w ON o.warehouse_id = w.warehouse_id
WHERE w.city = 'Санкт-Петербург'
	AND o.order_date BETWEEN '2017-08-15' AND '2017-08-30'
GROUP BY 
	p.product
ORDER BY 
	order_count DESC
LIMIT 5;
