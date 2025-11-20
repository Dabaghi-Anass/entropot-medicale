import os
import json
from typing import List, Dict, Any
from pathlib import Path
from langchain_community.document_loaders import CSVLoader, TextLoader, DirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from langchain_huggingface import HuggingFaceEndpoint, HuggingFacePipeline
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough


class HospitalityRAGSystem:
    def __init__(self, 
                 data_path: str = None,
                 embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2",
                 persist_directory: str = "./vectorstore"):
        self.data_path = data_path
        self.embedding_model_name = embedding_model
        self.persist_directory = persist_directory
        self.vectorstore = None
        
        print("Initializing Hospitality Embeddings System...")
        print(f"Embedding model: {self.embedding_model_name}")
        
        self._initialize_embeddings()
        
    def _initialize_embeddings(self):
        print(f"Loading embedding model: {self.embedding_model_name}")
        self.embeddings = HuggingFaceEmbeddings(
            model_name=self.embedding_model_name,
            model_kwargs={'device': 'cpu'}
        )
        
    def load_data(self, data_path: str = None) -> List[Any]:
        """Load hospitality data from various sources"""
        if data_path:
            self.data_path = data_path
            
        if not self.data_path:
            raise ValueError("Please provide a data_path")
            
        print(f"Loading data from: {self.data_path}")
        
        documents = []
        path = Path(self.data_path)
        
        try:
            if path.is_file():
                if path.suffix.lower() == '.csv':
                    loader = CSVLoader(file_path=str(path))
                elif path.suffix.lower() in ['.txt', '.md']:
                    loader = TextLoader(file_path=str(path))
                else:
                    raise ValueError(f"Unsupported file type: {path.suffix}")
                documents = loader.load()
                
            elif path.is_dir():
                loader = DirectoryLoader(str(path), glob="**/*.txt", loader_cls=TextLoader)
                documents = loader.load()
                
                csv_loader = DirectoryLoader(str(path), glob="**/*.csv", loader_cls=CSVLoader)
                documents.extend(csv_loader.load())
                
            else:
                raise ValueError(f"Path does not exist: {self.data_path}")
                
            print(f"✅ Loaded {len(documents)} documents")
            return documents
            
        except Exception as e:
            print(f"❌ Error loading data: {e}")
            raise
            
        
    def split_documents(self, documents: List[Any], 
                       chunk_size: int = 1000, 
                       chunk_overlap: int = 200) -> List[Any]:
        print(f"Splitting documents into chunks (size={chunk_size}, overlap={chunk_overlap})")
        
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            length_function=len,
        )
        
        chunks = text_splitter.split_documents(documents)
        print(f"✅ Created {len(chunks)} chunks")
        return chunks
        
    def create_vectorstore(self, documents: List[Any], persist: bool = True):
        print("Creating vector store and embeddings...")
        
        self.vectorstore = FAISS.from_documents(
            documents=documents,
            embedding=self.embeddings
        )
        
        if persist:
            os.makedirs(self.persist_directory, exist_ok=True)
            self.vectorstore.save_local(self.persist_directory)
            print(f"💾 Embeddings saved to: {self.persist_directory}")
        
        print("✅ Embeddings created successfully")
        
    def load_vectorstore(self):
        """Load existing vector store from disk"""
        if not os.path.exists(self.persist_directory):
            raise ValueError(f"Vector store not found at: {self.persist_directory}")
            
        print(f"📥 Loading embeddings from: {self.persist_directory}")
        self.vectorstore = FAISS.load_local(
            self.persist_directory,
            self.embeddings,
            allow_dangerous_deserialization=True
        )
        print("✅ Embeddings loaded successfully")
        
    def setup_from_scratch(self, data_path: str = None, use_sample: bool = False):
        print("Creating embeddings from scratch...")
        try:
            if use_sample:
                print("Creating sample hospitality dataset...")
                data_path = self.create_sample_dataset()
                
            documents = self.load_data(data_path)
            chunks = self.split_documents(documents)
            self.create_vectorstore(chunks)
            
            print("\nEmbeddings saved successfully!")
            return True
            
        except Exception as e:
            print(f"\nSetup failed: {e}")
            return False
        
    def embed_prompt(self, prompt: str) -> List[float]:
        embedded_prompt = self.embeddings.embed_query(prompt)
        return embedded_prompt
    
    def get_similar_documents(self, prompt: str, k: int = 10) -> List[str]:
        if not self.vectorstore:
            raise ValueError("Vector store not loaded. Call load_vectorstore() first.")
        
        self.retriever = self.vectorstore.as_retriever(
            search_kwargs={"k": k}
        )
        
        similar_docs = self.retriever.invoke(prompt)
        
        facility_ids = []
        for doc in similar_docs:
            content = doc.page_content
            for line in content.split('\n'):
                if line.startswith('Facility ID:'):
                    facility_id = line.split(':', 1)[1].strip()
                    facility_ids.append(facility_id)
                    break
        
        return facility_ids
