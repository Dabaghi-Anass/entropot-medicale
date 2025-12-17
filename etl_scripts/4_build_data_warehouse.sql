DROP TABLE IF EXISTS staging_emergency_passages;
DROP TABLE IF EXISTS staging_hospitals;
DROP TABLE IF EXISTS staging_medecins;


CREATE TABLE staging_emergency_passages LIKE emergency_passages;
CREATE TABLE staging_hospitals LIKE hospitals_with_departements;
CREATE TABLE staging_medecins LIKE medecins;


UPDATE staging_emergency_passages
SET date_de_passage = STR_TO_DATE(date_de_passage, '%d/%m/%Y')
where date_de_passage;

-- Remove duplicate hospitals based on FINESS code
DELETE h1 FROM staging_hospitals h1
INNER JOIN staging_hospitals h2 
WHERE h1.__id < h2.__id AND h1.finess_et = h2.finess_et;
-- Regions
INSERT IGNORE INTO regions (region_id, name)
SELECT DISTINCT CAST(num_dept AS UNSIGNED), dept
FROM staging_hospitals
WHERE dept IS NOT NULL;

-- Provinces
INSERT IGNORE INTO provinces (province_id, name, region_id)
SELECT DISTINCT CAST(num_dept AS UNSIGNED), dept, CAST(num_dept AS UNSIGNED)
FROM staging_hospitals;

-- Cities
INSERT IGNORE INTO cities (city_id, name, province_id, region_id)
SELECT DISTINCT NULL, cp_ville, CAST(num_dept AS UNSIGNED), CAST(num_dept AS UNSIGNED)
FROM staging_hospitals;

-- Facility types
INSERT IGNORE INTO facility_types (facility_type_id, name)
SELECT DISTINCT CAST(num_type AS UNSIGNED), type_etablissement
FROM staging_hospitals;

-- Ownership types
INSERT IGNORE INTO ownership_types (ownership_type_id, name)
VALUES (1,'Public'),(2,'Private');  -- example

-- Sources
INSERT IGNORE INTO sources (source_id, name, description)
VALUES (1,'Health Ministry','Official MOH data'),
      (2,'Emergency Passages','Sursaud emergency visits');
INSERT INTO hospitals (
    hospital_id, name_french, display_name, city_id, province_id, region_id,
    street_address, latitude, longitude, facility_type_id, ownership_type_id,
    contact_phone, contact_email, website, source_id, source_record_key, raw_source
)
SELECT 
    __id,
    raison_sociale,
    raison_sociale,
    cpt_num,
    num_dept,
    num_dept,
    CONCAT(adresse_administrative_1,' ',adresse_administrative_2),
    CAST(lat AS DECIMAL(9,6)),
    CAST(lng AS DECIMAL(9,6)),
    num_type,
    1,  -- assume public
    num_tel,
    NULL,
    NULL,
    2,
    finess_et,
    NULL
FROM staging_hospitals;
-- Emergency passages fact
INSERT INTO emergency_passages (
    id, code_departement, date_de_passage, sursaud_cl_age_corona,
    nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona,
    nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f,
    nbre_hospit_corona_h, nbre_hospit_corona_f, nbre_acte_corona,
    nbre_acte_tot, nbre_acte_corona_h, nbre_acte_corona_f,
    nbre_acte_tot_h, nbre_acte_tot_f, dwh_create_date
)
SELECT 
    id, code_departement, date_de_passage, sursaud_cl_age_corona,
    nbre_pass_corona, nbre_pass_tot, nbre_hospit_corona,
    nbre_pass_corona_h, nbre_pass_corona_f, nbre_pass_tot_h, nbre_pass_tot_f,
    nbre_hospit_corona_h, nbre_hospit_corona_f, nbre_acte_corona,
    nbre_acte_tot, nbre_acte_corona_h, nbre_acte_corona_f,
    nbre_acte_tot_h, nbre_acte_tot_f,
    NOW()
FROM staging_emergency_passages;


-- Hospital stats
INSERT INTO hospital_stats_moh (hospital_id, annee_mise_service, capacite_theorique, capacite_fonctionnelle)
SELECT __id, date_ouverture, NULL, NULL
FROM staging_hospitals;
-- Example: check orphan hospitals
SELECT * FROM hospitals h
LEFT JOIN cities c ON h.city_id = c.city_id
WHERE c.city_id IS NULL;