-- ================================================================
-- DATABASE ADMINISTRATION TEMPLATE (TOPIC 11)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE ROLE statements for at least 2 distinct roles.
--    Example roles: read-only analyst, read-write editor.
--
-- 2) GRANT statements assigning appropriate permissions to each role:
--    - Read-only role: GRANT SELECT ON ALL TABLES IN SCHEMA ...
--    - Read-write role: GRANT SELECT, INSERT, UPDATE, DELETE ...
--
-- 3) CREATE USER statements for at least 2 users.
--    Each user must be assigned to one of the defined roles.
--
-- 4) Comments before each section explaining the rationale:
--    - Why this role exists
--    - What access it should and should not have
--
-- RECOMMENDED ORDER:
-- 1) Roles + their GRANTs
-- 2) Users + GRANT ROLE TO USER
-- 3) Optional: REVOKE statements for fine-grained restrictions
-- 4) Optional cleanup block (commented out by default):
--    -- DROP USER ...; DROP ROLE ...;
--
-- IMPORTANT:
-- - Use explicit GRANT / REVOKE statements — do not rely on defaults.
-- - Roles must have meaningfully different permission levels.
-- - Script must execute in PostgreSQL without errors.
-- ================================================================

-- Add your script below this line
-- ============================================================================
-- 1) ROLES + THEIR GRANTS (Створення ролей та надання прав)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- РОЛЬ 1: Аналітик тільки для читання (role_fitness_analyst)
-- Обґрунтування: Для бізнес-аналітиків та звітності.
-- Дозволений доступ: Тільки читання (SELECT) усіх таблиць у схемі fitness_center.
-- Заборонений доступ: Модифікація даних (INSERT, UPDATE, DELETE) та DDL-операції.
-- ----------------------------------------------------------------------------
CREATE ROLE role_fitness_analyst;

GRANT USAGE ON SCHEMA fitness_center TO role_fitness_analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA fitness_center TO role_fitness_analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA fitness_center 
GRANT SELECT ON TABLES TO role_fitness_analyst;


-- ----------------------------------------------------------------------------
-- РОЛЬ 2: Операційний менеджер (role_fitness_manager)
-- Обґрунтування: Для працівників рецепції, які керують щоденною діяльністю.
-- Дозволений доступ: Повний DML доступ (SELECT, INSERT, UPDATE, DELETE) та SEQUENCES.
-- Заборонений доступ: DDL-команди (CREATE/DROP) та системні налаштування.
-- ----------------------------------------------------------------------------
CREATE ROLE role_fitness_manager;

GRANT USAGE ON SCHEMA fitness_center TO role_fitness_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fitness_center TO role_fitness_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA fitness_center TO role_fitness_manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA fitness_center 
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO role_fitness_manager;

ALTER DEFAULT PRIVILEGES IN SCHEMA fitness_center 
GRANT USAGE, SELECT ON SEQUENCES TO role_fitness_manager;


-- ----------------------------------------------------------------------------
-- РОЛЬ 3: Стажер рецепції / Оператор (role_fitness_operator)
-- Обґрунтування: Для тимчасових працівників. Початково надаються розширені
-- права запису, які надалі обмежуються в розділі REVOKE до рівня Read-Only.
-- ----------------------------------------------------------------------------
CREATE ROLE role_fitness_operator;

GRANT USAGE ON SCHEMA fitness_center TO role_fitness_operator;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fitness_center TO role_fitness_operator;


-- ============================================================================
-- 2) USERS + GRANT ROLE TO USER (Створення користувачів та призначення ролей)
-- ============================================================================

-- КОРИСТУВАЧ 1: Обліковий запис аналітика (analyst_alex)
CREATE USER analyst_alex WITH PASSWORD 'alex_123';
GRANT role_fitness_analyst TO analyst_alex;

-- КОРИСТУВАЧ 2: Обліковий запис менеджера (manager_olena)
CREATE USER manager_olena WITH PASSWORD 'olena_123';
GRANT role_fitness_manager TO manager_olena;

