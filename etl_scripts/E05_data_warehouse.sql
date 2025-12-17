DROP DATABASE IF EXISTS chargement_des_donnees;
DROP DATABASE IF EXISTS hopital_data_warehouse;

CREATE DATABASE IF NOT EXISTS chargement_des_donnees;
CREATE DATABASE IF NOT EXISTS hopital_data_warehouse;

USE chargement_des_donnees;

-- ============================================
-- PART 2: CREATE SOURCE TABLES
-- ============================================

-- Drop tables in correct order
DROP TABLE IF EXISTS hopital_services;
DROP TABLE IF EXISTS medecins;
DROP TABLE IF EXISTS hopital;

-- Create hopital table
CREATE TABLE hopital (
    finess VARCHAR(20) PRIMARY KEY,
    numero_finess_ej VARCHAR(20),
    raison_sociale VARCHAR(255),
    raison_sociale_longue VARCHAR(500),
    complement_raison_sociale VARCHAR(255),
    complement_distribution VARCHAR(255),
    numero_voie VARCHAR(20),
    type_voie VARCHAR(50),
    libelle_voie VARCHAR(255),
    complement_voie VARCHAR(255),
    lieu_dit_bp VARCHAR(255),
    commune VARCHAR(100),
    code_commune VARCHAR(10),
    departement VARCHAR(10),
    libelle_departement VARCHAR(100),
    ligne_acheminement VARCHAR(255),
    telephone VARCHAR(20),
    telecopie VARCHAR(20),
    categorie_etablissement VARCHAR(10),
    libelle_categorie VARCHAR(255),
    categorie_agregat VARCHAR(10),
    libelle_categorie_agregat VARCHAR(255),
    numero_siret VARCHAR(20),
    code_ape VARCHAR(20),
    code_mft VARCHAR(10),
    libelle_mft VARCHAR(100),
    code_sph VARCHAR(10),
    libelle_sph VARCHAR(255),
    date_ouverture VARCHAR(20),
    date_autorisation VARCHAR(20),
    date_mise_a_jour VARCHAR(20),
    numero_education_nationale VARCHAR(20),
    coordxet DECIMAL(11,8),
    coordyet DECIMAL(10,8),
    source_coordet VARCHAR(255),
    date_maj_coordonnees VARCHAR(20),
    nom_officiel_commune VARCHAR(100),
    code_officiel_region VARCHAR(10),
    nom_officiel_region VARCHAR(100),
    code_officiel_epci VARCHAR(20),
    nom_officiel_epci VARCHAR(255),
    adresse VARCHAR(500),
    coord VARCHAR(255)
);

-- Create child tables
CREATE TABLE hopital_services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    finess VARCHAR(20),
    urgences TINYINT DEFAULT 0,
    reanimation TINYINT DEFAULT 0,
    maternite TINYINT DEFAULT 0,
    dialyse TINYINT DEFAULT 0,
    chimio TINYINT DEFAULT 0,
    bloc TINYINT DEFAULT 0,
    imagerie TINYINT DEFAULT 0,
    psychiatrie TINYINT DEFAULT 0
);

CREATE TABLE medecins (
    id VARCHAR(20),
    N_RPPS VARCHAR(20),
    Nom VARCHAR(100),
    Prenom VARCHAR(100),
    Specialite VARCHAR(150),
    Date_accreditation VARCHAR(50),
    OA VARCHAR(50),
    Nom_equipe VARCHAR(150),
    Departement VARCHAR(50),
    FINESS VARCHAR(20),
    Statut VARCHAR(100),
    dwh_create_date DATETIME DEFAULT NOW()
);

-- ============================================
-- PART 3: LOAD SOURCE DATA
-- ============================================

