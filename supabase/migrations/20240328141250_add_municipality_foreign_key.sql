ALTER TABLE contract_report 
ADD CONSTRAINT municipality_id 
FOREIGN KEY (municipality) 
REFERENCES municipalities (id);