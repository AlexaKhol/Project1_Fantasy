-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:
-- ЗАПРОС 2.1
SELECT COUNT(*) AS total_purchases, --общее кол-во покупок
SUM(amount) AS total_amount, --суммарная стоимость всех покупок
MIN(amount) AS min_amount, --минимальная стоимость покупки
MAX(amount) AS max_amount, --максимальная стоимость покупки
AVG(amount) AS avg_amount, --средняя стоимость покупки
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) AS median_amount, --медиана стоимости покупки
STDDEV(amount) AS stddev_amount --стандартное отклонение стоимости покупки
FROM fantasy.events;