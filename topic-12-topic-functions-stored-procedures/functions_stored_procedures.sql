-- ================================================================
-- FUNCTIONS & STORED PROCEDURES TEMPLATE (TOPIC 12)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
--
-- FUNCTIONS (at least 3):
--   - Each function should encapsulate reusable logic or a
--     calculation relevant to your project domain.
--   - Use CREATE OR REPLACE FUNCTION ... RETURNS ...
--
-- STORED PROCEDURES — SELECT / INSERT (at least 2):
--   - Procedures that retrieve data or insert new records.
--   - Use CREATE OR REPLACE PROCEDURE ...
--
-- STORED PROCEDURES — UPDATE (at least 2):
--   - Procedures that modify existing records.
--
-- FOR EACH FUNCTION / PROCEDURE, ADD COMMENTS EXPLAINING:
--   - Purpose: what it does
--   - Parameters: name, type, meaning
--   - Expected behavior / return value
--
-- TEST CALLS:
--   - Include at least one example call per function/procedure
--     (SELECT my_function(...) or CALL my_procedure(...))
--
-- OPTIONAL:
--   - EXCEPTION blocks for error handling
--   - Transaction management with BEGIN / COMMIT / ROLLBACK
--
-- RECOMMENDED ORDER:
-- 1) Functions
-- 2) SELECT / INSERT procedures
-- 3) UPDATE procedures
-- 4) Test calls
--
-- IMPORTANT:
-- - All routines must execute in PostgreSQL without errors.
-- - Logic must be relevant to your project domain.
-- - Submit everything in this single SQL file.
-- ================================================================

-- Add your functions and procedures below this line
-- ============================================================================
-- 1. ФУНКЦІЇ (FUNCTIONS)
-- ============================================================================

