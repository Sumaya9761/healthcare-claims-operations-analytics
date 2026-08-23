CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'staging', 'analytics')
ORDER BY schema_name;

-- Patients
CREATE TABLE raw.patients (
    id TEXT,
    birthdate TEXT,
    deathdate TEXT,
    ssn TEXT,
    drivers TEXT,
    passport TEXT,
    prefix TEXT,
    first TEXT,
    middle TEXT,
    last TEXT,
    suffix TEXT,
    maiden TEXT,
    marital TEXT,
    race TEXT,
    ethnicity TEXT,
    gender TEXT,
    birthplace TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    county TEXT,
    fips TEXT,
    zip TEXT,
    lat TEXT,
    lon TEXT,
    healthcare_expenses TEXT,
    healthcare_coverage TEXT,
    income TEXT
);

-- Claims
CREATE TABLE raw.claims (
    id TEXT,
    patientid TEXT,
    providerid TEXT,
    primarypatientinsuranceid TEXT,
    secondarypatientinsuranceid TEXT,
    departmentid TEXT,
    patientdepartmentid TEXT,
    diagnosis1 TEXT,
    diagnosis2 TEXT,
    diagnosis3 TEXT,
    diagnosis4 TEXT,
    diagnosis5 TEXT,
    diagnosis6 TEXT,
    diagnosis7 TEXT,
    diagnosis8 TEXT,
    referringproviderid TEXT,
    appointmentid TEXT,
    currentillnessdate TEXT,
    servicedate TEXT,
    supervisingproviderid TEXT,
    status1 TEXT,
    status2 TEXT,
    statusp TEXT,
    outstanding1 TEXT,
    outstanding2 TEXT,
    outstandingp TEXT,
    lastbilleddate1 TEXT,
    lastbilleddate2 TEXT,
    lastbilleddatep TEXT,
    healthcareclaimtypeid1 TEXT,
    healthcareclaimtypeid2 TEXT
);

-- Claim transactions
CREATE TABLE raw.claims_transactions (
    id TEXT,
    claimid TEXT,
    chargeid TEXT,
    patientid TEXT,
    type TEXT,
    amount TEXT,
    method TEXT,
    fromdate TEXT,
    todate TEXT,
    placeofservice TEXT,
    procedurecode TEXT,
    modifier1 TEXT,
    modifier2 TEXT,
    diagnosisref1 TEXT,
    diagnosisref2 TEXT,
    diagnosisref3 TEXT,
    diagnosisref4 TEXT,
    units TEXT,
    departmentid TEXT,
    notes TEXT,
    unitamount TEXT,
    transferoutid TEXT,
    transfertype TEXT,
    payments TEXT,
    adjustments TEXT,
    transfers TEXT,
    outstanding TEXT,
    appointmentid TEXT,
    linenote TEXT,
    patientinsuranceid TEXT,
    feescheduleid TEXT,
    providerid TEXT,
    supervisingproviderid TEXT
);

-- Encounters
CREATE TABLE raw.encounters (
    id TEXT,
    start TEXT,
    stop TEXT,
    patient TEXT,
    organization TEXT,
    provider TEXT,
    payer TEXT,
    encounterclass TEXT,
    code TEXT,
    description TEXT,
    base_encounter_cost TEXT,
    total_claim_cost TEXT,
    payer_coverage TEXT,
    reasoncode TEXT,
    reasondescription TEXT
);

-- Conditions
CREATE TABLE raw.conditions (
    start TEXT,
    stop TEXT,
    patient TEXT,
    encounter TEXT,
    system TEXT,
    code TEXT,
    description TEXT
);

-- Procedures
CREATE TABLE raw.procedures (
    start TEXT,
    stop TEXT,
    patient TEXT,
    encounter TEXT,
    system TEXT,
    code TEXT,
    description TEXT,
    base_cost TEXT,
    reasoncode TEXT,
    reasondescription TEXT
);

-- Providers
CREATE TABLE raw.providers (
    id TEXT,
    organization TEXT,
    name TEXT,
    gender TEXT,
    speciality TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    lat TEXT,
    lon TEXT,
    encounters TEXT,
    procedures TEXT,
    npi TEXT
);

-- Organizations
CREATE TABLE raw.organizations (
    id TEXT,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    lat TEXT,
    lon TEXT,
    phone TEXT,
    revenue TEXT,
    utilization TEXT,
    npi TEXT
);

-- Payers
CREATE TABLE raw.payers (
    id TEXT,
    name TEXT,
    ownership TEXT,
    address TEXT,
    city TEXT,
    state_headquartered TEXT,
    zip TEXT,
    phone TEXT,
    amount_covered TEXT,
    amount_uncovered TEXT,
    revenue TEXT,
    covered_encounters TEXT,
    uncovered_encounters TEXT,
    covered_medications TEXT,
    uncovered_medications TEXT,
    covered_procedures TEXT,
    uncovered_procedures TEXT,
    covered_immunizations TEXT,
    uncovered_immunizations TEXT,
    unique_customers TEXT,
    qols_avg TEXT,
    member_months TEXT
);

-- Payer transitions
CREATE TABLE raw.payer_transitions (
    patient TEXT,
    memberid TEXT,
    start_date TEXT,
    end_date TEXT,
    payer TEXT,
    secondary_payer TEXT,
    plan_ownership TEXT,
    owner_name TEXT
);


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw'
ORDER BY table_name;

SELECT COUNT(*)
FROM raw.patients;

SELECT 'patients' AS table_name, COUNT(*) AS row_count FROM raw.patients
UNION ALL
SELECT 'providers', COUNT(*) FROM raw.providers
UNION ALL
SELECT 'organizations', COUNT(*) FROM raw.organizations
UNION ALL
SELECT 'payers', COUNT(*) FROM raw.payers
UNION ALL
SELECT 'encounters', COUNT(*) FROM raw.encounters
UNION ALL
SELECT 'conditions', COUNT(*) FROM raw.conditions
UNION ALL
SELECT 'procedures', COUNT(*) FROM raw.procedures
UNION ALL
SELECT 'claims', COUNT(*) FROM raw.claims
UNION ALL
SELECT 'claims_transactions', COUNT(*) FROM raw.claims_transactions
UNION ALL
SELECT 'payer_transitions', COUNT(*) FROM raw.payer_transitions
ORDER BY table_name;


DROP TABLE IF EXISTS staging.patients;

CREATE TABLE staging.patients AS
SELECT
    TRIM(id) AS patient_id,

    NULLIF(TRIM(birthdate), '')::date AS birth_date,
    NULLIF(TRIM(deathdate), '')::date AS death_date,

    NULLIF(TRIM(marital), '') AS marital_status,
    NULLIF(TRIM(race), '') AS race,
    NULLIF(TRIM(ethnicity), '') AS ethnicity,
    NULLIF(TRIM(gender), '') AS gender,

    NULLIF(TRIM(birthplace), '') AS birthplace,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(state), '') AS state,
    NULLIF(TRIM(county), '') AS county,
    NULLIF(TRIM(fips), '') AS fips,
    NULLIF(TRIM(zip), '') AS zip,

    NULLIF(TRIM(lat), '')::numeric AS latitude,
    NULLIF(TRIM(lon), '')::numeric AS longitude,

    NULLIF(TRIM(healthcare_expenses), '')::numeric(14,2)
        AS healthcare_expenses,

    NULLIF(TRIM(healthcare_coverage), '')::numeric(14,2)
        AS healthcare_coverage,

    NULLIF(TRIM(income), '')::numeric(14,2) AS income

FROM raw.patients;

SELECT COUNT(*)
FROM staging.patients;
SELECT *
FROM staging.patients
LIMIT 5;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'patients'
ORDER BY ordinal_position;

SELECT
    (SELECT COUNT(*) FROM raw.patients) AS raw_rows,
    (SELECT COUNT(*) FROM staging.patients) AS staging_rows;

	SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT patient_id) AS unique_patients,
    COUNT(*) - COUNT(DISTINCT patient_id) AS duplicate_ids
FROM staging.patients;

ALTER TABLE staging.patients
ADD CONSTRAINT pk_staging_patients
PRIMARY KEY (patient_id);



DROP TABLE IF EXISTS staging.providers;

CREATE TABLE staging.providers AS
SELECT
    TRIM(id) AS provider_id,
    NULLIF(TRIM(organization), '') AS organization_id,
    NULLIF(TRIM(name), '') AS provider_name,
    NULLIF(TRIM(gender), '') AS gender,
    NULLIF(TRIM(speciality), '') AS specialty,

    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(state), '') AS state,
    NULLIF(TRIM(zip), '') AS zip,

    NULLIF(TRIM(lat), '')::numeric AS latitude,
    NULLIF(TRIM(lon), '')::numeric AS longitude,

    NULLIF(TRIM(encounters), '')::integer AS encounter_count,
    NULLIF(TRIM(procedures), '')::integer AS procedure_count,

    NULLIF(TRIM(npi), '') AS npi

FROM raw.providers;

ALTER TABLE staging.providers
ADD CONSTRAINT pk_staging_providers
PRIMARY KEY (provider_id);

DROP TABLE IF EXISTS staging.organizations;

CREATE TABLE staging.organizations AS
SELECT
    TRIM(id) AS organization_id,
    NULLIF(TRIM(name), '') AS organization_name,

    NULLIF(TRIM(address), '') AS address,
    NULLIF(TRIM(city), '') AS city,
    NULLIF(TRIM(state), '') AS state,
    NULLIF(TRIM(zip), '') AS zip,

    NULLIF(TRIM(lat), '')::numeric AS latitude,
    NULLIF(TRIM(lon), '')::numeric AS longitude,

    NULLIF(TRIM(phone), '') AS phone,

    NULLIF(TRIM(revenue), '')::numeric(16,2) AS revenue,
    NULLIF(TRIM(utilization), '')::integer AS utilization,

    NULLIF(TRIM(npi), '') AS npi

FROM raw.organizations;
ALTER TABLE staging.organizations
ADD CONSTRAINT pk_staging_organizations
PRIMARY KEY (organization_id);


DROP TABLE IF EXISTS staging.payers;

CREATE TABLE staging.payers AS
SELECT
    TRIM(id) AS payer_id,
    NULLIF(TRIM(name), '') AS payer_name,
    NULLIF(TRIM(ownership), '') AS ownership,

    NULLIF(TRIM(amount_covered), '')::numeric(16,2)
        AS amount_covered,

    NULLIF(TRIM(amount_uncovered), '')::numeric(16,2)
        AS amount_uncovered,

    NULLIF(TRIM(revenue), '')::numeric(16,2)
        AS revenue,

    NULLIF(TRIM(covered_encounters), '')::integer
        AS covered_encounters,

    NULLIF(TRIM(uncovered_encounters), '')::integer
        AS uncovered_encounters,

    NULLIF(TRIM(covered_medications), '')::integer
        AS covered_medications,

    NULLIF(TRIM(uncovered_medications), '')::integer
        AS uncovered_medications,

    NULLIF(TRIM(covered_procedures), '')::integer
        AS covered_procedures,

    NULLIF(TRIM(uncovered_procedures), '')::integer
        AS uncovered_procedures,

    NULLIF(TRIM(unique_customers), '')::integer
        AS unique_customers,

    NULLIF(TRIM(qols_avg), '')::numeric
        AS qols_avg,

    NULLIF(TRIM(member_months), '')::integer
        AS member_months