-- Load data into parent table first
LOAD DATA LOCAL INFILE 'C:/Users/Osaka Gaming Maroc/Desktop/entropot-medicale/data/hopital.csv'
INTO TABLE hopital
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load data into child tables
LOAD DATA LOCAL INFILE 'C:/Users/Osaka Gaming Maroc/Desktop/entropot-medicale/data/hopital_service.csv'
INTO TABLE hopital_services
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'c:/Users/Osaka Gaming Maroc/Desktop/entropot-medicale/data/medecins.csv'
INTO TABLE medecins
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Clean orphaned data
DELETE hs FROM hopital_services hs 
LEFT JOIN hopital h ON hs.finess = h.finess 
WHERE h.finess IS NULL;

DELETE m FROM medecins m 
LEFT JOIN hopital h ON m.FINESS = h.finess 
WHERE h.finess IS NULL;

-- Add foreign keys
ALTER TABLE hopital_services 
ADD CONSTRAINT fk_finess_services 
FOREIGN KEY (finess) REFERENCES hopital(finess);

ALTER TABLE medecins 
ADD CONSTRAINT fk_finess_medecins 
FOREIGN KEY (FINESS) REFERENCES hopital(finess);

SELECT 'Source data loaded successfully' AS status;

-- ============================================
-- PART 4: BUILD SIMPLIFIED DATA WAREHOUSE
-- ============================================
-- ============================================
-- SIMPLER, CLEANER DATA WAREHOUSE DESIGN
-- ============================================

USE hopital_data_warehouse;

-- Clear existing tables
DROP TABLE IF EXISTS fact_doctor_assignments;
DROP TABLE IF EXISTS fact_hospital_services;
DROP TABLE IF EXISTS dim_hopital;
DROP TABLE IF EXISTS dim_medecin;
DROP TABLE IF EXISTS dim_services;

-- ============================================
-- CREATE SIMPLE DIMENSION TABLES
-- ============================================

-- 1. Hospital Dimension
CREATE TABLE dim_hopital (
    hopital_id INT AUTO_INCREMENT PRIMARY KEY,
    finess VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(255) NOT NULL,
    region VARCHAR(100),
    departement VARCHAR(10),
    ville VARCHAR(100),
    categorie VARCHAR(100),
    INDEX idx_finess (finess),
    INDEX idx_region (region),
    INDEX idx_dept (departement)
);

-- 2. Doctor Dimension
CREATE TABLE dim_medecin (
    medecin_id INT AUTO_INCREMENT PRIMARY KEY,
    rpps VARCHAR(20) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    specialite VARCHAR(150),
    statut VARCHAR(100),
    INDEX idx_rpps (rpps),
    INDEX idx_specialite (specialite(50))
);

-- 3. Services Dimension (simple list of services)
CREATE TABLE dim_services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_nom VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================
-- CREATE SEPARATE FACT TABLES
-- ============================================

-- 1. Fact table for Doctor Assignments
CREATE TABLE fact_doctor_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    hopital_id INT NOT NULL,
    medecin_id INT NOT NULL,
    date_chargement DATE DEFAULT (CURDATE()),
    FOREIGN KEY (hopital_id) REFERENCES dim_hopital(hopital_id),
    FOREIGN KEY (medecin_id) REFERENCES dim_medecin(medecin_id),
    INDEX idx_hopital_medecin (hopital_id, medecin_id)
);

-- 2. Fact table for Hospital Services
CREATE TABLE fact_hospital_services (
    service_fact_id INT AUTO_INCREMENT PRIMARY KEY,
    hopital_id INT NOT NULL,
    service_id INT NOT NULL,
    disponible BOOLEAN DEFAULT TRUE,
    date_chargement DATE DEFAULT (CURDATE()),
    FOREIGN KEY (hopital_id) REFERENCES dim_hopital(hopital_id),
    FOREIGN KEY (service_id) REFERENCES dim_services(service_id),
    UNIQUE KEY unique_hopital_service (hopital_id, service_id),
    INDEX idx_hopital_service (hopital_id, service_id)
);

-- ============================================
-- POPULATE DIMENSIONS
-- ============================================

