-- Задача 2. Исследование внутриигровых покупок
-- 2.3: Популярные эпические предметы:
-- ЗАПРОС 2.3
WITH filtered_events AS (SELECT e.id, e.item_code
FROM fantasy.events AS e
WHERE e.amount > 0), --Исключаем нулевые покупки
total_sales AS (SELECT COUNT(*) AS total_count FROM filtered_events), -- Считаем общее кол-во продаж, исключив нулевые
total_buyers AS (SELECT COUNT(DISTINCT id) AS total_users 
FROM filtered_events) -- Считаем общее кол-во покупателей предметов, исключив нулевые покупки
SELECT
i.game_items, -- Название предмета
i.item_code, -- Код предмета
COUNT(*) AS sales_count, --общее кол-во продаж (без нулевых)
ROUND(COUNT(*)::numeric/ts.total_count, 4) AS sales_share, --доля продаж каждого предмета
ROUND(COUNT(DISTINCT fe.id)::numeric/tb.total_users,4) AS buyers_share --доля покупателей предмета от общего кол-ва покупателей предметов (без нулевых покупок)
FROM filtered_events AS fe
INNER JOIN fantasy.items AS i
ON i.item_code = fe.item_code
CROSS JOIN total_sales AS ts --Присоединяем к каждой строке значение total_sales (вместо подзапроса и оконных)
CROSS JOIN total_buyers AS tb --Присоединяем к каждой строке значение total_buyers (вместо подзапроса и оконных)
GROUP BY i.game_items, i.item_code, ts.total_count, tb.total_users
ORDER BY buyers_share DESC; --Сортируем по популярности предмета среди игроков 