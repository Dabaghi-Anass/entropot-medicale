USE ProjetDWH;
-- In MySQL, schemas are synonymous with databases, but to simulate layers (bronze, silver, gold),
-- we will create separate databases for each layer.
-- If you prefer everything in one database and use table prefixes (e.g., bronze_hospitals_paris),
-- let me know, but here we follow the original structure with separate databases.

CREATE DATABASE IF NOT EXISTS bronze;
CREATE DATABASE IF NOT EXISTS silver;
CREATE DATABASE IF NOT EXISTS gold;

-- Switch to bronze database
USE bronze;

-- Creating tables to load data

DROP TABLE IF EXISTS hospitals_paris;
CREATE TABLE hospitals_paris (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(500),
    phone VARCHAR(50),
    latitude VARCHAR(50),
    longitude VARCHAR(50),
    capacity VARCHAR(500),
    description TEXT,
    services TEXT,
    url TEXT
);

DROP TABLE IF EXISTS hospitals_with_departements;
CREATE TABLE hospitals_with_departements (
    __id INT AUTO_INCREMENT PRIMARY KEY,
    finess_et VARCHAR(20),
    finess_ej VARCHAR(20),
    raison_sociale VARCHAR(255),
    raison_sociale_entite_juridique VARCHAR(255),
    adresse_administrative_1 VARCHAR(255),
    adresse_administrative_2 VARCHAR(255),
    num_voie VARCHAR(20),
    cpt_num VARCHAR(20),
    type_voie VARCHAR(50),
    voie VARCHAR(255),
    adresse_complete VARCHAR(500),
    complement_adresse VARCHAR(255),
    num_dept VARCHAR(10),
    dept VARCHAR(100),
    cp_ville VARCHAR(50),
    num_tel VARCHAR(50),
    num_fax VARCHAR(50),
    num_cat VARCHAR(20),
    categorie_de_l_etablissement VARCHAR(255),
    num_type VARCHAR(20),
    type_etablissement VARCHAR(255),
    num_siret VARCHAR(50),
    code_ape VARCHAR(20),
    code_tarif VARCHAR(20),
    lib_tarification VARCHAR(255),
    code_psph VARCHAR(50),
    participant_service_public_hospitalier VARCHAR(50),
    date_ouverture VARCHAR(50),
    lat VARCHAR(50),
    lng VARCHAR(50),
    wgs84 VARCHAR(50)
);

DROP TABLE IF EXISTS emergency_passages;
CREATE TABLE emergency_passages (
    id VARCHAR(50),
    code_departement VARCHAR(50),
    date_de_passage VARCHAR(50),
    sursaud_cl_age_corona VARCHAR(100),
    nbre_pass_corona VARCHAR(50),
    nbre_pass_tot VARCHAR(50),
    nbre_hospit_corona VARCHAR(50),
    nbre_pass_corona_h VARCHAR(50),
    nbre_pass_corona_f VARCHAR(50),
    nbre_pass_tot_h VARCHAR(50),
    nbre_pass_tot_f VARCHAR(50),
    nbre_hospit_corona_h VARCHAR(50),
    nbre_hospit_corona_f VARCHAR(50),
    nbre_acte_corona VARCHAR(50),
    nbre_acte_tot VARCHAR(50),
    nbre_acte_corona_h VARCHAR(50),
    nbre_acte_corona_f VARCHAR(50),
    nbre_acte_tot_h VARCHAR(50),
    nbre_acte_tot_f VARCHAR(50)
);

DROP TABLE IF EXISTS medecins;
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
    Statut VARCHAR(100)
);

-- Procedure to load data (MySQL requires changing delimiter for CREATE PROCEDURE)

DELIMITER //

CREATE PROCEDURE load_data()
BEGIN
    TRUNCATE TABLE hospitals_paris;
    LOAD DATA LOCAL INFILE 'C:/Users/pcc/Documents/WISD/S3/BDA/Hospital_project/scraping/hospitals_paris_clean.csv'
    INTO TABLE hospitals_paris
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    SELECT * FROM hospitals_paris;

    TRUNCATE TABLE hospitals_with_departements;
    LOAD DATA LOCAL INFILE 'C:/Users/pcc/Documents/WISD/S3/BDA/Hospital_project/departements.csv'
    INTO TABLE hospitals_with_departements
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    SELECT * FROM hospitals_with_departements;

    TRUNCATE TABLE emergency_passages;
    LOAD DATA LOCAL INFILE 'C:/Users/pcc/Documents/WISD/S3/BDA/Hospital_project/emergency_with_id.csv'
    INTO TABLE emergency_passages
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    SELECT * FROM emergency_passages;

    TRUNCATE TABLE medecins;
    LOAD DATA LOCAL INFILE 'C:/Users/pcc/Documents/WISD/S3/BDA/Hospital_project/medecins_modified.csv'
    INTO TABLE medecins
    FIELDS TERMINATED BY ';'
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    SELECT * FROM medecins;
END //

DELIMITER ;

-- Final query (translated to MySQL)
SELECT DISTINCT cpt_num FROM hospitals_with_departements;

-- Notes:
-- 1. MySQL does not have schemas like SQL Server. Here, we used separate databases (bronze, silver, gold).
--    All tables and the procedure are created in the 'bronze' database.
-- 2. Use LOAD DATA LOCAL INFILE (requires --local-infile=1 on client and server if needed).
-- 3. Paths use forward slashes (works on Windows too).
-- 4. Added ENCLOSED BY '"' as it's common in CSVs.
-- 5. NVARCHAR(MAX) -> TEXT in MySQL.
-- 6. INT IDENTITY -> INT AUTO_INCREMENT.
-- 7. To call the procedure: CALL load_data();