-- 1.1. Доля платящих пользователей по всем данным:
-- ЗАПРОС 1.1
SELECT COUNT(id) AS total_amt_users, --общее количество игроков, зарегистрированных в игре;
COUNT(id) FILTER (WHERE payer = 1) AS payer_users_amt, --количество платящих игроков;
ROUND(COUNT(id) FILTER (WHERE payer = 1)::numeric / COUNT(id),3) AS payer_users_share --доля платящих игроков от общего количества пользователей, зарегистрированных в игре.
FROM fantasy.users;