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