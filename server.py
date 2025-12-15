from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from RAG_SYSTEM import HospitalityRAGSystem
import uvicorn
import mysql.connector
from mysql.connector import Error
from packages.llm import prompt_generator_llm, ask_llm

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="0000",
            database="hospital_warehouse"
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def run_select_query(query):
    connection = get_db_connection()
    if connection is None:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query)
        results = cursor.fetchall()
        return results
    except Error as e:
        print(f"Error executing query: {e}")
        return None
    finally:
        cursor.close()
        connection.close()

def fetch_facilities_with_details(facility_ids: list):
    if not facility_ids:
        return []
    
    placeholders = ','.join(['%s'] * len(facility_ids))
    query = f"""
    SELECT 
        f.FacilityID,
        f.FacilityName,
        f.OverallRating,
        f.OverallRatingFootnote,
        l.City,
        l.State,
        l.County,
        l.Country,
        l.ZIPCode,
        c.Address,
        c.Telephone,
        h.HospitalType,
        h.HospitalOwnership,
        h.EmergencyServices,
        h.BirthingFriendlyDesignation,
        m.FacilityMORTMeasures,
        s.FacilitySafetyMeasures,
        r.FacilityREADMMeasures,
        e.FacilityPtExpMeasures,
        e.FacilityTEMeasures
    FROM Facility f
    LEFT JOIN DimLocation l ON f.LocationID = l.LocationID
    LEFT JOIN DimContact c ON f.ContactID = c.ContactID
    LEFT JOIN DimHospitalAttributes h ON f.HospitalAttributesID = h.HospitalAttributesID
    LEFT JOIN MortalityMeasures m ON f.FacilityID = m.FacilityID
    LEFT JOIN SafetyMeasures s ON f.FacilityID = s.FacilityID
    LEFT JOIN ReadmissionMeasures r ON f.FacilityID = r.FacilityID
    LEFT JOIN ExperienceAndTE e ON f.FacilityID = e.FacilityID
    WHERE f.FacilityID IN ({placeholders})
    """
    
    connection = get_db_connection()
    if connection is None:
        return []
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query, facility_ids)
        results = cursor.fetchall()
        return results
    except Error as e:
        print(f"Error executing query: {e}")
        return []
    finally:
        cursor.close()
        connection.close()

rag = HospitalityRAGSystem(
    persist_directory="./vectorstore_hospitality"
)
rag.load_vectorstore()

class QueryRequest(BaseModel):
    query: str
def generate_prompt(request: QueryRequest) -> str:
    return request.query
async def retrieve_documents(prompt: str):
    ids = rag.get_similar_documents(prompt, k=10)

    results = fetch_facilities_with_details(ids)
    return results

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

@app.post("/ask")
async def generate_completions(request: QueryRequest):
    prompt = prompt_generator_llm(request.query)
    documents = await retrieve_documents(prompt)
    answer = ask_llm(request.query, str(documents))

    return {"prompt": prompt, "answer": answer, "resources": documents}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)