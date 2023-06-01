-- AD Codes --

/*ICD9: 331.0 -> Unspecified AD. 
ICD10: G30.0 -> EOAD (Early Onset AD)
ICD10: G30.9 -> Unspecified AD
ICD10: G30.1 -> LOAD (Late Onset AD)
ICD10: G31.1 -> Senile degeneration of the brain
ICD10: G30.8 -> Other AD*/

---- Count distinct id of patients with EOAD -----------------

SELECT COUNT (DISTINCT person_id)
FROM IDEALIST.CDM.CONDITION_OCCURRENCE
WHERE condition_source_value = 'ICD10: G30.0';
ORDER BY person_id ASC;

---- Show distinct id of patients with EOAD -----------------

SELECT DISTINCT person_id
FROM IDEALIST.CDM.CONDITION_OCCURRENCE
WHERE condition_source_value = 'ICD10: G30.0';
ORDER BY person_id ASC;

---- Show patient id and notes by type of EOAD patient ----

SELECT CD.person_id, CD.condition_start_date, Note.note_text, Note.note_title
FROM IDEALIST.CDM.NOTE AS Note
    JOIN IDEALIST.CDM.CONDITION_OCCURRENCE AS CD
        ON (Note.person_id = CD.person_id)
WHERE CD.condition_source_value = 'ICD10: G30.0'
ORDER BY CD.person_id ASC;

-------- Query used to extract the data from rotation project ---------------
/*Showing EOAD patient with their personal data from the "order_narative: CONSULT" table
Dataset 1 is the same query but getting tables order_narative: IMAGING and order_impression: IMAGING.
Dataset 2 corresponds to the table "order_narative: CONSULT*/

SELECT CD.person_id,
       Person.birth_datetime,
       Person.gender_source_value,
       Person.race_source_value,
       Person.ethnicity_source_value,
       Note.note_title,
       Note.note_text
FROM IDEALIST.CDM.NOTE AS Note
JOIN IDEALIST.CDM.CONDITION_OCCURRENCE AS CD
ON (Note.person_id = CD.person_id)
JOIN IDEALIST.CDM.PERSON as Person
ON (CD.person_id = Person.person_id)
WHERE CD.condition_source_value = 'ICD10: G30.0' AND
      /*(note_title = 'order_narative: IMAGING' OR
       note_title = 'order_impression: IMAGING')  OR
       note_title = 'H&P (View-Only)' OR
       note_title = 'H&P' OR */
       note_title = 'order_narative: CONSULT'
ORDER BY CD.person_id ASC;

---- See existing codes in DB associated with PD -------------

SELECT DISTINCT condition_source_value
FROM IDEALIST.CDM.CONDITION_OCCURRENCE
WHERE (condition_source_value LIKE '%ICD10: G20%' OR condition_source_value LIKE '%ICD10: G21%')
ORDER BY condition_source_value ASC;

-- PD Codes in DB --

ICD10:G20 and ICD10:G21 refere to idiophatic PD and secondary PD respectively (PD caused by other factors. )

/*
ICD9: 332.0 -> Paralysis agitans (PD)
ICD9: 332.1 -> Secondary parkinsonism
ICD10: G20 -> Parkinson's disease. 
ICD10: G21.0 -> Malignant neuroleptic syndrome
ICD10: G21.11 -> Neuroleptic induced parkinsonism
ICD10: G21.19 -> Other drug induced secondary parkinsonism
ICD10: G21.2 -> Secondary parkinsonism due to other external agents
ICD10: G21.3 -> Postencephalitic parkinsonism
ICD10: G21.4 -> Vascular parkinsonism
ICD10: G21.8 -> Other secondary parkinsonism
ICD10: G21.9 -> Secondary parkinsonism, unspecified
*/

----------- Number of patients for each kind of PD --------------

SELECT condition_source_value, COUNT(DISTINCT person_id) AS distinct_person_count
FROM IDEALIST.CDM.CONDITION_OCCURRENCE
WHERE condition_source_value IN (
    SELECT DISTINCT condition_source_value
    FROM IDEALIST.CDM.CONDITION_OCCURRENCE
    WHERE (
        condition_source_value LIKE '%ICD10: G20%'
        OR condition_source_value LIKE '%ICD10: G21%'
        OR condition_source_value LIKE '%ICD9: 332%'
    )
)
GROUP BY condition_source_value
ORDER BY distinct_person_count DESC;

