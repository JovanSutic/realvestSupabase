alter table contracts add for_view boolean;
update contracts set for_view = true where for_view is null;
update contracts set for_view = false where subtype = 'Parking internal' and size < 8;
update contracts set for_view = false where subtype = 'Parking internal' and size < 1000;