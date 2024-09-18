CREATE TYPE apartment_detail_profitability AS (
    id bigint,
    is_photo boolean,
    size float,
    price bigint,
    city_part text,
    average_price float,
    date_signed date,
    is_details boolean,
    detail_id bigint,
    detail_type text,
    detail_ad_id bigint,
    detail_lng numeric,
    detail_lat numeric,
    detail_listed  boolean,
    profitability_id integer,
    profitability_competition_trend float,
    profitability_rental_count integer,
    profitability_average_competition float,
    profitability_ad_id bigint
);

-- DROP FUNCTION get_apartments_with_details_and_profitability(
--     integer, integer, integer, integer, integer, integer, integer, integer, integer, float, text
-- );
-- DROP FUNCTION get_apartments_count(
--     integer, integer, integer, integer, integer, integer, integer, float, text
-- );

CREATE OR REPLACE FUNCTION get_apartments_with_details_and_profitability(p_limit INTEGER,
    p_offset INTEGER, size_from INTEGER, size_to INTEGER, price_from INTEGER, price_to INTEGER, m2_price_from INTEGER, m2_price_to INTEGER, rental INTEGER, trend float, part TEXT)
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
    p.ad_id AS profitability_ad_id
FROM
  apartments a
  JOIN ad_details d ON a.id = d.ad_id
  JOIN ad_profitability p ON a.id = p.ad_id
WHERE
  a.is_photo = true
  AND d.type = 'apartment'
  AND a.size > size_from
  AND a.size < size_to
  AND a.price > price_from
  AND a.price < price_to
  AND a.average_price > m2_price_from
  AND a.average_price < m2_price_to
  AND p.rental_count >= rental
  AND p.competition_trend >= trend
  AND (part = 'all' OR a.city_part = part)
ORDER BY
  a.id
LIMIT p_limit 
OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_apartments_count(size_from INTEGER, size_to INTEGER, price_from INTEGER, price_to INTEGER, m2_price_from INTEGER, m2_price_to INTEGER, rental INTEGER, trend float, part TEXT)
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
        AND a.size > size_from
        AND a.size < size_to
        AND a.price > price_from
        AND a.price < price_to
        AND a.average_price > m2_price_from
        AND a.average_price < m2_price_to
        AND p.rental_count >= rental
        AND p.competition_trend >= trend
        AND (part = 'all' OR a.city_part = part);
    RETURN total_count;
END;
$$ LANGUAGE plpgsql;