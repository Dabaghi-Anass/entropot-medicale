from openai import OpenAI
API_KEY = "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"

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key=API_KEY,
)

def prompt_generator_llm(prompt: str) -> str:
  row = """
010001,SOUTHEAST HEALTH MEDICAL CENTER,1108 ROSS CLARK CIRCLE,DOTHAN,AL,36301,HOUSTON,(334) 793-8701,Acute Care Hospitals,Government - Hospital District or Authority,Yes,Y,4,,7,7,0,7,0,,8,7,3,4,0,,11,11,0,11,0,,8,8,,12,11,"""
  """Generate a CSV-formatted prompt from database schema for RAG system."""
  schema_context = f"""Based on the following database schema, generate a comprehensive prompt based on informations from user prompt for a RAG system in CSV format without csv HEADERS, usage_guidelines.
  example csv row used in rag:
  {row}
  example input:
  hi how are you
  output:
  ""
  example input:
  what are hospitals in california with phone number (870) 836-1000
  output:
  California, (870) 836-1000
  now answer the following User Prompt: {prompt}
Return only valid CSV format without csv headers."""
  
  completion = client.chat.completions.create(
    extra_body={},
    model="x-ai/grok-4.1-fast",
    messages=[
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": schema_context
          }
        ]
      }
    ]
  )
  return completion.choices[0].message.content

def ask_llm(prompt: str, resources: str) -> str:
  system_instruction = """You are a helpful hospitality database assistant. Use from the provided context relevant information, return a markdown formatted response. if the user query is not related to hospitality database, return the attribut "include_resources": false in your answer.
  output format:
  ```
  {
    "answer": "your answer here",
    "include_resources": true/false
  }
  ```"""

  completion = client.chat.completions.create(
    extra_body={},
    model="x-ai/grok-4.1-fast",
    messages=[
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": f"{system_instruction}\nContext: {resources}\nUser Prompt: {prompt}"
          }
        ]
      }
    ]
  )
  out = completion.choices[0].message.content
  out = out.replace("```json", "").replace("```", "").strip()
  return out

def query_llm(prompt: str) -> str:
  completion = client.chat.completions.create(
    extra_body={},
    model="x-ai/grok-4.1-fast",
    messages=[
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": prompt
          }
        ]
      }
    ]
  )
  return completion.choices[0].message.content