FROM raw.payers;

ALTER TABLE staging.payers
ADD CONSTRAINT pk_staging_payers
PRIMARY KEY (payer_id);


SELECT 'providers' AS table_name, COUNT(*) AS row_count
FROM staging.providers

UNION ALL

SELECT 'organizations', COUNT(*)
FROM staging.organizations

UNION ALL

SELECT 'payers', COUNT(*)
FROM staging.payers;

SELECT
    (SELECT COUNT(DISTINCT provider_id)
     FROM staging.providers) AS unique_providers,

    (SELECT COUNT(DISTINCT organization_id)
     FROM staging.organizations) AS unique_organizations,

    (SELECT COUNT(DISTINCT payer_id)
     FROM staging.payers) AS unique_payers;


	 SELECT COUNT(*) AS orphan_provider_organizations
FROM staging.providers p
LEFT JOIN staging.organizations o
    ON p.organization_id = o.organization_id
WHERE p.organization_id IS NOT NULL
  AND o.organization_id IS NULL;

 ALTER TABLE staging.providers
ADD CONSTRAINT fk_providers_organization
FOREIGN KEY (organization_id)
REFERENCES staging.organizations(organization_id);

/*
Create staging.encounters
*/
DROP TABLE IF EXISTS staging.encounters;

CREATE TABLE staging.encounters AS
SELECT
    TRIM(id) AS encounter_id,

    NULLIF(TRIM(start), '')::timestamptz AS start_datetime,
    NULLIF(TRIM(stop), '')::timestamptz AS stop_datetime,

    TRIM(patient) AS patient_id,
    TRIM(organization) AS organization_id,
    TRIM(provider) AS provider_id,
    TRIM(payer) AS payer_id,

    NULLIF(TRIM(encounterclass), '') AS encounter_class,

    NULLIF(TRIM(code), '') AS encounter_code,
    NULLIF(TRIM(description), '') AS encounter_description,

    NULLIF(TRIM(base_encounter_cost), '')::numeric(14,2)
        AS base_encounter_cost,

    NULLIF(TRIM(total_claim_cost), '')::numeric(14,2)
        AS total_claim_cost,

    NULLIF(TRIM(payer_coverage), '')::numeric(14,2)
        AS payer_coverage,

    NULLIF(TRIM(reasoncode), '') AS reason_code,
    NULLIF(TRIM(reasondescription), '') AS reason_description

FROM raw.encounters;

ALTER TABLE staging.encounters
ADD CONSTRAINT pk_staging_encounters
PRIMARY KEY (encounter_id);


	SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT encounter_id) AS unique_encounters
FROM staging.encounters;