-------------------------------------------------------------------------------
-- ФУНКЦІЯ 1: fn_get_member_subscriptions_days_left
-- Мета: Розрахунок залишку днів для всіх активних абонементів клієнта.
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
-- Очікувана поведінка:
--   - Повертає таблицю (membership_name VARCHAR(100), days_left INT) з
--     деталізацією по кожному діючому абонементу на поточну дату (CURRENT_DATE).
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fitness_center.fn_get_member_subscriptions_days_left(
    p_phone_number BIGINT
)
RETURNS TABLE (
    membership_name VARCHAR(100),
    days_left INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ms.type_membership::VARCHAR(100) AS membership_name,
        (s.end_date - CURRENT_DATE)::INT AS days_left
    FROM fitness_center.subscriptions s
    JOIN fitness_center.members m ON s.member_id = m.member_id
    JOIN fitness_center.memberships ms ON s.membership_id = ms.membership_id
    WHERE m.phone_number = p_phone_number
      AND CURRENT_DATE BETWEEN s.start_date AND s.end_date
    ORDER BY days_left DESC;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- ФУНКЦІЯ 2: fn_get_member_discount_by_phone
-- Мета: Визначення відсотка персональної знижки на основі кількості відвідувань.
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
-- Очікувана поведінка:
--   - Повертає значення NUMERIC (0.00 — 0%, 0.05 — 5%, 0.10 — 10%, 0.15 — 15%)
--     залежно від загальної кількості візитів клієнта.
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fitness_center.fn_get_member_discount_by_phone(
    p_phone_number BIGINT
)
RETURNS NUMERIC AS $$
DECLARE
    v_visit_count INT;
BEGIN
    SELECT COUNT(a.attendance_id) INTO v_visit_count
    FROM fitness_center.attendances a
    JOIN fitness_center.members m ON a.member_id = m.member_id
    WHERE m.phone_number = p_phone_number;

    IF v_visit_count >= 50 THEN
        RETURN 0.15;
    ELSIF v_visit_count >= 20 THEN
        RETURN 0.10;
    ELSIF v_visit_count >= 5 THEN
        RETURN 0.05;
    ELSE
        RETURN 0.00;
    END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------------------------------
-- ФУНКЦІЯ 3: fn_get_discounted_membership_price
-- Мета: Обчислення кінцевої вартості абонемента з урахуванням лояльної знижки.
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
--   - p_membership_id (INT): Ідентифікатор обраного типу абонемента.
-- Очікувана поведінка:
--   - Повертає значення NUMERIC (вартість у грн, округлена до 2 знаків)
--     після розрахунку базової ціни та персональної знижки.
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fitness_center.fn_get_discounted_membership_price(
    p_phone_number BIGINT,
    p_membership_id INT
)
RETURNS NUMERIC AS $$
DECLARE
    v_base_price NUMERIC;
    v_discount NUMERIC;
    v_final_price NUMERIC;
BEGIN
    SELECT price_membership INTO v_base_price
    FROM fitness_center.memberships
    WHERE membership_id = p_membership_id;

    IF v_base_price IS NULL THEN
        RAISE EXCEPTION 'Тип абонемента з ID % не знайдено.', p_membership_id;
    END IF;

    v_discount := fitness_center.fn_get_member_discount_by_phone(p_phone_number);
    v_final_price := v_base_price * (1 - v_discount);

    RETURN ROUND(v_final_price, 2);
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- 2. ПРОЦЕДУРИ SELECT / INSERT (З КЕРУВАННЯМ ТРАНЗАКЦІЯМИ)
-- ============================================================================

-------------------------------------------------------------------------------
-- ПРОЦЕДУРА 1: sp_register_check_in
-- Мета: Реєстрація входу клієнта до фітнес-центру (INSERT).
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
-- Очікувана поведінка:
--   - Перевіряє наявність активного абонемента та відсутність незавершеного візиту.
--   - Створює новий запис у таблиці attendances (check_out_datetime залишається NULL).
--   - Фіксує зміни за допомогою COMMIT. У разі помилок виконує ROLLBACK і перериває процедуру.
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE fitness_center.sp_register_check_in(
    p_phone_number BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_member_id UUID;
    v_has_active_sub BOOLEAN;
    v_is_already_inside BOOLEAN;
BEGIN
    SELECT member_id INTO v_member_id
    FROM fitness_center.members
    WHERE phone_number = p_phone_number;

    IF v_member_id IS NULL THEN
        ROLLBACK;
        RAISE EXCEPTION 'Клієнта з номером телефону % не знайдено.', p_phone_number;
    END IF;

    SELECT EXISTS (
        SELECT 1 
        FROM fitness_center.subscriptions 
        WHERE member_id = v_member_id
          AND CURRENT_DATE BETWEEN start_date AND end_date
    ) INTO v_has_active_sub;

    IF NOT v_has_active_sub THEN
        ROLLBACK;
        RAISE EXCEPTION 'У клієнта немає активного абонемента на сьогодні.';
    END IF;

    SELECT EXISTS (
        SELECT 1 
        FROM fitness_center.attendances 
        WHERE member_id = v_member_id 
          AND check_out_datetime IS NULL
    ) INTO v_is_already_inside;

    IF v_is_already_inside THEN
        ROLLBACK;
        RAISE EXCEPTION 'Клієнт вже зареєстрований у залі.';
    END IF;

    INSERT INTO fitness_center.attendances (
        member_id, 
        check_in_datetime
    )
    VALUES (
        v_member_id, 
        CURRENT_TIMESTAMP
    );

    COMMIT;

    RAISE NOTICE 'Візит успішно зареєстровано для клієнта з телефоном %', p_phone_number;
END;
$$;

-------------------------------------------------------------------------------
-- ПРОЦЕДУРА 2: sp_add_member_subscription
-- Мета: Оформлення та додавання нового абонемента клієнту (INSERT).
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
--   - p_membership_id (INT): Ідентифікатор типу абонемента.
-- Очікувана поведінка:
--   - Автоматично розраховує дату закінчення (end_date) на основі типу абонемента.
--   - Вставляє новий запис у таблицю subscriptions та фіксує транзакцію (COMMIT).
--   - У разі помилок виконує ROLLBACK і прериває виконання.
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE fitness_center.sp_add_member_subscription(
    p_phone_number BIGINT,
    p_membership_id INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_member_id UUID;
    v_type_membership fitness_center.membership_type_enum;
    v_start_date DATE := CURRENT_DATE;
    v_end_date DATE;
BEGIN
    SELECT member_id INTO v_member_id
    FROM fitness_center.members
    WHERE phone_number = p_phone_number;

    IF v_member_id IS NULL THEN
        ROLLBACK;
        RAISE EXCEPTION 'Клієнта з номером телефону % не знайдено.', p_phone_number;
    END IF;

    SELECT type_membership INTO v_type_membership
    FROM fitness_center.memberships
    WHERE membership_id = p_membership_id;

    IF v_type_membership IS NULL THEN
        ROLLBACK;
        RAISE EXCEPTION 'Тип абонемента з ID % не знайдено.', p_membership_id;
    END IF;

    CASE v_type_membership::TEXT
        WHEN 'monthly' THEN v_end_date := (v_start_date + INTERVAL '1 month')::DATE;
        WHEN 'yearly'  THEN v_end_date := (v_start_date + INTERVAL '1 year')::DATE;
        WHEN 'premium' THEN v_end_date := (v_start_date + INTERVAL '1 year')::DATE;
    END CASE;

    INSERT INTO fitness_center.subscriptions (
        member_id, 
        membership_id, 
        start_date, 
        end_date
    )
    VALUES (
        v_member_id, 
        p_membership_id, 
        v_start_date, 
        v_end_date
    );

    COMMIT;
END;
$$;


-- ============================================================================
-- 3. ПРОЦЕДУРИ ОНОВЛЕННЯ (З КЕРУВАННЯМ ТРАНЗАКЦІЯМИ)
-- ============================================================================

-------------------------------------------------------------------------------
-- ПРОЦЕДУРА 1: sp_register_check_out
-- Мета: Фіксація виходу клієнта з фітнес-центру (UPDATE).
-- Параметри:
--   - p_phone_number (BIGINT): Номер телефону клієнта.
-- Очікувана поведінка:
--   - Знаходить активний візит клієнта (де check_out_datetime IS NULL) і
--     записує поточний час виходу (CURRENT_TIMESTAMP).
--   - Фіксує зміни через COMMIT. Якщо відкритий візит відсутній або виникла помилка — робить ROLLBACK.
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE fitness_center.sp_register_check_out(
    p_phone_number BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_member_id UUID;
BEGIN
    SELECT member_id INTO v_member_id
    FROM fitness_center.members
    WHERE phone_number = p_phone_number;

    IF v_member_id IS NULL THEN
        ROLLBACK;
        RAISE EXCEPTION 'Клієнта з номером телефону % не знайдено.', p_phone_number;
    END IF;

    UPDATE fitness_center.attendances
    SET check_out_datetime = CURRENT_TIMESTAMP
    WHERE member_id = v_member_id
      AND check_out_datetime IS NULL;

    IF NOT FOUND THEN
        ROLLBACK;
        RAISE EXCEPTION 'У клієнта з телефоном % немає активного входу в клуб.', p_phone_number;
    END IF;

    COMMIT;
END;
$$;

-------------------------------------------------------------------------------
-- ПРОЦЕДУРА 2: sp_update_member_phone
-- Мета: Зміна номера телефону клієнта з перевіркою унікальності (UPDATE).
-- Параметри:
--   - p_old_phone (BIGINT): Поточний номер телефону клієнта.
--   - p_new_phone (BIGINT): Новий номер телефону для встановлення.
-- Очікувана поведінка:
--   - Перевіряє відсутність дублікатів та відмінність нового номера від старого.
--   - Оновлює номер телефону в таблиці members і завершує транзакцію (COMMIT).
--   - У разі виявлення помилок скасовує зміни (ROLLBACK).
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE fitness_center.sp_update_member_phone(
    p_old_phone BIGINT,
    p_new_phone BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_member_id UUID;
    v_new_phone_exists BOOLEAN;
BEGIN
    IF p_old_phone = p_new_phone THEN
        ROLLBACK;
        RAISE EXCEPTION 'Новий номер телефону збігається зі старим.';
    END IF;

    SELECT member_id INTO v_member_id
    FROM fitness_center.members
    WHERE phone_number = p_old_phone;

    IF v_member_id IS NULL THEN
        ROLLBACK;
        RAISE EXCEPTION 'Клієнта зі старим номером телефону % не знайдено.', p_old_phone;
    END IF;

    SELECT EXISTS (
        SELECT 1 
        FROM fitness_center.members 
        WHERE phone_number = p_new_phone
    ) INTO v_new_phone_exists;

    IF v_new_phone_exists THEN
        ROLLBACK;
        RAISE EXCEPTION 'Номер телефону % вже зареєстрований за іншим клієнтом.', p_new_phone;
    END IF;

    UPDATE fitness_center.members
    SET phone_number = p_new_phone
    WHERE member_id = v_member_id;

    COMMIT;
END;
$$;


-- ============================================================================
-- 4. ТЕСТОВІ ВИКЛИКИ (TEST CALLS)
-- ============================================================================

-- 4.1. Перевірка функцій:
SELECT * FROM fitness_center.fn_get_member_subscriptions_days_left(380671234501);
SELECT fitness_center.fn_get_member_discount_by_phone(380671234501) AS discount_rate;
SELECT fitness_center.fn_get_discounted_membership_price(380671234501, 1) AS final_price;

-- 4.2. Перевірка SELECT / INSERT процедур:
CALL fitness_center.sp_register_check_in(380671234502);
CALL fitness_center.sp_add_member_subscription(380671234502, 1);

-- 4.3. Перевірка UPDATE процедур:
CALL fitness_center.sp_register_check_out(380671234502);
CALL fitness_center.sp_update_member_phone(380671234502, 380671234577);

