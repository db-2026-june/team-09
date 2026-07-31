-- ================================================================
-- SQL DML TEMPLATE (TOPIC 09)
-- ================================================================
-- WHAT SHOULD BE ADDED HERE:
-- 1) INSERT scripts for all required tables in your database.
-- 2) At least 10 records per table with meaningful, realistic values.
-- 3) UPDATE / DELETE scripts where they are relevant to business logic.
-- 4) If UPDATE / DELETE are not relevant for a table, add a short note
--    in documentation explaining why.
-- 5) Comments by section so the script is easy to read and run.
--
-- SCRIPT GOALS:
-- - Populate the database with usable test data.
-- - Validate constraints through realistic DML scenarios.
-- - Support the core functionality of your application.
--
-- RECOMMENDED ORDER:
-- 1) Reference data (lookups/dictionaries)
-- 2) Core entities
-- 3) Transactional data
-- 4) Optional UPDATE / DELETE checks
--
-- IMPORTANT:
-- - Use anonymized or privacy-safe sample data where possible.
-- - The script must execute in PostgreSQL.
-- - Submit this as one SQL file.
-- ================================================================

-- Add your DML below this line
-- =============================================================================
-- 1) ДОВІДКОВІ ДАНІ
-- =============================================================================

-- 1.1. Memberships (Типи абонементів) — ENUM: 'monthly', 'yearly', 'premium'
INSERT INTO fitness_center.memberships (type_membership, price_membership) VALUES
('monthly', 500),
('yearly', 5000),
('premium', 9000);

-- 1.2. Classes (Напрямки занять)
INSERT INTO fitness_center.classes (name_class) VALUES
('Yoga'),
('Spinning'),
('Strength Training'),
('Pilates'),
('Zumba'),
('CrossFit'),
('Aerobics'),
('Stretching'),
('Functional Training'),
('HIIT');

-- 1.3. Specializations (Спеціалізації)
INSERT INTO fitness_center.specializations (name_specialization) VALUES
('Yoga Instructor'),
('Spinning Coach'),
('Strength Training Coach'),
('Pilates Instructor'),
('Zumba Instructor'),
('CrossFit Coach'),
('Aerobics Instructor'),
('Stretching Coach'),
('Functional Training Coach'),
('HIIT Coach');

-- 1.4. Rooms (Зали фітнес-центру)
INSERT INTO fitness_center.rooms (name_room, capacity) VALUES
('Yoga Studio', 20),
('Cycling Studio', 25),
('Strength Gym', 30),
('Functional Training Area', 20),
('Pilates Studio', 18),
('Aerobics Studio', 25),
('CrossFit Area', 24),
('HIIT Studio', 22),
('Stretching Studio', 16),
('Dance Studio', 30);


-- =============================================================================
-- 2) ОСНОВНІ СУТНОСТІ
-- =============================================================================

-- 2.1. Members (Клієнти)
INSERT INTO fitness_center.members (first_name, last_name, phone_number) VALUES
('Vasyl', 'Hnatyuk', 380671234501),
('Liudmyla', 'Sydorenko', 380671234502),
('Pavlo', 'Yaremchuk', 380671234503),
('Sofiia', 'Levchenko', 380671234504),
('Mykola', 'Klymenko', 380671234505),
('Viktoriia', 'Zakharenko', 380671234506),
('Rostyslav', 'Chumak', 380671234507),
('Alina', 'Bilyk', 380671234508),
('Yurii', 'Kulyk', 380671234509),
('Khrystyna', 'Nazarenko', 380671234510),
('Roman', 'Babenko', 380671234511),
('Daryna', 'Tereshchenko', 380671234512),
('Oleh', 'Yakovenko', 380671234513),
('Solomiia', 'Bezkorovaina', 380671234514),
('Taras', 'Verbytskyi', 380671234515);

-- 2.2. Trainers (Тренери) — ENUM: 'available', 'busy', 'on leave', 'unavailable'
INSERT INTO fitness_center.trainers (first_name, last_name, trainer_availability) VALUES
('Oleksandr', 'Koval', 'available'),
('Anastasiia', 'Shevchenko', 'available'),
('Maksym', 'Bondarenko', 'on leave'),
('Kateryna', 'Melnyk', 'available'),
('Andrii', 'Tkachenko', 'busy'),
('Olena', 'Kravets', 'available'),
('Dmytro', 'Lysenko', 'unavailable'),
('Iryna', 'Polishchuk', 'available'),
('Bohdan', 'Savchenko', 'busy'),
('Yuliia', 'Moroz', 'available'),
('Vitalii', 'Romaniuk', 'available'),
('Mariia', 'Kovalchuk', 'busy'),
('Serhii', 'Ivanenko', 'available'),
('Nataliia', 'Oliinyk', 'available'),
('Volodymyr', 'Petrenko', 'unavailable'),
('Tetianna', 'Danyliuk', 'available'),
('Yevhen', 'Hrytsenko', 'busy'),
('Oksana', 'Mazur', 'available'),
('Ihor', 'Kozak', 'available'),
('Svitlana', 'Rudenko', 'on leave');

