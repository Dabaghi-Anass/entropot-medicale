import csv
import json

input_file = "Hospitals.csv"
output_file = "output.jsonl"

def mappedData(data):
    return {
        "Facility": {
            "FacilityID": data.get("Facility ID"),
            "FacilityName": data.get("Facility Name"),
            "LocationID": data.get("Facility ID"),  # Assuming LocationID maps to Facility ID
            "ContactID": data.get("Facility ID"),   # Assuming ContactID maps to Facility ID
            "HospitalAttributesID": data.get("Facility ID"),  # Assuming same mapping
            "OverallRating": data.get("Hospital overall rating"),
            "OverallRatingFootnote": data.get("Hospital overall rating footnote")
        },
        "DimLocation": {
            "LocationID": data.get("Facility ID"),
            "City": data.get("City/Town"),
            "State": data.get("State"),
            "County": data.get("County/Parish"),
            "Country": "USA",  # Assuming all are in the USA if not in data
            "ZIPCode": data.get("ZIP Code")
        },
        "DimContact": {
            "ContactID": data.get("Facility ID"),
            "Address": data.get("Address"),
            "Telephone": data.get("Telephone Number")
        },
        "DimHospitalAttributes": {
            "HospitalAttributesID": data.get("Facility ID"),
            "HospitalType": data.get("Hospital Type"),
            "HospitalOwnership": data.get("Hospital Ownership"),
            "EmergencyServices": data.get("Emergency Services"),
            "BirthingFriendlyDesignation": data.get("Meets criteria for birthing friendly designation")
        },
        "MortalityMeasures": {
            "FacilityID": data.get("Facility ID"),
            "MORTGroupMeasureCount": data.get("MORT Group Measure Count"),
            "FacilityMORTMeasures": data.get("Count of Facility MORT Measures"),
            "MORTBetter": data.get("Count of MORT Measures Better"),
            "MORTNoDifferent": data.get("Count of MORT Measures No Different"),
            "MORTWorse": data.get("Count of MORT Measures Worse"),
            "MORTFootnote": data.get("MORT Group Footnote")
        },
        "SafetyMeasures": {
            "FacilityID": data.get("Facility ID"),
            "SafetyGroupMeasureCount": data.get("Safety Group Measure Count"),
            "FacilitySafetyMeasures": data.get("Count of Facility Safety Measures"),
            "SafetyBetter": data.get("Count of Safety Measures Better"),
            "SafetyNoDifferent": data.get("Count of Safety Measures No Different"),
            "SafetyWorse": data.get("Count of Safety Measures Worse"),
            "SafetyFootnote": data.get("Safety Group Footnote")
        },
        "ReadmissionMeasures": {
            "FacilityID": data.get("Facility ID"),
            "READMGroupMeasureCount": data.get("READM Group Measure Count"),
            "FacilityREADMMeasures": data.get("Count of Facility READM Measures"),
            "READMBetter": data.get("Count of READM Measures Better"),
            "READMNoDifferent": data.get("Count of READM Measures No Different"),
            "READMWorse": data.get("Count of READM Measures Worse"),
            "READMFootnote": data.get("READM Group Footnote")
        },
        "ExperienceAndTE": {
            "FacilityID": data.get("Facility ID"),
            "PtExpGroupMeasureCount": data.get("Pt Exp Group Measure Count"),
            "FacilityPtExpMeasures": data.get("Count of Facility Pt Exp Measures"),
            "PtExpFootnote": data.get("Pt Exp Group Footnote"),
            "TEGroupMeasureCount": data.get("TE Group Measure Count"),
            "FacilityTEMeasures": data.get("Count of Facility TE Measures"),
            "TEFootnote": data.get("TE Group Footnote")
        },
        "Footnote": {
            "FootnoteID": None,  # Not in CSV
            "FootnoteText": None  # Not in CSV
        }
    }

results = []

with open(input_file, newline='') as f:
    reader = csv.DictReader(f)

    for row in reader:
        result = mappedData(row)
        results.append(result)

with open(output_file, "w") as out:
    json.dump(results, out, indent=2)
