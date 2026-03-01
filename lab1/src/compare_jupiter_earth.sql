SELECT
  (SELECT mass_kg FROM celestial_body WHERE name = 'Jupiter')
  /
  (SELECT mass_kg FROM celestial_body WHERE name = 'Earth')
  AS mass_ratio,

  (SELECT volume_km3 FROM celestial_body WHERE name = 'Jupiter')
  /
  (SELECT volume_km3 FROM celestial_body WHERE name = 'Earth')
  AS volume_ratio,

  (SELECT equatorial_radius_km FROM celestial_body WHERE name = 'Jupiter')
  /
  (SELECT equatorial_radius_km FROM celestial_body WHERE name = 'Earth')
  AS radius_ratio;
