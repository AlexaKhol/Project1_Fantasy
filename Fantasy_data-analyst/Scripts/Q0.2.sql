--Запросы секции 0.N предназначены для самостоятельного исследования данных пользователем, чтобы понять структуру БД,
--данные, хранящиеся в полях таблиц
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