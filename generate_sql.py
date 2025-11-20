import pandas as pd
import os
import json

file_path = os.path.join(os.path.dirname(__file__), "output.json")

with open(file_path, 'r') as f:
    data = json.load(f)

tables = list(data[0].keys())

sql_script = ["DROP DATABASE HOSPITAL_WAREHOUSE;", "CREATE DATABASE HOSPITAL_WAREHOUSE;", "USE HOSPITAL_WAREHOUSE;"]

for table in tables:
    if table == "Footnote":
        continue
    
    sample = data[0][table]
    if sample and isinstance(sample, dict):
        columns = list(sample.keys())
        col_defs = ", ".join([f"{col} TEXT" for col in columns])
        sql_script.append(f"CREATE TABLE IF NOT EXISTS {table} ({col_defs});")

for record in data:
    for table in tables:
        if table == "Footnote" or not record[table]:
            continue
        
        values = record[table]
        columns = list(values.keys())
        vals = [f"'{str(v).replace(chr(39), chr(39)*2)}'" if v else "NULL" for v in values.values()]
        
        sql_script.append(f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({', '.join(vals)});")

with open("hospital_schema.sql", "w") as f:
    f.write("\n".join(sql_script))

print("SQL script generated: hospital_schema.sql")