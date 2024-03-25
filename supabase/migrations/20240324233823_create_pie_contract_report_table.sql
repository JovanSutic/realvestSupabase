create table
pie_contract_report (
id  serial primary key,
size_map integer[],
price_map numeric[],
average_price_map numeric[],
date_from date,
date_to date,
municipality integer,
type text
);