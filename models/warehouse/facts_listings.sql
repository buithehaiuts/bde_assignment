
WITH check_dimensions AS
(
    SELECT
        lst.*,
        CASE WHEN lst.listing_neighbourhood IN (SELECT DISTINCT lga_name FROM {{ ref('nsw_lga_stg') }}) THEN TRUE
            ELSE FALSE
        END AS exists_in_lga
    FROM {{ ref('listings_stg') }} AS lst
)

SELECT
	lst.*,
    lga.lga_code AS lga_code,
    lga.lga_name AS lga_name
FROM check_dimensions AS lst
LEFT JOIN {{ ref('nsw_lga_stg') }} AS lga
    ON lst.listing_neighbourhood = lga.lga_name
LEFT JOIN {{ ref('g01_stg') }} AS g01
    ON CAST(SUBSTRING(g01.lga_code, 4) AS INTEGER) = CAST(lga.lga_code AS INTEGER)
LEFT JOIN {{ ref('g02_stg') }} AS g02
    ON CAST(SUBSTRING(g02.lga_code, 4) AS INTEGER) = CAST(lga.lga_code AS INTEGER)
WHERE (g01.lga_code IS NOT NULL AND g02.lga_code IS NOT NULL)
