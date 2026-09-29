-- CivicConnect
-- Transaction and Atomicity Verification
-- Milestone 2

-- =========================================================
-- TEST 1: SUCCESSFUL ATOMIC STATUS TRANSITION
-- Both operations should succeed and be committed.
-- =========================================================

BEGIN;

UPDATE service_requests
SET
    current_status = 'In Progress',
    updated_at = CURRENT_TIMESTAMP,
    version = version + 1
WHERE request_id = 1;

INSERT INTO status_history (
    request_id,
    changed_by,
    previous_status,
    new_status
)
VALUES (
    1,
    2,
    'Submitted',
    'In Progress'
);

COMMIT;

-- Verify successful transaction
SELECT
    request_id,
    current_status,
    version
FROM service_requests
WHERE request_id = 1;

SELECT
    status_history_id,
    request_id,
    previous_status,
    new_status,
    changed_by
FROM status_history
WHERE request_id = 1
ORDER BY status_history_id;

-- =========================================================
-- TEST 2: FAILED TRANSACTION AND ROLLBACK
-- The status update should NOT persist if the
-- StatusHistory insert fails.
-- =========================================================

BEGIN;

-- Attempt to move the request to Resolved
UPDATE service_requests
SET
    current_status = 'Resolved',
    updated_at = CURRENT_TIMESTAMP,
    version = version + 1
WHERE request_id = 1;

-- Deliberately invalid changed_by value.
-- No user with this ID exists, so the foreign key
-- constraint should cause this operation to fail.
INSERT INTO status_history (
    request_id,
    changed_by,
    previous_status,
    new_status
)
VALUES (
    1,
    999999,
    'In Progress',
    'Resolved'
);

ROLLBACK;