WITH claim AS (
  SELECT
    row_num,
    service_cd,
    place_of_service AS claim_pos,
    srv_prvdr_zip_cd AS claim_zip,
    allowed_amt
  FROM `claims_table`
  WHERE row_num = 8557558
),
standard_rates AS (
  -- 👇 reuse the query from Step 3, but WITHOUT the ORDER BY
  SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    scm.primary_svc_cd AS SERVICE_CD,
    tsdc.PRODUCT_CD,
    TRIM(scm.supporting_pos_cd) AS PIPELINE_POS,
    sp.TIN_GEOGRAPHIC_AREA_CD   AS PIPELINE_GA,
    t4.GEOGRAPHIC_AREA_CD       AS RATE_GA,
    t4.SPECIALTY_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
  FROM Standard_zips sp
  JOIN `{{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_detail_view}}` t4
    ON t4.RATE_SYSTEM_CD    = sp.OVERRIDE_RATE_SYSTEM_CD
   AND t4.GEOGRAPHIC_AREA_CD = 'NONE'
  JOIN `{{ce_project}}.{{ce_dataset}}.{{cet_scsr_differentiation_criteria_view}}` tsdc
    ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
  JOIN `{{ce_project}}.{{ce_dec_dataset}}.{{ce_scm}}` scm
    ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
  WHERE scm.primary_svc_cd = '90837'
    AND t4.EXTENSION_CD = ''
    AND scm.in_scope_ind = 1
)

SELECT
  c.row_num,
  c.allowed_amt,
  sr.RATE AS candidate_rate,
  sr.PIPELINE_POS,
  c.claim_pos,
  sr.PIPELINE_GA,
  sr.RATE_GA,
  CASE
    WHEN ABS(sr.RATE - c.allowed_amt)/c.allowed_amt <= 0.05
      THEN 'CORRECT_MATCH'
    ELSE 'WRONG_MATCH'
  END AS match_flag
FROM claim c
CROSS JOIN standard_rates sr
WHERE sr.PIPELINE_POS = c.claim_pos   -- ensure POS matches
ORDER BY candidate_rate DESC;
