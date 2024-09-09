CREATE TABLE IF NOT EXISTS "public"."photos"(
    "id" serial primary key NOT NULL,
    "link" text,
    "apartment_id" bigint,
    constraint "apartment_id"
     foreign key ("apartment_id") 
     REFERENCES "apartments" ("id")
);

ALTER TABLE apartments
ADD column is_photo boolean DEFAULT false;
