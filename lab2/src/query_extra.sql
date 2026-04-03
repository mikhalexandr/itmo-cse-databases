DROP TABLE IF EXISTS test1, test2;

CREATE TABLE test1 (
    id int PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE test2 (
    id int PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO test1
SELECT i, 'test1_' || i
FROM generate_series(1, 600) AS i;

INSERT INTO test2
SELECT i, 'test2_' || i
FROM generate_series(1, 1000) AS i;

---

SET enable_hashjoin TO on;
SET enable_mergejoin TO off;
SET enable_nestloop TO off;

-- 1. Hash Join

EXPLAIN ANALYSE
SELECT *
FROM test1
LEFT JOIN test2
    ON test1.id = test2.id;

/*
   PostgreSQL строит хеш-таблицу по одной из таблиц (обычно по меньшей),
   затем для каждой строки из другой таблицы выполняет поиск совпадения в этой хеш-таблице
   Подходит для соединения больших таблиц по равенству, особенно когда нет подходящих индексов
   Может требовать много памяти, если хеш-таблица получается большой
*/

---

SET enable_nestloop TO on;
SET enable_hashjoin TO off;
SET enable_mergejoin TO off;

-- 2. Nested Loop Join

EXPLAIN ANALYSE
SELECT *
FROM test1
LEFT JOIN test2
    ON test1.id = test2.id;

/*
   Для каждой строки из одной таблицы выполняется поиск соответствующих строк в другой таблице
   Эффективен при небольшом объёме данных или когда на второй таблице есть индекс по ключу соединения
   При отсутствии индекса приводит к большому числу сравнений и может работать очень медленно на больших таблицах
*/

---

SET enable_mergejoin TO on;
SET enable_hashjoin TO off;
SET enable_nestloop TO off;

-- 3. Merge Join

EXPLAIN ANALYSE
SELECT *
FROM test1
LEFT JOIN test2
    ON test1.id = test2.id;

/*
   Обе таблицы должны быть отсортированы по ключу соединения (либо явно, либо за счёт индекса)
   После этого происходит один проход по данным двумя указателями (аналогично merge-фазе в merge sort)
   Эффективен для больших таблиц, особенно если данные уже отсортированы
   При наличии B-tree индекса сортировка не требуется, так как данные читаются в порядке,
   что значительно ускоряет выполнение
*/

---