-- 1. Populate Hospital Dimension (simplified)
INSERT INTO dim_hopital (finess, nom, region, departement, ville, categorie)
SELECT DISTINCT 
    h.finess,
    COALESCE(h.raison_sociale, 'Nom inconnu') AS nom,
    COALESCE(h.nom_officiel_region, 'Région inconnue') AS region,
    COALESCE(h.departement, '00') AS departement,
    COALESCE(h.commune, 'Ville inconnue') AS ville,
    COALESCE(h.libelle_categorie, 'Catégorie inconnue') AS categorie
FROM chargement_des_donnees.hopital h;

-- 2. Populate Doctor Dimension (simplified)
INSERT INTO dim_medecin (rpps, nom, prenom, specialite, statut)
SELECT DISTINCT
    m.N_RPPS,
    COALESCE(m.Nom, 'Nom inconnu') AS nom,
    COALESCE(m.Prenom, 'Prénom inconnu') AS prenom,
    TRIM(BOTH '"' FROM COALESCE(m.Specialite, 'Spécialité inconnue')) AS specialite,
    COALESCE(m.Statut, 'Statut inconnu') AS statut
FROM chargement_des_donnees.medecins m
WHERE m.N_RPPS IS NOT NULL AND m.N_RPPS != '';

-- 3. Populate Services Dimension
INSERT INTO dim_services (service_nom) VALUES
('Urgences'),
('Réanimation'),
('Maternité'),
('Dialyse'),
('Chimiothérapie'),
('Bloc opératoire'),
('Imagerie'),
('Psychiatrie');

-- ============================================
-- POPULATE FACT TABLES
-- ============================================

-- 1. Populate Doctor Assignments
INSERT INTO fact_doctor_assignments (hopital_id, medecin_id)
SELECT DISTINCT
    dh.hopital_id,
    dm.medecin_id
FROM chargement_des_donnees.medecins m
JOIN dim_hopital dh ON m.FINESS = dh.finess
JOIN dim_medecin dm ON m.N_RPPS = dm.rpps
WHERE m.N_RPPS IS NOT NULL AND m.N_RPPS != '';

-- 2. Populate Hospital Services
INSERT INTO fact_hospital_services (hopital_id, service_id, disponible)
SELECT 
    dh.hopital_id,
    ds.service_id,
    TRUE AS disponible
FROM chargement_des_donnees.hopital_services hs
JOIN dim_hopital dh ON hs.finess = dh.finess
CROSS JOIN dim_services ds
WHERE 
    (ds.service_nom = 'Urgences' AND hs.urgences = 1) OR
    (ds.service_nom = 'Réanimation' AND hs.reanimation = 1) OR
    (ds.service_nom = 'Maternité' AND hs.maternite = 1) OR
    (ds.service_nom = 'Dialyse' AND hs.dialyse = 1) OR
    (ds.service_nom = 'Chimiothérapie' AND hs.chimio = 1) OR
    (ds.service_nom = 'Bloc opératoire' AND hs.bloc = 1) OR
    (ds.service_nom = 'Imagerie' AND hs.imagerie = 1) OR
    (ds.service_nom = 'Psychiatrie' AND hs.psychiatrie = 1);

-- ============================================
-- CREATE SIMPLE VIEWS
-- ============================================

-- 1. View for Doctor Assignments
CREATE OR REPLACE VIEW vw_assignments AS
SELECT 
    fda.assignment_id,
    dh.finess,
    dh.nom AS hopital_nom,
    dh.region,
    dh.departement,
    dm.rpps,
    CONCAT(dm.prenom, ' ', dm.nom) AS medecin_nom,
    dm.specialite,
    dm.statut,
    fda.date_chargement
FROM fact_doctor_assignments fda
JOIN dim_hopital dh ON fda.hopital_id = dh.hopital_id
JOIN dim_medecin dm ON fda.medecin_id = dm.medecin_id;