-- 2.3. Equipment (Інвентар) — ENUM: 'available', 'under repair', 'decommissioned'
INSERT INTO fitness_center.equipment (room_id, name_equipment, status_equipment) VALUES
(1, 'Yoga Mat', 'available'),
(1, 'Yoga Block', 'available'),
(1, 'Yoga Strap', 'available'),
(2, 'Spin Bike', 'under repair'),
(3, 'Barbell', 'available'),
(3, 'Weight Plate', 'available'),
(3, 'Dumbbell', 'available'),
(3, 'Bench Press', 'under repair'),
(3, 'Squat Rack', 'available'),
(5, 'Pilates Ring', 'available'),
(5, 'Fitness Band', 'available'),
(5, 'Fitball', 'under repair'),
(6, 'Sound System', 'available'),
(6, 'Step Platform', 'available'),
(7, 'Pull-up Bar', 'available'),
(8, 'Jump Rope', 'available'),
(7, 'Plyo Box', 'under repair'),
(4, 'Rowing Machine', 'available'),
(9, 'Massage Roller', 'available'),
(7, 'Kettlebell', 'available'),
(8, 'Medicine Ball', 'available'),
(4, 'TRX Straps', 'available'),
(7, 'CrossFit Battle Rope', 'decommissioned'),
(4, 'Agility Ladder', 'available');


-- =============================================================================
-- 3) ТРАНЗАКЦІЙНІ ДАНІ
-- =============================================================================

-- 3.1. Subscriptions (Придбані абонементи)
INSERT INTO fitness_center.subscriptions (member_id, membership_id, start_date, end_date) VALUES
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501), 1, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '20 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502), 2, CURRENT_DATE - INTERVAL '2 months', CURRENT_DATE + INTERVAL '10 months'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503), 3, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '25 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504), 1, CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE + INTERVAL '15 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505), 2, CURRENT_DATE - INTERVAL '6 months', CURRENT_DATE + INTERVAL '6 months'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506), 3, CURRENT_DATE - INTERVAL '1 month', CURRENT_DATE + INTERVAL '11 months'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507), 1, CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE + INTERVAL '27 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508), 2, CURRENT_DATE - INTERVAL '1 year', CURRENT_DATE),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509), 1, CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE + INTERVAL '10 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510), 3, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month');



-- 3.2. Schedule (Розклад занять) — 12 записів
INSERT INTO fitness_center.schedule (room_id, class_id, trainer_id, date_schedule, day_of_week, start_time, end_time) VALUES
-- Регулярні заняття (day_of_week заповнено, date_schedule = NULL)
(1, 1, 1, NULL, 'monday', '08:00:00', '09:00:00'), -- Yoga Studio, Yoga, Oleksandr Koval
(2, 2, 2, NULL, 'monday', '18:30:00', '19:30:00'), -- Cycling Studio, Spinning, Anastasiia Shevchenko
(3, 3, 4, NULL, 'tuesday', '10:00:00', '11:30:00'), -- Strength Gym, Strength Training, Kateryna Melnyk
(5, 4, 8, NULL, 'tuesday', '17:00:00', '18:00:00'), -- Pilates Studio, Pilates, Iryna Polishchuk
(6, 5, 10, NULL, 'wednesday', '19:00:00', '20:00:00'), -- Aerobics Studio, Zumba, Yuliia Moroz
(7, 6, 6, NULL, 'thursday', '09:00:00', '10:15:00'), -- CrossFit Area, CrossFit, Olena Kravets
(6, 7, 14, NULL, 'thursday', '18:00:00', '19:00:00'), -- Aerobics Studio, Aerobics, Nataliia Oliinyk
(9, 8, 18, NULL, 'friday', '11:00:00', '12:00:00'), -- Stretching Studio, Stretching, Oksana Mazur
(4, 9, 13, NULL, 'friday', '16:30:00', '17:30:00'), -- Functional Training Area, Functional, Serhii Ivanenko
(8, 10, 16, NULL, 'saturday', '11:00:00', '12:00:00'), -- HIIT Studio, HIIT, Tetianna Danyliuk

