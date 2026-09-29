-- CivicConnect
-- Optimistic Concurrency Verification
-- Milestone 2

-- Starting state:
-- Request #1 = In Progress, Version 2
-- Staff A and Staff B both read Version 2.

-- TEST 1: STAFF A SAVES FIRST
UPDATE service_requests
SET
    current_status = 'Under Review',
    updated_at = CURRENT_TIMESTAMP,
    version = version + 1
WHERE request_id = 1
  AND version = 2;

-- Verify Staff A's update
SELECT
    request_id,
    current_status,
    version
FROM service_requests
WHERE request_id = 1;


-- TEST 2: STAFF B ATTEMPTS A STALE UPDATE
-- Staff B still believes the request is Version 2.

UPDATE service_requests
SET
    current_status = 'Resolved',
    updated_at = CURRENT_TIMESTAMP,
    version = version + 1
WHERE request_id = 1
  AND version = 2;

-- Verify that Staff B did not overwrite Staff A's update
SELECT
    request_id,
    current_status,
    version
FROM service_requests
WHERE request_id = 1;