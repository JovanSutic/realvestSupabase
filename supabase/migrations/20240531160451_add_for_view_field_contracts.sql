alter table contracts add for_view boolean;
update contracts set for_view = true where for_view is null;
update contracts set for_view = false where subtype = 'Parking internal' and TO_NUMBER(
        size,
        '99G999D9S'
    ) < 8;
update contracts set for_view = false where subtype = 'Parking internal' and TO_NUMBER(
        price,
        '99G999D9S'
    ) < 1000;