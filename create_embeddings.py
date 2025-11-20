import os
from RAG_SYSTEM import HospitalityRAGSystem

def save_embeddings():
    rag = HospitalityRAGSystem(
        persist_directory="./vectorstore_hospitality"
    )
    data_path = "Hospital_General_Information.csv"
    if os.path.exists(data_path):
        rag.setup_from_scratch(data_path=data_path)
    else:
        print(f"❌ Path not found: {data_path}")


if __name__ == "__main__":
    save_embeddings()
