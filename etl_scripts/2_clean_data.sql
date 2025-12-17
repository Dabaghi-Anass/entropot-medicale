-- Switch to the silver database (assuming we're continuing the structure with separate databases)
USE silver;

-- Drop and create tables in silver layer

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
    url TEXT,
    dwh_create_date DATETIME DEFAULT NOW()
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
    cpt_num VARCHAR(30),
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
    wgs84 VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
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
    nbre_acte_tot_f VARCHAR(50),
    dwh_create_date DATETIME DEFAULT NOW()
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
    Statut VARCHAR(100),
    dwh_create_date DATETIME DEFAULT NOW()
);

-- Optional: Check for duplicates or nulls in primary key (informational query)
SELECT __id, COUNT(*) 
FROM bronze.hospitals_with_departements 
GROUP BY __id 
HAVING COUNT(*) > 1 OR __id IS NULL;

-- Data cleaning and load into silver.hospitals_with_departements
TRUNCATE TABLE hospitals_with_departements;

INSERT INTO hospitals_with_departements (
    finess_et,
    finess_ej,
    raison_sociale,
    raison_sociale_entite_juridique,
    adresse_administrative_1,
    adresse_administrative_2,
    num_voie,
    cpt_num,
    type_voie,
    voie,
    adresse_complete,
    complement_adresse,
    num_dept,
    dept,
    cp_ville,
    num_tel,
    num_fax,
    num_cat,
    categorie_de_l_etablissement,
    num_type,
    type_etablissement,
    num_siret,
    code_ape,
    code_tarif,
    lib_tarification,
    code_psph,
    participant_service_public_hospitalier,
    date_ouverture,
    lat,
    lng,
    wgs84
)
SELECT
    COALESCE(TRIM(finess_et), 'n/a'),
    COALESCE(TRIM(finess_ej), 'n/a'),
    COALESCE(TRIM(raison_sociale), 'n/a'),
    COALESCE(TRIM(raison_sociale_entite_juridique), 'n/a'),
    COALESCE(TRIM(adresse_administrative_1), 'n/a'),
    COALESCE(TRIM(adresse_administrative_2), 'n/a'),
    COALESCE(TRIM(num_voie), 'n/a'),
    COALESCE(
        CASE TRIM(cpt_num)
            WHEN 'T' THEN 'Titulaire'
            WHEN 'B' THEN 'Bénéficiaire'
            ELSE 'n/a'
        END,
        'n/a'
    ),
    CASE UPPER(TRIM(type_voie))
        WHEN 'RTE' THEN 'Route'
        WHEN 'AV' THEN 'Avenue'
        WHEN 'SQ' THEN 'Square'
        WHEN 'PAS' THEN 'Passage'
        WHEN 'TSSE' THEN 'Traverse'
        WHEN 'RPT' THEN 'Rond-Point'
        WHEN 'CHE' THEN 'Chemin'
        WHEN 'VLA' THEN 'Villa'
        WHEN 'CHT' THEN 'Château'
        WHEN 'ALL' THEN 'Allée'
        WHEN 'LD' THEN 'Lieu-Dit'
        WHEN 'QU' THEN 'Quai'
        WHEN 'RLE' THEN 'Ruelle'
        WHEN 'GR' THEN 'Grande Rue'
        WHEN 'IMP' THEN 'Impasse'
        WHEN 'RES' THEN 'Résidence'
        WHEN 'PROM' THEN 'Promenade'
        WHEN 'QUA' THEN 'Quartier'
        WHEN 'CITE' THEN 'Cité'
        WHEN 'PL' THEN 'Place'
        WHEN 'VOI' THEN 'Voie'
        WHEN 'R' THEN 'Rue'
        WHEN 'COUR' THEN 'Cour'
        WHEN 'ESP' THEN 'Esplanade'
        WHEN 'BD' THEN 'Boulevard'
        WHEN 'CRS' THEN 'Cours'
        WHEN 'PRV' THEN 'Privée'
        ELSE 'n/a'
    END,
    COALESCE(TRIM(voie), 'n/a'),
    COALESCE(TRIM(adresse_complete), 'n/a'),
    COALESCE(
        REPLACE(
            REPLACE(
                REPLACE(TRIM(complement_adresse), 'B.P.', 'Boîte Postale'),
                'BP', 'Boîte Postale'
            ),
            'CD', 'Chemin Départemental'
        ),
        'n/a'
    ),
    COALESCE(TRIM(num_dept), 'n/a'),
    COALESCE(TRIM(dept), 'n/a'),
    COALESCE(TRIM(cp_ville), 'n/a'),
    COALESCE(TRIM(num_tel), 'n/a'),
    COALESCE(TRIM(num_fax), 'n/a'),
    COALESCE(TRIM(num_cat), 'n/a'),
    COALESCE(TRIM(categorie_de_l_etablissement), 'n/a'),
    COALESCE(TRIM(num_type), 'n/a'),
    COALESCE(TRIM(type_etablissement), 'n/a'),
    COALESCE(TRIM(num_siret), 'n/a'),
    COALESCE(TRIM(code_ape), 'n/a'),
    COALESCE(TRIM(code_tarif), 'n/a'),
    COALESCE(TRIM(lib_tarification), 'n/a'),
    COALESCE(TRIM(code_psph), 'n/a'),
    COALESCE(TRIM(participant_service_public_hospitalier), 'n/a'),
    COALESCE(TRIM(date_ouverture), 'n/a'),
    COALESCE(TRIM(lat), 'n/a'),
    COALESCE(TRIM(lng), 'n/a'),
    COALESCE(TRIM(wgs84), 'n/a')
FROM bronze.hospitals_with_departements;

