CREATE TYPE apartment_detail_profitability AS (
    id bigint,
    ais_photo boolean,
    size integer,
    price integer,
    city_part text,
    average_price float,
    date_signed date,
    is_details boolean,
    detail_id bigint,
    detail_type text,
    detail_ad_id bigint,
    detail_lng float,
    detail_lat float,
    detail_listed  boolean,
    detail_description text,
    profitability_id bigint,
    profitability_competition_trend float,
    profitability_rental_count integer,
    profitability_average_competition float,
    profitability_ad_id bigint
);

CREATE OR REPLACE FUNCTION get_apartments_with_details_and_profitability()
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
    d.description AS detail_description,
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
LIMIT
  20;
END;
$$ LANGUAGE plpgsql;