--------------------- New query ---------------------------------------------------
SELECT CD.person_id,
       Person.birth_datetime,
       Person.gender_source_value,
       Person.race_source_value,
       Person.ethnicity_source_value,
       PO.procedure_source_value,
       CD.condition_concept_id,
       DE.drug_source_value,
       DE.drug_source_concept_id,
       DE.drug_exposure_start_datetime,
       DE.quantity,
       DE.sig,
       DE.route_source_value,
       DE.dose_source_value,
       DE.dose_unit_source_value,
       Note.note_title,
       Note.note_source_value,
       Note.note_text
FROM NOTE AS Note
JOIN CONDITION_OCCURRENCE AS CD
ON (Note.person_id = CD.person_id)
AND CD.condition_source_value = 'ICD10: G20'
JOIN PERSON as Person
ON (CD.person_id = Person.person_id)
JOIN PROCEDURE_OCCURRENCE AS PO
ON (Note.person_id = PO.person_id)
JOIN DRUG_EXPOSURE AS DE
ON (Note.person_id = DE.person_id)
WHERE Note.note_title = 'order_narative: CONSULT'
      /*(note_title = 'order_narative: IMAGING' OR
       note_title = 'order_impression: IMAGING')  OR
       note_title = 'H&P (View-Only)' OR
       note_title = 'H&P' OR */
ORDER BY CD.person_id ASC, DE.drug_source_value ASC;

************New version***********************

SELECT CD.person_id,
       Person.birth_datetime,
       Person.gender_source_value,
       Person.race_source_value,
       Person.ethnicity_source_value,
       PO.procedure_source_value,
       CD.condition_concept_id,
       DE.drug_source_value,
       DE.drug_source_concept_id,
       DE.drug_exposure_start_datetime,
       DE.quantity,
       DE.sig,
       DE.route_source_value,
       DE.dose_source_value,
       DE.dose_unit_source_value,
       Note.note_title,
       Note.note_text
FROM NOTE AS Note
JOIN CONDITION_OCCURRENCE AS CD ON CD.person_id = Note.person_id
JOIN PERSON AS Person ON Person.person_id = CD.person_id
JOIN PROCEDURE_OCCURRENCE AS PO ON PO.person_id = Note.person_id
JOIN DRUG_EXPOSURE AS DE ON DE.person_id = Note.person_id
WHERE Note.note_title = 'order_narative: CONSULT'
      /*(note_title = 'order_narative: IMAGING' OR
       note_title = 'order_impression: IMAGING')  OR
       note_title = 'H&P (View-Only)' OR
       note_title = 'H&P' OR */
      AND CD.condition_source_value = 'ICD10: G20'
ORDER BY CD.person_id ASC, DE.drug_source_value ASC;

---------------- Qs--------------------
procedure_type_concept_id vs procedure_source_value
In Athena: procedure_concept_id == Concept ID. 
procedure_source_value == Concept code. Bur procedure_concept_id is empty in most cases. Both  values map to each other

drug_source_concept_id maps to drug_source_value.
condition_concept_id (?)

--------------------- Notes -------------------------
H&P: History and Physical examination
Impression: Interpretation/Findings
Narrative: Backstory, Highlights of findings. Sometimes whole impression

------------------- Query used at the end after 12 h --------------------------

SELECT CD.person_id,
       Person.birth_datetime,
       Person.gender_source_value,
       Person.race_source_value,
       Person.ethnicity_source_value,
       PO.procedure_source_value,
       CD.drug_source_value,
       CD.quantity,
       CD.sig,
       CD.route_source_value,
       CD.dose_source_value,
       CD.dose_unit_source_value,
       Note.note_text
FROM (
  SELECT person_id, note_title, note_text
  FROM NOTE
  WHERE note_title = 'order_narative: CONSULT'
) AS Note
JOIN (
  SELECT CO.person_id, DE.drug_source_value, DE.drug_exposure_start_datetime, DE.quantity, DE.sig, DE.route_source_value, DE.dose_source_value, DE.dose_unit_source_value
  FROM CONDITION_OCCURRENCE AS CO
  JOIN DRUG_EXPOSURE AS DE ON DE.person_id = CO.person_id
  WHERE CO.condition_source_value = 'ICD10: G20'
) AS CD ON CD.person_id = Note.person_id
JOIN PERSON AS Person ON Person.person_id = CD.person_id
JOIN PROCEDURE_OCCURRENCE AS PO ON PO.person_id = Note.person_id
ORDER BY CD.person_id ASC, CD.drug_source_value ASC;