-- Optional: View result
SELECT * FROM hospitals_with_departements LIMIT 100;

-- Check for negative values (informational)
SELECT nbre_acte_tot
FROM bronze.emergency_passages
WHERE SAFE_CAST(nbre_acte_tot AS DECIMAL(10,2)) < 0;

-- Load cleaned data into silver.emergency_passages
TRUNCATE TABLE emergency_passages;

INSERT INTO emergency_passages (
    id,
    code_departement,
    date_de_passage,
    sursaud_cl_age_corona,
    nbre_pass_corona,
    nbre_pass_tot,
    nbre_hospit_corona,
    nbre_pass_corona_h,
    nbre_pass_corona_f,
    nbre_pass_tot_h,
    nbre_pass_tot_f,
    nbre_hospit_corona_h,
    nbre_hospit_corona_f,
    nbre_acte_corona,
    nbre_acte_tot,
    nbre_acte_corona_h,
    nbre_acte_corona_f,
    nbre_acte_tot_h,
    nbre_acte_tot_f
)
SELECT
    id,
    code_departement,
    COALESCE(TRIM(date_de_passage), 'n/a'),
    CASE TRIM(sursaud_cl_age_corona)
        WHEN '0' THEN 'Tous âges'
        WHEN '1' THEN '0-4 ans'
        WHEN '2' THEN '5-14 an'
        WHEN '3' THEN '15-44 ans'
        WHEN '4' THEN '45-64 ans'
        WHEN '5' THEN '65-74 ans'
        WHEN '6' THEN '75 ans ou plus'
        ELSE 'n/a'
    END,
    COALESCE(TRIM(nbre_pass_corona), 'n/a'),
    COALESCE(TRIM(nbre_pass_tot), 'n/a'),
    COALESCE(TRIM(nbre_hospit_corona), 'n/a'),
    COALESCE(TRIM(nbre_pass_corona_h), 'n/a'),
    COALESCE(TRIM(nbre_pass_corona_f), 'n/a'),
    COALESCE(TRIM(nbre_pass_tot_h), 'n/a'),
    COALESCE(TRIM(nbre_pass_tot_f), 'n/a'),
    COALESCE(TRIM(nbre_hospit_corona_h), 'n/a'),
    COALESCE(TRIM(nbre_hospit_corona_f), 'n/a'),
    COALESCE(TRIM(nbre_acte_corona), 'n/a'),
    COALESCE(TRIM(nbre_acte_tot), 'n/a'),
    COALESCE(TRIM(nbre_acte_corona_h), 'n/a'),
    COALESCE(TRIM(nbre_acte_corona_f), 'n/a'),
    COALESCE(TRIM(nbre_acte_tot_h), 'n/a'),
    COALESCE(TRIM(nbre_acte_tot_f), 'n/a')
FROM bronze.emergency_passages;

-- Check for future dates (informational)
SELECT date_de_passage
FROM emergency_passages
WHERE STR_TO_DATE(date_de_passage, '%d/%m/%Y') > CURDATE();  -- Adjust format if needed (common French: dd/mm/yyyy)

SELECT * FROM emergency_passages LIMIT 100;

-- Load cleaned data into silver.medecins
TRUNCATE TABLE medecins;

INSERT INTO medecins (
    id,
    N_RPPS,
    Nom,
    Prenom,
    Specialite,
    Date_accreditation,
    OA,
    Nom_equipe,
    Departement,
    FINESS,
    Statut
)
SELECT
    COALESCE(LEFT(TRIM(id), 20), 'n/a'),
    COALESCE(LEFT(TRIM(N_RPPS), 20), 'n/a'),
    COALESCE(LEFT(TRIM(REPLACE(Nom, '"', '')), 100), 'n/a'),
    COALESCE(LEFT(TRIM(REPLACE(Prenom, '"', '')), 100), 'n/a'),
    COALESCE(LEFT(TRIM(REPLACE(Specialite, '"', '')), 150), 'n/a'),
    COALESCE(
        CASE
            WHEN Date_accreditation REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'  -- dd-MM-yyyy format
            THEN DATE_FORMAT(STR_TO_DATE(Date_accreditation, '%d-%m-%Y'), '%d-%m-%Y')
            WHEN Date_accreditation REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'  -- dd/MM/yyyy
            THEN DATE_FORMAT(STR_TO_DATE(Date_accreditation, '%d/%m/%Y'), '%d-%m-%Y')
            ELSE LEFT(TRIM(Date_accreditation), 50)
        END,
        'n/a'
    ),
    COALESCE(TRIM(OA), 'n/a'),
    COALESCE(TRIM(Nom_equipe), 'n/a'),
    COALESCE(TRIM(Departement), 'n/a'),
    COALESCE(TRIM(FINESS), 'n/a'),
    COALESCE(LEFT(TRIM(REPLACE(Statut, '"', '')), 100), 'n/a')
FROM bronze.medecins;

SELECT * FROM medecins LIMIT 100;

-- Notes:
-- 1. All tables are in the 'silver' database (separate from 'bronze').
-- 2. DATETIME DEFAULT NOW() replaces GETDATE().
-- 3. No direct equivalent to TRY_CAST or ISDATE → used SAFE_CAST and REGEXP for validation.
-- 4. Date formatting uses STR_TO_DATE and DATE_FORMAT (adjust input format if your dates are in different style, e.g., yyyy-mm-dd).
-- 5. The hospitals_paris table is created but not populated in your original script — you can add an INSERT similar to the others if needed.
-- 6. The final bcp and login parts are Windows/SQL Server specific and have no direct MySQL equivalent (use mysqldump or SELECT ... INTO OUTFILE for export).