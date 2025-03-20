CREATE TABLE doctors(
	doctor_id SERIAL PRIMARY KEY,
	doctor_name VARCHAR(30) NOT NULL,
	specialization VARCHAR(30) NOT NULL
)
CREATE TABLE patients(
	patient_id SERIAL PRIMARY KEY,
	patient_name VARCHAR(30) NOT NULL,
	patient_age INT CHECK(patient_age > 0) NOT NULL
)

CREATE TABLE appointments(
	appointment_id SERIAL PRIMARY KEY,
	disease VARCHAR(30) NOT NULL,
	patient_id INT REFERENCES patients(patient_id) NOT NULL ,
	doctor_id INT REFERENCES doctors(doctor_id) NOT NULL 
)



-- Creating doctor details
CREATE FUNCTION create_Doctor(d_name TEXT, d_special TEXT)
RETURNS BOOLEAN AS $$
DECLARE 
	rowsAffect INT;
	status BOOLEAN;
BEGIN
	INSERT INTO doctors (doctor_name, specialization) 
    VALUES (d_name, d_special);
    GET DIAGNOSTICS rowsAffect = ROW_COUNT;
	IF rowsAffect > 0 THEN
		status := TRUE;
	ELSE 
		status := FALSE;
	END IF;
	RETURN status;
END;
$$ LANGUAGE plpgsql;

-- Creating patient details
CREATE FUNCTION create_Patient(p_name TEXT, p_age INT)
RETURNS BOOLEAN AS $$
DECLARE 
	rowsAffect INT;
	status BOOLEAN;
BEGIN
	INSERT INTO patients(patient_name, patient_age) VALUES(p_name, p_age);
	GET DIAGNOSTICS rowsAffect = ROW_COUNT;
	IF rowsAffect > 0 THEN
		status := TRUE;
	ELSE 
		status := FALSE;
	END IF;
	RETURN status;
END;
$$ LANGUAGE plpgsql;

-- Creating appointment details
CREATE FUNCTION create_Appointment(d_id INT, p_id INT, p_disease TEXT)
RETURNS BOOLEAN AS $$
DECLARE 
	rowsAffect INT;
	status BOOLEAN;
BEGIN
	INSERT INTO appointments(doctor_id, patient_id, disease) VALUES(d_id, p_id, p_disease);
	GET DIAGNOSTICS rowsAffect = ROW_COUNT;
	IF rowsAffect > 0 THEN
		status := TRUE;
	ELSE 
		status := FALSE;
	END IF;
	RETURN status;
END;
$$ LANGUAGE plpgsql;

-- Doctor present
CREATE FUNCTION doctor_present(d_id INT)
RETURNS BOOLEAN AS $$
DECLARE 
	present TEXT;
BEGIN
	present := NULL;
	present := (SELECT doctor_id FROM doctors WHERE doctor_id = d_id );
	CASE WHEN present IS NOT NULL
	THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END CASE;
END;
$$ LANGUAGE plpgsql;

-- Patient present
CREATE FUNCTION patient_present(p_id INT)
RETURNS BOOLEAN AS $$
DECLARE 
	present TEXT;
BEGIN
	present := NULL;
	present := (SELECT patient_id FROM patients WHERE patient_id = p_id );
	CASE WHEN present IS NOT NULL
	THEN
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END CASE;
END;
$$ LANGUAGE plpgsql;

-- Have Appointment
CREATE FUNCTION have_appointment(d_id INT, p_id INT)
RETURNS INT AS $$
DECLARE 
    appointmentsCount INT;
BEGIN 
    appointmentsCount := (SELECT COUNT(appointment_id) 
                          FROM appointments 
                          WHERE patient_id = p_id AND doctor_id = d_id);
    
    RETURN appointmentsCount;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TYPE APT_Patients_Records AS (
    appointment_id INT,
	disease VARCHAR(30),
    patient_id INT,
	patient_name VARCHAR(30),
	patient_age INT
);

CREATE TYPE APT_Doctors_Records AS (
    appointment_id INT,
	disease VARCHAR(30),
    doctor_id INT,
	doctor_name VARCHAR(30),
	specialization VARCHAR(30)
);

-- Showing appointment list for Doctor
CREATE FUNCTION ShowAppointments_Doctor(D_id INT)
RETURNS SETOF APT_Patients_Records AS $$
BEGIN
	    RETURN QUERY
	    SELECT A.appointment_id, A.disease, P.patient_id, P.patient_name, P.patient_age FROM appointments A 
		INNER JOIN patients P ON P.patient_id = A.patient_id 
		WHERE A.doctor_id = D_id; 
END;
$$ LANGUAGE plpgsql;

-- Showing appointment list for Patient
CREATE FUNCTION ShowAppointments_Patient(P_id INT)
RETURNS SETOF APT_Doctors_Records AS $$
BEGIN
	    RETURN QUERY
	    SELECT A.appointment_id, A.disease, D.doctor_id, D.doctor_name, D.specialization FROM appointments A 
		INNER JOIN doctors D ON D.doctor_id = A.doctor_id 
		WHERE A.patient_id = P_id; 
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM appointmentList(1, 'patient')
-- DROP FUNCTION appointmentList(person_id INT, person TEXT)

-- SELECT * FROM doctors
		SELECT create_Doctor('hari', 'dermatology')
		SELECT create_Doctor('Kumar', 'cardiology')
		SELECT create_Patient('sundar', 23)
		SELECT create_Appointment(1, 1, 'skin')  -- Doctor_id , Patient_id , disease
		SELECT create_Patient('murugan', 24)
		SELECT create_Appointment(1, 2, 'skin')
		SELECT doctor_present(1)
		SELECT patient_present(1)
		SELECT have_appointment(1,1)
SELECT appointment_id, disease, patient_name, patient_age, patient_id FROM ShowAppointments_Doctor(1) 
SELECT appointment_id, disease, specialization, doctor_name, doctor_id FROM ShowAppointments_Patient(1) 
