IF OBJECT_ID('silver.hospitals_paris','U') IS NOT NULL
    DROP TABLE silver.hospitals_paris;
CREATE TABLE silver.hospitals_paris (
    id          INT  PRIMARY KEY,
    name        NVARCHAR(255),
    address     NVARCHAR(500),
    phone       NVARCHAR(50),
    latitude    NVARCHAR(50),
    longitude   NVARCHAR(50),
    capacity    NVARCHAR(500),
    description NVARCHAR(MAX),
    services    NVARCHAR(MAX),
    url         NVARCHAR(MAX),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID('silver.hospitals_with_departements','U') IS NOT NULL
    DROP TABLE silver.hospitals_with_departements;
CREATE TABLE silver.hospitals_with_departements (
    __id INT IDENTITY(1,1) PRIMARY KEY,

    finess_et NVARCHAR(20),
    finess_ej NVARCHAR(20),

    raison_sociale NVARCHAR(255),
    raison_sociale_entite_juridique NVARCHAR(255),

    adresse_administrative_1 NVARCHAR(255),
    adresse_administrative_2 NVARCHAR(255),

    num_voie NVARCHAR(20),
    cpt_num NVARCHAR(30),
    type_voie NVARCHAR(50),
    voie NVARCHAR(255),

    adresse_complete NVARCHAR(500),
    complement_adresse NVARCHAR(255),

    num_dept NVARCHAR(10),
    dept NVARCHAR(100),
    cp_ville NVARCHAR(50),

    num_tel NVARCHAR(50),
    num_fax NVARCHAR(50),

    num_cat NVARCHAR(20),
    categorie_de_l_etablissement NVARCHAR(255),

    num_type NVARCHAR(20),
    type_etablissement NVARCHAR(255),

    num_siret NVARCHAR(50),
    code_ape NVARCHAR(20),

    code_tarif NVARCHAR(20),
    lib_tarification NVARCHAR(255),

    code_psph NVARCHAR(50),
    participant_service_public_hospitalier NVARCHAR(50),

    date_ouverture NVARCHAR(50),

    lat NVARCHAR(50),
    lng NVARCHAR(50),
    wgs84 NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);


IF OBJECT_ID('silver.emergency_passages','U') IS NOT NULL
    DROP TABLE silver.emergency_passages;
CREATE TABLE silver.emergency_passages (
    id   VARCHAR(50),

    code_departement VARCHAR(50),  -- or CHAR(3) if it's French department codes like '75'
    
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
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);



IF OBJECT_ID('silver.medecins','U') IS NOT NULL
    DROP TABLE silver.medecins;
CREATE TABLE silver.medecins (
    id VARCHAR(20),
    N_RPPS VARCHAR(20),
    Nom VARCHAR(100),
    Prenom VARCHAR(100),
    Specialite VARCHAR(150),
    Date_accreditation  VARCHAR(50),
    OA VARCHAR(50),
    Nom_equipe VARCHAR(150),
    Departement VARCHAR(50),
    FINESS VARCHAR(20),
    Statut VARCHAR(100)
);



-- ghnbdaw hna data cleaning 
-- awl haja hya duplicates w null f primarykey
select 
    __id , COUNT(*) 
    from bronze.hospitals_with_departements 
    GROUP BY __id HAVING COUNT(*) > 1 OR __id IS NULL;

--ghan9llebo ela unwanted spaces fles colonnes lli endy
--ghan7yyed les abbreviations wn7ett les mots kamlin f colonne type_voie
--ghan7wwel ll upper case 
--ghan7awll f complement_adresse mn BP -> Boite Postale


INSERT INTO silver.hospitals_with_departements(
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
    wgs84)
SELECT 
    COALESCE(TRIM(finess_et), 'n/a') AS finess_et,
    COALESCE(TRIM(finess_ej), 'n/a') AS finess_ej,
    COALESCE(TRIM(raison_sociale), 'n/a') AS raison_sociale,
    COALESCE(TRIM(raison_sociale_entite_juridique), 'n/a') AS raison_sociale_entite_juridique,
    COALESCE(TRIM(adresse_administrative_1), 'n/a') AS adresse_administrative_1,
    COALESCE(TRIM(adresse_administrative_2), 'n/a') AS adresse_administrative_2,
    COALESCE(TRIM(num_voie), 'n/a') AS num_voie,
    COALESCE(
        CASE TRIM(cpt_num)
            WHEN 'T' THEN 'Titulaire'
            WHEN 'B' THEN 'Bénéficiaire'
            ELSE 'n/a'
        END,
        'n/a'
    ) AS cpt_num,
    
    CASE UPPER(TRIM(type_voie))
        WHEN 'RTE' THEN 'Route'
        WHEN 'AV'  THEN 'Avenue'
        WHEN 'SQ'  THEN 'Square'
        WHEN 'PAS' THEN 'Passage'
        WHEN 'TSSE' THEN 'Traverse'
        WHEN 'RPT' THEN 'Rond-Point'
        WHEN 'CHE' THEN 'Chemin'
        WHEN 'VLA' THEN 'Villa'
        WHEN 'CHT' THEN 'Château'
        WHEN 'ALL' THEN 'Allée'
        WHEN 'LD'  THEN 'Lieu-Dit'
        WHEN 'QU'  THEN 'Quai'
        WHEN 'RLE' THEN 'Ruelle'
        WHEN 'GR'  THEN 'Grande Rue'
        WHEN 'IMP' THEN 'Impasse'
        WHEN 'RES' THEN 'Résidence'
        WHEN 'PROM' THEN 'Promenade'
        WHEN 'QUA' THEN 'Quartier'
        WHEN 'CITE' THEN 'Cité'
        WHEN 'PL'  THEN 'Place'
        WHEN 'VOI' THEN 'Voie'
        WHEN 'R'   THEN 'Rue'
        WHEN 'COUR' THEN 'Cour'
        WHEN 'ESP'  THEN 'Esplanade'
        WHEN 'BD'   THEN 'Boulevard'
        WHEN 'CRS'  THEN 'Cours'
        WHEN 'PRV'  THEN 'Privée'
        ELSE 'n/a'
    END AS type_voie,
    COALESCE(TRIM(voie), 'n/a') AS voie,
    COALESCE(TRIM(adresse_complete), 'n/a') AS adresse_complete,
    COALESCE(
        REPLACE(
            REPLACE(
                REPLACE(TRIM(complement_adresse), 'B.P.', 'Boîte Postale'),
                'BP', 'Boîte Postale'
                ),
                'CD', 'Chemin Départemental'
            ),
            'n/a'
        ) AS complement_adresse,
    COALESCE(TRIM(num_dept), 'n/a') AS num_dept,
    COALESCE(TRIM(dept), 'n/a') AS dept,
    COALESCE(TRIM(cp_ville), 'n/a') AS cp_ville,
    COALESCE(TRIM(num_tel), 'n/a') AS num_tel,
    COALESCE(TRIM(num_fax), 'n/a') AS num_fax,
    COALESCE(TRIM(num_cat), 'n/a') AS num_cat,
    COALESCE(TRIM(categorie_de_l_etablissement), 'n/a') AS categorie_de_l_etablissement,
    COALESCE(TRIM(num_type), 'n/a') AS num_type,
    COALESCE(TRIM(type_etablissement), 'n/a') AS type_etablissement,
    COALESCE(TRIM(num_siret), 'n/a') AS num_siret,
    COALESCE(TRIM(code_ape), 'n/a') AS code_ape,
    COALESCE(TRIM(code_tarif), 'n/a') AS code_tarif,

    COALESCE(TRIM(lib_tarification), 'n/a') AS lib_tarification,
    COALESCE(TRIM(code_psph), 'n/a') AS code_psph,
    COALESCE(TRIM(participant_service_public_hospitalier), 'n/a') AS participant_service_public_hospitalier,
    COALESCE(TRIM(date_ouverture), 'n/a') AS date_ouverture,
    COALESCE(TRIM(lat), 'n/a') AS lat,
    COALESCE(TRIM(lng), 'n/a') AS lng,
    COALESCE(TRIM(wgs84), 'n/a') AS wgs84
    
FROM bronze.hospitals_with_departements;
select * from silver.hospitals_with_departements;
--select distinct categorie_de_l_etablissement from bronze.hospitals_with_departements;




--hna salit mea table 1 

--table 2 : 
SELECT nbre_acte_tot
FROM bronze.emergency_passages
WHERE 
    TRY_CAST(nbre_acte_tot AS FLOAT) < 0;



INSERT INTO silver.emergency_passages(
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
select 
    id,
    code_departement,
    COALESCE(TRIM(date_de_passage), 'n/a') AS date_de_passage,
    CASE TRIM(sursaud_cl_age_corona)
        WHEN '0' THEN 'Tous âges'
        WHEN '1'  THEN '0-4 ans'
        WHEN '2'  THEN '5-14 an'
        WHEN '3' THEN '15-44 ans'
        WHEN '4' THEN '45-64 ans'
        WHEN '5' THEN '65-74 ans'
        WHEN '6' THEN '75 ans ou plus'
        ELSE 'n/a'
    END AS sursaud_cl_age_corona,
    COALESCE(TRIM(nbre_pass_corona), 'n/a') AS nbre_pass_corona,
    COALESCE(TRIM(nbre_pass_tot), 'n/a') AS nbre_pass_tot,
    COALESCE(TRIM(nbre_hospit_corona), 'n/a') AS nbre_hospit_corona,
    COALESCE(TRIM(nbre_pass_corona_h), 'n/a') AS nbre_pass_corona_h,
    COALESCE(TRIM(nbre_pass_corona_f), 'n/a') AS nbre_pass_corona_f,
    COALESCE(TRIM(nbre_pass_tot_h), 'n/a') AS nbre_pass_tot_h,
    COALESCE(TRIM(nbre_pass_tot_f), 'n/a') AS nbre_pass_tot_f,
    COALESCE(TRIM(nbre_hospit_corona_h), 'n/a') AS nbre_hospit_corona_h,
    COALESCE(TRIM(nbre_hospit_corona_f), 'n/a') AS nbre_hospit_corona_f,
    COALESCE(TRIM(nbre_acte_corona), 'n/a') AS nbre_acte_corona,
    COALESCE(TRIM(nbre_acte_tot), 'n/a') AS nbre_acte_tot,
    COALESCE(TRIM(nbre_acte_corona_h), 'n/a') AS nbre_acte_corona_h,
    COALESCE(TRIM(nbre_acte_corona_f), 'n/a') AS nbre_acte_corona_f,
    COALESCE(TRIM(nbre_acte_tot_h), 'n/a') AS nbre_acte_tot_h,
    COALESCE(TRIM(nbre_acte_tot_f), 'n/a') AS nbre_acte_tot_f


from bronze.emergency_passages;


EXEC sp_help 'bronze.emergency_passages';

SELECT date_de_passage
FROM silver.emergency_passages
WHERE TRY_CONVERT(date, date_de_passage, 23) > CAST(GETDATE() AS date);

select * from silver.emergency_passages;



TRUNCATE TABLE silver.medecins;
INSERT INTO silver.medecins(
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
    COALESCE(LEFT(TRIM(id), 20), 'n/a') AS id,
    COALESCE(LEFT(TRIM(N_RPPS), 20), 'n/a') AS N_RPPS,
    COALESCE(LEFT(TRIM(REPLACE(Nom, '"', '')), 100), 'n/a') AS Nom,
    COALESCE(LEFT(TRIM(REPLACE(Prenom, '"', '')), 100), 'n/a') AS Prenom,
    COALESCE(LEFT(TRIM(REPLACE(Specialite, '"', '')), 150), 'n/a') AS Specialite,
    -- Format date to dd-MM-yyyy if valid, else keep original
    COALESCE(
        CASE 
            WHEN ISDATE(Date_accreditation) = 1 
            THEN FORMAT(CONVERT(DATE, Date_accreditation, 103), 'dd-MM-yyyy')
            ELSE LEFT(TRIM(Date_accreditation), 50)
        END,
        'n/a'
    ) AS Date_accreditation,
    COALESCE(TRIM(OA), 'n/a') AS OA,
    COALESCE(TRIM(Nom_equipe), 'n/a') AS Nom_equipe,
    COALESCE(TRIM(Departement), 'n/a') AS Departement,
    COALESCE(TRIM(FINESS), 'n/a') AS FINESS,
    COALESCE(LEFT(TRIM(REPLACE(Statut, '"', '')), 100), 'n/a') AS Statut
FROM bronze.medecins;

select * from silver.medecins;

bcp "SELECT * FROM ProjetDWH.silver.medecins"
queryout "C:\Users\pcc\Documents\WISD\S3\BDA\Hospital_project\cleaned_medecins.csv"
-c -t, -T -S SERVERNAME


USE master;
IF NOT EXISTS (
    SELECT 1 FROM sys.server_principals 
    WHERE name = 'DESKTOP-PIVE6CS\pcc'
)
CREATE LOGIN [DESKTOP-PIVE6CS\pcc] FROM WINDOWS;



