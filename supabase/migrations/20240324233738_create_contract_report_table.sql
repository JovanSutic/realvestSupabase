create table
contract_report (
id serial primary key,
sum_price numeric,
sum_size integer,
count integer,
max_price numeric,
max_size integer,
min_price numeric,
min_size integer,
average_meter_price numeric,
max_average numeric,
min_average numeric,
date_from date,
date_to date,
municipality integer,
type text
);