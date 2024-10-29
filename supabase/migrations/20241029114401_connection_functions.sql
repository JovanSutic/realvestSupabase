 CREATE OR REPLACE FUNCTION "public"."get_archived_aps"(city_id INTEGER) RETURNS TABLE("id" bigint, "ad_details" "text")
    LANGUAGE "sql"
    AS $$ select apartments_archive.id, ad_details from apartments inner join apartments_archive on apartments_archive.name = apartments.name inner join ad_details on apartments.id = ad_details.ad_id where ad_details.type = 'apartment' and apartments.city = city_id order by apartments_archive.id asc $$;
 
 
 CREATE OR REPLACE FUNCTION "public"."get_archived_rentals"(city_id INTEGER) RETURNS TABLE("id" bigint, "ad_details" "text")
    LANGUAGE "sql"
    AS $$ select apartments_archive.id, ad_details from rentals inner join apartments_archive on apartments_archive.name = rentals.name inner join ad_details on rentals.id = ad_details.ad_id where ad_details.type = 'rental' and rentals.city = city_id order by apartments_archive.id asc $$;

CREATE OR REPLACE FUNCTION get_distinct_city_part(city_id INT)
RETURNS SETOF TEXT AS $$
SELECT DISTINCT city_part 
FROM apartments_archive 
WHERE link_id IS NOT NULL 
  AND city_id = $1
ORDER BY city_part;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_homepage_potential(city_id INTEGER)
RETURNS SETOF apartment_detail_profitability AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.is_photo,
        a.size,
        a.price,
        a.city_part,
        a.average_price,
        a.date_signed,
        a.is_details,
        d.id AS detail_id,
        d.type AS detail_type,
        d.ad_id AS detail_ad_id,
        d.lng AS detail_lng,
        d.lat AS detail_lat,
        d.listed AS detail_listed,
        p.id AS profitability_id,
        p.competition_trend AS profitability_competition_trend,
        p.rental_count AS profitability_rental_count,
        p.average_competition AS profitability_average_competition,
        p.ad_id AS profitability_ad_id,
        p.average_rental AS profitability_average_rental
    FROM
        apartments a
        JOIN ad_details d ON a.id = d.ad_id
        JOIN ad_profitability p ON a.id = p.ad_id
   WHERE
            a.is_photo = true
            AND d.type = 'apartment'
            AND d.parking = true
            AND d.lift = true
            AND p.competition_trend > 0.05
            AND d.floor is not null
            AND d.floor != d.floor_limit
            AND  a.average_price < p.max_competition / 2.1
            AND a.city = city_id
        ORDER BY
            a.date_created DESC, a.date_signed, a.name
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_homepage_rental(city_id INTEGER)
RETURNS SETOF apartment_detail_profitability AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id,
        a.is_photo,
        a.size,
        a.price,
        a.city_part,
        a.average_price,
        a.date_signed,
        a.is_details,
        d.id AS detail_id,
        d.type AS detail_type,
        d.ad_id AS detail_ad_id,
        d.lng AS detail_lng,
        d.lat AS detail_lat,
        d.listed AS detail_listed,
        p.id AS profitability_id,
        p.competition_trend AS profitability_competition_trend,
        p.rental_count AS profitability_rental_count,
        p.average_competition AS profitability_average_competition,
        p.ad_id AS profitability_ad_id,
        p.average_rental AS profitability_average_rental
    FROM
        apartments a
        JOIN ad_details d ON a.id = d.ad_id
        JOIN ad_profitability p ON a.id = p.ad_id
  WHERE
            a.is_photo = true
            AND d.type = 'apartment'
            AND  p.rental_count > 3
            AND (p.average_rental * 135) > a.average_price
            AND a.city = city_id
        ORDER BY
        p.average_rental ASC, a.date_signed, a.name
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- ALTER TYPE apartment_detail_profitability ADD ATTRIBUTE profitability_average_rental float


