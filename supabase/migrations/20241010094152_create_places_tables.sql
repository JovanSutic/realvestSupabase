CREATE TABLE IF NOT EXISTS "public"."places" (
"id"  serial primary key NOT NULL,
"name" varchar(256),
"type" varchar(256),
"address" varchar(256),
"lat" float,
"lng" float,
"city_id" bigint,
constraint "city_id"
     foreign key ("city_id") 
     REFERENCES "cities" ("id")
);

CREATE TABLE IF NOT EXISTS "public"."adds_places" (
"id"  serial primary key NOT NULL,
"distance" float,
"duration" float,
"place_id" bigint,
constraint "place_id"
     foreign key ("place_id") 
     REFERENCES "places" ("id"),
"add_id" bigint,
constraint "add_id"
     foreign key ("add_id") 
     REFERENCES "apartments" ("id")
);

ALTER TABLE user_roles
ALTER COLUMN count
SET DATA TYPE integer[]
USING ARRAY[count];