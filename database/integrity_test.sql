-- TEST 1: FOREIGN KEY INTEGRITY
-- Attempt to create a service request for a requester
-- that does not exist.

INSERT INTO service_requests (
    requester_id,
    category_id,
    title,
    description,
    current_status
)
VALUES (
    999999,
    1,
    'Invalid Request Test',
    'This record should be rejected by the database.',
    'Submitted'
);

-- TEST 2: REQUIRED DATA INTEGRITY
-- A service request cannot be created without a title.

INSERT INTO service_requests (
    requester_id,
    category_id,
    title,
    description,
    current_status
)
VALUES (
    1,
    1,
    NULL,
    'Testing rejection of missing required data.',
    'Submitted'
);

-- TEST 3: UNIQUE CONSTRAINT
-- Attempt to create another user
-- with an existing email address.

INSERT INTO users (
    name,
    email,
    role
)
VALUES (
    'Duplicate Test User',
    'requester@civicconnect.test',
    'Requester'
);