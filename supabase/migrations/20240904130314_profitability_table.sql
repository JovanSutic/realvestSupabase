CREATE TABLE IF NOT EXISTS "public"."ad_profitability"(
    "id" serial primary key NOT NULL,
    "averageCompetition" float,
    "medianCompetition" float,
    "minCompetition" float,
    "maxCompetition" float,
    "competitionNewBuildAverage" float,
    "competitionCount" integer,
    "competitionNewBuildCount" integer,
    "cityCountSold" integer,
    "cityCountAds" integer,
    "cityAverage" float,
    "competitionTrend" float,
    "averageRental" float,
    "minRental" float,
    "maxRental" float,
    "rentalCount" integer,
    "ad_type" varchar(50),
    "ad_id" bigint
);

-- ALTER TABLE apartments
-- ADD ad_profitability_id bigint,
-- ADD CONSTRAINT ad_profitability_id 
-- FOREIGN KEY (ad_profitability_id) 
-- REFERENCES ad_profitability (id)
-- ON DELETE SET NULL;

-- ALTER TABLE commercials
-- ADD ad_profitability_id bigint,
-- ADD CONSTRAINT ad_profitability_id 
-- FOREIGN KEY (ad_profitability_id) 
-- REFERENCES ad_profitability (id)
-- ON DELETE SET NULL;

-- ALTER TABLE garages
-- ADD ad_profitability_id bigint,
-- ADD CONSTRAINT ad_profitability_id 
-- FOREIGN KEY (ad_profitability_id) 
-- REFERENCES ad_profitability (id)
-- ON DELETE SET NULL;