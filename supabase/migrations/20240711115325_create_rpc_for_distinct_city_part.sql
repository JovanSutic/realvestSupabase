create
or replace function get_distinct_city_part () returns setof text language sql as $$ select distinct(city_part) from apartments_archive where link_id is not null order by city_part $$;