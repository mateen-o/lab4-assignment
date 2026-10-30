-- Query 3: one row per patient with the clinical and sample columns for the feature table.
-- Expected rows: 566. Every patient has exactly one sample
-- Actual rows: 566
 
SELECT
    patients.patient_id,
    patients.sex,
    patients.age_at_diagnosis,
    patients.stage,
    samples.tissue_source_site,
    samples.tmb_nonsynonymous
FROM patients
LEFT JOIN samples
    ON patients.patient_id = samples.patient_id
ORDER BY patients.patient_id;