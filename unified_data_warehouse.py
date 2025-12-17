#!/usr/bin/env python3
"""
Comprehensive ETL Script for Medical Data Warehouse
Processes all tables, unifies shared columns, and builds data warehouse with time dimension
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os
import json
import sqlite3
from pathlib import Path

class MedicalDataWarehouse:
    def __init__(self, data_dir="data"):
        self.data_dir = Path(data_dir)
        self.db_path = Path("medical_warehouse.db")
        self.conn = None
        self.setup_database()

    def setup_database(self):
        """Initialize SQLite database with all necessary tables"""
        self.conn = sqlite3.connect(self.db_path)

        # Enable foreign keys
        self.conn.execute("PRAGMA foreign_keys = ON")

        # Create bronze layer tables
        self.create_bronze_tables()

        # Create silver layer tables
        self.create_silver_tables()

        # Create gold layer (data warehouse) tables
        self.create_gold_tables()

    def create_bronze_tables(self):
        """Create raw data tables (bronze layer)"""
        queries = [
            """
            CREATE TABLE IF NOT EXISTS bronze_hospitals_paris (
                id INTEGER PRIMARY KEY,
                name TEXT,
                address TEXT,
                phone TEXT,
                latitude REAL,
                longitude REAL,
                capacity TEXT,
                description TEXT,
                services TEXT,
                url TEXT,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS bronze_hospitals_departements (
                __id INTEGER PRIMARY KEY,
                finess_et TEXT,
                finess_ej TEXT,
                raison_sociale TEXT,
                raison_sociale_entite_juridique TEXT,
                adresse_administrative_1 TEXT,
                adresse_administrative_2 TEXT,
                num_voie TEXT,
                cpt_num TEXT,
                type_voie TEXT,
                voie TEXT,
                adresse_complete TEXT,
                complement_adresse TEXT,
                num_dept TEXT,
                dept TEXT,
                cp_ville TEXT,
                num_tel TEXT,
                num_fax TEXT,
                num_cat TEXT,
                categorie_de_l_etablissement TEXT,
                num_type TEXT,
                type_etablissement TEXT,
                num_siret TEXT,
                code_ape TEXT,
                code_tarif TEXT,
                lib_tarification TEXT,
                code_psph TEXT,
                participant_service_public_hospitalier TEXT,
                date_ouverture TEXT,
                lat REAL,
                lng REAL,
                wgs84 TEXT,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS bronze_emergency_passages (
                id TEXT,
                code_departement TEXT,
                date_de_passage TEXT,
                sursaud_cl_age_corona TEXT,
                nbre_pass_corona INTEGER,
                nbre_pass_tot INTEGER,
                nbre_hospit_corona INTEGER,
                nbre_pass_corona_h INTEGER,
                nbre_pass_corona_f INTEGER,
                nbre_pass_tot_h INTEGER,
                nbre_pass_tot_f INTEGER,
                nbre_hospit_corona_h INTEGER,
                nbre_hospit_corona_f INTEGER,
                nbre_acte_corona INTEGER,
                nbre_acte_tot INTEGER,
                nbre_acte_corona_h INTEGER,
                nbre_acte_corona_f INTEGER,
                nbre_acte_tot_h INTEGER,
                nbre_acte_tot_f INTEGER,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS bronze_medecins (
                id TEXT PRIMARY KEY,
                N_RPPS TEXT,
                Nom TEXT,
                Prenom TEXT,
                Specialite TEXT,
                Date_accreditation TEXT,
                OA TEXT,
                Nom_equipe TEXT,
                Departement TEXT,
                FINESS TEXT,
                Statut TEXT,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        ]

        for query in queries:
            self.conn.execute(query)
        self.conn.commit()

    def create_silver_tables(self):
        """Create unified and cleaned tables (silver layer)"""
        queries = [
            """
            CREATE TABLE IF NOT EXISTS silver_unified_hospitals (
                unified_id INTEGER PRIMARY KEY AUTOINCREMENT,
                source_table TEXT,
                original_id TEXT,
                hospital_name TEXT,
                hospital_name_clean TEXT,
                address TEXT,
                city TEXT,
                postal_code TEXT,
                department TEXT,
                region TEXT,
                country TEXT DEFAULT 'France',
                phone TEXT,
                fax TEXT,
                latitude REAL,
                longitude REAL,
                facility_type TEXT,
                facility_category TEXT,
                ownership_type TEXT,
                operational_status TEXT DEFAULT 'Active',
                capacity_beds INTEGER,
                services TEXT,
                website TEXT,
                finess_code TEXT,
                siret_code TEXT,
                opening_date DATE,
                accreditation_info TEXT,
                source_id INTEGER,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                dwh_update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS silver_unified_emergency_passages (
                passage_id TEXT PRIMARY KEY,
                hospital_id INTEGER,
                passage_date DATE,
                age_category TEXT,
                total_passages INTEGER DEFAULT 0,
                corona_passages INTEGER DEFAULT 0,
                corona_hospitalizations INTEGER DEFAULT 0,
                passages_male INTEGER DEFAULT 0,
                passages_female INTEGER DEFAULT 0,
                corona_passages_male INTEGER DEFAULT 0,
                corona_passages_female INTEGER DEFAULT 0,
                corona_hosp_male INTEGER DEFAULT 0,
                corona_hosp_female INTEGER DEFAULT 0,
                total_acts INTEGER DEFAULT 0,
                corona_acts INTEGER DEFAULT 0,
                acts_male INTEGER DEFAULT 0,
                acts_female INTEGER DEFAULT 0,
                corona_acts_male INTEGER DEFAULT 0,
                corona_acts_female INTEGER DEFAULT 0,
                department_code TEXT,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS silver_unified_medecins (
                doctor_id TEXT PRIMARY KEY,
                rpps_number TEXT,
                first_name TEXT,
                last_name TEXT,
                full_name TEXT,
                specialty TEXT,
                accreditation_date DATE,
                organization_accreditation TEXT,
                team_name TEXT,
                department TEXT,
                finess_code TEXT,
                hospital_id INTEGER,
                employment_status TEXT,
                dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        ]

        for query in queries:
            self.conn.execute(query)
        self.conn.commit()

    def create_gold_tables(self):
        """Create data warehouse tables (gold layer)"""
        queries = [
            """
            CREATE TABLE IF NOT EXISTS dim_time (
                time_id INTEGER PRIMARY KEY,
                date DATE,
                day INTEGER,
                month INTEGER,
                year INTEGER,
                quarter INTEGER,
                day_of_week INTEGER,
                day_name TEXT,
                month_name TEXT,
                is_weekend BOOLEAN,
                is_holiday BOOLEAN DEFAULT FALSE,
                holiday_name TEXT
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_regions (
                region_id INTEGER PRIMARY KEY AUTOINCREMENT,
                region_name TEXT UNIQUE,
                region_code TEXT,
                country TEXT DEFAULT 'France'
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_departments (
                department_id INTEGER PRIMARY KEY AUTOINCREMENT,
                department_name TEXT UNIQUE,
                department_code TEXT,
                region_id INTEGER,
                FOREIGN KEY (region_id) REFERENCES dim_regions(region_id)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_cities (
                city_id INTEGER PRIMARY KEY AUTOINCREMENT,
                city_name TEXT,
                postal_code TEXT,
                department_id INTEGER,
                latitude REAL,
                longitude REAL,
                FOREIGN KEY (department_id) REFERENCES dim_departments(department_id)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_facility_types (
                facility_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
                facility_type_name TEXT UNIQUE,
                facility_category TEXT
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_ownership_types (
                ownership_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
                ownership_type_name TEXT UNIQUE
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_sources (
                source_id INTEGER PRIMARY KEY AUTOINCREMENT,
                source_name TEXT UNIQUE,
                source_description TEXT
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_hospitals (
                hospital_id INTEGER PRIMARY KEY AUTOINCREMENT,
                hospital_name TEXT,
                hospital_name_clean TEXT,
                address TEXT,
                city_id INTEGER,
                department_id INTEGER,
                region_id INTEGER,
                phone TEXT,
                fax TEXT,
                latitude REAL,
                longitude REAL,
                facility_type_id INTEGER,
                ownership_type_id INTEGER,
                operational_status TEXT,
                capacity_beds INTEGER,
                services TEXT,
                website TEXT,
                finess_code TEXT,
                siret_code TEXT,
                opening_date DATE,
                accreditation_info TEXT,
                source_id INTEGER,
                is_active BOOLEAN DEFAULT TRUE,
                FOREIGN KEY (city_id) REFERENCES dim_cities(city_id),
                FOREIGN KEY (department_id) REFERENCES dim_departments(department_id),
                FOREIGN KEY (region_id) REFERENCES dim_regions(region_id),
                FOREIGN KEY (facility_type_id) REFERENCES dim_facility_types(facility_type_id),
                FOREIGN KEY (ownership_type_id) REFERENCES dim_ownership_types(ownership_type_id),
                FOREIGN KEY (source_id) REFERENCES dim_sources(source_id)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS dim_doctors (
                doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
                rpps_number TEXT UNIQUE,
                first_name TEXT,
                last_name TEXT,
                full_name TEXT,
                specialty TEXT,
                accreditation_date DATE,
                organization_accreditation TEXT,
                team_name TEXT,
                department TEXT,
                employment_status TEXT,
                is_active BOOLEAN DEFAULT TRUE
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS fact_emergency_passages (
                fact_id INTEGER PRIMARY KEY AUTOINCREMENT,
                time_id INTEGER,
                hospital_id INTEGER,
                doctor_id INTEGER,
                department_id INTEGER,
                age_category TEXT,
                total_passages INTEGER DEFAULT 0,
                corona_passages INTEGER DEFAULT 0,
                corona_hospitalizations INTEGER DEFAULT 0,
                passages_male INTEGER DEFAULT 0,
                passages_female INTEGER DEFAULT 0,
                corona_passages_male INTEGER DEFAULT 0,
                corona_passages_female INTEGER DEFAULT 0,
                corona_hosp_male INTEGER DEFAULT 0,
                corona_hosp_female INTEGER DEFAULT 0,
                total_acts INTEGER DEFAULT 0,
                corona_acts INTEGER DEFAULT 0,
                acts_male INTEGER DEFAULT 0,
                acts_female INTEGER DEFAULT 0,
                corona_acts_male INTEGER DEFAULT 0,
                corona_acts_female INTEGER DEFAULT 0,
                source_record_id TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
                FOREIGN KEY (hospital_id) REFERENCES dim_hospitals(hospital_id),
                FOREIGN KEY (doctor_id) REFERENCES dim_doctors(doctor_id),
                FOREIGN KEY (department_id) REFERENCES dim_departments(department_id)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS fact_hospital_stats (
                fact_id INTEGER PRIMARY KEY AUTOINCREMENT,
                hospital_id INTEGER,
                time_id INTEGER,
                stat_type TEXT,
                stat_value INTEGER,
                stat_description TEXT,
                source_id INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (hospital_id) REFERENCES dim_hospitals(hospital_id),
                FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
                FOREIGN KEY (source_id) REFERENCES dim_sources(source_id)
            )
            """
        ]

        for query in queries:
            self.conn.execute(query)
        self.conn.commit()

    def load_bronze_data(self):
        """Load raw data into bronze layer"""
        print("Loading bronze layer data...")

        # Load Paris hospitals
        paris_file = self.data_dir / "hospitals_paris_clean.csv"
        if paris_file.exists():
            df_paris = pd.read_csv(paris_file)
            df_paris.to_sql('bronze_hospitals_paris', self.conn, if_exists='replace', index=False)
            print(f"Loaded {len(df_paris)} Paris hospitals")

        # Load departmental hospitals
        dept_file = self.data_dir / "departements.csv"
        if dept_file.exists():
            df_dept = pd.read_csv(dept_file, low_memory=False)
            df_dept.to_sql('bronze_hospitals_departements', self.conn, if_exists='replace', index=False)
            print(f"Loaded {len(df_dept)} departmental hospitals")

        # Load emergency passages
        emergency_file = self.data_dir / "emergency_with_id.csv"
        if emergency_file.exists():
            df_emergency = pd.read_csv(emergency_file, sep=';')
            df_emergency.to_sql('bronze_emergency_passages', self.conn, if_exists='replace', index=False)
            print(f"Loaded {len(df_emergency)} emergency passages")

        # Load doctors
        doctors_file = self.data_dir / "medecins_modified.csv"
        if doctors_file.exists():
            df_doctors = pd.read_csv(doctors_file, sep=';', low_memory=False)
            df_doctors.to_sql('bronze_medecins', self.conn, if_exists='replace', index=False)
            print(f"Loaded {len(df_doctors)} doctors")

    def process_silver_data(self):
        """Process and unify data in silver layer"""
        print("Processing silver layer data...")

        # Process Paris hospitals
        df_paris = pd.read_sql("SELECT * FROM bronze_hospitals_paris", self.conn)
        unified_paris = self.unify_paris_hospitals(df_paris)
        unified_paris.to_sql('silver_unified_hospitals', self.conn, if_exists='append', index=False)

        # Process departmental hospitals
        df_dept = pd.read_sql("SELECT * FROM bronze_hospitals_departements", self.conn)
        unified_dept = self.unify_departmental_hospitals(df_dept)
        unified_dept.to_sql('silver_unified_hospitals', self.conn, if_exists='append', index=False)

        # Process emergency passages
        df_emergency = pd.read_sql("SELECT * FROM bronze_emergency_passages", self.conn)
        unified_emergency = self.unify_emergency_passages(df_emergency)
        unified_emergency.to_sql('silver_unified_emergency_passages', self.conn, if_exists='replace', index=False)

        # Process doctors
        df_doctors = pd.read_sql("SELECT * FROM bronze_medecins", self.conn)
        unified_doctors = self.unify_doctors(df_doctors)
        unified_doctors.to_sql('silver_unified_medecins', self.conn, if_exists='replace', index=False)

        print("Silver layer processing completed")

    def unify_paris_hospitals(self, df):
        """Unify Paris hospitals data"""
        unified = pd.DataFrame({
            'source_table': 'paris',
            'original_id': df['id'].astype(str),
            'hospital_name': df['name'],
            'hospital_name_clean': df['name'].str.replace(r'AP-HP\s+', '', regex=True)
                                                .str.replace(r'Hôpital\s+', '', regex=True)
                                                .str.replace(r'Hopital\s+', '', regex=True)
                                                .str.strip(),
            'address': df['address'],
            'city': df['address'].str.extract(r'(\d{5})\s+([^,]+)$')[1].fillna('Paris'),
            'postal_code': df['address'].str.extract(r'(\d{5})').fillna('75001'),
            'department': 'Paris',
            'region': 'Île-de-France',
            'phone': df['phone'],
            'latitude': pd.to_numeric(df['latitude'], errors='coerce'),
            'longitude': pd.to_numeric(df['longitude'], errors='coerce'),
            'capacity_beds': df['capacity'].str.extract(r'Médecine\s*:\s*(\d+)').astype(float),
            'services': df['services'],
            'website': df['url'],
            'source_id': 1
        })
        return unified

    def unify_departmental_hospitals(self, df):
        """Unify departmental hospitals data"""
        unified = pd.DataFrame({
            'source_table': 'departements',
            'original_id': df['__id'].astype(str),
            'hospital_name': df['raison_sociale'],
            'hospital_name_clean': df['raison_sociale'].str.replace(r'HOPITAL\s+', '', regex=True)
                                                       .str.replace(r'Hôpital\s+', '', regex=True)
                                                       .str.replace(r'CENTRE HOSPITALIER', 'CH')
                                                       .str.strip(),
            'address': df[['adresse_administrative_1', 'adresse_administrative_2', 'complement_adresse']].fillna('').agg(' '.join, axis=1).str.strip(),
            'city': df['cp_ville'],
            'postal_code': df['cp_ville'],
            'department': df['dept'],
            'region': df['dept'],
            'phone': df['num_tel'],
            'fax': df['num_fax'],
            'latitude': pd.to_numeric(df['lat'], errors='coerce'),
            'longitude': pd.to_numeric(df['lng'], errors='coerce'),
            'facility_type': df['type_etablissement'],
            'facility_category': df['categorie_de_l_etablissement'],
            'finess_code': df['finess_et'],
            'siret_code': df['num_siret'],
            'opening_date': pd.to_datetime(df['date_ouverture'], errors='coerce'),
            'source_id': 2
        })
        return unified

    def unify_emergency_passages(self, df):
        """Unify emergency passages data"""
        # Parse dates
        df['date_de_passage'] = pd.to_datetime(df['date_de_passage'], errors='coerce')

        unified = pd.DataFrame({
            'passage_id': df['id'],
            'passage_date': df['date_de_passage'],
            'age_category': df['sursaud_cl_age_corona'],
            'total_passages': pd.to_numeric(df['nbre_pass_tot'], errors='coerce').fillna(0).astype(int),
            'corona_passages': pd.to_numeric(df['nbre_pass_corona'], errors='coerce').fillna(0).astype(int),
            'corona_hospitalizations': pd.to_numeric(df['nbre_hospit_corona'], errors='coerce').fillna(0).astype(int),
            'passages_male': pd.to_numeric(df['nbre_pass_tot_h'], errors='coerce').fillna(0).astype(int),
            'passages_female': pd.to_numeric(df['nbre_pass_tot_f'], errors='coerce').fillna(0).astype(int),
            'corona_passages_male': pd.to_numeric(df['nbre_pass_corona_h'], errors='coerce').fillna(0).astype(int),
            'corona_passages_female': pd.to_numeric(df['nbre_pass_corona_f'], errors='coerce').fillna(0).astype(int),
            'corona_hosp_male': pd.to_numeric(df['nbre_hospit_corona_h'], errors='coerce').fillna(0).astype(int),
            'corona_hosp_female': pd.to_numeric(df['nbre_hospit_corona_f'], errors='coerce').fillna(0).astype(int),
            'total_acts': pd.to_numeric(df['nbre_acte_tot'], errors='coerce').fillna(0).astype(int),
            'corona_acts': pd.to_numeric(df['nbre_acte_corona'], errors='coerce').fillna(0).astype(int),
            'acts_male': pd.to_numeric(df['nbre_acte_tot_h'], errors='coerce').fillna(0).astype(int),
            'acts_female': pd.to_numeric(df['nbre_acte_tot_f'], errors='coerce').fillna(0).astype(int),
            'corona_acts_male': pd.to_numeric(df['nbre_acte_corona_h'], errors='coerce').fillna(0).astype(int),
            'corona_acts_female': pd.to_numeric(df['nbre_acte_corona_f'], errors='coerce').fillna(0).astype(int),
            'department_code': df['code_departement']
        })
        return unified

    def unify_doctors(self, df):
        """Unify doctors data"""
        # Parse accreditation dates
        df['Date_accreditation'] = pd.to_datetime(df['Date_accreditation'], errors='coerce')

        unified = pd.DataFrame({
            'doctor_id': df['id'],
            'rpps_number': df['N_RPPS'],
            'first_name': df['Prenom'],
            'last_name': df['Nom'],
            'full_name': df['Prenom'] + ' ' + df['Nom'],
            'specialty': df['Specialite'],
            'accreditation_date': df['Date_accreditation'],
            'organization_accreditation': df['OA'],
            'team_name': df['Nom_equipe'],
            'department': df['Departement'],
            'finess_code': df['FINESS'],
            'employment_status': df['Statut']
        })
        return unified

    def populate_data_warehouse(self):
        """Populate the final data warehouse (gold layer)"""
        print("Populating data warehouse...")

        # Populate time dimension
        self.populate_time_dimension()

        # Populate regions
        self.populate_regions()

        # Populate departments
        self.populate_departments()

        # Populate cities
        self.populate_cities()

        # Populate facility types
        self.populate_facility_types()

        # Populate ownership types
        self.populate_ownership_types()

        # Populate sources
        self.populate_sources()

        # Populate hospitals dimension
        self.populate_hospitals_dimension()

        # Populate doctors dimension
        self.populate_doctors_dimension()

        # Populate emergency passages fact table
        self.populate_emergency_passages_fact()

        print("Data warehouse population completed")

    def populate_time_dimension(self):
        """Populate time dimension with dates from 2020-2025"""
        dates = []
        start_date = datetime(2020, 1, 1)
        end_date = datetime(2025, 12, 31)

        current_date = start_date
        while current_date <= end_date:
            dates.append({
                'time_id': int(current_date.strftime('%Y%m%d')),
                'date': current_date.date(),
                'day': current_date.day,
                'month': current_date.month,
                'year': current_date.year,
                'quarter': (current_date.month - 1) // 3 + 1,
                'day_of_week': current_date.weekday() + 1,  # Monday = 1
                'day_name': current_date.strftime('%A'),
                'month_name': current_date.strftime('%B'),
                'is_weekend': current_date.weekday() >= 5
            })
            current_date += timedelta(days=1)

        df_time = pd.DataFrame(dates)
        df_time.to_sql('dim_time', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_time)} time dimension records")

    def populate_regions(self):
        """Populate regions dimension"""
        query = """
        SELECT DISTINCT region, region as region_code
        FROM silver_unified_hospitals
        WHERE region IS NOT NULL AND region != ''
        """
        df_regions = pd.read_sql(query, self.conn)
        df_regions.columns = ['region_name', 'region_code']
        df_regions.to_sql('dim_regions', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_regions)} region records")

    def populate_departments(self):
        """Populate departments dimension"""
        query = """
        SELECT DISTINCT uh.department, uh.num_dept as department_code, dr.region_id
        FROM silver_unified_hospitals uh
        JOIN dim_regions dr ON dr.region_name = uh.region
        WHERE uh.department IS NOT NULL AND uh.department != ''
        """
        df_departments = pd.read_sql(query, self.conn)
        df_departments.to_sql('dim_departments', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_departments)} department records")

    def populate_cities(self):
        """Populate cities dimension"""
        query = """
        SELECT DISTINCT uh.city, uh.postal_code, dd.department_id, uh.latitude, uh.longitude
        FROM silver_unified_hospitals uh
        JOIN dim_departments dd ON dd.department_name = uh.department
        WHERE uh.city IS NOT NULL AND uh.city != ''
        """
        df_cities = pd.read_sql(query, self.conn)
        df_cities.to_sql('dim_cities', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_cities)} city records")

    def populate_facility_types(self):
        """Populate facility types dimension"""
        query = """
        SELECT DISTINCT facility_type, facility_category
        FROM silver_unified_hospitals
        WHERE facility_type IS NOT NULL AND facility_type != ''
        """
        df_facility_types = pd.read_sql(query, self.conn)
        df_facility_types.to_sql('dim_facility_types', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_facility_types)} facility type records")

    def populate_ownership_types(self):
        """Populate ownership types dimension"""
        ownership_types = [
            {'ownership_type_name': 'Public'},
            {'ownership_type_name': 'Private'},
            {'ownership_type_name': 'Mixed'}
        ]
        df_ownership = pd.DataFrame(ownership_types)
        df_ownership.to_sql('dim_ownership_types', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_ownership)} ownership type records")

    def populate_sources(self):
        """Populate sources dimension"""
        sources = [
            {'source_name': 'Paris Hospitals', 'source_description': 'Official Paris hospital data'},
            {'source_name': 'French Departments', 'source_description': 'French departmental hospital data'},
            {'source_name': 'Emergency Passages', 'source_description': 'Emergency room visit statistics'}
        ]
        df_sources = pd.DataFrame(sources)
        df_sources.to_sql('dim_sources', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_sources)} source records")

    def populate_hospitals_dimension(self):
        """Populate hospitals dimension"""
        query = """
        SELECT
            uh.hospital_name,
            uh.hospital_name_clean,
            uh.address,
            dc.city_id,
            dd.department_id,
            dr.region_id,
            uh.phone,
            uh.fax,
            uh.latitude,
            uh.longitude,
            dft.facility_type_id,
            1 as ownership_type_id, -- Assume public ownership
            uh.capacity_beds,
            uh.services,
            uh.website,
            uh.finess_code,
            uh.siret_code,
            uh.opening_date,
            ds.source_id
        FROM silver_unified_hospitals uh
        LEFT JOIN dim_cities dc ON dc.city_name = uh.city AND dc.postal_code = uh.postal_code
        LEFT JOIN dim_departments dd ON dd.department_name = uh.department
        LEFT JOIN dim_regions dr ON dr.region_name = uh.region
        LEFT JOIN dim_facility_types dft ON dft.facility_type_name = uh.facility_type
        LEFT JOIN dim_sources ds ON (
            (uh.source_table = 'paris' AND ds.source_name = 'Paris Hospitals') OR
            (uh.source_table = 'departements' AND ds.source_name = 'French Departments')
        )
        """
        df_hospitals = pd.read_sql(query, self.conn)
        df_hospitals.to_sql('dim_hospitals', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_hospitals)} hospital records")

    def populate_doctors_dimension(self):
        """Populate doctors dimension"""
        df_doctors = pd.read_sql("SELECT * FROM silver_unified_medecins", self.conn)
        df_doctors.to_sql('dim_doctors', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_doctors)} doctor records")

    def populate_emergency_passages_fact(self):
        """Populate emergency passages fact table"""
        query = """
        SELECT
            strftime('%Y%m%d', uep.passage_date) as time_id,
            NULL as hospital_id,
            uep.age_category,
            uep.total_passages,
            uep.corona_passages,
            uep.corona_hospitalizations,
            uep.passages_male,
            uep.passages_female,
            uep.corona_passages_male,
            uep.corona_passages_female,
            uep.corona_hosp_male,
            uep.corona_hosp_female,
            uep.total_acts,
            uep.corona_acts,
            uep.acts_male,
            uep.acts_female,
            uep.corona_acts_male,
            uep.corona_acts_female,
            dd.department_id,
            uep.passage_id as source_record_id
        FROM silver_unified_emergency_passages uep
        LEFT JOIN dim_departments dd ON dd.department_code = uep.department_code
        WHERE uep.passage_date IS NOT NULL
        """
        df_facts = pd.read_sql(query, self.conn)
        df_facts.to_sql('fact_emergency_passages', self.conn, if_exists='replace', index=False)
        print(f"Populated {len(df_facts)} emergency passage fact records")

    def run_etl(self):
        """Run the complete ETL process"""
        print("Starting ETL process...")

        # Bronze layer
        self.load_bronze_data()

        # Silver layer
        self.process_silver_data()

        # Gold layer (data warehouse)
        self.populate_data_warehouse()

        print("ETL process completed successfully!")
        print(f"Database created at: {self.db_path}")

    def get_summary(self):
        """Get a summary of the data warehouse"""
        summary = {}

        tables = [
            'dim_time', 'dim_regions', 'dim_departments', 'dim_cities',
            'dim_facility_types', 'dim_ownership_types', 'dim_sources',
            'dim_hospitals', 'dim_doctors', 'fact_emergency_passages', 'fact_hospital_stats'
        ]

        for table in tables:
            try:
                count = pd.read_sql(f"SELECT COUNT(*) as count FROM {table}", self.conn)['count'].iloc[0]
                summary[table] = count
            except:
                summary[table] = 0

        return summary

    def close(self):
        """Close database connection"""
        if self.conn:
            self.conn.close()

def main():
    # Initialize data warehouse
    warehouse = MedicalDataWarehouse()

    try:
        # Run ETL process
        warehouse.run_etl()

        # Get summary
        summary = warehouse.get_summary()

        print("\n=== Data Warehouse Summary ===")
        for table, count in summary.items():
            print(f"{table}: {count} records")

        print("\n=== Sample Queries ===")
        print("1. Total emergency passages by department:")
        query1 = """
        SELECT dd.department_name, SUM(fep.total_passages) as total_passages
        FROM fact_emergency_passages fep
        JOIN dim_departments dd ON fep.department_id = dd.department_id
        GROUP BY dd.department_name
        ORDER BY total_passages DESC
        LIMIT 10
        """
        df1 = pd.read_sql(query1, warehouse.conn)
        print(df1)

        print("\n2. Hospitals by facility type:")
        query2 = """
        SELECT dft.facility_type_name, COUNT(*) as hospital_count
        FROM dim_hospitals dh
        JOIN dim_facility_types dft ON dh.facility_type_id = dft.facility_type_id
        GROUP BY dft.facility_type_name
        ORDER BY hospital_count DESC
        """
        df2 = pd.read_sql(query2, warehouse.conn)
        print(df2)

    finally:
        warehouse.close()

if __name__ == "__main__":
    main()