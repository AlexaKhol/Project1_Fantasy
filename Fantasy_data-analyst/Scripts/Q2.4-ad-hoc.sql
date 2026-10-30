-- Часть 2. Решение ad hoc-задачи
-- Задача: Зависимость активности игроков от расы персонажа:
-- ЗАПРОС 2.4
WITH filtered_events AS (SELECT id, amount
FROM fantasy.events
WHERE amount > 0),
user_stats AS (
SELECT u.race_id, u.id, u.payer,
-- Количество покупок пользователя (0, если не покупал)
COALESCE(COUNT(fe.amount), 0) AS user_purchases_count,
-- Средняя стоимость одной покупки пользователя (0, если не покупал)
COALESCE(AVG(fe.amount), 0) AS user_avg_purchase_cost,
-- Суммарная стоимость покупок пользователя (0, если не покупал)
COALESCE(SUM(fe.amount), 0) AS user_total_cost
FROM fantasy.users AS u
LEFT JOIN filtered_events AS fe ON u.id = fe.id
GROUP BY u.race_id, u.id, u.payer)
SELECT 
us.race_id, r.race,
-- 1. Общее количество зарегистрированных игроков
COUNT(id) AS total_users,   
-- 2. Количество игроков, совершающих покупки
COUNT(id) FILTER (WHERE user_purchases_count>0) AS buying_users_count,
-- Доля покупателей от общего числа зарегистрированных игроков
ROUND(COUNT(id) FILTER (WHERE user_purchases_count>0)::numeric/COUNT(id),4) AS buying_users_share,
-- 3. Доля платящих игроков среди тех, кто совершил покупки (NULLIF помогает избежать деления на 0 в случае, если в какой-то из рас никто не совершил покупку)
ROUND(COUNT(id) FILTER (WHERE payer = 1 AND user_purchases_count>0)::numeric/NULLIF(COUNT(id) FILTER (WHERE user_purchases_count>0),0),4) AS payers_share_among_buyers,
-- 4. Среднее количество покупок на одного покупателя
ROUND(AVG(user_purchases_count) FILTER (WHERE user_purchases_count>0)::numeric,2) AS avg_purchases_per_buyer,
-- 5. Средняя стоимость одной покупки на одного покупателя (Суммарные траты / Число покупок расы)
ROUND(AVG(user_avg_purchase_cost) FILTER (WHERE user_purchases_count>0)::numeric,2) AS avg_purchase_cost_per_buyer,
-- 5.1. Средний чек транзакции (Траты расы / число её покупок)
ROUND(SUM(user_total_cost)::numeric / NULLIF(SUM(user_purchases_count),0),2) AS avg_purchase_cost_per_transaction,
-- 6. Средняя суммарная стоимость всех покупок на одного покупателя
ROUND(AVG(user_total_cost) FILTER (WHERE user_purchases_count>0)::numeric,2) AS avg_total_cost_per_buyer
FROM user_stats AS us
INNER JOIN fantasy.race AS r ON us.race_id = r.race_id
GROUP BY us.race_id, r.race 
ORDER BY r.race;