CREATE TABLE IF NOT EXISTS "public"."ad_profitability"(
    "id" serial primary key NOT NULL,
    "average_competition" float,
    "median_competition" float,
    "min_competition" float,
    "max_competition" float,
    "competition_new_build_average" float,
    "competition_count" integer,
    "competition_new_build_count" integer,
    "city_count_sold" integer,
    "cityCountAds" integer,
    "city_average" float,
    "competition_trend" float,
    "average_rental" float,
    "min_rental" float,
    "max_rental" float,
    "rental_count" integer,
    "ad_type" varchar(50),
    "ad_id" bigint
);

-- ALTER TABLE apartments
-- ADD ad_profitability_id bigint,
-- ADD CONSTRAINT ad_profitability_id 
-- FOREIGN KEY (ad_profitability_id) 
-- REFERENCES ad_profitability (id)
-- ON DELETE SET NULL;