-- Разові події / майстер-класи (date_schedule заповнено, day_of_week = NULL)
(1, 1, 1, CURRENT_DATE + INTERVAL '2 days', NULL, '10:00:00', '12:00:00'), -- Yoga Intensive
(7, 6, 6, CURRENT_DATE + INTERVAL '5 days', NULL, '14:00:00', '16:00:00'); -- CrossFit Challenge



-- 3.3. Attendances (Облік відвідуваності) — 10 записів
INSERT INTO fitness_center.attendances (member_id, check_in_datetime, check_out_datetime) VALUES
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501), NOW() - INTERVAL '2 hours', NOW() - INTERVAL '30 minutes'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502), NOW() - INTERVAL '1 day',   NOW() - INTERVAL '1 day' + INTERVAL '1.5 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503), NOW() - INTERVAL '3 hours', NOW() - INTERVAL '1 hour'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504), NOW() - INTERVAL '2 days',  NOW() - INTERVAL '2 days' + INTERVAL '2 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505), NOW() - INTERVAL '4 hours', NOW() - INTERVAL '2 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506), NOW() - INTERVAL '3 days',  NOW() - INTERVAL '3 days' + INTERVAL '1 hour'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507), NOW() - INTERVAL '5 hours', NOW() - INTERVAL '4 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508), NOW() - INTERVAL '4 days',  NOW() - INTERVAL '4 days' + INTERVAL '1.5 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509), NOW() - INTERVAL '6 hours', NOW() - INTERVAL '5 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510), NOW() - INTERVAL '5 days',  NOW() - INTERVAL '5 days' + INTERVAL '2 hours');



-- 3.4. Progress (Прогрес та цілі клієнтів) — 10 записів
INSERT INTO fitness_center.progress (member_id, fitness_goals, progress_metrics, goal_achievement_date) VALUES
-- Цілі в процесі (goal_achievement_date = NULL)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501), 'Achieve splits flexibility', 'Flexibility: +4cm', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502), 'Increase bench press to 100kg', 'Current weight: 85kg', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503), 'Lose 5kg of body fat', 'Weight: 78kg -> 75kg', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504), 'Improve marathon endurance', '10km run time: 52min', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505), 'Gain 3kg of muscle mass', 'Current weight: 70kg', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506), 'Master handstand push-ups', 'Pike push-ups: 15 reps', NULL),

-- Досягнуті цілі (заповнено фактичну дату досягнення)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507), 'Improve posture and back strength', 'Core plank: 2 min', CURRENT_DATE - INTERVAL '10 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508), 'Deadlift 150kg', 'Max reached: 150kg', CURRENT_DATE - INTERVAL '1 month'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509), 'Reduce body fat percentage to 15%', 'Current fat: 15%', CURRENT_DATE - INTERVAL '5 days'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510), 'Complete 100 pull-ups session', 'Completed in 45 min', CURRENT_DATE - INTERVAL '2 weeks');



-- 3.5. TrainerClasses (Допуски тренерів до занять) [Many-to-Many] — 12 записів
INSERT INTO fitness_center.trainer_classes (class_id, trainer_id) VALUES
(1, 1),  -- Oleksandr Koval -> Yoga
(2, 2),  -- Anastasiia Shevchenko -> Spinning
(3, 4),  -- Kateryna Melnyk -> Strength Training
(4, 8),  -- Iryna Polishchuk -> Pilates
(5, 10), -- Yuliia Moroz -> Zumba
(6, 6),  -- Olena Kravets -> CrossFit
(7, 14), -- Nataliia Oliinyk -> Aerobics
(8, 18), -- Oksana Mazur -> Stretching
(9, 13), -- Serhii Ivanenko -> Functional Training
(10, 16),-- Tetianna Danyliuk -> HIIT
(1, 8),  -- Iryna Polishchuk -> Yoga
(8, 1);  -- Oleksandr Koval -> Stretching




