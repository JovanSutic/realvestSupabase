CREATE TABLE IF NOT EXISTS "public"."ad_profitability"(
    "id" serial primary key NOT NULL,
    "ad_id" bigint NOT NULL,
    "type" "text" NOT NULL,
    "averageCompetition" float,
    "minCompetition" float,
    "maxCompetition" float,
    "competitionCount" integer,
    "unsoldCompetitionCount" integer,
    "cityCountSold" integer,
    "cityCountAds" integer,
    "competitionTrend" float,
    "averageRental" float,
    "minRental" float,
    "maxRental" float,
    "rentalCount" integer,
    "activeRentalCount" integer
)