-- 2. View for Hospital Services
CREATE OR REPLACE VIEW vw_services AS
SELECT 
    fhs.service_fact_id,
    dh.finess,
    dh.nom AS hopital_nom,
    dh.region,
    dh.departement,
    ds.service_nom,
    fhs.disponible,
    fhs.date_chargement
FROM fact_hospital_services fhs
JOIN dim_hopital dh ON fhs.hopital_id = dh.hopital_id
JOIN dim_services ds ON fhs.service_id = ds.service_id;

-- 3. Combined Hospital Summary
CREATE OR REPLACE VIEW vw_hospital_summary AS
SELECT 
    dh.hopital_id,
    dh.finess,
    dh.nom AS hopital_nom,
    dh.region,
    dh.departement,
    dh.ville,
    dh.categorie,
    
    -- Count doctors
    (SELECT COUNT(*) 
     FROM fact_doctor_assignments fda 
     WHERE fda.hopital_id = dh.hopital_id) AS nombre_medecins,
    
    -- Count services
    (SELECT COUNT(*) 
     FROM fact_hospital_services fhs 
     WHERE fhs.hopital_id = dh.hopital_id AND fhs.disponible = TRUE) AS nombre_services,
    
    -- List services
    (SELECT GROUP_CONCAT(ds.service_nom ORDER BY ds.service_nom SEPARATOR ', ')
     FROM fact_hospital_services fhs
     JOIN dim_services ds ON fhs.service_id = ds.service_id
     WHERE fhs.hopital_id = dh.hopital_id AND fhs.disponible = TRUE) AS services_list
    
FROM dim_hopital dh;

-- ============================================
-- VALIDATION QUERIES
-- ============================================

SELECT '=== DATA WAREHOUSE CREATED ===' AS status;
SELECT ' ' AS empty_line;

-- Show counts
SELECT 'TABLE COUNTS' AS section;
SELECT 'dim_hopital' AS table_name, COUNT(*) as records FROM dim_hopital
UNION ALL
SELECT 'dim_medecin', COUNT(*) FROM dim_medecin
UNION ALL
SELECT 'dim_services', COUNT(*) FROM dim_services
UNION ALL
SELECT 'fact_doctor_assignments', COUNT(*) FROM fact_doctor_assignments
UNION ALL
SELECT 'fact_hospital_services', COUNT(*) FROM fact_hospital_services;

SELECT ' ' AS empty_line;

-- Sample data from assignments
SELECT 'SAMPLE DOCTOR ASSIGNMENTS (first 10)' AS section;
SELECT 
    assignment_id,
    finess,
    hopital_nom,
    medecin_nom,
    specialite,
    date_chargement
FROM vw_assignments 
LIMIT 10;

SELECT ' ' AS empty_line;

-- Sample data from services
SELECT 'SAMPLE HOSPITAL SERVICES (first 10)' AS section;
SELECT 
    finess,
    hopital_nom,
    service_nom,
    disponible,
    date_chargement
FROM vw_services 
LIMIT 10;

SELECT ' ' AS empty_line;

-- Sample hospital summary
SELECT 'SAMPLE HOSPITAL SUMMARY (first 5)' AS section;
SELECT 
    finess,
    hopital_nom,
    region,
    departement,
    nombre_medecins,
    nombre_services,
    services_list
FROM vw_hospital_summary 
LIMIT 5;

SELECT ' ' AS empty_line;

SELECT 'SUMMARY STATISTICS' AS section;
SELECT 
    (SELECT COUNT(DISTINCT hopital_id) FROM fact_doctor_assignments) AS hopitaux_avec_medecins,
    (SELECT COUNT(DISTINCT hopital_id) FROM fact_hospital_services) AS hopitaux_avec_services,
    (SELECT COUNT(DISTINCT medecin_id) FROM fact_doctor_assignments) AS medecins_affilies,
    (SELECT COUNT(*) FROM fact_hospital_services WHERE disponible = TRUE) AS services_disponibles;

SELECT '=== READY FOR ANALYSIS ===' AS final_status;