ALTER TABLE garages
DROP COLUMN source_id;

ALTER TABLE garages
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE garages
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE apartments
DROP COLUMN room_ratio;

ALTER TABLE apartments
DROP COLUMN source_id;

ALTER TABLE apartments
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE apartments
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);

ALTER TABLE apartments_archive
DROP COLUMN source_id;

ALTER TABLE apartments_archive
DROP COLUMN link;

ALTER TABLE apartments_archive
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE apartments_archive
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE commercials
DROP COLUMN source_id;

ALTER TABLE commercials
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE commercials
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE commercials_rentals
DROP COLUMN source_id;

ALTER TABLE commercials_rentals
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE commercials_rentals
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);

ALTER TABLE contracts
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE contracts
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE garages_rentals
DROP COLUMN source_id;

ALTER TABLE garages_rentals
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE garages_rentals
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE price_action
DROP COLUMN source_id;

ALTER TABLE price_action
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE price_action
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);


ALTER TABLE rentals
DROP COLUMN room_ratio;

ALTER TABLE rentals
DROP COLUMN source_id;

ALTER TABLE rentals
ALTER COLUMN city TYPE integer
USING city::integer;

ALTER TABLE rentals
ADD CONSTRAINT city_id
FOREIGN KEY (city) REFERENCES cities(id);