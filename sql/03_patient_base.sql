-- Query 3: one row per patient with the clinical and sample columns for the feature table.
-- Expected rows: 566. Every patient has exactly one sample
-- Actual rows: 566
-- Previous script
-- SELECT
    -- patients.patient_id,
    -- patients.sex,
    -- patients.age_at_diagnosis,
    -- patients.stage,
    -- samples.tissue_source_site,
    -- samples.tmb_nonsynonymous
-- FROM patients
-- LEFT JOIN samples
    -- ON patients.patient_id = samples.patient_id
-- ORDER BY patients.patient_id;

-- Updated script
-- Included: has_mutation_calls = 1 if the tumor has any mutation rows, 0 if it has none (4 tumors).
SELECT
    patients.patient_id,
    patients.sex,
    patients.age_at_diagnosis,
    patients.stage,
    samples.tissue_source_site,
    samples.tmb_nonsynonymous,
    CASE WHEN samples_with_mutation_calls.sample_id IS NULL THEN 0 ELSE 1 END AS has_mutation_calls
FROM patients
LEFT JOIN samples
    ON patients.patient_id = samples.patient_id
LEFT JOIN (SELECT DISTINCT sample_id FROM mutations) AS samples_with_mutation_calls
    ON samples_with_mutation_calls.sample_id = samples.sample_id
ORDER BY patients.patient_id;