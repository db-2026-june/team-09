-- ================================================================
-- SQL VIEWS TEMPLATE (TOPIC 10)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) CREATE VIEW scripts for required view types:
--    - Horizontal view (select specific columns)
--    - Vertical view (filter specific rows)
--    - Mixed view (columns + row filters)
--    - Join-based view (multiple tables)
--    - Subquery-based view
--    - UNION-based view
--    - View based on another view
--    - Updatable view with WITH CHECK OPTION
--
-- 2) Comments before each view explaining:
--    - Purpose of the view
--    - How it supports your project design
--
-- 3) Optional demo SELECT statements to show view output.
--
-- RECOMMENDED ORDER:
-- 1) Simple views (horizontal / vertical / mixed)
-- 2) Join and subquery views
-- 3) UNION and layered views
-- 4) CHECK OPTION view
--
-- IMPORTANT:
-- - Script must execute in PostgreSQL without errors.
-- - Keep naming consistent and readable.
-- - Submit all views in this single SQL file.
-- ================================================================

-- Add your CREATE VIEW statements below this line
-- ============================================================================
-- 01. HORIZONTAL VIEW (Filtered Rows)
-- Description: Фільтрує РЯДКИ за певною умовою, не приховуючи колонки.
-- Purpose: Відображає все обладнання, яке наразі перебуває на обслуговуванні або в ремонті.
-- Project design rationale: Допомагає технічному персоналу швидко виокремити 
-- обладнання, що потребує ремонту, без використання зайвих JOIN.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_equipment_under_repair AS
SELECT *
FROM fitness_center.equipment
WHERE status_equipment = 'under repair';

-- Демо 01:
SELECT * FROM fitness_center.view_equipment_under_repair;


-- ============================================================================
-- 02. VERTICAL VIEW (Selected Columns)
-- Description: Обирає конкретні КОЛОНКИ з усіх рядків для приховування чутливих даних.
-- Purpose: Приховує конфіденційну інформацію клієнтів (номери телефонів, UUID, внутрішні дати).
-- Project design rationale: Використовується для публічних табло або списків тренерів, 
-- щоб відображати імена clients без розголошення персональних даних.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_member_public_profile AS
SELECT 
    first_name, 
    last_name
FROM fitness_center.members;

-- Демо 02:
SELECT * FROM fitness_center.view_member_public_profile;


-- ============================================================================
-- 03. MIXED VIEW (Selected Columns + Filtered Rows)
-- Description: Поєднує вертикальні обмеження (вибір колонок) із горизонтальною фільтрацією (умова WHERE).
-- Purpose: Відображає публічний каталог доступних на даний момент тренерів.
-- Project design rationale: Приховує внутрішні зарплати/ID, показуючи лише активних та доступних тренерів.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_available_trainers_public AS
SELECT 
    first_name, 
    last_name
FROM fitness_center.trainers
WHERE trainer_availability = 'available';

-- Демо 03:
SELECT * FROM fitness_center.view_available_trainers_public;


-- ============================================================================
-- 04. JOIN-BASED VIEW (Multiple Tables)
-- Description: Об'єднує декілька пов'язаних таблиць за допомогою INNER JOIN.
-- Purpose: Формує зрозумілий розклад щотижневий із назвами занять, 
-- залів та іменами призначених тренерів.
-- Project design rationale: Використовується мобільними додатками та рецепцією 
-- для відображення зручного розкладу без системних ID.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_recurring_schedule_details AS
SELECT 
    s.day_of_week,
    s.start_time,
    s.end_time,
    c.name_class,
    r.name_room,
    t.first_name || ' ' || t.last_name AS trainer_name
FROM fitness_center.schedule s
JOIN fitness_center.classes c ON s.class_id = c.class_id
JOIN fitness_center.rooms r ON s.room_id = r.room_id
JOIN fitness_center.trainers t ON s.trainer_id = t.trainer_id
WHERE s.day_of_week IS NOT NULL;

-- Демо 04:
SELECT * FROM fitness_center.view_recurring_schedule_details;


-- ============================================================================
-- 05. SUBQUERY-BASED VIEW (Nested Subqueries)
-- Description: Використовує вкладені підзапити для фільтрації записів між пов'язаними сутностями.
-- Purpose: Відображає контактну інформацію членів клубу з місячними абонементами.
-- Project design rationale: Використовується відділом маркетингу для цільових акцій 
-- з метою пропонування довгострокових абонементів.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_monthly_subscription_members AS
SELECT 
    m.first_name,
    m.last_name,
    m.phone_number
