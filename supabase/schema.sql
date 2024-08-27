
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "public";

ALTER SCHEMA "public" OWNER TO "pg_database_owner";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "plv8" WITH SCHEMA "pg_catalog";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."custom_access_token_hook"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
  declare
    claims jsonb;
    user_role varchar(50);
  begin
    -- Fetch the user role in the user_roles table
    select role into user_role from public.user_roles where user_id = (event->>'user_id')::uuid;

    claims := event->'claims';

    if user_role is not null then
      -- Set the claim
      claims := jsonb_set(claims, '{user_role}', to_jsonb(user_role));
    else
      claims := jsonb_set(claims, '{user_role}', 'null');
    end if;

    -- Update the 'claims' object in the original event
    event := jsonb_set(event, '{claims}', claims);

    -- Return the modified or original event
    return event;
  end;
$$;

ALTER FUNCTION "public"."custom_access_token_hook"("event" "jsonb") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_archive_with_link"("lathigh" bigint, "latlow" bigint, "lnghigh" bigint, "lnglow" bigint, "mytype" "text") RETURNS TABLE("id" bigint, "name" "text", "size" integer, "price" integer, "description" "text", "lat" "text", "lng" "text")
    LANGUAGE "sql"
    AS $$ select apartments_archive.id, apartments_archive.name, apartments_archive.size, apartments_archive.price, ad_details.description, ad_details.lat, ad_details.lng from apartments_archive inner join ad_details on apartments_archive.link_id = ad_details.id where apartments_archive.type = myType and ad_details.lat != '' and ad_details.lng != '' and cast (ad_details.lat as decimal) < latHigh and cast (ad_details.lat as decimal) > latLow and cast (ad_details.lng as decimal) < lngHigh and cast (ad_details.lng as decimal) > lngLow order by apartments_archive.id $$;

ALTER FUNCTION "public"."get_archive_with_link"("lathigh" bigint, "latlow" bigint, "lnghigh" bigint, "lnglow" bigint, "mytype" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_archived_aps"() RETURNS TABLE("id" bigint, "ad_details" "text")
    LANGUAGE "sql"
    AS $$ select apartments_archive.id, ad_details from apartments inner join apartments_archive on apartments_archive.name = apartments.name inner join ad_details on apartments.id = ad_details.ad_id where ad_details.type = 'apartment' order by apartments_archive.id asc $$;

ALTER FUNCTION "public"."get_archived_aps"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_archived_rentals"() RETURNS TABLE("id" bigint, "ad_details" "text")
    LANGUAGE "sql"
    AS $$ select apartments_archive.id, ad_details from rentals inner join apartments_archive on apartments_archive.name = rentals.name inner join ad_details on rentals.id = ad_details.ad_id where ad_details.type = 'rental' order by apartments_archive.id asc $$;

ALTER FUNCTION "public"."get_archived_rentals"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_detail_duplicates"() RETURNS integer[]
    LANGUAGE "plv8"
    AS $$
    var original = {};
    var duplicates = [];
    var selected = plv8.execute(`SELECT * FROM ad_details ORDER BY id`);

    for (var index = 0; index < selected.length; index++) {
      if(original[selected.ad_id]) {
        duplicates.push(selected[index].id)
      } else {
        original[selected.ad_id] = selected[index].id;
      }
    }
    

    return duplicates;
$$;

ALTER FUNCTION "public"."get_detail_duplicates"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_distinct_city_part"() RETURNS SETOF "text"
    LANGUAGE "sql"
    AS $$ select distinct(city_part) from apartments_archive where link_id is not null order by city_part $$;

ALTER FUNCTION "public"."get_distinct_city_part"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_duplicates"("table_name" "text") RETURNS integer[]
    LANGUAGE "plv8"
    AS $_$
    var original = {};
    var duplicates = [];
    var selected = plv8.execute(`SELECT * FROM ${table_name} WHERE name IN (SELECT name FROM ${table_name} GROUP BY name HAVING COUNT(*) > 1) ORDER BY name, id DESC`);

    for (var index = 0; index < selected.length; index++) {
        var identifier = `${selected[index].name}${selected[index].size}${selected[index].room_number}${selected[index].city_part}`.replace(/\s/g, '');
      if(original[identifier]) {
        duplicates.push(selected[index].id)
      } else {
        original[identifier] = selected[index].id;
      }
    }
    

    return duplicates;
$_$;

ALTER FUNCTION "public"."get_duplicates"("table_name" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."ad_details" (
    "id" bigint NOT NULL,
    "type" "text",
    "ad_id" bigint,
    "lng" numeric(10,7),
    "lat" numeric(10,7),
    "floor" bigint,
    "floor_limit" bigint,
    "built_year" bigint,
    "listed" boolean,
    "built_state" "text",
    "furnished" boolean,
    "lift" boolean,
    "terrace" boolean,
    "cellar" boolean,
    "intercom" boolean,
    "heating" "text",
    "parking" boolean,
    "parking_type" "text",
    "parking_level" bigint,
    "parking_entrance" "text",
    "rooms" numeric,
    "baths" numeric,
    "pets" boolean,
    "inner_state" "text",
    "description" "text",
    "additional" "text",
    "security" "text",
    "technical" "text",
    "rest" "text",
    "parking_ownership" boolean
);

ALTER TABLE "public"."ad_details" OWNER TO "postgres";

ALTER TABLE "public"."ad_details" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."ad_details_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."apartments" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" double precision,
    "room_number" double precision,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "average_price" double precision,
    "room_ratio" double precision,
    "is_details" boolean
);

ALTER TABLE "public"."apartments" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."apartments_archive" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" double precision,
    "room_number" bigint,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_signed" "date",
    "link" "text",
    "source_id" "text",
    "is_active" boolean,
    "type" "text",
    "comm_type" "text",
    "link_id" integer
);

