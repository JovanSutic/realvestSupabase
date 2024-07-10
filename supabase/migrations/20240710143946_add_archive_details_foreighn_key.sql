ALTER TABLE apartments_archive 
ADD CONSTRAINT details_id 
FOREIGN KEY (link_id) 
REFERENCES ad_details (id);