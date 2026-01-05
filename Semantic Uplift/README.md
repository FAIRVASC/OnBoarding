# Italian ANCA-Associated Vasculitis Registry

\[ *What is Italivas?* \] → *Work in progress*

Contact for data uplift in FAIRVASC: [miki-tesi](https://github.com/miki-tesi)

# Semantic uplift of Italian registry data

## PREMISE: REDCap data export 

The patient data that these mappings are done upon was exported in REDCap such that it is limited to **AAV patients only** (i.e. should there be any non-AAV patients, they will be excluded) without any overlap syndrome. To do this, a specific REDCap report was made *ad hoc* called “AAV patients only” that includes all data fields but filters only those records that meet the following selection criteria. When applying the filter, the *“Show data for all repeating instruments/events for each record returned”* checkbox must be left ticked as it is by default, so as to apply the filter by record rather than by instrument or by row.
HOW TO DO THIS: Once opened the REDCap page of the project of interest (the FAIRVASC project), the path to follow in order to create the new report is: Applications → Data Exports, Reports, and Stats → Create New Report. Then, here: in STEP 2, all data fields must be included, and in STEP 3, after ensuring that the *“Show data for all repeating instruments/events for each record returned”* checkbox is ticked (it should be by default), a filter must be applied by setting: 
- ‘small_vessel_vas_anca’ as NOT equal to blank, AND
- ‘small_vessel_vas_immune’ as equal to blank, AND
- ‘secondary_vasculitis’ as NOT equal to ‘Yes’, AND
- ‘medium_vessel_vasculitis’ as equal to blank, AND
- ‘large_vessel_vasculitis’ as equal to blank, AND
- ‘variable_vessel_vasculitis’ as equal to blank

If the REDCap data export is done by following these guidelines, then **no pre-processing** of the patient data will be needed in order to run the following mappings with R2RML. 

## Details worth knowing on how the mappings were done

- When mapping the 'tracheal involvement' to the "generic" version of the organ pattern (as opposed to the "specific" version), this kind of involvement was equated to the ENT involvement (as there was no specific term for that).
- Regarding the diagnosis section, there is no 'dateOfCarePathwayStart' in the EUVAS registry model, thus the date of diagnosis was mapped as the care start date. 
- The 'inclusion type' property comment in the ontology says: "Possible values are: 'Prospective', 'Retrospective'. If date of consent <= 6 months after date of diagnosis then use 'Prospective'. If date of consent > 6 months after date of diagnosis then use 'Retrospective'." The date of enrolment in the registry was used rather than the date of consent, as the exact date of consent is often unavailable for most patients.
- Among the possible string values for the diagnosis classification, 'Clinical' was used (for all patients), since diagnosis was not done according to anyone specific diagnostic criterion.
- Among the possible URIs for the comorbidities, there is no mention of "Peripheral Vascular Disorder" and "Osteoporotic Fracture" in the EUVAS registry model, so these values were left unmapped. 
- Possible URIs are not specified for the 'treatmentType' property (so NCIT was used based on the code of the other FAIRVASC registries, even though the EUVAS model refers to this other ontology instead: https://bioportal.bioontology.org/ontologies/ATC/).   
- Route of administration: except for corticosteroids and cyclophosphamide, where oral is distinguished from intravenous in the registry, the route of administration was mapped (even though not explicitly indicated in the registry) for those drugs that are known to have only one possible route of administration according to this schema: azathioprine - oral; rituximab - intravenous; leflunomide - oral; methotrexate - oral (even though this isn’t the only possible route of administration for methotrexate); mycophenolate mofetil - oral; plasmapheresis - intravenous. The route of administration was not mapped for the drugs that are not listed here.
- With regard to the sections named <#induction_other> and <#maintenance_other>, It was checked manually which drugs were entered at least once, and then a 'CASE' statement was used to convert every ATC code to the corresponding NCIT code.
- In the FAIRVASC ontology, the ‘ESKDApproximation’ property is described as “An approximate definition for ESKD defined by a specific registry”. In the EUVAS model, there is a form that must be filled out if the patient is in ESKD, where the definition of ESKD is the same as the standard definition, and there’s nothing such as an approximate definition. So the property ‘ESKDApproximation’ was not mapped at all.
- With regard to the ‘death’ property (“Did death occur?”), there isn’t such a simple boolean variable in the EUVAS model. Instead, there’s a form that must be filled out if the patient died, wherein information on the death is entered. Thus a compensatory solution was opted for where the patient is mapped as “dead” if and only if there is some data in the ‘date_of_death’ column or in the ‘cause_of_death’ column.
- Like in the ‘death’ property case. As the EUVAS model lacks any boolean ESKD variable, any patient was mapped as being in ESKD if and only if there’s some data in the ‘date_dialysis_start’ column or in the ‘date_dialysis_stop’ column or in the ‘dialysis_type’ column.
- In the EUVAS model there isn’t an element corresponding to the ‘lastRecordedContact’ property. Thus, a compensatory algorithm was used: if there’s a date of death for the patient, then that becomes the last recorded contact, otherwise the date of the last visit is chosen.
- In the EUVAS model, two fields regarding the cause of death must be entered when filling out the “Death” form for a given patient. One of them is less granular and allows four possible values ("Vasculitis Related","Treatment Related","Not Vasculitis related","Unknown Cause of Death") whereas the other one refers to the SNOMED-CT ontology and allows all possible values from this ontology, each of them corresponding to a cause of death (a subset of these possible values is provided in the “data dictionary” - that can be downloaded from REDCap - but it looks totally arbitrary if not even random). On the other hand, the ‘causeOfDeath’ property from the FAIRVASC ontology allows the values 'Vasculitis', 'Malignancy', 'Infection', 'Cardiovascular', 'Other', 'Unknown'. What was done is: if the cause of death is ‘Vasculitis Related’ then it was mapped to ‘Vasculitis’, if the cause of death is ‘Unknown Cause of Death’ then it was mapped to ‘Unknown’. If instead it is neither of these two cases, then it’s looked for if any SNOMED-CT cause of death was entered for the patient, in which case that one is mapped to the appropriate ‘causeOfDeath’ property string value allowed in the FAIRVASC ontology.
- The ‘complicationSeverity’ property was mapped to a string value (possible values: 'ctcae_mild_selfmanaged', 'ctcae_moderate_outpatient', 'ctcae_severe_inpatient', 'ctcae_life_threatening', 'ctcae_death') like the other registries did, even though the FAIRVASC ontology prescribes that this property has range xsd:anyURI. 
- The severity for the thromboembolic type of complications was not mapped as there’s no rating of their severity in our registry, unlike infections, malignancies and cardiovascular complications.
- When the value is entered in the registry for complement c3 and c4, the unit of measure is not indicated, so it happened that for some patients it was entered as mg/dl (c3 found in approximate range 20.00-250.00 and c4 in range 15.00-60.00) and for some others as g/l (c3 range: 0.00-2.50 and c4 range 0.00-4.00). So a ‘CASE’ statement was used to divide the value by 100 (to convert from mg/dl to g/l) whenever it was greater than 15 for c3 and greater than 10 for c4.   
- 'MpoTest' was mapped to fvc:mpoTitreDefault (possible values ‘Positive’, ‘Negative’, ‘Not available’) rather than fvc:mpoTitre (possible values 'Negative', 'Low positive', 'High positive', 'Not available'). The same for 'Pr3Test' as well.
- The date of extraction of the patient data csv file (the raw matter for these mappings) is manually updated every time a new extraction is done.  
- Patients give their consent for the inclusion of their data in Italivas by signing a dedicated form. This form include consent for including the patient data in the registry (mapped through the fvc:RegistryConsent property) and for collecting a biological sample that will be stored in a biobank (mapped through the fvc:BiobankConsent property), but do not include the consent for future contact.   

## Mapping Guide

- Pull this directory
- Rename your input .csv file into "FV_PATIENTDATA.CSV" and move it into the pulled directory
- If not already installed, installa Java (https://www.java.com/en/)
- Open a shell, move inside the pulled directory and type: “java
-jar r2rml.jar config.properties”
