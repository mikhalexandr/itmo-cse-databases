BEGIN;

-- 1. Создаём корабль
WITH new_vehicle AS (
    INSERT INTO vehicle (name, registry_code, type, crew_capacity)
    VALUES ('Discovery One', 'DISC-0001', 'spacecraft', 1)
    RETURNING id
),

-- 2. Создаём наблюдателя (Флойд)
new_observer AS (
    INSERT INTO observer (name, role, vehicle_id)
    SELECT 'Флойд', 'passenger', id
    FROM new_vehicle
    RETURNING id
),

-- 3. Создаём Солнце
new_sun AS (
    INSERT INTO celestial_body
    (name, type, has_rings, mass_kg,
     equatorial_radius_km, polar_radius_km,
     volume_km3, surface_area_km2, parent_body_id)
    VALUES
    ('Sun', 'star', false,
     1.9885e30, 695700.000000, 695700.000000,
     1.412e18, 6.087e12, NULL)
    RETURNING id
),

-- 4. Создаём Землю (родитель — Солнце)
new_earth AS (
    INSERT INTO celestial_body
    (name, type, has_rings, mass_kg,
     equatorial_radius_km, polar_radius_km,
     volume_km3, surface_area_km2, parent_body_id)
    SELECT
     'Earth', 'planet', false,
     5.9722e24, 6378.137000, 6356.752000,
     1.08321e12, 5.10072e8, id
    FROM new_sun
    RETURNING id
),

-- 5. Создаём Юпитер (родитель — Солнце)
new_jupiter AS (
    INSERT INTO celestial_body
    (name, type, has_rings, mass_kg,
     equatorial_radius_km, polar_radius_km,
     volume_km3, surface_area_km2, parent_body_id)
    SELECT
     'Jupiter', 'planet', true,
     1.8982e27, 71492.000000, 66854.000000,
     1.43128e15, 6.1419e10, id
    FROM new_sun
    RETURNING id
),

-- 6a. Поле зрения: Юпитер
new_fov_jupiter AS (
    INSERT INTO field_of_view
    (description, start_time, end_time, viewing_angle_deg, distance_km)
    VALUES
    ('Флойд наблюдает Юпитер, заслоняющий полнеба.',
     '2026-03-01 20:00:00+03',
     '2026-03-01 21:30:00+03',
     180.000,
     5000000.000)
    RETURNING id
),

-- 6b. Поле зрения: Земля
new_fov_earth AS (
    INSERT INTO field_of_view
    (description, start_time, end_time, viewing_angle_deg, distance_km)
    VALUES
    ('Флойд наблюдает Землю на фоне звёзд.',
     '2026-03-01 21:45:00+03',
     '2026-03-01 22:10:00+03',
     20.000,
     1000000.000)
    RETURNING id
),

-- 7a. Связь наблюдатель <-> FOV (Юпитер)
link_observer_fov_jupiter AS (
    INSERT INTO observer_field_of_view (observer_id, fov_id)
    SELECT o.id, f.id
    FROM new_observer o, new_fov_jupiter f
    RETURNING 1
),

-- 7b. Связь наблюдатель <-> FOV (Земля)
link_observer_fov_earth AS (
    INSERT INTO observer_field_of_view (observer_id, fov_id)
    SELECT o.id, f.id
    FROM new_observer o, new_fov_earth f
    RETURNING 1
)

-- 8. Связи FOV <-> небесные тела (каждое FOV — со своим телом)
INSERT INTO field_of_view_celestial_body (fov_id, body_id)
SELECT f.id, j.id
FROM new_fov_jupiter f, new_jupiter j
UNION ALL
SELECT f.id, e.id
FROM new_fov_earth f, new_earth e;


COMMIT;
