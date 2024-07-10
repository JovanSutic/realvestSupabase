alter table ad_details 
alter column lng type decimal(10,7) USING lng::decimal(10,7),
alter column lat type decimal(10,7) USING lat::decimal(10,7)