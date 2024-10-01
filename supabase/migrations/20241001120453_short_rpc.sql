CREATE OR REPLACE FUNCTION get_matching_short_calendar(ids integer[])
RETURNS TABLE(id bigint, date date, booked jsonb) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM short_calendar sc 
    WHERE EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(sc.booked) AS b  
        WHERE b::int = ANY(ids)
    );
END; 
$$ LANGUAGE plpgsql;