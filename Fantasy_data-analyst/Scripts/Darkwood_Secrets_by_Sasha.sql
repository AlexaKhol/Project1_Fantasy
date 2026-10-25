/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Холодилина Александра Романовна
 * Дата: 21.10.2026
*/

--Запросы секции 0.N предназначены для самостоятельного исследования данных пользователем, чтобы понять структуру БД,
--данные, хранящиеся в полях таблиц
--0.1 Таблицы, хранящиеся в схеме fantasy
-- ЗАПРОС 0.1
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'fantasy';

--0.2 Изучение таблицы Users (с помощью структуры данного запроса можно изучить любую таблицу в БД)
-- ЗАПРОС 0.2
SELECT
c.table_schema, --название схемы
c.table_name, --название таблицы
c.column_name, --название поля
c.data_type, --тип данных, хранящихся в поле
k.constraint_name --информация о первичном или внешнем ключе (если NULL - поле не имеет ограничений и не используется в качестве PK или FK)
FROM information_schema.columns AS c
LEFT JOIN information_schema.key_column_usage AS k ON  c.table_schema = k.table_schema
AND c.table_name   = k.table_name
AND c.column_name  = k.column_name
WHERE c.table_schema = 'fantasy'
AND c.table_name   = 'users';

--0.3 Проверка на наличие пустых значений в полях таблицы Users
-- ЗАПРОС 0.3
SELECT COUNT(*) AS rows_with_nulls
FROM fantasy.users
WHERE class_id    IS NULL
   OR ch_id       IS NULL
   OR pers_gender IS NULL
   OR server      IS NULL
   OR race_id     IS NULL
   OR payer       IS NULL
   OR loc_id      IS NULL;

-- 1.1. Доля платящих пользователей по всем данным:
-- ЗАПРОС 1.1
SELECT COUNT(id) AS total_amt_users, --общее количество игроков, зарегистрированных в игре;
COUNT(id) FILTER (WHERE payer = 1) AS payer_users_amt, --количество платящих игроков;
ROUND(COUNT(id) FILTER (WHERE payer = 1)::numeric / COUNT(id),3) AS payer_users_share --доля платящих игроков от общего количества пользователей, зарегистрированных в игре.
FROM fantasy.users;

-- 1.2. Доля платящих пользователей в разрезе расы персонажа:
-- ЗАПРОС 1.2
SELECT r.race, --название расы персонажа;
r.race_id, --код расы персонажа;
COUNT(id) FILTER (WHERE payer = 1) AS payer_users_amt, --количество платящих игроков этой расы;
COUNT(id) AS total_amt_users, -- общее количество зарегистрированных игроков этой расы;
ROUND(COUNT(id) FILTER (WHERE payer = 1)::numeric / COUNT(id),4) AS payer_users_share --доля платящих игроков среди всех зарегистрированных игроков этой расы.
FROM fantasy.users AS u
INNER JOIN fantasy.race AS r ON u.race_id = r.race_id -- присоединяем таблицу race для вывода названий рас
GROUP BY r.race, r.race_id
ORDER BY payer_users_share DESC;

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

-- 2.2: Аномальные нулевые покупки:
-- ЗАПРОС 2.2
SELECT COUNT(*) FILTER (WHERE amount = 0) AS zero_purchases, --общее кол-во нулевых покупок
ROUND(COUNT(*) FILTER (WHERE amount = 0)::numeric / COUNT(*),6)  AS zero_purchases_share --доля нулевых покпок от общего кол-ва покупок
FROM fantasy.events;

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