-- 3.6. TrainerSpecializations (Спеціалізації тренерів) [Many-to-Many] — 12 записів
INSERT INTO fitness_center.trainer_specializations (trainer_id, specialization_id) VALUES
(1, 1),   -- Oleksandr Koval -> Yoga Instructor
(2, 2),   -- Anastasiia Shevchenko -> Spinning Coach
(4, 3),   -- Kateryna Melnyk -> Strength Training Coach
(8, 4),   -- Iryna Polishchuk -> Pilates Instructor
(10, 5),  -- Yuliia Moroz -> Zumba Instructor
(6, 6),   -- Olena Kravets -> CrossFit Coach
(14, 7),  -- Nataliia Oliinyk -> Aerobics Instructor
(18, 8),  -- Oksana Mazur -> Stretching Coach
(13, 9),  -- Serhii Ivanenko -> Functional Training Coach
(16, 10), -- Tetianna Danyliuk -> HIIT Coach
(1, 8),   -- Oleksandr Koval -> додатково Stretching Coach
(8, 1);   -- Iryna Polishchuk -> додатково Yoga Instructor




-- 3.7. ClassRegistrations (Записи клієнтів на групові заняття) — 12 записів
INSERT INTO fitness_center.class_registrations (schedule_id, member_id) VALUES
(1, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501)),
(1, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502)),
(2, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503)),
(2, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504)),
(3, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505)),
(4, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506)),
(5, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507)),
(6, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508)),
(7, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509)),
(8, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510)),
(11, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501)), -- Запис на разову подію (Yoga Intensive)
(12, (SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503)); -- Запис на разову подію (CrossFit Challenge)




-- 3.8. PersonalTrainingSessions (Персональні тренування) — 10 записів
INSERT INTO fitness_center.personal_training_sessions (member_id, trainer_id, start_datetime, end_datetime) VALUES
-- Завершені тренування (у минулому)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501), 1,  NOW() - INTERVAL '3 days' + INTERVAL '10 hours', NOW() - INTERVAL '3 days' + INTERVAL '11 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502), 2,  NOW() - INTERVAL '2 days' + INTERVAL '14 hours', NOW() - INTERVAL '2 days' + INTERVAL '15 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503), 4,  NOW() - INTERVAL '1 day'  + INTERVAL '09 hours', NOW() - INTERVAL '1 day'  + INTERVAL '10 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504), 8,  NOW() - INTERVAL '5 hours',                      NOW() - INTERVAL '4 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505), 10, NOW() - INTERVAL '2 hours',                      NOW() - INTERVAL '1 hour'),

-- Заплановані тренування (у майбутньому)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506), 6,  NOW() + INTERVAL '1 day'  + INTERVAL '10 hours', NOW() + INTERVAL '1 day'  + INTERVAL '11 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507), 14, NOW() + INTERVAL '2 days' + INTERVAL '16 hours', NOW() + INTERVAL '2 days' + INTERVAL '17 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508), 18, NOW() + INTERVAL '3 days' + INTERVAL '11 hours', NOW() + INTERVAL '3 days' + INTERVAL '12 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509), 13, NOW() + INTERVAL '4 days' + INTERVAL '18 hours', NOW() + INTERVAL '4 days' + INTERVAL '19 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510), 16, NOW() + INTERVAL '5 days' + INTERVAL '12 hours', NOW() + INTERVAL '5 days' + INTERVAL '13 hours');




-- 3.9. Locations (Переміщення клієнтів залами) — 10 записів
INSERT INTO fitness_center.locations (member_id, room_id, start_datetime, end_datetime) VALUES
-- Завершені переміщення (клієнт увійшов і вийшов із залу)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234501), 1, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234502), 2, NOW() - INTERVAL '1 day' + INTERVAL '10 hours', NOW() - INTERVAL '1 day' + INTERVAL '11 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234503), 3, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '2 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234504), 5, NOW() - INTERVAL '2 days' + INTERVAL '15 hours', NOW() - INTERVAL '2 days' + INTERVAL '17 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234505), 4, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '3 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234506), 7, NOW() - INTERVAL '3 days' + INTERVAL '09 hours', NOW() - INTERVAL '3 days' + INTERVAL '10 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234507), 6, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '4 hours'),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234508), 9, NOW() - INTERVAL '4 days' + INTERVAL '18 hours', NOW() - INTERVAL '4 days' + INTERVAL '19 hours'),

-- Активні перебування в залі прямо зараз (end_datetime = NULL)
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234509), 8, NOW() - INTERVAL '30 minutes', NULL),
((SELECT member_id FROM fitness_center.members WHERE phone_number = 380671234510), 3, NOW() - INTERVAL '15 minutes', NULL);





-- =============================================================================
-- 4) ПЕРЕВІРКА ОБМЕЖЕНЬ (CONSTRAINT TESTING)
-- Примітка: Кожен із цих запитів МАЄ повертати помилку (Constraint Violation)
-- =============================================================================