ALTER TABLE "public"."apartments_archive" OWNER TO "postgres";

ALTER TABLE "public"."apartments_archive" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."apartments_archive_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE "public"."apartments" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."apartments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" integer NOT NULL,
    "name" "text"
);

ALTER TABLE "public"."cities" OWNER TO "postgres";

CREATE SEQUENCE IF NOT EXISTS "public"."cities_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."cities_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."cities_id_seq" OWNED BY "public"."cities"."id";

CREATE TABLE IF NOT EXISTS "public"."commercials" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" bigint,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "is_details" boolean,
    "comm_type" "text"
);

ALTER TABLE "public"."commercials" OWNER TO "postgres";

ALTER TABLE "public"."commercials" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."commercials_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."commercials_rentals" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" bigint,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "is_details" boolean,
    "comm_type" "text"
);

ALTER TABLE "public"."commercials_rentals" OWNER TO "postgres";

ALTER TABLE "public"."commercials_rentals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."commercials_rentals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."contract_report" (
    "id" integer NOT NULL,
    "sum_price" numeric,
    "sum_size" integer,
    "count" integer,
    "max_price" numeric,
    "max_size" integer,
    "min_price" numeric,
    "min_size" integer,
    "average_meter_price" numeric,
    "max_average" numeric,
    "min_average" numeric,
    "date_from" "date",
    "date_to" "date",
    "municipality" integer,
    "type" "text"
);

ALTER TABLE "public"."contract_report" OWNER TO "postgres";

CREATE SEQUENCE IF NOT EXISTS "public"."contract_report_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."contract_report_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."contract_report_id_seq" OWNED BY "public"."contract_report"."id";

CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "id" bigint NOT NULL,
    "lng" double precision,
    "lat" double precision,
    "municipality" "text",
    "city" "text",
    "price" double precision,
    "size" bigint,
    "date" "date",
    "transaction" "text",
    "subtype" "text",
    "type" "text",
    "external_property_id" bigint,
    "external_contract_id" bigint,
    "parking_link" bigint,
    "location_id" bigint,
    "for_view" boolean
);

ALTER TABLE "public"."contracts" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."garages" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" bigint,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "is_details" boolean
);

ALTER TABLE "public"."garages" OWNER TO "postgres";

