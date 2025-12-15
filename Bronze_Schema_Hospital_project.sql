use ProjetDWH
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

--Creating tables to load data 
--had les commentaires lli dert bach tferr9o bin les section de code


IF OBJECT_ID('bronze.hospitals_paris','U') IS NOT NULL
    DROP TABLE bronze.hospitals_paris;
CREATE TABLE bronze.hospitals_paris (
    id          INT  PRIMARY KEY,
    name        NVARCHAR(255),
    address     NVARCHAR(500),
    phone       NVARCHAR(50),
    latitude    NVARCHAR(50),
    longitude   NVARCHAR(50),
    capacity    NVARCHAR(500),
    description NVARCHAR(MAX),
    services    NVARCHAR(MAX),
    url         NVARCHAR(MAX)
);



IF OBJECT_ID('bronze.hospitals_with_departements','U') IS NOT NULL
    DROP TABLE bronze.hospitals_with_departements;
CREATE TABLE bronze.hospitals_with_departements (
    __id INT IDENTITY(1,1) PRIMARY KEY,

    finess_et NVARCHAR(20),
    finess_ej NVARCHAR(20),

    raison_sociale NVARCHAR(255),
    raison_sociale_entite_juridique NVARCHAR(255),

    adresse_administrative_1 NVARCHAR(255),
    adresse_administrative_2 NVARCHAR(255),

    num_voie NVARCHAR(20),
    cpt_num NVARCHAR(20),
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

);


IF OBJECT_ID('bronze.emergency_passages','U') IS NOT NULL
    DROP TABLE bronze.emergency_passages;
CREATE TABLE bronze.emergency_passages (
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

 
);


IF OBJECT_ID('bronze.medecins','U') IS NOT NULL
    DROP TABLE bronze.medecins;
CREATE TABLE bronze.medecins (
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



--db ghan3mmro had les tableau mn csv lli endna 
CREATE OR ALTER PROCEDURE bronze.load_data AS
BEGIN

    TRUNCATE TABLE bronze.hospitals_paris;
    BULK INSERT bronze.hospitals_paris
    FROM 'C:\Users\pcc\Documents\WISD\S3\BDA\Hospital_project\scraping\hospitals_paris_clean.csv'
    WITH
    (
        FIRSTROW = 2,               -- skip header
        FIELDTERMINATOR = ',',       -- column separator
        CODEPAGE = '65001',          -- UTF-8 support
        TABLOCK
    );
    select * from bronze.hospitals_paris;

    TRUNCATE TABLE bronze.hospitals_with_departements;
    BULK INSERT bronze.hospitals_with_departements
    FROM 'C:\Users\pcc\Documents\WISD\S3\BDA\Hospital_project\departements.csv'
    WITH
    (
        FIRSTROW = 2,               -- skip header
        FIELDTERMINATOR = ',',       -- column separator
        CODEPAGE = '65001',          -- UTF-8 support
        TABLOCK
    );
    select * from bronze.hospitals_with_departements;


    TRUNCATE TABLE bronze.emergency_passages;
    BULK INSERT bronze.emergency_passages
    FROM 'C:\Users\pcc\Documents\WISD\S3\BDA\Hospital_project\emergency_with_id.csv'
    WITH
    (
        FIRSTROW = 2,               -- skip header
        FIELDTERMINATOR = ';',       -- column separator
        CODEPAGE = '65001',          -- UTF-8 support
        KEEPNULLS,
        TABLOCK
    );
    select * from bronze.emergency_passages;


    TRUNCATE TABLE bronze.medecins;
    BULK INSERT bronze.medecins
    FROM 'C:\Users\pcc\Documents\WISD\S3\BDA\Hospital_project\medecins_modified.csv'
    WITH
    (
        FIRSTROW = 2,               -- skip header
        FIELDTERMINATOR = ';',
        ROWTERMINATOR  = '\n',-- column separator
        CODEPAGE = '65001',          -- UTF-8 support
        KEEPNULLS,
        TABLOCK
    );

    select * from bronze.medecins;
END

select distinct cpt_num from bronze.hospitals_with_departements;



