SELECT DISTINCT
  t1.ZIP_CD,
  t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
  t1.GEOGRAPHIC_AREA_CD AS TIN_GEOGRAPHIC_AREA_CD,
  t3.GEOGRAPHIC_AREA_CD AS OVERRIDE_GEOGRAPHIC_AREA_CD,
  t3.OVERRIDE_RATE_SYSTEM_CD
FROM `{{ce_project}}.{{ce_dataset}}.{{cet_address_detail_view}}` t1
LEFT JOIN `{{ce_project}}.{{ce_dataset}}.{{cet_business_group_view}}` t2
  ON t1.provider_identification_nbr = t2.provider_identification_nbr
 AND t1.tax_identification_nbr    = t2.tax_identification_nbr
 AND t1.service_location_nbr      = t2.service_location_nbr
 AND t1.network_id                = t2.network_id
LEFT JOIN `{{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_override_view}}` t3
  ON t1.ZIP_CD         = t3.GEOGRAPHIC_AREA_CD
 AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
WHERE t2.provider_business_group_nbr IS NULL
  AND t1.ZIP_CD = '77079';   -- 👈 use claim_zip from step 1