ALTER TABLE "public"."garages" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."garages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."garages_rentals" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" bigint,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "is_details" boolean
);

ALTER TABLE "public"."garages_rentals" OWNER TO "postgres";

ALTER TABLE "public"."garages_rentals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."garages_rentals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."municipalities" (
    "id" integer NOT NULL,
    "name" "text",
    "city_id" integer
);

ALTER TABLE "public"."municipalities" OWNER TO "postgres";

CREATE SEQUENCE IF NOT EXISTS "public"."municipalities_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."municipalities_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."municipalities_id_seq" OWNED BY "public"."municipalities"."id";

CREATE TABLE IF NOT EXISTS "public"."pie_contract_report" (
    "id" integer NOT NULL,
    "size_map" integer[],
    "price_map" numeric[],
    "average_price_map" numeric[],
    "date_from" "date",
    "date_to" "date",
    "municipality" integer,
    "type" "text"
);

ALTER TABLE "public"."pie_contract_report" OWNER TO "postgres";

CREATE SEQUENCE IF NOT EXISTS "public"."pie_contract_report_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."pie_contract_report_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."pie_contract_report_id_seq" OWNED BY "public"."pie_contract_report"."id";

CREATE TABLE IF NOT EXISTS "public"."price_action" (
    "id" bigint NOT NULL,
    "price_up" boolean,
    "city" "text",
    "source_id" "text",
    "price_change" bigint,
    "creation_date" "date",
    "type" "text",
    "price" bigint,
    "apartment_id" bigint
);

ALTER TABLE "public"."price_action" OWNER TO "postgres";

ALTER TABLE "public"."price_action" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."price_action_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."rentals" (
    "id" bigint NOT NULL,
    "name" "text",
    "price" bigint,
    "size" bigint,
    "room_number" double precision,
    "city" "text",
    "city_part" "text",
    "date_created" "date",
    "date_updated" "date",
    "date_signed" "date",
    "is_agency" boolean,
    "link" "text",
    "source_id" "text",
    "average_price" numeric,
    "room_ratio" numeric,
    "is_details" boolean
);

ALTER TABLE "public"."rentals" OWNER TO "postgres";

ALTER TABLE "public"."rentals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."rentals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."short_calendar" (
    "id" bigint NOT NULL,
    "date" "date" NOT NULL,
    "booked" "jsonb"
);

ALTER TABLE "public"."short_calendar" OWNER TO "postgres";

ALTER TABLE "public"."short_calendar" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."short_calendar_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."short_rentals" (
    "id" bigint NOT NULL,
    "price" bigint,
    "address" "text",
    "size" bigint,
    "link" "text",
    "rating" "text",
    "room_number" bigint,
    "name" "text",
    "is_calendar" boolean,
    "date_created" "date",
    "date_updated" "date",
    "source" "text",
    "amenities" "jsonb",
    "is_parking" boolean,
    "parking_price" bigint,
    "lat" double precision,
    "lng" double precision
);

ALTER TABLE "public"."short_rentals" OWNER TO "postgres";

ALTER TABLE "public"."short_rentals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."short_rentals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" character varying(50) NOT NULL
);

ALTER TABLE "public"."user_roles" OWNER TO "postgres";

ALTER TABLE "public"."user_roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE ONLY "public"."cities" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."cities_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."contract_report" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."contract_report_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."municipalities" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."municipalities_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."pie_contract_report" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."pie_contract_report_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."ad_details"
    ADD CONSTRAINT "ad_details_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."ad_details"
    ADD CONSTRAINT "ad_details_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."apartments_archive"
    ADD CONSTRAINT "apartments_archive_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."apartments"
    ADD CONSTRAINT "apartments_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."commercials"
    ADD CONSTRAINT "commercials_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."commercials"
    ADD CONSTRAINT "commercials_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."commercials_rentals"
    ADD CONSTRAINT "commercials_rentals_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."commercials_rentals"
    ADD CONSTRAINT "commercials_rentals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."contract_report"
    ADD CONSTRAINT "contract_report_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."contracts"
    ADD CONSTRAINT "contracts_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."garages"
    ADD CONSTRAINT "garages_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."garages"
    ADD CONSTRAINT "garages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."garages_rentals"
    ADD CONSTRAINT "garages_rentals_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."garages_rentals"
    ADD CONSTRAINT "garages_rentals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."municipalities"
    ADD CONSTRAINT "municipalities_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."pie_contract_report"
    ADD CONSTRAINT "pie_contract_report_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."price_action"
    ADD CONSTRAINT "price_action_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."price_action"
    ADD CONSTRAINT "price_action_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."rentals"
    ADD CONSTRAINT "rentals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."short_calendar"
    ADD CONSTRAINT "short_calendar_date_key" UNIQUE ("date");