-- 4.1. Перевірка CHECK (capacity > 0) в таблиці Rooms
-- Спроба створити зал із нульовою місткістю
INSERT INTO fitness_center.rooms (name_room, capacity) 
VALUES ('Invalid Room', 0);

-- 4.2. Перевірка CHECK (end_time > start_time) в таблиці Schedule
-- Спроба поставити час закінчення заняття раніше за час початку
INSERT INTO fitness_center.schedule (room_id, class_id, trainer_id, day_of_week, start_time, end_time)
VALUES (1, 1, 1, 'monday', '10:00:00', '09:00:00');

-- 4.3. Перевірка XOR CHECK в таблиці Schedule (дата vs день тижня)
-- Спроба вставити запис, де вказано і дату, і день тижня одночасно
INSERT INTO fitness_center.schedule (room_id, class_id, trainer_id, date_schedule, day_of_week, start_time, end_time)
VALUES (1, 1, 1, CURRENT_DATE, 'monday', '10:00:00', '11:00:00');

-- 4.4. Перевірка FOREIGN KEY цілісності
-- Спроба записати клієнта на неіснуюче заняття (schedule_id = 99999)
INSERT INTO fitness_center.class_registrations (schedule_id, member_id)
VALUES (99999, (SELECT member_id FROM fitness_center.members LIMIT 1));

-- 4.5. Перевірка UNIQUE (дублікат унікального поля у Members)
-- Спроба додати нового клієнта з номером телефону, який вже існує в базі
INSERT INTO fitness_center.members (first_name, last_name, phone_number) 
VALUES ('Petro', 'Sydorenko', 380671234501);

-- 4.6. Перевірка CHECK (end_datetime >= start_datetime) в Locations
-- Спроба зафіксувати вихід із залу раніше, ніж вхід
INSERT INTO fitness_center.locations (member_id, room_id, start_datetime, end_datetime)
VALUES (
  (SELECT member_id FROM fitness_center.members LIMIT 1),
  1,
  NOW(),
  NOW() - INTERVAL '1 hour'
);



-- =============================================================================
-- ОНОВЛЕННЯ ДАНИХ (UPDATE STATEMENTS)
-- =============================================================================

-- 1. Зміна ціни тарифного плану в довіднику memberships
-- Бізнес-кейс: Проведення акції або корекція цін (зниження вартості 'premium' абонемента)
UPDATE fitness_center.memberships
SET price_membership = 8000
WHERE type_membership = 'premium';


-- 2. Зміна статусу інвентарю після технічного обслуговування
-- Бізнес-кейс: Spin Bike пройшов ремонт і повертається в експлуатацію.
UPDATE fitness_center.equipment
SET status_equipment = 'available'
WHERE status_equipment = 'under repair' 
  AND name_equipment = 'Spin Bike';


-- 3. Фіксація виходу клієнта із залу (закриття поточного відвідування в Locations)
-- Бізнес-кейс: Клієнт залікував турнікет/завершив тренування, проставляємо end_datetime замість NULL
UPDATE fitness_center.locations
SET end_datetime = NOW()
WHERE member_id = (
    SELECT member_id 
    FROM fitness_center.members 
    WHERE phone_number = 380671234509
) 
AND end_datetime IS NULL;



-- =============================================================================
-- ВИДАЛЕННЯ ДАНИХ (DELETE STATEMENTS)
-- =============================================================================

-- 1. Видалення списаного/застарілого обладнання (таблиця Equipment)
-- Бізнес-кейс: Інвентар більше не придатний до використання ('decommissioned')
DELETE FROM fitness_center.equipment
WHERE status_equipment = 'decommissioned';


-- 2. Скасування запису клієнта на конкретне групове заняття (ClassRegistrations)
-- Бізнес-кейс: Клієнт скасував свій запис на заняття
DELETE FROM fitness_center.class_registrations
WHERE schedule_id = 1 
  AND member_id = (
      SELECT member_id 
      FROM fitness_center.members 
      WHERE phone_number = 380671234501
  );


-- 3. Видалення профілю клієнта (Members) — перевірка каскадного видалення!
-- Бізнес-кейс: Клієнт попросив видалити його акаунт.
-- Завдяки ON DELETE CASCADE автоматично видаляються,
-- пов'язані записи з Subscriptions, Attendances, ClassRegistrations, Progress, Locations тощо.
DELETE FROM fitness_center.members
WHERE phone_number = 380671234515; -- Taras Verbytskyi



