from packages.llm import query_llm
import pandas as pd

json_structure="""{
  "Facility": {
    "FacilityID": "Unique identifier of the facility",
    "FacilityName": "Name of the facility",
    "LocationID": "Reference to the facility's location record",
    "ContactID": "Reference to the facility's contact information",
    "HospitalAttributesID": "Reference to the hospital's attribute details",
    "OverallRating": "Overall rating score for the facility",
    "OverallRatingFootnote": "Footnote associated with the overall rating"
  },
  "DimLocation": {
    "LocationID": "Unique identifier of the location",
    "City": "City where the facility is located",
    "State": "State where the facility is located",
    "County": "County where the facility is located",
    "Country": "Country where the facility is located",
    "ZIPCode": "Postal ZIP code of the facility location"
  },
  "DimContact": {
    "ContactID": "Unique identifier of the contact information",
    "Address": "Physical address of the facility",
    "Telephone": "Telephone number of the facility"
  },
  "DimHospitalAttributes": {
    "HospitalAttributesID": "Unique identifier of the hospital attributes",
    "HospitalType": "Type/category of the hospital",
    "HospitalOwnership": "Ownership classification of the hospital",
    "EmergencyServices": "Indicates whether emergency services are available",
    "BirthingFriendlyDesignation": "Designation indicating birthing-friendly status"
  },
  "MortalityMeasures": {
    "FacilityID": "Reference to the facility",
    "MORTGroupMeasureCount": "Number of mortality group measures reported",
    "FacilityMORTMeasures": "Total mortality measures at the facility",
    "MORTBetter": "Count of mortality measures better than expected",
    "MORTNoDifferent": "Count of mortality measures with no significant difference",
    "MORTWorse": "Count of mortality measures worse than expected",
    "MORTFootnote": "Footnote associated with mortality measures"
  },
  "SafetyMeasures": {
    "FacilityID": "Reference to the facility",
    "SafetyGroupMeasureCount": "Number of safety group measures reported",
    "FacilitySafetyMeasures": "Total safety measures at the facility",
    "SafetyBetter": "Count of safety measures better than expected",
    "SafetyNoDifferent": "Count of safety measures with no significant difference",
    "SafetyWorse": "Count of safety measures worse than expected",
    "SafetyFootnote": "Footnote associated with safety measures"
  },
  "ReadmissionMeasures": {
    "FacilityID": "Reference to the facility",
    "READMGroupMeasureCount": "Number of readmission group measures reported",
    "FacilityREADMMeasures": "Total readmission measures at the facility",
    "READMBetter": "Count of readmission outcomes better than expected",
    "READMNoDifferent": "Count of readmission outcomes with no significant difference",
    "READMWorse": "Count of readmission outcomes worse than expected",
    "READMFootnote": "Footnote associated with readmission measures"
  },
  "ExperienceAndTE": {
    "FacilityID": "Reference to the facility",
    "PtExpGroupMeasureCount": "Number of patient experience group measures reported",
    "FacilityPtExpMeasures": "Total patient experience measures at the facility",
    "PtExpFootnote": "Footnote associated with patient experience measures",
    "TEGroupMeasureCount": "Number of timely and effective care group measures",
    "FacilityTEMeasures": "Timely and effective care measures at the facility",
    "TEFootnote": "Footnote associated with timely and effective care"
  },
  "Footnote": {
    "FootnoteID": "Unique identifier for the footnote entry",
    "FootnoteText": "Content or explanation provided as a footnote"
  }
}
"""
system_instructions = f"You are an agent that transforms hospitality data from csv files into structured JSON format, you must respond with valid json array (DO not include [ and ] symbols) not markdown of each table here is the structure of the json you must follow: {json_structure}, "
hospitals_dataframe = pd.read_csv("Hospital_General_Information.csv")
columns = hospitals_dataframe.columns.tolist()
all_outputs = []
for i in range(0, len(hospitals_dataframe), 50):
    rows = hospitals_dataframe.iloc[i:i+50]
    prompt = f"{system_instructions} here are the columns of the csv file: {columns}, here are the rows: {rows.to_dict(orient='records')}"
    output = query_llm(prompt)
    output = output.replace("```json", "")
    output = output.replace("```", "")
    all_outputs.append(output)
    
    print(f"Processed rows {i} to {i+50}")



with open("output.json", "w") as f:
    f.write("[" + ",".join(all_outputs) + "]")