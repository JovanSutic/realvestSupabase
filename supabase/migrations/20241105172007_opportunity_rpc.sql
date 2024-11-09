CREATE TABLE IF NOT EXISTS opportunities (
    id SERIAL PRIMARY KEY,
    apartment_id INTEGER REFERENCES apartments(id),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    discount INT,
    renovation VARCHAR(10),
    new_rent DECIMAL(10, 2),
    is_qualified BOOLEAN DEFAULT FALSE,
    date_created TIMESTAMP DEFAULT NOW(),
    date_qualified TIMESTAMP DEFAULT NULL
);

CREATE OR REPLACE FUNCTION get_opportunity_list(
  _size INT,
  _rental_ratio FLOAT
)
RETURNS TABLE (
  id BIGINT,
  name TEXT,
  link TEXT,
  date_created DATE,
  size INT,
  price BIGINT,
  city_part TEXT,
  average_rental FLOAT,
  rental_count INT,
  competition_trend FLOAT,
  floor INT,
  floor_limit INT,
  lat FLOAT,
  lng FLOAT,
  description TEXT,
  rent_ratio FLOAT,
  price_ratio FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.name,
    a.link,
    a.date_created,
    CAST(a.size AS INT) AS size,
    a.price,
    a.city_part,
    p.average_rental,
    p.rental_count,
    p.competition_trend,
    CAST(d.floor AS INT) AS floor,
    CAST(d.floor_limit AS INT) AS floor_limit,
    CAST(d.lat AS FLOAT) AS lat,
    CAST(d.lng AS FLOAT) AS lng,
    d.description,
    p.average_rental / a.average_price AS rent_ratio,
    p.average_competition / a.average_price AS price_ratio
  FROM
    apartments a
  JOIN ad_details d ON a.id = d.ad_id
  JOIN ad_profitability p ON a.id = p.ad_id
  WHERE
    d.type = 'apartment'
    AND a.size BETWEEN 30 AND _size
    AND p.rental_count >= 2
    AND d.floor != 0
    AND d.floor != d.floor_limit
    AND p.average_rental / a.average_price > _rental_ratio
    AND a.id NOT IN (SELECT apartment_id FROM opportunities)
  ORDER BY rent_ratio DESC;
END;
$$ LANGUAGE plpgsql;