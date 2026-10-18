-- CivicConnect
-- Initial Persistence Verification Data
-- Milestone 2

-- Create test users
INSERT INTO users (name, email, role)
VALUES
    ('Test Requester', 'requester@civicconnect.test', 'Requester'),
    ('Test Staff', 'staff@civicconnect.test', 'Staff');

-- Create a controlled service category
INSERT INTO categories (name, description)
VALUES
    ('Road Maintenance', 'Requests relating to road maintenance.');

-- Create a service request
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
    'Pothole on Main Road',
    'Large pothole requiring maintenance.',
    'Submitted'
);

-- Assign the request to a staff member
INSERT INTO assignments (
    request_id,
    staff_id
)
VALUES (
    1,
    2
);

-- Record the initial request status
INSERT INTO status_history (
    request_id,
    changed_by,
    previous_status,
    new_status
)
VALUES (
    1,
    1,
    'New',
    'Submitted'
);

-- Verify persisted CivicConnect data
SELECT
    sr.request_id,
    sr.title,
    sr.current_status,
    sr.version,
    u.name AS requester,
    c.name AS category
FROM service_requests sr
JOIN users u
    ON sr.requester_id = u.user_id
JOIN categories c
    ON sr.category_id = c.category_id;