/*
check the 4 relationship
*/
SELECT
    SUM(CASE WHEN p.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_patients,

    SUM(CASE WHEN pr.provider_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_providers,

    SUM(CASE WHEN o.organization_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_organizations,

    SUM(CASE WHEN py.payer_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_payers

FROM staging.encounters e

LEFT JOIN staging.patients p
    ON e.patient_id = p.patient_id

LEFT JOIN staging.providers pr
    ON e.provider_id = pr.provider_id

LEFT JOIN staging.organizations o
    ON e.organization_id = o.organization_id

LEFT JOIN staging.payers py
    ON e.payer_id = py.payer_id;
/*
adding FK to them
*/
	ALTER TABLE staging.encounters
ADD CONSTRAINT fk_encounters_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.encounters
ADD CONSTRAINT fk_encounters_provider
FOREIGN KEY (provider_id)
REFERENCES staging.providers(provider_id);

ALTER TABLE staging.encounters
ADD CONSTRAINT fk_encounters_organization
FOREIGN KEY (organization_id)
REFERENCES staging.organizations(organization_id);

ALTER TABLE staging.encounters
ADD CONSTRAINT fk_encounters_payer
FOREIGN KEY (payer_id)
REFERENCES staging.payers(payer_id);


SELECT
    encounter_class,
    COUNT(*) AS encounter_count
FROM staging.encounters
GROUP BY encounter_class
ORDER BY encounter_count DESC;

SELECT
    MIN(start_datetime) AS earliest_encounter,
    MAX(start_datetime) AS latest_encounter,
    COUNT(DISTINCT patient_id) AS patients_with_encounters
FROM staging.encounters;
/*
staging other table
*/
DROP TABLE IF EXISTS staging.conditions;

CREATE TABLE staging.conditions AS
SELECT
    NULLIF(TRIM(start), '')::date AS start_date,
    NULLIF(TRIM(stop), '')::date AS stop_date,

    TRIM(patient) AS patient_id,
    TRIM(encounter) AS encounter_id,

    NULLIF(TRIM(system), '') AS code_system,
    NULLIF(TRIM(code), '') AS condition_code,
    NULLIF(TRIM(description), '') AS condition_description

FROM raw.conditions;

SELECT
    (SELECT COUNT(*) FROM raw.conditions) AS raw_rows,
    (SELECT COUNT(*) FROM staging.conditions) AS staging_rows;
	SELECT
    SUM(CASE WHEN p.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_patients,

    SUM(CASE WHEN e.encounter_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_encounters

FROM staging.conditions c

LEFT JOIN staging.patients p
    ON c.patient_id = p.patient_id

LEFT JOIN staging.encounters e
    ON c.encounter_id = e.encounter_id;

	ALTER TABLE staging.conditions
ADD CONSTRAINT fk_conditions_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.conditions
ADD CONSTRAINT fk_conditions_encounter
FOREIGN KEY (encounter_id)
REFERENCES staging.encounters(encounter_id);


DROP TABLE IF EXISTS staging.procedures;

CREATE TABLE staging.procedures AS
SELECT
    NULLIF(TRIM(start), '')::timestamptz AS start_datetime,
    NULLIF(TRIM(stop), '')::timestamptz AS stop_datetime,

    TRIM(patient) AS patient_id,
    TRIM(encounter) AS encounter_id,

    NULLIF(TRIM(system), '') AS code_system,
    NULLIF(TRIM(code), '') AS procedure_code,
    NULLIF(TRIM(description), '') AS procedure_description,

    NULLIF(TRIM(base_cost), '')::numeric(14,2)
        AS base_cost,

    NULLIF(TRIM(reasoncode), '') AS reason_code,
    NULLIF(TRIM(reasondescription), '') AS reason_description

FROM raw.procedures;

SELECT
    (SELECT COUNT(*) FROM raw.procedures) AS raw_rows,
    (SELECT COUNT(*) FROM staging.procedures) AS staging_rows;

	SELECT
    SUM(CASE WHEN p.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_patients,

    SUM(CASE WHEN e.encounter_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_encounters

FROM staging.procedures pr

LEFT JOIN staging.patients p
    ON pr.patient_id = p.patient_id

LEFT JOIN staging.encounters e
    ON pr.encounter_id = e.encounter_id;

	ALTER TABLE staging.procedures
ADD CONSTRAINT fk_procedures_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.procedures
ADD CONSTRAINT fk_procedures_encounter
FOREIGN KEY (encounter_id)
REFERENCES staging.encounters(encounter_id);

SELECT
    condition_description,
    COUNT(*) AS condition_count
FROM staging.conditions
GROUP BY condition_description
ORDER BY condition_count DESC
LIMIT 10;

SELECT
    procedure_description,
    COUNT(*) AS procedure_count,
    SUM(base_cost) AS total_base_cost
FROM staging.procedures
GROUP BY procedure_description
ORDER BY total_base_cost DESC
LIMIT 10;



DROP TABLE IF EXISTS staging.payer_transitions;

CREATE TABLE staging.payer_transitions AS
SELECT
    TRIM(patient) AS patient_id,
    NULLIF(TRIM(memberid), '') AS member_id,

    NULLIF(TRIM(start_date), '')::timestamptz AS coverage_start,
    NULLIF(TRIM(end_date), '')::timestamptz AS coverage_end,

    TRIM(payer) AS payer_id,
    NULLIF(TRIM(secondary_payer), '') AS secondary_payer_id,

    NULLIF(TRIM(plan_ownership), '') AS plan_ownership,
    NULLIF(TRIM(owner_name), '') AS owner_name

FROM raw.payer_transitions;
SELECT
    (SELECT COUNT(*) FROM raw.payer_transitions) AS raw_rows,
    (SELECT COUNT(*) FROM staging.payer_transitions) AS staging_rows;
	SELECT
    COUNT(*) AS enrollment_records,
    COUNT(DISTINCT patient_id) AS unique_patients,
    MIN(coverage_start) AS earliest_coverage,
    MAX(coverage_end) AS latest_coverage
FROM staging.payer_transitions;
SELECT
    SUM(CASE WHEN p.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_patients,

    SUM(CASE WHEN py.payer_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_primary_payers,

    SUM(
        CASE
            WHEN pt.secondary_payer_id IS NOT NULL
             AND spy.payer_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS orphan_secondary_payers

FROM staging.payer_transitions pt

LEFT JOIN staging.patients p
    ON pt.patient_id = p.patient_id

LEFT JOIN staging.payers py
    ON pt.payer_id = py.payer_id

LEFT JOIN staging.payers spy
    ON pt.secondary_payer_id = spy.payer_id;

	ALTER TABLE staging.payer_transitions
ADD CONSTRAINT fk_payer_transitions_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.payer_transitions
ADD CONSTRAINT fk_payer_transitions_payer
FOREIGN KEY (payer_id)
REFERENCES staging.payers(payer_id);

ALTER TABLE staging.payer_transitions
ADD CONSTRAINT fk_payer_transitions_secondary_payer
FOREIGN KEY (secondary_payer_id)
REFERENCES staging.payers(payer_id);


SELECT
    py.payer_name,
    COUNT(*) AS coverage_periods,
    COUNT(DISTINCT pt.patient_id) AS unique_members
FROM staging.payer_transitions pt
JOIN staging.payers py
    ON pt.payer_id = py.payer_id
GROUP BY py.payer_name
ORDER BY coverage_periods DESC;


DROP TABLE IF EXISTS staging.claims;

CREATE TABLE staging.claims AS
SELECT
    TRIM(id) AS claim_id,
    TRIM(patientid) AS patient_id,
    TRIM(providerid) AS provider_id,

    NULLIF(TRIM(primarypatientinsuranceid), '') AS primary_payer_id,
    NULLIF(TRIM(secondarypatientinsuranceid), '') AS secondary_payer_id,

    NULLIF(TRIM(departmentid), '') AS department_id,
    NULLIF(TRIM(patientdepartmentid), '') AS patient_department_id,

    NULLIF(TRIM(diagnosis1), '') AS diagnosis_1,
    NULLIF(TRIM(diagnosis2), '') AS diagnosis_2,
    NULLIF(TRIM(diagnosis3), '') AS diagnosis_3,
    NULLIF(TRIM(diagnosis4), '') AS diagnosis_4,
    NULLIF(TRIM(diagnosis5), '') AS diagnosis_5,
    NULLIF(TRIM(diagnosis6), '') AS diagnosis_6,
    NULLIF(TRIM(diagnosis7), '') AS diagnosis_7,
    NULLIF(TRIM(diagnosis8), '') AS diagnosis_8,

    TRIM(appointmentid) AS encounter_id,

    NULLIF(TRIM(currentillnessdate), '')::timestamptz
        AS current_illness_datetime,

    NULLIF(TRIM(servicedate), '')::timestamptz
        AS service_datetime,

    NULLIF(TRIM(supervisingproviderid), '')
        AS supervising_provider_id,

    NULLIF(TRIM(status1), '') AS primary_status,
    NULLIF(TRIM(status2), '') AS secondary_status,
    NULLIF(TRIM(statusp), '') AS patient_status,

    NULLIF(TRIM(outstanding1), '')::numeric(16,2)
        AS primary_outstanding,

    NULLIF(TRIM(outstanding2), '')::numeric(16,2)
        AS secondary_outstanding,

    NULLIF(TRIM(outstandingp), '')::numeric(16,2)
        AS patient_outstanding,

    NULLIF(TRIM(lastbilleddate1), '')::timestamptz
        AS primary_last_billed_datetime,

    NULLIF(TRIM(lastbilleddate2), '')::timestamptz
        AS secondary_last_billed_datetime,

    NULLIF(TRIM(lastbilleddatep), '')::timestamptz
        AS patient_last_billed_datetime,

    NULLIF(TRIM(healthcareclaimtypeid1), '')
        AS primary_claim_type_id,

    NULLIF(TRIM(healthcareclaimtypeid2), '')
        AS secondary_claim_type_id

FROM raw.claims;

ALTER TABLE staging.claims
ADD CONSTRAINT pk_staging_claims
PRIMARY KEY (claim_id);


	ALTER TABLE staging.claims
ADD CONSTRAINT fk_claims_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.claims
ADD CONSTRAINT fk_claims_provider
FOREIGN KEY (provider_id)
REFERENCES staging.providers(provider_id);

ALTER TABLE staging.claims
ADD CONSTRAINT fk_claims_encounter
FOREIGN KEY (encounter_id)
REFERENCES staging.encounters(encounter_id);

ALTER TABLE staging.claims
ADD CONSTRAINT fk_claims_primary_payer
FOREIGN KEY (primary_payer_id)
REFERENCES staging.payers(payer_id);

ALTER TABLE staging.claims
ADD CONSTRAINT fk_claims_secondary_payer
FOREIGN KEY (secondary_payer_id)
REFERENCES staging.payers(payer_id);

SELECT
    COUNT(*) AS total_claims,

    COUNT(primary_payer_id) AS claims_with_primary_insurance,

    COUNT(secondary_payer_id) AS claims_with_secondary_insurance,

    COUNT(*) - COUNT(primary_payer_id) AS claims_without_primary_insurance

FROM staging.claims;


DROP TABLE IF EXISTS staging.claims_transactions;

CREATE TABLE staging.claims_transactions AS
SELECT
    TRIM(id) AS transaction_id,
    TRIM(claimid) AS claim_id,
    NULLIF(TRIM(chargeid), '') AS charge_id,
    TRIM(patientid) AS patient_id,

    NULLIF(TRIM(type), '') AS transaction_type,
    NULLIF(TRIM(amount), '')::numeric(16,2) AS amount,
    NULLIF(TRIM(method), '') AS payment_method,

    NULLIF(TRIM(fromdate), '')::timestamptz AS from_datetime,
    NULLIF(TRIM(todate), '')::timestamptz AS to_datetime,

    NULLIF(TRIM(placeofservice), '') AS place_of_service,
    NULLIF(TRIM(procedurecode), '') AS procedure_code,

    NULLIF(TRIM(diagnosisref1), '') AS diagnosis_ref_1,
    NULLIF(TRIM(diagnosisref2), '') AS diagnosis_ref_2,
    NULLIF(TRIM(diagnosisref3), '') AS diagnosis_ref_3,
    NULLIF(TRIM(diagnosisref4), '') AS diagnosis_ref_4,

    NULLIF(TRIM(units), '')::numeric AS units,
    NULLIF(TRIM(departmentid), '') AS department_id,

    NULLIF(TRIM(notes), '') AS notes,

    NULLIF(TRIM(unitamount), '')::numeric(16,2) AS unit_amount,

    NULLIF(TRIM(transferoutid), '') AS transfer_out_id,
    NULLIF(TRIM(transfertype), '') AS transfer_type,

    NULLIF(TRIM(payments), '')::numeric(16,2) AS payments,
    NULLIF(TRIM(adjustments), '')::numeric(16,2) AS adjustments,
    NULLIF(TRIM(transfers), '')::numeric(16,2) AS transfers,
    NULLIF(TRIM(outstanding), '')::numeric(16,2) AS outstanding,

    NULLIF(TRIM(appointmentid), '') AS encounter_id,

    NULLIF(TRIM(patientinsuranceid), '') AS patient_insurance_id,
    NULLIF(TRIM(feescheduleid), '') AS fee_schedule_id,

    TRIM(providerid) AS provider_id,
    NULLIF(TRIM(supervisingproviderid), '') AS supervising_provider_id

FROM raw.claims_transactions;

ALTER TABLE staging.claims_transactions
ADD CONSTRAINT pk_staging_claims_transactions
PRIMARY KEY (transaction_id);

SELECT
    (SELECT COUNT(*) FROM raw.claims_transactions) AS raw_rows,
    (SELECT COUNT(*) FROM staging.claims_transactions) AS staging_rows;

	SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT transaction_id) AS unique_transactions,
    COUNT(DISTINCT claim_id) AS claims_represented
FROM staging.claims_transactions;

SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM staging.claims_transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;




	ALTER TABLE staging.claims_transactions
ADD CONSTRAINT fk_claim_transactions_claim
FOREIGN KEY (claim_id)
REFERENCES staging.claims(claim_id);

ALTER TABLE staging.claims_transactions
ADD CONSTRAINT fk_claim_transactions_patient
FOREIGN KEY (patient_id)
REFERENCES staging.patients(patient_id);

ALTER TABLE staging.claims_transactions
ADD CONSTRAINT fk_claim_transactions_encounter
FOREIGN KEY (encounter_id)
REFERENCES staging.encounters(encounter_id);

ALTER TABLE staging.claims_transactions
ADD CONSTRAINT fk_claim_transactions_provider
FOREIGN KEY (provider_id)
REFERENCES staging.providers(provider_id);

SELECT
    transaction_type,
    COUNT(*) AS rows,
    SUM(COALESCE(amount, 0)) AS total_amount,
    SUM(COALESCE(payments, 0)) AS total_payments,
    SUM(COALESCE(adjustments, 0)) AS total_adjustments,
    SUM(COALESCE(transfers, 0)) AS total_transfers,
    SUM(COALESCE(outstanding, 0)) AS total_outstanding
FROM staging.claims_transactions
GROUP BY transaction_type
ORDER BY transaction_type;


WITH claim_financials AS (
    SELECT
        claim_id,

        SUM(
            CASE
                WHEN transaction_type = 'CHARGE'
                THEN COALESCE(amount, 0)
                ELSE 0
            END
        ) AS total_charge,

        SUM(
            CASE
                WHEN transaction_type = 'PAYMENT'
                THEN COALESCE(payments, 0)
                ELSE 0
            END
        ) AS total_payment,

        SUM(
            CASE
                WHEN transaction_type = 'TRANSFERIN'
                THEN COALESCE(transfers, 0)
                ELSE 0
            END
        ) AS transfer_in,

        SUM(
            CASE
                WHEN transaction_type = 'TRANSFEROUT'
                THEN COALESCE(transfers, 0)
                ELSE 0
            END
        ) AS transfer_out

    FROM staging.claims_transactions
    GROUP BY claim_id
)

SELECT
    COUNT(*) AS total_claims,

    SUM(total_charge) AS total_charges,
    SUM(total_payment) AS total_payments,

    SUM(transfer_in) AS total_transfer_in,
    SUM(transfer_out) AS total_transfer_out,

    COUNT(*) FILTER (
        WHERE total_charge <> total_payment
    ) AS claims_charge_payment_mismatch,

    COUNT(*) FILTER (
        WHERE transfer_in <> transfer_out
    ) AS claims_transfer_mismatch

FROM claim_financials;

/*
ANalytical Layer/scheme
*/
DROP TABLE IF EXISTS analytics.dim_member;

CREATE TABLE analytics.dim_member AS
SELECT
    patient_id,
    birth_date,
    death_date,
    gender,
    race,
    ethnicity,
    marital_status,
    city,
    state,
    county,
    zip,
    income,

    CASE
        WHEN income IS NULL THEN 'Unknown'
        WHEN income < 25000 THEN '< $25K'
        WHEN income < 50000 THEN '$25K-$49K'
        WHEN income < 75000 THEN '$50K-$74K'
        WHEN income < 100000 THEN '$75K-$99K'
        ELSE '$100K+'
    END AS income_band

FROM staging.patients;

ALTER TABLE analytics.dim_member
ADD CONSTRAINT pk_dim_member
PRIMARY KEY (patient_id);

SELECT
    COUNT(*) AS members,
    COUNT(DISTINCT patient_id) AS unique_members
FROM analytics.dim_member;

SELECT
    income_band,
    COUNT(*) AS member_count
FROM analytics.dim_member
GROUP BY income_band
ORDER BY member_count DESC;

DROP TABLE IF EXISTS analytics.dim_date;

CREATE TABLE analytics.dim_date AS
SELECT
    TO_CHAR(d, 'YYYYMMDD')::integer AS date_key,
    d::date AS full_date,

    EXTRACT(YEAR FROM d)::integer AS year,
    EXTRACT(QUARTER FROM d)::integer AS quarter,
    EXTRACT(MONTH FROM d)::integer AS month_number,

    TO_CHAR(d, 'Month') AS month_name,
    TO_CHAR(d, 'Mon') AS month_short_name,

    TO_CHAR(d, 'YYYY-MM') AS year_month,

    DATE_TRUNC('month', d)::date AS month_start_date,

    EXTRACT(DAY FROM d)::integer AS day_of_month,
    EXTRACT(ISODOW FROM d)::integer AS day_of_week_number,

    TO_CHAR(d, 'Day') AS day_name,

    CASE
        WHEN EXTRACT(ISODOW FROM d) IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS is_weekend

FROM GENERATE_SERIES(
    (SELECT MIN(service_datetime)::date
     FROM staging.claims),

    (SELECT MAX(service_datetime)::date
     FROM staging.claims),

    INTERVAL '1 day'
) AS d;

ALTER TABLE analytics.dim_date
ADD CONSTRAINT pk_dim_date
PRIMARY KEY (date_key);

ALTER TABLE analytics.dim_date
ADD CONSTRAINT uq_dim_date_full_date
UNIQUE (full_date);

SELECT
    COUNT(*) AS calendar_days,
    MIN(full_date) AS first_date,
    MAX(full_date) AS last_date
FROM analytics.dim_date;



DROP TABLE IF EXISTS analytics.dim_provider;

CREATE TABLE analytics.dim_provider AS
SELECT
    p.provider_id,
    p.provider_name,
    p.gender,
    p.specialty,

    p.organization_id,
    o.organization_name,

    p.city,
    p.state,
    p.zip,
    p.npi

FROM staging.providers p
LEFT JOIN staging.organizations o
    ON p.organization_id = o.organization_id;

ALTER TABLE analytics.dim_provider
ADD CONSTRAINT pk_dim_provider
PRIMARY KEY (provider_id);



DROP TABLE IF EXISTS analytics.dim_organization;

CREATE TABLE analytics.dim_organization AS
SELECT
    organization_id,
    organization_name,

    city,
    state,
    zip,

    revenue,
    utilization,
    npi

FROM staging.organizations;

ALTER TABLE analytics.dim_organization
ADD CONSTRAINT pk_dim_organization
PRIMARY KEY (organization_id);



DROP TABLE IF EXISTS analytics.dim_payer;

CREATE TABLE analytics.dim_payer AS
SELECT
    payer_id,
    payer_name,
    ownership,

    amount_covered,
    amount_uncovered,

    covered_encounters,
    uncovered_encounters,

    covered_procedures,
    uncovered_procedures,

    unique_customers,
    member_months

FROM staging.payers;



SELECT
    COUNT(*) AS payers,
    COUNT(DISTINCT payer_id) AS unique_payers
FROM analytics.dim_payer;

SELECT 'member' AS dimension, COUNT(*) AS row_count
FROM analytics.dim_member

UNION ALL

SELECT 'date', COUNT(*)
FROM analytics.dim_date

UNION ALL

SELECT 'provider', COUNT(*)
FROM analytics.dim_provider

UNION ALL

SELECT 'organization', COUNT(*)
FROM analytics.dim_organization

UNION ALL

SELECT 'payer', COUNT(*)
FROM analytics.dim_payer;

/*
financial fact table
*/

CREATE TABLE analytics.fact_claim AS

WITH transaction_summary AS (

    SELECT
        claim_id,

        SUM(
            CASE
                WHEN transaction_type = 'CHARGE'
                THEN COALESCE(amount, 0)
                ELSE 0
            END
        )::numeric(16,2) AS total_charge,

        SUM(
            CASE
                WHEN transaction_type = 'PAYMENT'
                THEN COALESCE(payments, 0)
                ELSE 0
            END
        )::numeric(16,2) AS total_payment,

        SUM(
            CASE
                WHEN transaction_type = 'TRANSFERIN'
                THEN COALESCE(transfers, 0)
                ELSE 0
            END
        )::numeric(16,2) AS transfer_in,

        SUM(
            CASE
                WHEN transaction_type = 'TRANSFEROUT'
                THEN COALESCE(transfers, 0)
                ELSE 0
            END
        )::numeric(16,2) AS transfer_out,

        COUNT(*) AS transaction_count

    FROM staging.claims_transactions
    GROUP BY claim_id
),

claim_base AS (

    SELECT
        c.claim_id,
        c.patient_id,
        c.provider_id,

        c.primary_payer_id,
        c.secondary_payer_id,

        c.encounter_id,

        c.service_datetime::date AS service_date,

        TO_CHAR(
            c.service_datetime::date,
            'YYYYMMDD'
        )::integer AS service_date_key,

        c.diagnosis_1 AS primary_diagnosis_code,

        t.total_charge,
        t.total_payment,
        t.transfer_in,
        t.transfer_out,
        t.transaction_count,

        c.primary_outstanding,
        c.secondary_outstanding,
        c.patient_outstanding,

        DATE_PART(
            'year',
            AGE(
                c.service_datetime::date,
                p.birth_date
            )
        )::integer AS age_at_service

    FROM staging.claims c

    JOIN transaction_summary t
        ON c.claim_id = t.claim_id

    JOIN staging.patients p
        ON c.patient_id = p.patient_id
)

SELECT
    *,

    CASE
        WHEN age_at_service < 18 THEN '0-17'
        WHEN age_at_service BETWEEN 18 AND 34 THEN '18-34'
        WHEN age_at_service BETWEEN 35 AND 49 THEN '35-49'
        WHEN age_at_service BETWEEN 50 AND 64 THEN '50-64'
        WHEN age_at_service >= 65 THEN '65+'
        ELSE 'Unknown'
    END AS age_group,

    CASE
        WHEN primary_payer_id IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS has_primary_insurance,

    CASE
        WHEN secondary_payer_id IS NOT NULL
        THEN TRUE
        ELSE FALSE
    END AS has_secondary_insurance

FROM claim_base;

ALTER TABLE analytics.fact_claim
ADD CONSTRAINT pk_fact_claim
PRIMARY KEY (claim_id);

SELECT
    COUNT(*) AS total_claims,
    COUNT(DISTINCT claim_id) AS unique_claims,

    SUM(total_charge) AS total_charges,
    SUM(total_payment) AS total_payments,

    SUM(transfer_in) AS total_transfer_in,
    SUM(transfer_out) AS total_transfer_out

FROM analytics.fact_claim;

/*
Validate age
*/

SELECT
    MIN(age_at_service) AS minimum_age,
    MAX(age_at_service) AS maximum_age,
    COUNT(*) FILTER (
        WHERE age_at_service < 0
    ) AS negative_age_records
FROM analytics.fact_claim;

SELECT
    age_group,
    COUNT(*) AS claim_count,
    SUM(total_charge) AS total_charges
FROM analytics.fact_claim
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN '0-17' THEN 1
        WHEN '18-34' THEN 2
        WHEN '35-49' THEN 3
        WHEN '50-64' THEN 4
        WHEN '65+' THEN 5
        ELSE 6
    END;

	SELECT
    SUM(CASE
        WHEN m.patient_id IS NULL
        THEN 1 ELSE 0
    END) AS orphan_members,

    SUM(CASE
        WHEN pr.provider_id IS NULL
        THEN 1 ELSE 0
    END) AS orphan_providers,

    SUM(CASE
        WHEN d.date_key IS NULL
        THEN 1 ELSE 0
    END) AS orphan_dates,

    SUM(CASE
        WHEN fc.primary_payer_id IS NOT NULL
         AND py.payer_id IS NULL
        THEN 1 ELSE 0
    END) AS orphan_primary_payers

FROM analytics.fact_claim fc

LEFT JOIN analytics.dim_member m
    ON fc.patient_id = m.patient_id

LEFT JOIN analytics.dim_provider pr
    ON fc.provider_id = pr.provider_id

LEFT JOIN analytics.dim_date d
    ON fc.service_date_key = d.date_key

LEFT JOIN analytics.dim_payer py
    ON fc.primary_payer_id = py.payer_id;

	ALTER TABLE analytics.fact_claim
ADD CONSTRAINT fk_fact_claim_member
FOREIGN KEY (patient_id)
REFERENCES analytics.dim_member(patient_id);

ALTER TABLE analytics.fact_claim
ADD CONSTRAINT fk_fact_claim_provider
FOREIGN KEY (provider_id)
REFERENCES analytics.dim_provider(provider_id);

ALTER TABLE analytics.fact_claim
ADD CONSTRAINT fk_fact_claim_date
FOREIGN KEY (service_date_key)
REFERENCES analytics.dim_date(date_key);

ALTER TABLE analytics.fact_claim
ADD CONSTRAINT fk_fact_claim_primary_payer
FOREIGN KEY (primary_payer_id)
REFERENCES analytics.dim_payer(payer_id);

ALTER TABLE analytics.fact_claim
ADD CONSTRAINT fk_fact_claim_secondary_payer
FOREIGN KEY (secondary_payer_id)
REFERENCES analytics.dim_payer(payer_id);

CREATE INDEX idx_fact_claim_patient
ON analytics.fact_claim(patient_id);

CREATE INDEX idx_fact_claim_provider
ON analytics.fact_claim(provider_id);

CREATE INDEX idx_fact_claim_primary_payer
ON analytics.fact_claim(primary_payer_id);

CREATE INDEX idx_fact_claim_service_date
ON analytics.fact_claim(service_date_key);

CREATE INDEX idx_fact_claim_encounter
ON analytics.fact_claim(encounter_id);

/*
utilization side of the model:
*/

DROP TABLE IF EXISTS analytics.fact_encounter;

CREATE TABLE analytics.fact_encounter AS
SELECT
    e.encounter_id,

    e.patient_id,
    e.provider_id,
    e.organization_id,
    e.payer_id,

    e.start_datetime,
    e.stop_datetime,

    e.start_datetime::date AS encounter_date,

    TO_CHAR(
        e.start_datetime::date,
        'YYYYMMDD'
    )::integer AS encounter_date_key,

    e.encounter_class,
    e.encounter_code,
    e.encounter_description,

    e.reason_code,
    e.reason_description,

    e.base_encounter_cost,
    e.total_claim_cost,
    e.payer_coverage,

    ROUND(
        (
            EXTRACT(EPOCH FROM (e.stop_datetime - e.start_datetime))
            / 3600
        )::numeric,
        2
    ) AS duration_hours,

    ROUND(
        (
            EXTRACT(EPOCH FROM (e.stop_datetime - e.start_datetime))
            / 86400
        )::numeric,
        2
    ) AS duration_days,

    DATE_PART(
        'year',
        AGE(
            e.start_datetime::date,
            p.birth_date
        )
    )::integer AS age_at_encounter,

    CASE
        WHEN DATE_PART(
            'year',
            AGE(e.start_datetime::date, p.birth_date)
        ) < 18 THEN '0-17'

        WHEN DATE_PART(
            'year',
            AGE(e.start_datetime::date, p.birth_date)
        ) BETWEEN 18 AND 34 THEN '18-34'

        WHEN DATE_PART(
            'year',
            AGE(e.start_datetime::date, p.birth_date)
        ) BETWEEN 35 AND 49 THEN '35-49'

        WHEN DATE_PART(
            'year',
            AGE(e.start_datetime::date, p.birth_date)
        ) BETWEEN 50 AND 64 THEN '50-64'

        ELSE '65+'
    END AS age_group,

    CASE
        WHEN LOWER(e.encounter_class) = 'emergency'
        THEN TRUE ELSE FALSE
    END AS emergency_flag,

    CASE
        WHEN LOWER(e.encounter_class) = 'inpatient'
        THEN TRUE ELSE FALSE
    END AS inpatient_flag,

    CASE
        WHEN LOWER(e.encounter_class) = 'outpatient'
        THEN TRUE ELSE FALSE
    END AS outpatient_flag

FROM staging.encounters e

JOIN staging.patients p
    ON e.patient_id = p.patient_id;

	SELECT
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT encounter_id) AS unique_encounters
FROM analytics.fact_encounter;

SELECT
    MIN(age_at_encounter) AS minimum_age,
    MAX(age_at_encounter) AS maximum_age,

    COUNT(*) FILTER (
        WHERE age_at_encounter < 0
    ) AS negative_age_records,

    COUNT(*) FILTER (
        WHERE duration_hours < 0
    ) AS negative_duration_records
FROM analytics.fact_encounter;

SELECT
    COUNT(*) AS total_encounters,

    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,

    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,

    COUNT(*) FILTER (
        WHERE outpatient_flag = TRUE
    ) AS outpatient_visits
FROM analytics.fact_encounter;

/*
30-day readmission proxy.
*/

ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT pk_fact_encounter
PRIMARY KEY (encounter_id);

SELECT
    SUM(CASE WHEN m.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_members,

    SUM(CASE WHEN pr.provider_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_providers,

    SUM(CASE WHEN org.organization_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_organizations,

    SUM(CASE WHEN py.payer_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_payers,

    SUM(CASE WHEN d.date_key IS NULL THEN 1 ELSE 0 END)
        AS orphan_dates

FROM analytics.fact_encounter fe

LEFT JOIN analytics.dim_member m
    ON fe.patient_id = m.patient_id

LEFT JOIN analytics.dim_provider pr
    ON fe.provider_id = pr.provider_id

LEFT JOIN analytics.dim_organization org
    ON fe.organization_id = org.organization_id

LEFT JOIN analytics.dim_payer py
    ON fe.payer_id = py.payer_id

LEFT JOIN analytics.dim_date d
    ON fe.encounter_date_key = d.date_key;

	ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT fk_fact_encounter_member
FOREIGN KEY (patient_id)
REFERENCES analytics.dim_member(patient_id);

ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT fk_fact_encounter_provider
FOREIGN KEY (provider_id)
REFERENCES analytics.dim_provider(provider_id);

ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT fk_fact_encounter_organization
FOREIGN KEY (organization_id)
REFERENCES analytics.dim_organization(organization_id);

ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT fk_fact_encounter_payer
FOREIGN KEY (payer_id)
REFERENCES analytics.dim_payer(payer_id);


CREATE INDEX idx_fact_encounter_patient
ON analytics.fact_encounter(patient_id);

CREATE INDEX idx_fact_encounter_provider
ON analytics.fact_encounter(provider_id);

CREATE INDEX idx_fact_encounter_organization
ON analytics.fact_encounter(organization_id);

CREATE INDEX idx_fact_encounter_payer
ON analytics.fact_encounter(payer_id);

CREATE INDEX idx_fact_encounter_date
ON analytics.fact_encounter(encounter_date_key);

CREATE INDEX idx_fact_encounter_class
ON analytics.fact_encounter(encounter_class);

ALTER TABLE analytics.fact_encounter
ADD CONSTRAINT fk_fact_encounter_date
FOREIGN KEY (encounter_date_key)
REFERENCES analytics.dim_date(date_key);



SELECT
    patient_id,
    encounter_id,
    start_datetime,
    stop_datetime,

    LEAD(encounter_id) OVER (
        PARTITION BY patient_id
        ORDER BY start_datetime
    ) AS next_inpatient_encounter_id,

    LEAD(start_datetime) OVER (
        PARTITION BY patient_id
        ORDER BY start_datetime
    ) AS next_inpatient_start

FROM analytics.fact_encounter

WHERE inpatient_flag = TRUE

ORDER BY patient_id, start_datetime;



DROP TABLE IF EXISTS analytics.readmission_events;

CREATE TABLE analytics.readmission_events AS

WITH inpatient_sequence AS (

    SELECT
        patient_id,
        encounter_id AS index_encounter_id,

        start_datetime AS admission_datetime,
        stop_datetime AS discharge_datetime,

        provider_id,
        organization_id,
        payer_id,

        total_claim_cost,

        LEAD(encounter_id) OVER (
            PARTITION BY patient_id
            ORDER BY start_datetime
        ) AS next_inpatient_encounter_id,

        LEAD(start_datetime) OVER (
            PARTITION BY patient_id
            ORDER BY start_datetime
        ) AS next_inpatient_start

    FROM analytics.fact_encounter

    WHERE inpatient_flag = TRUE
)

SELECT
    *,

    ROUND(
        (
            EXTRACT(
                EPOCH FROM (
                    next_inpatient_start - discharge_datetime
                )
            ) / 86400
        )::numeric,
        2
    ) AS days_to_next_inpatient,

    CASE
        WHEN next_inpatient_start IS NOT NULL
         AND next_inpatient_start >= discharge_datetime
         AND next_inpatient_start <= discharge_datetime + INTERVAL '30 days'
        THEN TRUE
        ELSE FALSE
    END AS readmission_30d_flag

FROM inpatient_sequence;

SELECT
    COUNT(*) AS inpatient_encounters,

    COUNT(*) FILTER (
        WHERE next_inpatient_encounter_id IS NOT NULL
    ) AS encounters_with_later_inpatient_visit,

    COUNT(*) FILTER (
        WHERE readmission_30d_flag = TRUE
    ) AS readmissions_within_30_days

FROM analytics.readmission_events;


SELECT
    COUNT(*) FILTER (
        WHERE readmission_30d_flag = TRUE
    ) AS readmissions_30d,

    COUNT(*) AS inpatient_encounters,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE readmission_30d_flag = TRUE
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_proxy_pct

FROM analytics.readmission_events;


DROP TABLE IF EXISTS analytics.fact_procedure;

CREATE TABLE analytics.fact_procedure AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            pr.patient_id,
            pr.encounter_id,
            pr.start_datetime,
            pr.procedure_code,
            pr.procedure_description
    )::bigint AS procedure_event_id,

    pr.patient_id,
    pr.encounter_id,

    fe.provider_id,
    fe.organization_id,
    fe.payer_id,

    pr.start_datetime,
    pr.stop_datetime,

    pr.start_datetime::date AS procedure_date,

    TO_CHAR(
        pr.start_datetime::date,
        'YYYYMMDD'
    )::integer AS procedure_date_key,

    pr.code_system,
    pr.procedure_code,
    pr.procedure_description,

    pr.base_cost,

    pr.reason_code,
    pr.reason_description,

    DATE_PART(
        'year',
        AGE(pr.start_datetime::date, m.birth_date)
    )::integer AS age_at_procedure,

    CASE
        WHEN DATE_PART(
            'year',
            AGE(pr.start_datetime::date, m.birth_date)
        ) < 18 THEN '0-17'

        WHEN DATE_PART(
            'year',
            AGE(pr.start_datetime::date, m.birth_date)
        ) BETWEEN 18 AND 34 THEN '18-34'

        WHEN DATE_PART(
            'year',
            AGE(pr.start_datetime::date, m.birth_date)
        ) BETWEEN 35 AND 49 THEN '35-49'

        WHEN DATE_PART(
            'year',
            AGE(pr.start_datetime::date, m.birth_date)
        ) BETWEEN 50 AND 64 THEN '50-64'

        ELSE '65+'
    END AS age_group

FROM staging.procedures pr

JOIN analytics.fact_encounter fe
    ON pr.encounter_id = fe.encounter_id

JOIN analytics.dim_member m
    ON pr.patient_id = m.patient_id;

SELECT
    COUNT(*) AS total_procedures,
    COUNT(DISTINCT procedure_event_id) AS unique_procedure_events
FROM analytics.fact_procedure;

SELECT
    (SELECT SUM(base_cost)
     FROM staging.procedures) AS staging_base_cost,

    (SELECT SUM(base_cost)
     FROM analytics.fact_procedure) AS analytics_base_cost;

	 SELECT
    MIN(age_at_procedure) AS minimum_age,
    MAX(age_at_procedure) AS maximum_age,
    COUNT(*) FILTER (
        WHERE age_at_procedure < 0
    ) AS negative_age_records
FROM analytics.fact_procedure;


ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT pk_fact_procedure
PRIMARY KEY (procedure_event_id);

SELECT
    SUM(CASE WHEN m.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_members,

    SUM(CASE WHEN pr.provider_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_providers,

    SUM(CASE WHEN org.organization_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_organizations,

    SUM(CASE WHEN py.payer_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_payers,

    SUM(CASE WHEN d.date_key IS NULL THEN 1 ELSE 0 END)
        AS orphan_dates

FROM analytics.fact_procedure fp

LEFT JOIN analytics.dim_member m
    ON fp.patient_id = m.patient_id

LEFT JOIN analytics.dim_provider pr
    ON fp.provider_id = pr.provider_id

LEFT JOIN analytics.dim_organization org
    ON fp.organization_id = org.organization_id

LEFT JOIN analytics.dim_payer py
    ON fp.payer_id = py.payer_id

LEFT JOIN analytics.dim_date d
    ON fp.procedure_date_key = d.date_key;


	ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT fk_fact_procedure_member
FOREIGN KEY (patient_id)
REFERENCES analytics.dim_member(patient_id);

ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT fk_fact_procedure_provider
FOREIGN KEY (provider_id)
REFERENCES analytics.dim_provider(provider_id);

ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT fk_fact_procedure_organization
FOREIGN KEY (organization_id)
REFERENCES analytics.dim_organization(organization_id);

ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT fk_fact_procedure_payer
FOREIGN KEY (payer_id)
REFERENCES analytics.dim_payer(payer_id);

ALTER TABLE analytics.fact_procedure
ADD CONSTRAINT fk_fact_procedure_date
FOREIGN KEY (procedure_date_key)
REFERENCES analytics.dim_date(date_key);

CREATE INDEX idx_fact_procedure_patient
ON analytics.fact_procedure(patient_id);

CREATE INDEX idx_fact_procedure_provider
ON analytics.fact_procedure(provider_id);

CREATE INDEX idx_fact_procedure_organization
ON analytics.fact_procedure(organization_id);

CREATE INDEX idx_fact_procedure_payer
ON analytics.fact_procedure(payer_id);

CREATE INDEX idx_fact_procedure_date
ON analytics.fact_procedure(procedure_date_key);

CREATE INDEX idx_fact_procedure_code
ON analytics.fact_procedure(procedure_code);

DROP TABLE IF EXISTS analytics.fact_condition;

CREATE TABLE analytics.fact_condition AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            c.patient_id,
            c.encounter_id,
            c.start_date,
            c.condition_code,
            c.condition_description
    )::bigint AS condition_event_id,

    c.patient_id,
    c.encounter_id,

    fe.provider_id,
    fe.organization_id,
    fe.payer_id,

    c.start_date,
    c.stop_date,

    TO_CHAR(
        c.start_date,
        'YYYYMMDD'
    )::integer AS condition_start_date_key,

    c.code_system,
    c.condition_code,
    c.condition_description,

    CASE
        WHEN LOWER(c.condition_description) LIKE '%(disorder)%'
            THEN 'Disorder'
        WHEN LOWER(c.condition_description) LIKE '%(finding)%'
            THEN 'Finding'
        WHEN LOWER(c.condition_description) LIKE '%(situation)%'
            THEN 'Situation'
        ELSE 'Other'
    END AS condition_category,

    CASE
        WHEN c.stop_date IS NULL
        THEN TRUE
        ELSE FALSE
    END AS active_condition_flag,

    CASE
        WHEN c.stop_date IS NOT NULL
        THEN c.stop_date - c.start_date
        ELSE NULL
    END AS condition_duration_days,

    DATE_PART(
        'year',
        AGE(c.start_date, m.birth_date)
    )::integer AS age_at_condition,

    CASE
        WHEN DATE_PART('year', AGE(c.start_date, m.birth_date)) < 18
            THEN '0-17'
        WHEN DATE_PART('year', AGE(c.start_date, m.birth_date)) BETWEEN 18 AND 34
            THEN '18-34'
        WHEN DATE_PART('year', AGE(c.start_date, m.birth_date)) BETWEEN 35 AND 49
            THEN '35-49'
        WHEN DATE_PART('year', AGE(c.start_date, m.birth_date)) BETWEEN 50 AND 64
            THEN '50-64'
        ELSE '65+'
    END AS age_group

FROM staging.conditions c

JOIN analytics.fact_encounter fe
    ON c.encounter_id = fe.encounter_id

JOIN analytics.dim_member m
    ON c.patient_id = m.patient_id;


	SELECT
    condition_category,
    COUNT(*) AS condition_count
FROM analytics.fact_condition
GROUP BY condition_category
ORDER BY condition_count DESC;


SELECT
    COUNT(*) AS total_conditions,

    COUNT(*) FILTER (
        WHERE active_condition_flag = TRUE
    ) AS active_conditions,

    COUNT(*) FILTER (
        WHERE age_at_condition < 0
    ) AS negative_age_records,

    COUNT(*) FILTER (
        WHERE condition_duration_days < 0
    ) AS negative_duration_records

FROM analytics.fact_condition;

SELECT
    SUM(CASE WHEN m.patient_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_members,

    SUM(CASE WHEN pr.provider_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_providers,

    SUM(CASE WHEN org.organization_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_organizations,

    SUM(CASE WHEN py.payer_id IS NULL THEN 1 ELSE 0 END)
        AS orphan_payers,

    SUM(CASE WHEN d.date_key IS NULL THEN 1 ELSE 0 END)
        AS orphan_dates

FROM analytics.fact_condition fc

LEFT JOIN analytics.dim_member m
    ON fc.patient_id = m.patient_id

LEFT JOIN analytics.dim_provider pr
    ON fc.provider_id = pr.provider_id

LEFT JOIN analytics.dim_organization org
    ON fc.organization_id = org.organization_id

LEFT JOIN analytics.dim_payer py
    ON fc.payer_id = py.payer_id

LEFT JOIN analytics.dim_date d
    ON fc.condition_start_date_key = d.date_key;



	ALTER TABLE analytics.fact_condition
ADD CONSTRAINT pk_fact_condition
PRIMARY KEY (condition_event_id);

ALTER TABLE analytics.fact_condition
ADD CONSTRAINT fk_fact_condition_member
FOREIGN KEY (patient_id)
REFERENCES analytics.dim_member(patient_id);

ALTER TABLE analytics.fact_condition
ADD CONSTRAINT fk_fact_condition_provider
FOREIGN KEY (provider_id)
REFERENCES analytics.dim_provider(provider_id);

ALTER TABLE analytics.fact_condition
ADD CONSTRAINT fk_fact_condition_organization
FOREIGN KEY (organization_id)
REFERENCES analytics.dim_organization(organization_id);

ALTER TABLE analytics.fact_condition
ADD CONSTRAINT fk_fact_condition_payer
FOREIGN KEY (payer_id)
REFERENCES analytics.dim_payer(payer_id);

ALTER TABLE analytics.fact_condition
ADD CONSTRAINT fk_fact_condition_date
FOREIGN KEY (condition_start_date_key)
REFERENCES analytics.dim_date(date_key);


CREATE INDEX idx_fact_condition_patient
ON analytics.fact_condition(patient_id);

CREATE INDEX idx_fact_condition_encounter
ON analytics.fact_condition(encounter_id);

CREATE INDEX idx_fact_condition_provider
ON analytics.fact_condition(provider_id);

CREATE INDEX idx_fact_condition_organization
ON analytics.fact_condition(organization_id);

CREATE INDEX idx_fact_condition_payer
ON analytics.fact_condition(payer_id);

CREATE INDEX idx_fact_condition_date
ON analytics.fact_condition(condition_start_date_key);

CREATE INDEX idx_fact_condition_code
ON analytics.fact_condition(condition_code);

CREATE INDEX idx_fact_condition_category
ON analytics.fact_condition(condition_category);



SELECT 'dim_member' AS table_name, COUNT(*) AS row_count
FROM analytics.dim_member

UNION ALL
SELECT 'dim_provider', COUNT(*)
FROM analytics.dim_provider

UNION ALL
SELECT 'dim_organization', COUNT(*)
FROM analytics.dim_organization

UNION ALL
SELECT 'dim_payer', COUNT(*)
FROM analytics.dim_payer

UNION ALL
SELECT 'dim_date', COUNT(*)
FROM analytics.dim_date

UNION ALL
SELECT 'fact_claim', COUNT(*)
FROM analytics.fact_claim

UNION ALL
SELECT 'fact_encounter', COUNT(*)
FROM analytics.fact_encounter

UNION ALL
SELECT 'fact_procedure', COUNT(*)
FROM analytics.fact_procedure

UNION ALL
SELECT 'fact_condition', COUNT(*)
FROM analytics.fact_condition

UNION ALL
SELECT 'readmission_events', COUNT(*)
FROM analytics.readmission_events

ORDER BY table_name;

SELECT
    EXTRACT(YEAR FROM service_date)::integer AS service_year,
    COUNT(*) AS claim_count,
    COUNT(DISTINCT patient_id) AS unique_members,
    ROUND(SUM(total_charge), 2) AS total_charges,
    ROUND(SUM(total_payment), 2) AS total_payments,
    ROUND(AVG(total_charge), 2) AS avg_claim_charge
FROM analytics.fact_claim
GROUP BY EXTRACT(YEAR FROM service_date)
ORDER BY service_year;

SELECT
    EXTRACT(YEAR FROM encounter_date)::integer AS encounter_year,
    COUNT(*) AS total_encounters,

    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,

    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,

    COUNT(DISTINCT patient_id) AS unique_members

FROM analytics.fact_encounter
GROUP BY EXTRACT(YEAR FROM encounter_date)
ORDER BY encounter_year;



CREATE OR REPLACE VIEW analytics.vw_executive_kpis AS

SELECT
    DATE '2021-01-01' AS reporting_start,
    DATE '2025-12-31' AS reporting_end,

    COUNT(*) AS total_claims,

    COUNT(DISTINCT patient_id) AS members_with_claims,

    ROUND(SUM(total_charge), 2) AS total_charges,

    ROUND(SUM(total_payment), 2) AS total_payments,

    ROUND(AVG(total_charge), 2) AS average_claim_charge,

    ROUND(
        SUM(total_charge)
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS charge_per_member,

    ROUND(
        COUNT(*)::numeric
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS claims_per_member

FROM analytics.fact_claim

WHERE service_date >= DATE '2021-01-01'
  AND service_date < DATE '2026-01-01';

  SELECT *
FROM analytics.vw_executive_kpis;


SELECT * FROM analytics.vw_executive_kpis;



CREATE OR REPLACE VIEW analytics.vw_monthly_membership AS

WITH months AS (
    SELECT
        month_start::date,
        (month_start + INTERVAL '1 month - 1 day')::date AS month_end
    FROM GENERATE_SERIES(
        DATE '2021-01-01',
        DATE '2025-12-01',
        INTERVAL '1 month'
    ) AS month_start
)

SELECT
    m.month_start,
    m.month_end,

    COUNT(DISTINCT pt.patient_id) AS active_members

FROM months m

LEFT JOIN staging.payer_transitions pt
    ON pt.coverage_start::date <= m.month_end
   AND pt.coverage_end::date >= m.month_start

GROUP BY
    m.month_start,
    m.month_end

ORDER BY m.month_start;


SELECT *
FROM analytics.vw_monthly_membership;

SELECT
    COUNT(*) AS reporting_months,
    SUM(active_members) AS total_member_months,
    ROUND(AVG(active_members), 2) AS avg_monthly_members
FROM analytics.vw_monthly_membership;

DROP VIEW IF EXISTS analytics.vw_executive_kpis;
CREATE VIEW analytics.vw_executive_kpis AS

WITH claim_metrics AS (
    SELECT
        COUNT(*) AS total_claims,

        COUNT(DISTINCT patient_id) AS members_with_claims,

        ROUND(SUM(total_charge), 2) AS total_charges,

        ROUND(SUM(total_payment), 2) AS total_payments,

        ROUND(AVG(total_charge), 2) AS average_claim_charge,

        ROUND(
            SUM(total_charge)
            / NULLIF(COUNT(DISTINCT patient_id), 0),
            2
        ) AS charge_per_member,

        ROUND(
            COUNT(*)::numeric
            / NULLIF(COUNT(DISTINCT patient_id), 0),
            2
        ) AS claims_per_member

    FROM analytics.fact_claim

    WHERE service_date >= DATE '2021-01-01'
      AND service_date < DATE '2026-01-01'
),

membership_metrics AS (
    SELECT
        SUM(active_members) AS total_member_months,
        ROUND(AVG(active_members), 2) AS avg_monthly_members

    FROM analytics.vw_monthly_membership
)

SELECT
    DATE '2021-01-01' AS reporting_start,
    DATE '2025-12-31' AS reporting_end,

    c.total_claims,
    c.members_with_claims,

    c.total_charges,
    c.total_payments,

    c.average_claim_charge,
    c.charge_per_member,
    c.claims_per_member,

    m.total_member_months,
    m.avg_monthly_members,

    ROUND(
        c.total_charges
        / NULLIF(m.total_member_months, 0),
        2
    ) AS charge_pmpm

FROM claim_metrics c
CROSS JOIN membership_metrics m;

SELECT *
FROM analytics.vw_executive_kpis;



/*
monthly cost trend view
*/

CREATE OR REPLACE VIEW analytics.vw_monthly_cost_trend AS

WITH monthly_claims AS (
    SELECT
        DATE_TRUNC('month', service_date)::date AS month_start,

        COUNT(*) AS claim_count,

        COUNT(DISTINCT patient_id) AS members_with_claims,

        ROUND(SUM(total_charge), 2) AS total_charges,

        ROUND(SUM(total_payment), 2) AS total_payments,

        ROUND(AVG(total_charge), 2) AS average_claim_charge

    FROM analytics.fact_claim

    WHERE service_date >= DATE '2021-01-01'
      AND service_date < DATE '2026-01-01'

    GROUP BY
        DATE_TRUNC('month', service_date)
),

monthly_metrics AS (
    SELECT
        mc.month_start,
        mm.active_members,

        mc.claim_count,
        mc.members_with_claims,

        mc.total_charges,
        mc.total_payments,
        mc.average_claim_charge,

        ROUND(
            mc.total_charges
            / NULLIF(mm.active_members, 0),
            2
        ) AS charge_pmpm,

        LAG(mc.total_charges) OVER (
            ORDER BY mc.month_start
        ) AS previous_month_charges

    FROM monthly_claims mc

    JOIN analytics.vw_monthly_membership mm
        ON mc.month_start = mm.month_start
)

SELECT
    month_start,

    EXTRACT(YEAR FROM month_start)::integer AS year,

    EXTRACT(MONTH FROM month_start)::integer AS month_number,

    TO_CHAR(month_start, 'Mon') AS month_name,

    TO_CHAR(month_start, 'YYYY-MM') AS year_month,

    active_members,
    members_with_claims,
    claim_count,

    total_charges,
    total_payments,
    average_claim_charge,
    charge_pmpm,

    previous_month_charges,

    ROUND(
        100.0 *
        (total_charges - previous_month_charges)
        / NULLIF(previous_month_charges, 0),
        2
    ) AS mom_charge_change_pct

FROM monthly_metrics;


SELECT *
FROM analytics.vw_monthly_cost_trend
ORDER BY month_start;

SELECT
    COUNT(*) AS months,

    ROUND(SUM(total_charges), 2) AS total_charges,

    ROUND(AVG(active_members), 2) AS avg_monthly_members

FROM analytics.vw_monthly_cost_trend;


/*
Member Cost Analytics
*/


CREATE OR REPLACE VIEW analytics.vw_member_cost AS

SELECT
    fc.patient_id,

    dm.gender,
    dm.race,
    dm.ethnicity,
    dm.income_band,

    COUNT(*) AS claim_count,

    ROUND(SUM(fc.total_charge), 2) AS total_charges,

    ROUND(SUM(fc.total_payment), 2) AS total_payments,

    ROUND(AVG(fc.total_charge), 2) AS average_claim_charge,

    MIN(fc.service_date) AS first_claim_date,
    MAX(fc.service_date) AS last_claim_date

FROM analytics.fact_claim fc

JOIN analytics.dim_member dm
    ON fc.patient_id = dm.patient_id

WHERE fc.service_date >= DATE '2021-01-01'
  AND fc.service_date < DATE '2026-01-01'

GROUP BY
    fc.patient_id,
    dm.gender,
    dm.race,
    dm.ethnicity,
    dm.income_band;

	SELECT *
FROM analytics.vw_member_cost
ORDER BY total_charges DESC
LIMIT 10;


CREATE OR REPLACE VIEW analytics.vw_member_utilization AS

SELECT
    patient_id,

    COUNT(*) AS total_encounters,

    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,

    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,

    COUNT(*) FILTER (
        WHERE outpatient_flag = TRUE
    ) AS outpatient_visits,

    ROUND(
        AVG(duration_hours),
        2
    ) AS average_encounter_duration_hours,

    ROUND(
        SUM(total_claim_cost),
        2
    ) AS encounter_level_cost

FROM analytics.fact_encounter

WHERE encounter_date >= DATE '2021-01-01'
  AND encounter_date < DATE '2026-01-01'

GROUP BY patient_id;

CREATE OR REPLACE VIEW analytics.vw_member_cost_utilization AS

SELECT
    mc.patient_id,

    mc.gender,
    mc.race,
    mc.ethnicity,
    mc.income_band,

    mc.claim_count,
    mc.total_charges,
    mc.average_claim_charge,

    COALESCE(mu.total_encounters, 0) AS total_encounters,
    COALESCE(mu.emergency_visits, 0) AS emergency_visits,
    COALESCE(mu.inpatient_visits, 0) AS inpatient_visits,
    COALESCE(mu.outpatient_visits, 0) AS outpatient_visits,

    mc.cost_rank,
    mc.cost_decile,

    CASE
        WHEN mc.cost_decile = 1
        THEN TRUE
        ELSE FALSE
    END AS high_cost_member_flag

FROM analytics.vw_member_cost_ranked mc

LEFT JOIN analytics.vw_member_utilization mu
    ON mc.patient_id = mu.patient_id;

	SELECT COUNT(*)
FROM analytics.vw_member_cost;

CREATE OR REPLACE VIEW analytics.vw_member_cost_ranked AS

SELECT
    mc.*,

    ROW_NUMBER() OVER (
        ORDER BY total_charges DESC
    ) AS cost_rank,

    NTILE(10) OVER (
        ORDER BY total_charges DESC
    ) AS cost_decile,

    ROUND(
        100.0 * total_charges
        / SUM(total_charges) OVER (),
        2
    ) AS pct_of_total_cost,

    ROUND(
        100.0 *
        SUM(total_charges) OVER (
            ORDER BY total_charges DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        / SUM(total_charges) OVER (),
        2
    ) AS cumulative_cost_pct

FROM analytics.vw_member_cost mc;


SELECT
    cost_rank,
    patient_id,
    claim_count,
    total_charges,
    cost_decile,
    pct_of_total_cost,
    cumulative_cost_pct
FROM analytics.vw_member_cost_ranked
ORDER BY cost_rank
LIMIT 10;


CREATE OR REPLACE VIEW analytics.vw_member_cost_utilization AS

SELECT
    mc.patient_id,

    mc.gender,
    mc.race,
    mc.ethnicity,
    mc.income_band,

    mc.claim_count,
    mc.total_charges,
    mc.average_claim_charge,

    COALESCE(mu.total_encounters, 0) AS total_encounters,
    COALESCE(mu.emergency_visits, 0) AS emergency_visits,
    COALESCE(mu.inpatient_visits, 0) AS inpatient_visits,
    COALESCE(mu.outpatient_visits, 0) AS outpatient_visits,

    mc.cost_rank,
    mc.cost_decile,

    CASE
        WHEN mc.cost_decile = 1 THEN TRUE
        ELSE FALSE
    END AS high_cost_member_flag

FROM analytics.vw_member_cost_ranked mc

LEFT JOIN analytics.vw_member_utilization mu
    ON mc.patient_id = mu.patient_id;




SELECT
    patient_id,
    claim_count,
    total_charges,
    total_encounters,
    emergency_visits,
    inpatient_visits,
    high_cost_member_flag
FROM analytics.vw_member_cost_utilization
ORDER BY total_encounters DESC
LIMIT 10;

SELECT
    COUNT(*) AS members,
    SUM(claim_count) AS total_claims,
    ROUND(SUM(total_charges), 2) AS total_charges
FROM analytics.vw_member_cost_utilization;


/*
Provider Performance Analytics
*/

CREATE OR REPLACE VIEW analytics.vw_provider_performance AS

WITH provider_claims AS (
    SELECT
        provider_id,

        COUNT(*) AS claim_count,
        COUNT(DISTINCT patient_id) AS unique_claim_members,

        ROUND(SUM(total_charge), 2) AS total_charges,
        ROUND(SUM(total_payment), 2) AS total_payments,
        ROUND(AVG(total_charge), 2) AS average_claim_charge,

        ROUND(
            SUM(total_charge)
            / NULLIF(COUNT(DISTINCT patient_id), 0),
            2
        ) AS charges_per_member

    FROM analytics.fact_claim

    WHERE service_date >= DATE '2021-01-01'
      AND service_date < DATE '2026-01-01'

    GROUP BY provider_id
),

provider_encounters AS (
    SELECT
        provider_id,

        COUNT(*) AS total_encounters,
        COUNT(DISTINCT patient_id) AS unique_encounter_members,

        COUNT(*) FILTER (
            WHERE emergency_flag = TRUE
        ) AS emergency_visits,

        COUNT(*) FILTER (
            WHERE inpatient_flag = TRUE
        ) AS inpatient_visits,

        COUNT(*) FILTER (
            WHERE outpatient_flag = TRUE
        ) AS outpatient_visits

    FROM analytics.fact_encounter

    WHERE encounter_date >= DATE '2021-01-01'
      AND encounter_date < DATE '2026-01-01'

    GROUP BY provider_id
)

SELECT
    dp.provider_id,
    dp.provider_name,
    dp.specialty,

    dp.organization_id,
    dp.organization_name,

    COALESCE(pc.claim_count, 0) AS claim_count,
    COALESCE(pc.unique_claim_members, 0) AS unique_claim_members,

    COALESCE(pc.total_charges, 0) AS total_charges,
    COALESCE(pc.total_payments, 0) AS total_payments,
    COALESCE(pc.average_claim_charge, 0) AS average_claim_charge,
    COALESCE(pc.charges_per_member, 0) AS charges_per_member,

    COALESCE(pe.total_encounters, 0) AS total_encounters,
    COALESCE(pe.unique_encounter_members, 0) AS unique_encounter_members,

    COALESCE(pe.emergency_visits, 0) AS emergency_visits,
    COALESCE(pe.inpatient_visits, 0) AS inpatient_visits,
    COALESCE(pe.outpatient_visits, 0) AS outpatient_visits

FROM analytics.dim_provider dp

LEFT JOIN provider_claims pc
    ON dp.provider_id = pc.provider_id

LEFT JOIN provider_encounters pe
    ON dp.provider_id = pe.provider_id

WHERE
    COALESCE(pc.claim_count, 0) > 0
    OR COALESCE(pe.total_encounters, 0) > 0;


	SELECT
    COUNT(*) AS active_providers,
    SUM(claim_count) AS total_claims,
    ROUND(SUM(total_charges), 2) AS total_charges
FROM analytics.vw_provider_performance;


SELECT
    provider_name,
    specialty,
    organization_name,

    unique_claim_members,
    claim_count,
    total_charges,
    average_claim_charge,
    charges_per_member,
    total_encounters

FROM analytics.vw_provider_performance

ORDER BY total_charges DESC

LIMIT 10;



CREATE OR REPLACE VIEW analytics.vw_provider_performance_ranked AS

WITH thresholds AS (
    SELECT
        PERCENTILE_CONT(0.90)
        WITHIN GROUP (
            ORDER BY average_claim_charge
        ) AS avg_charge_p90

    FROM analytics.vw_provider_performance

    WHERE claim_count >= 10
)

SELECT
    p.*,

    ROW_NUMBER() OVER (
        ORDER BY total_charges DESC
    ) AS total_cost_rank,

    ROW_NUMBER() OVER (
        ORDER BY average_claim_charge DESC
    ) AS avg_cost_rank,

    CASE
        WHEN p.claim_count >= 10
         AND p.average_claim_charge >= t.avg_charge_p90
        THEN TRUE
        ELSE FALSE
    END AS high_avg_cost_flag

FROM analytics.vw_provider_performance p

CROSS JOIN thresholds t;



SELECT
    provider_name,
    specialty,
    claim_count,
    unique_claim_members,
    total_charges,
    average_claim_charge,
    charges_per_member,
    high_avg_cost_flag

FROM analytics.vw_provider_performance_ranked

WHERE high_avg_cost_flag = TRUE

ORDER BY average_claim_charge DESC;


SELECT
    COUNT(*) AS active_providers,

    COUNT(*) FILTER (
        WHERE high_avg_cost_flag = TRUE
    ) AS high_avg_cost_providers,

    SUM(claim_count) AS claims,

    ROUND(SUM(total_charges), 2) AS charges

FROM analytics.vw_provider_performance_ranked;

/*
Utilization Analytics
*/
CREATE OR REPLACE VIEW analytics.vw_utilization_summary AS

SELECT
    COUNT(*) AS total_encounters,

    COUNT(DISTINCT patient_id) AS members_with_encounters,

    ROUND(
        COUNT(*)::numeric
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS encounters_per_member,

    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,

    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,

    COUNT(*) FILTER (
        WHERE outpatient_flag = TRUE
    ) AS outpatient_visits,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE emergency_flag = TRUE
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS emergency_visit_pct,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE inpatient_flag = TRUE
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS inpatient_visit_pct,

    ROUND(
        AVG(duration_days) FILTER (
            WHERE inpatient_flag = TRUE
        ),
        2
    ) AS avg_inpatient_length_of_stay_days,

    ROUND(
        SUM(total_claim_cost),
        2
    ) AS encounter_level_cost

FROM analytics.fact_encounter

WHERE encounter_date >= DATE '2021-01-01'
  AND encounter_date < DATE '2026-01-01';

  SELECT *
FROM analytics.vw_utilization_summary;

CREATE OR REPLACE VIEW analytics.vw_encounter_type_utilization AS

SELECT
    encounter_class,

    COUNT(*) AS encounter_count,

    COUNT(DISTINCT patient_id) AS unique_members,

    ROUND(
        COUNT(*)::numeric
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS encounters_per_member,

    ROUND(
        AVG(duration_hours),
        2
    ) AS average_duration_hours,

    ROUND(
        SUM(total_claim_cost),
        2
    ) AS total_encounter_cost,

    ROUND(
        AVG(total_claim_cost),
        2
    ) AS average_encounter_cost

FROM analytics.fact_encounter

WHERE encounter_date >= DATE '2021-01-01'
  AND encounter_date < DATE '2026-01-01'

GROUP BY encounter_class;

SELECT *
FROM analytics.vw_encounter_type_utilization
ORDER BY encounter_count DESC;


CREATE OR REPLACE VIEW analytics.vw_utilization_by_age AS

SELECT
    age_group,

    COUNT(*) AS total_encounters,

    COUNT(DISTINCT patient_id) AS unique_members,

    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,

    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,

    COUNT(*) FILTER (
        WHERE outpatient_flag = TRUE
    ) AS outpatient_visits,

    ROUND(
        COUNT(*)::numeric
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS encounters_per_member

FROM analytics.fact_encounter

WHERE encounter_date >= DATE '2021-01-01'
  AND encounter_date < DATE '2026-01-01'

GROUP BY age_group;


SELECT *
FROM analytics.vw_utilization_by_age
ORDER BY
    CASE age_group
        WHEN '0-17' THEN 1
        WHEN '18-34' THEN 2
        WHEN '35-49' THEN 3
        WHEN '50-64' THEN 4
        WHEN '65+' THEN 5
        ELSE 6
    END;


	CREATE OR REPLACE VIEW analytics.vw_condition_utilization AS

SELECT
    condition_code,
    condition_description,
    condition_category,

    COUNT(*) AS condition_events,

    COUNT(DISTINCT patient_id) AS unique_members,

    COUNT(DISTINCT encounter_id) AS associated_encounters,

    COUNT(*) FILTER (
        WHERE active_condition_flag = TRUE
    ) AS active_condition_events,

    ROUND(
        COUNT(DISTINCT encounter_id)::numeric
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS encounters_per_affected_member

FROM analytics.fact_condition

WHERE start_date >= DATE '2021-01-01'
  AND start_date < DATE '2026-01-01'

GROUP BY
    condition_code,
    condition_description,
    condition_category;

	SELECT *
FROM analytics.vw_condition_utilization
ORDER BY associated_encounters DESC
LIMIT 15;


SELECT
    condition_description,
    condition_events,
    unique_members,
    associated_encounters,
    encounters_per_affected_member
FROM analytics.vw_condition_utilization
WHERE condition_category = 'Disorder'
ORDER BY associated_encounters DESC
LIMIT 15;


/*
Procedure/service analysis
*/

CREATE OR REPLACE VIEW analytics.vw_procedure_performance AS

SELECT
    procedure_code,
    procedure_description,

    COUNT(*) AS procedure_count,

    COUNT(DISTINCT patient_id) AS unique_members,

    COUNT(DISTINCT encounter_id) AS associated_encounters,

    ROUND(
        SUM(base_cost),
        2
    ) AS total_procedure_base_cost,

    ROUND(
        AVG(base_cost),
        2
    ) AS average_procedure_base_cost,

    ROUND(
        SUM(base_cost)
        / NULLIF(COUNT(DISTINCT patient_id), 0),
        2
    ) AS procedure_cost_per_member

FROM analytics.fact_procedure

WHERE procedure_date >= DATE '2021-01-01'
  AND procedure_date < DATE '2026-01-01'

GROUP BY
    procedure_code,
    procedure_description;

	SELECT *
FROM analytics.vw_procedure_performance
ORDER BY total_procedure_base_cost DESC
LIMIT 15;


SELECT *
FROM analytics.vw_procedure_performance
ORDER BY procedure_count DESC
LIMIT 15;


SELECT
    SUM(procedure_count) AS procedure_events,
    ROUND(SUM(total_procedure_base_cost), 2) AS total_base_cost
FROM analytics.vw_procedure_performance;

SELECT
    COUNT(*) AS procedure_events,
    ROUND(SUM(base_cost), 2) AS total_base_cost
FROM analytics.fact_procedure
WHERE procedure_date >= DATE '2021-01-01'
  AND procedure_date < DATE '2026-01-01';


  /*
Payer analysis
*/
CREATE OR REPLACE VIEW analytics.vw_payer_monthly_membership AS

WITH months AS (
    SELECT
        month_start::date AS month_start,
        (month_start + INTERVAL '1 month - 1 day')::date AS month_end

    FROM GENERATE_SERIES(
        DATE '2021-01-01',
        DATE '2025-12-01',
        INTERVAL '1 month'
    ) AS month_start
)

SELECT
    m.month_start,
    pt.payer_id,

    COUNT(DISTINCT pt.patient_id) AS active_members

FROM months m

JOIN staging.payer_transitions pt
    ON pt.coverage_start::date <= m.month_end
   AND pt.coverage_end::date >= m.month_start

GROUP BY
    m.month_start,
    pt.payer_id;


	CREATE OR REPLACE VIEW analytics.vw_payer_performance AS

WITH payer_claims AS (

    SELECT
        primary_payer_id AS payer_id,

        COUNT(*) AS claim_count,

        COUNT(DISTINCT patient_id) AS members_with_claims,

        ROUND(SUM(total_charge), 2) AS total_charges,

        ROUND(SUM(total_payment), 2) AS total_payments,

        ROUND(AVG(total_charge), 2) AS average_claim_charge

    FROM analytics.fact_claim

    WHERE service_date >= DATE '2021-01-01'
      AND service_date < DATE '2026-01-01'
      AND primary_payer_id IS NOT NULL

    GROUP BY primary_payer_id
),

payer_membership AS (

    SELECT
        payer_id,

        SUM(active_members) AS total_member_months,

        ROUND(AVG(active_members), 2) AS avg_monthly_members

    FROM analytics.vw_payer_monthly_membership

    GROUP BY payer_id
)

SELECT
    dp.payer_id,
    dp.payer_name,
    dp.ownership,

    COALESCE(pc.claim_count, 0) AS claim_count,
    COALESCE(pc.members_with_claims, 0) AS members_with_claims,

    COALESCE(pc.total_charges, 0) AS total_charges,
    COALESCE(pc.total_payments, 0) AS total_payments,

    COALESCE(pc.average_claim_charge, 0)
        AS average_claim_charge,

    COALESCE(pm.total_member_months, 0)
        AS total_member_months,

    COALESCE(pm.avg_monthly_members, 0)
        AS avg_monthly_members,

    ROUND(
        COALESCE(pc.total_charges, 0)
        / NULLIF(pm.total_member_months, 0),
        2
    ) AS charge_pmpm

FROM analytics.dim_payer dp

LEFT JOIN payer_claims pc
    ON dp.payer_id = pc.payer_id

LEFT JOIN payer_membership pm
    ON dp.payer_id = pm.payer_id;



	SELECT
    payer_name,
    members_with_claims,
    claim_count,
    total_charges,
    total_member_months,
    avg_monthly_members,
    charge_pmpm
FROM analytics.vw_payer_performance
ORDER BY total_charges DESC;


SELECT
    COUNT(*) AS claims_without_primary_payer,

    COUNT(DISTINCT patient_id) AS members,

    ROUND(SUM(total_charge), 2) AS charges_without_primary_payer

FROM analytics.fact_claim

WHERE service_date >= DATE '2021-01-01'
  AND service_date < DATE '2026-01-01'
  AND primary_payer_id IS NULL;


  SELECT
    ROUND(
        (
            SELECT SUM(total_charges)
            FROM analytics.vw_payer_performance
        )
        +
        (
            SELECT SUM(total_charge)
            FROM analytics.fact_claim
            WHERE service_date >= DATE '2021-01-01'
              AND service_date < DATE '2026-01-01'
              AND primary_payer_id IS NULL
        ),
        2
    ) AS reconstructed_total_charges;



/*
Final QA
*/

SELECT
    COUNT(*) AS claims,
    COUNT(DISTINCT claim_id) AS unique_claims,
    ROUND(SUM(total_charge), 2) AS total_charges,
    ROUND(SUM(total_payment), 2) AS total_payments
FROM analytics.fact_claim
WHERE service_date >= DATE '2021-01-01'
  AND service_date < DATE '2026-01-01';

SELECT
    e.total_claims AS executive_claims,
    m.monthly_claims,

    e.total_charges AS executive_charges,
    m.monthly_charges

FROM analytics.vw_executive_kpis e

CROSS JOIN (
    SELECT
        SUM(claim_count) AS monthly_claims,
        ROUND(SUM(total_charges), 2) AS monthly_charges
    FROM analytics.vw_monthly_cost_trend
) m;



	SELECT
    SUM(claim_count) AS member_view_claims,
    ROUND(SUM(total_charges), 2) AS member_view_charges
FROM analytics.vw_member_cost;


SELECT
    SUM(claim_count) AS provider_view_claims,
    ROUND(SUM(total_charges), 2) AS provider_view_charges
FROM analytics.vw_provider_performance;


SELECT
    COUNT(*) AS encounters,
    COUNT(*) FILTER (
        WHERE emergency_flag = TRUE
    ) AS emergency_visits,
    COUNT(*) FILTER (
        WHERE inpatient_flag = TRUE
    ) AS inpatient_visits,
    COUNT(*) FILTER (
        WHERE outpatient_flag = TRUE
    ) AS outpatient_visits
FROM analytics.fact_encounter
WHERE encounter_date >= DATE '2021-01-01'
  AND encounter_date < DATE '2026-01-01';


  SELECT
    COUNT(*) AS fact_procedures,
    ROUND(SUM(base_cost), 2) AS fact_procedure_cost
FROM analytics.fact_procedure
WHERE procedure_date >= DATE '2021-01-01'
  AND procedure_date < DATE '2026-01-01';

  SELECT
    SUM(procedure_count) AS view_procedures,
    ROUND(SUM(total_procedure_base_cost), 2) AS view_procedure_cost
FROM analytics.vw_procedure_performance;

SELECT
    COUNT(*) AS fact_conditions
FROM analytics.fact_condition
WHERE start_date >= DATE '2021-01-01'
  AND start_date < DATE '2026-01-01';

  SELECT
    SUM(condition_events) AS view_conditions
FROM analytics.vw_condition_utilization;