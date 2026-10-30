--Запросы секции 0.N предназначены для самостоятельного исследования данных пользователем, чтобы понять структуру БД,
--данные, хранящиеся в полях таблиц
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