-- Задача 2. Исследование внутриигровых покупок
-- 2.2: Аномальные нулевые покупки:
-- ЗАПРОС 2.2
SELECT COUNT(*) FILTER (WHERE amount = 0) AS zero_purchases, --общее кол-во нулевых покупок
ROUND(COUNT(*) FILTER (WHERE amount = 0)::numeric / COUNT(*),6)  AS zero_purchases_share --доля нулевых покпок от общего кол-ва покупок
FROM fantasy.events;
