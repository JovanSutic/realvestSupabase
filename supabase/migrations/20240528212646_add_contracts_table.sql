create table
contracts (
id serial primary key,
lng float,
lat float,
municipality text,
city text,
price text,
size text,
date text,
transaction text,
subtype text,
type text,
external_property_id integer,
external_contract_id integer,
parking_link text,
location_id text
);