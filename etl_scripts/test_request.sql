-- Quick view of ALL fact data
SELECT 
    'DOCTOR' AS type,
    fda.assignment_id AS id,
    dh.finess,
    dh.nom AS hospital,
    CONCAT(dm.prenom, ' ', dm.nom) AS doctor,
    NULL AS service,
    fda.date_chargement AS date
FROM fact_doctor_assignments fda
JOIN dim_hopital dh ON fda.hopital_id = dh.hopital_id
JOIN dim_medecin dm ON fda.medecin_id = dm.medecin_id

UNION ALL

SELECT 
    'SERVICE' AS type,
    fhs.service_fact_id AS id,
    dh.finess,
    dh.nom AS hospital,
    NULL AS doctor,
    ds.service_nom AS service,
    fhs.date_chargement AS date
FROM fact_hospital_services fhs
JOIN dim_hopital dh ON fhs.hopital_id = dh.hopital_id
JOIN dim_services ds ON fhs.service_id = ds.service_id
WHERE fhs.disponible = TRUE

ORDER BY finess, type, id;