FROM fitness_center.members m
WHERE m.member_id IN (
    SELECT s.member_id 
    FROM fitness_center.subscriptions s
    WHERE s.membership_id = (
        SELECT ms.membership_id 
        FROM fitness_center.memberships ms 
        WHERE ms.type_membership = 'monthly'
    )
);

-- Демо 05:
SELECT * FROM fitness_center.view_monthly_subscription_members;


-- ============================================================================
-- 06. UNION-BASED VIEW
-- Description: Об'єднує записи груп, персональних тренувань та самостійних відвідувань 
-- в єдину стрічку активності.
-- Purpose: Забезпечує консолідований лог усіх дій членів клубу в комплексі.
-- Project design rationale: Об'єднує три різні операційні сутності в 
-- стандартизовану структуру з позначкою 'activity_type'.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_all_member_activity_feed AS
-- 1. Групові заняття
SELECT 
    m.first_name,
    m.last_name,
    c.name_class AS activity_name,
    'Group Class' AS activity_type
FROM fitness_center.class_registrations cr
JOIN fitness_center.members m ON cr.member_id = m.member_id
JOIN fitness_center.schedule s ON cr.schedule_id = s.schedule_id
JOIN fitness_center.classes c ON s.class_id = c.class_id

UNION ALL

-- 2. Персональні тренування
SELECT 
    m.first_name,
    m.last_name,
    CONCAT('Personal Session with ', t.first_name, ' ', t.last_name) AS activity_name,
    'Personal Session' AS activity_type
FROM fitness_center.personal_training_sessions pts
JOIN fitness_center.members m ON pts.member_id = m.member_id
JOIN fitness_center.trainers t ON pts.trainer_id = t.trainer_id

UNION ALL

-- 3. Самостійні відвідування (Locations)
SELECT 
    m.first_name,
    m.last_name,
    CONCAT('Self-training in ', r.name_room) AS activity_name,
    'Self-Training' AS activity_type
FROM fitness_center.locations l
JOIN fitness_center.members m ON l.member_id = m.member_id
JOIN fitness_center.rooms r ON l.room_id = r.room_id;

-- Демо 06:
SELECT * FROM fitness_center.view_all_member_activity_feed;


-- ============================================================================
-- 07. LAYERED VIEW (View based on another view)
-- Description: Виконує запит до 'view_all_member_activity_feed' (Task 06) для розрахунку 
-- загальної кількості та процентної частки кожного формату тренувань.
-- Purpose: Надає аналітику для керівництва щодо вподобань клієнтів та розподілу завантаженості.
-- Project design rationale: Демонструє багаторівневий аналітичний підхід через застосування 
-- агрегацій (COUNT, GROUP BY) та віконних функцій (SUM OVER) поверх UNION-представлення.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_training_format_distribution AS
SELECT 
    activity_type,
    COUNT(*) AS total_activities,
    ROUND(
        (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER()), 2
    ) AS percentage_share
FROM fitness_center.view_all_member_activity_feed
GROUP BY activity_type
ORDER BY total_activities DESC;

-- Демо 07:
SELECT * FROM fitness_center.view_training_format_distribution;


-- ============================================================================
-- 08. UPDATABLE VIEW WITH CHECK OPTION
-- Description: Створює оновлюване представление для управління діючими підписками 
-- (де end_date >= CURRENT_DATE) із застосуванням WITH CHECK OPTION.
-- Purpose: Захищає цілісність даних, забороняючи операторам додавати або змінювати 
-- записи підписок на прострочені через це інтерфейсне представление.
-- Project design rationale: Гарантує, що операційний персонал не зможе випадково 
-- встановити дату закінчення абонемента в минулому.
-- ============================================================================
CREATE OR REPLACE VIEW fitness_center.view_active_subscriptions_updatable AS
SELECT 
    subscription_id,
    member_id,
    membership_id,
    start_date,
    end_date
FROM fitness_center.subscriptions
WHERE end_date >= CURRENT_DATE
WITH CHECK OPTION;

-- Демо 08:
SELECT * FROM fitness_center.view_active_subscriptions_updatable;



-- TEST TEST TEST
-- ============================================================================
-- Успішно: Нова дата end_date у майбутньому (>= CURRENT_DATE)
UPDATE fitness_center.view_active_subscriptions_updatable
SET end_date = CURRENT_DATE + INTERVAL '90 days'
WHERE subscription_id = 1; 

-- Заблоковано - Менеджер помиляється при введенні та випадково вказує минулий рік у дати закінчення
UPDATE fitness_center.view_active_subscriptions_updatable
SET end_date = start_date - INTERVAL '1 year'
WHERE subscription_id = 1;

