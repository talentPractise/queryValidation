WITH base AS (
    SELECT 
        RATE,
        SPECIALTY_CD,
        CASE 
            WHEN SPECIALTY_CD = @providerspecialtycode THEN 1
            ELSE 0
        END AS priority
    FROM CET_RATES
    WHERE 
        RATE_SYSTEM_CD = @ratesystemcd
        AND SERVICE_CD = @servicecd
        AND SERVICE_TYPE_CD = @servicetype
        AND GEOGRAPHIC_AREA_CD = @geographicareacd
        AND PLACE_OF_SERVICE_CD = @placeofservice
        AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
        AND CONTRACT_TYPE = 'S'
)

SELECT RATE
FROM base
ORDER BY priority DESC, RATE DESC
LIMIT 1;
