CREATE OR REPLACE FUNCTION get_homepage_potential()
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
            AND d.parking = true
            AND d.lift = true
            AND d.floor is not null
            AND d.floor != d.floor_limit
            AND  a.average_price < p.max_competition / 2.1
        ORDER BY
            a.date_created DESC, a.date_signed, a.name
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_homepage_rental()
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
            AND  p.rental_count > 3
            AND (p.average_rental * 135) > a.average_price
        ORDER BY
        p.average_rental ASC, a.date_signed, a.name
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;
