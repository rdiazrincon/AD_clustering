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
