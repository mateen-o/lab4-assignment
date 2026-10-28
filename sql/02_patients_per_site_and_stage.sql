-- Query 2: number of patients per tissue source site per tumor stage
--
-- Grain: one row per site + stage combination.
-- Expected rows: 142 (counted with SELECT DISTINCT site, stage).
-- Actual rows:   142. The patient counts add up to 566, so there was no dropped patients.

SELECT samples.tissue_source_site,
       patients.stage,
       COUNT(DISTINCT patients.patient_id) AS patient_count
FROM patients
LEFT JOIN samples ON samples.patient_id = patients.patient_id
GROUP BY samples.tissue_source_site, patients.stage
ORDER BY samples.tissue_source_site, patients.stage;