ALTER TABLE ONLY "public"."short_calendar"
    ADD CONSTRAINT "short_calendar_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."short_calendar"
    ADD CONSTRAINT "short_calendar_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."short_rentals"
    ADD CONSTRAINT "short_rentals_id_key" UNIQUE ("id");

ALTER TABLE ONLY "public"."short_rentals"
    ADD CONSTRAINT "short_rentals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_role_key" UNIQUE ("user_id", "role");

ALTER TABLE ONLY "public"."apartments_archive"
    ADD CONSTRAINT "details_id" FOREIGN KEY ("link_id") REFERENCES "public"."ad_details"("id");

ALTER TABLE ONLY "public"."contract_report"
    ADD CONSTRAINT "municipality_id" FOREIGN KEY ("municipality") REFERENCES "public"."municipalities"("id");

ALTER TABLE ONLY "public"."pie_contract_report"
    ADD CONSTRAINT "municipality_id" FOREIGN KEY ("municipality") REFERENCES "public"."municipalities"("id");

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

CREATE POLICY "Allow auth admin to read user roles" ON "public"."user_roles" FOR SELECT TO "supabase_auth_admin" USING (true);

CREATE POLICY "Enable  access for all users" ON "public"."cities" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."ad_details" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."apartments" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."apartments_archive" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."commercials" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."commercials_rentals" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."contract_report" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."garages" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."garages_rentals" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."municipalities" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."pie_contract_report" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."price_action" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."rentals" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."short_calendar" USING (true);

CREATE POLICY "Enable access for all users" ON "public"."short_rentals" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."contracts" FOR SELECT TO "authenticated" USING (true);

ALTER TABLE "public"."ad_details" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."apartments" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."apartments_archive" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."cities" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."commercials" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."commercials_rentals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contract_report" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."contracts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."garages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."garages_rentals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."municipalities" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."pie_contract_report" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."price_action" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."rentals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."short_calendar" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."short_rentals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "supabase_auth_admin";

REVOKE ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") TO "supabase_auth_admin";