-- КОРИСТУВАЧ 3: Обліковий запис стажера (operator_denys)
CREATE USER operator_denys WITH PASSWORD 'denys_123';
GRANT role_fitness_operator TO operator_denys;



-- ПЕРЕВІРКА ПРАВ --

------------------------------------------
-- ANALYST_ALEX
------------------------------------------
-- УСПІШНЕ (Аналітик)
SELECT * FROM fitness_center.memberships;

-- НЕУСПІШНЕ(спроба зміни даних заблокована)
UPDATE fitness_center.memberships 
SET price_membership = 9999 
WHERE membership_id = 1;


------------------------------------------
-- MANAGER_OLENA
-----------------------------------------
-- УСПІШНЕ (UPDATE) для Менеджера
UPDATE fitness_center.memberships 
SET price_membership = 600 
WHERE membership_id = 1;

-- НЕУСПІШНЕ(спроба створити нову таблицю)
CREATE TABLE fitness_center.equipment (
    equipment_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL
);


------------------------------------------------
-- OPERATOR_DENYS
------------------------------------------------

-- УСПІШНЕ operator_denys
INSERT INTO fitness_center.members (first_name, last_name, phone_number) 
VALUES ('Andrii', 'Koval', 380671234599);

-- НЕУСПІШНЕ(Не зможе змінити структуру таблиці)
ALTER TABLE fitness_center.members ADD COLUMN email VARCHAR(100);



-- ============================================================================
-- 3) OPTIONAL: REVOKE STATEMENTS FOR FINE-GRAINED RESTRICTIONS
-- ============================================================================

-- 1. Обмеження для менеджера: Відкликаємо право видаляти тарифні плани (memberships),
-- щоб уникнути випадкового знищення фінансових довідників.
REVOKE DELETE ON fitness_center.memberships FROM role_fitness_manager;
COMMIT;

-- ПЕРЕВІРКА(неуспішна для manager_olena)
DELETE FROM fitness_center.memberships 
WHERE membership_id = 1;


-- 2. Точкове обмеження для стажера: Відкликаємо права на зміну даних (INSERT, UPDATE, DELETE),
-- переводячи роль role_fitness_operator у режим "Тільки перегляд".
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fitness_center FROM role_fitness_operator;
COMMIT;

-- ПЕРЕВІРКА (неуспішна для operator_denys)
INSERT INTO fitness_center.members (first_name, last_name, phone_number) 
VALUES ('Oleh', 'Sydorov', 380671234577);





-- ============================================================================
-- 4) OPTIONAL CLEANUP BLOCK (COMMENTED OUT BY DEFAULT)
-- ============================================================================
-- 1. Відкликаємо ролі у користувачів
-- REVOKE role_fitness_analyst FROM analyst_alex;
-- REVOKE role_fitness_manager FROM manager_olena;
-- REVOKE role_fitness_operator FROM operator_denys;

-- 2. Видаляємо користувачів
-- DROP USER IF EXISTS analyst_alex;
-- DROP USER IF EXISTS manager_olena;
-- DROP USER IF EXISTS operator_denys;

-- 3. Скасовуємо стандартні права (Default Privileges) у ролей
-- ALTER DEFAULT PRIVILEGES IN SCHEMA fitness_center REVOKE ALL ON TABLES FROM role_fitness_analyst, role_fitness_manager, role_fitness_operator;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA fitness_center REVOKE ALL ON SEQUENCES FROM role_fitness_manager;

-- 4. Відкликаємо всі привілеї на таблиці, послідовності та схему
-- REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA fitness_center FROM role_fitness_analyst, role_fitness_manager, role_fitness_operator;
-- REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA fitness_center FROM role_fitness_manager;
-- REVOKE USAGE ON SCHEMA fitness_center FROM role_fitness_analyst, role_fitness_manager, role_fitness_operator;

-- 5. Видаляємо ролі
-- DROP ROLE IF EXISTS role_fitness_analyst;
-- DROP ROLE IF EXISTS role_fitness_manager;
-- DROP ROLE IF EXISTS role_fitness_operator;

