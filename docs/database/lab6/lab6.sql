--IT108 LABORATORY ACTIVITY 6
-- Maternal Health Monitoring and notification with machine learning for prenatal and postnatal care
SET search_path TO monitoring, public;

--DATA INTEGRITY CONSTRAINTS
ALTER TABLE monitoring.health_records
  ADD CONSTRAINT uq_mother_visit_date UNIQUE (mother_id, visit_date);

--THE TRANSACTION (Implementation)
BEGIN;

-- Lock the Mother's row
SELECT mother_id FROM monitoring.mothers WHERE mother_id = 101 FOR UPDATE;

-- Insert Health Record
INSERT INTO monitoring.health_records 
  (mother_id, bhw_id, blood_pressure, notes)
VALUES 
  (101, 101, '150/95', 'High BP detected - Lab 6 test');

-- Insert ML Prediction
INSERT INTO monitoring.ml_predictions 
  (mother_id, record_id, risk_level, confidence_score)
VALUES 
  (101, (SELECT record_id FROM monitoring.health_records WHERE notes = 'High BP detected - Lab 6 test' LIMIT 1), 'High', 95.50);

-- Update Mother Risk
UPDATE monitoring.mothers 
SET risk_level = 'High' 
WHERE mother_id = 101;

COMMIT;

-- Verify
SELECT * FROM monitoring.health_records WHERE notes = 'High BP detected - Lab 6 test';

--TESTING DATA INTEGRITY (Constraint Violation)

DELETE FROM monitoring.health_records WHERE notes LIKE 'Duplicate Test%';

INSERT INTO monitoring.health_records 
  (mother_id, bhw_id, blood_pressure, notes, visit_date) 
VALUES 
  (101, 101, '120/80', 'Duplicate Test 1', '2026-10-19 12:00:00');

INSERT INTO monitoring.health_records 
  (mother_id, bhw_id, blood_pressure, notes, visit_date) 
VALUES 
  (101, 101, '120/80', 'Duplicate Test 2', '2026-10-19 12:00:00');


-- Session A: 
-- BEGIN;
-- SELECT mother_id FROM monitoring.mothers WHERE mother_id = 101 FOR UPDATE;

-- Session B:
-- BEGIN;
-- SELECT mother_id FROM monitoring.mothers WHERE mother_id = 101 FOR UPDATE;

-- Session A:
-- COMMIT; (or ROLLBACK for Part H)

-- Session B:
-- COMMIT;