GRANT ALL ON FUNCTION "public"."get_archive_with_link"("lathigh" bigint, "latlow" bigint, "lnghigh" bigint, "lnglow" bigint, "mytype" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_archive_with_link"("lathigh" bigint, "latlow" bigint, "lnghigh" bigint, "lnglow" bigint, "mytype" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_archive_with_link"("lathigh" bigint, "latlow" bigint, "lnghigh" bigint, "lnglow" bigint, "mytype" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."get_archived_aps"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_archived_aps"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_archived_aps"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_archived_rentals"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_archived_rentals"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_archived_rentals"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_detail_duplicates"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_detail_duplicates"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_detail_duplicates"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_distinct_city_part"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_distinct_city_part"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_distinct_city_part"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_duplicates"("table_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_duplicates"("table_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_duplicates"("table_name" "text") TO "service_role";

GRANT ALL ON TABLE "public"."ad_details" TO "anon";
GRANT ALL ON TABLE "public"."ad_details" TO "authenticated";
GRANT ALL ON TABLE "public"."ad_details" TO "service_role";

GRANT ALL ON SEQUENCE "public"."ad_details_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."ad_details_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."ad_details_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."apartments" TO "anon";
GRANT ALL ON TABLE "public"."apartments" TO "authenticated";
GRANT ALL ON TABLE "public"."apartments" TO "service_role";

GRANT ALL ON TABLE "public"."apartments_archive" TO "anon";
GRANT ALL ON TABLE "public"."apartments_archive" TO "authenticated";
GRANT ALL ON TABLE "public"."apartments_archive" TO "service_role";

GRANT ALL ON SEQUENCE "public"."apartments_archive_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."apartments_archive_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."apartments_archive_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."apartments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."apartments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."apartments_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."cities" TO "anon";
GRANT ALL ON TABLE "public"."cities" TO "authenticated";
GRANT ALL ON TABLE "public"."cities" TO "service_role";

GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."commercials" TO "anon";
GRANT ALL ON TABLE "public"."commercials" TO "authenticated";
GRANT ALL ON TABLE "public"."commercials" TO "service_role";

GRANT ALL ON SEQUENCE "public"."commercials_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."commercials_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."commercials_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."commercials_rentals" TO "anon";
GRANT ALL ON TABLE "public"."commercials_rentals" TO "authenticated";
GRANT ALL ON TABLE "public"."commercials_rentals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."commercials_rentals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."commercials_rentals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."commercials_rentals_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."contract_report" TO "anon";
GRANT ALL ON TABLE "public"."contract_report" TO "authenticated";
GRANT ALL ON TABLE "public"."contract_report" TO "service_role";

GRANT ALL ON SEQUENCE "public"."contract_report_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."contract_report_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."contract_report_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."contracts" TO "anon";
GRANT ALL ON TABLE "public"."contracts" TO "authenticated";
GRANT ALL ON TABLE "public"."contracts" TO "service_role";

GRANT ALL ON TABLE "public"."garages" TO "anon";
GRANT ALL ON TABLE "public"."garages" TO "authenticated";
GRANT ALL ON TABLE "public"."garages" TO "service_role";

GRANT ALL ON SEQUENCE "public"."garages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."garages_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."garages_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."garages_rentals" TO "anon";
GRANT ALL ON TABLE "public"."garages_rentals" TO "authenticated";
GRANT ALL ON TABLE "public"."garages_rentals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."garages_rentals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."garages_rentals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."garages_rentals_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."municipalities" TO "anon";
GRANT ALL ON TABLE "public"."municipalities" TO "authenticated";
GRANT ALL ON TABLE "public"."municipalities" TO "service_role";

GRANT ALL ON SEQUENCE "public"."municipalities_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."municipalities_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."municipalities_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."pie_contract_report" TO "anon";
GRANT ALL ON TABLE "public"."pie_contract_report" TO "authenticated";
GRANT ALL ON TABLE "public"."pie_contract_report" TO "service_role";

GRANT ALL ON SEQUENCE "public"."pie_contract_report_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."pie_contract_report_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."pie_contract_report_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."price_action" TO "anon";
GRANT ALL ON TABLE "public"."price_action" TO "authenticated";
GRANT ALL ON TABLE "public"."price_action" TO "service_role";

GRANT ALL ON SEQUENCE "public"."price_action_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."price_action_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."price_action_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."rentals" TO "anon";
GRANT ALL ON TABLE "public"."rentals" TO "authenticated";
GRANT ALL ON TABLE "public"."rentals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."rentals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."rentals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."rentals_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."short_calendar" TO "anon";
GRANT ALL ON TABLE "public"."short_calendar" TO "authenticated";
GRANT ALL ON TABLE "public"."short_calendar" TO "service_role";

GRANT ALL ON SEQUENCE "public"."short_calendar_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."short_calendar_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."short_calendar_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."short_rentals" TO "anon";
GRANT ALL ON TABLE "public"."short_rentals" TO "authenticated";
GRANT ALL ON TABLE "public"."short_rentals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."short_rentals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."short_rentals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."short_rentals_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."user_roles" TO "service_role";
GRANT ALL ON TABLE "public"."user_roles" TO "supabase_auth_admin";

GRANT ALL ON SEQUENCE "public"."user_roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_roles_id_seq" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