CREATE OR REPLACE FUNCTION get_apartments_with_details_and_profitability(
  p_limit INTEGER,
  p_offset INTEGER,
  size_from INTEGER,
  size_to INTEGER,
  price_from INTEGER,
  price_to INTEGER,
  m2_price_from INTEGER,
  m2_price_to INTEGER,
  rental INTEGER,
  trend FLOAT,
  part TEXT,
  low_price TEXT,  -- Change from BOOLEAN to TEXT
  city_id INT,  -- New parameter for city ID
  p_sort_column TEXT DEFAULT 'a.id',
  p_sort_order TEXT DEFAULT 'ASC'
)
RETURNS SETOF apartment_detail_profitability AS $$
DECLARE
  sql_query TEXT;
BEGIN
  sql_query := format(
    'SELECT
      a.id,
      a.is_photo,
      a.size,
      a.price,
      a.city_part,
      a.average_price,
      a.date_signed,
      a.is_details,
      d.id AS detail_id,
      d.type AS detail_type,
      d.ad_id AS detail_ad_id,
      d.lng AS detail_lng,
      d.lat AS detail_lat,
      d.listed AS detail_listed,
      p.id AS profitability_id,
      p.competition_trend AS profitability_competition_trend,
      p.rental_count AS profitability_rental_count,
      p.average_competition AS profitability_average_competition,
      p.ad_id AS profitability_ad_id,
      p.average_rental AS profitability_average_rental
    FROM
      apartments a
    JOIN ad_details d ON a.id = d.ad_id
    JOIN ad_profitability p ON a.id = p.ad_id
    WHERE
      a.is_photo = true
      AND d.type = ''apartment''
      AND a.size >= $1
      AND a.size <= $2
      AND a.price >= $3
      AND a.price <= $4
      AND a.average_price >= $5
      AND a.average_price <= $6
      AND p.rental_count >= $7
      AND p.competition_trend >= $8
      AND (a.city = CAST($11 AS INTEGER) OR $11 IS NULL)
      AND ($9 = ''all'' OR a.city_part = $9)
      AND (LOWER($10) = ''true'' OR a.average_price < p.average_competition)
    ORDER BY
      %I %s, a.name
    LIMIT $12 OFFSET $13',
    p_sort_column, p_sort_order
  );

  RETURN QUERY EXECUTE sql_query
  USING size_from, size_to, price_from, price_to, m2_price_from, m2_price_to, rental, trend, part, low_price, city_id, p_limit, p_offset;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION get_apartments_count(
    size_from INTEGER,
    size_to INTEGER,
    price_from INTEGER,
    price_to INTEGER,
    m2_price_from INTEGER,
    m2_price_to INTEGER,
    rental INTEGER,
    trend FLOAT,
    part TEXT,
    low_price TEXT,
    city_id INT
)
RETURNS BIGINT AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Get the total count of records that match the filters
    SELECT COUNT(*)
    INTO total_count
    FROM
        apartments a
        JOIN ad_details d ON a.id = d.ad_id
        JOIN ad_profitability p ON a.id = p.ad_id
    WHERE
        a.is_photo = true
        AND d.type = 'apartment'
        AND a.size >= size_from
        AND a.size <= size_to
        AND a.price >= price_from
        AND a.price <= price_to
        AND a.average_price >= m2_price_from
        AND a.average_price <= m2_price_to
        AND p.rental_count >= rental
        AND p.competition_trend >= trend
        AND (part = 'all' OR a.city_part = part)
        AND a.city = city_id
        AND (LOWER(low_price) = 'true' OR a.average_price < p.average_competition);  -- Include the low_price condition

    RETURN total_count;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION get_distinct_photo_apartments(city_id INT)
RETURNS TABLE (apartment_id BIGINT) AS $$
BEGIN
  RETURN QUERY 
    SELECT DISTINCT p.apartment_id 
    FROM photos p
    JOIN apartments a ON p.apartment_id = a.id
    WHERE a.city = city_id;
END;
$$ LANGUAGE plpgsql;