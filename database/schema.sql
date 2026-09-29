-- CivicConnect
-- Initial PostgreSQL Persistence Schema
-- Milestone 2

CREATE TABLE users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE service_requests (
    request_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    requester_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    current_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Used for optimistic concurrency control
    version INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT fk_service_request_requester
        FOREIGN KEY (requester_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_service_request_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE assignments (
    assignment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_assignment_request
        FOREIGN KEY (request_id)
        REFERENCES service_requests(request_id),

    CONSTRAINT fk_assignment_staff
        FOREIGN KEY (staff_id)
        REFERENCES users(user_id)
);

CREATE TABLE status_history (
    status_history_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id INTEGER NOT NULL,
    changed_by INTEGER NOT NULL,
    previous_status VARCHAR(50) NOT NULL,
    new_status VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_status_history_request
        FOREIGN KEY (request_id)
        REFERENCES service_requests(request_id),

    CONSTRAINT fk_status_history_user
        FOREIGN KEY (changed_by)
        REFERENCES users(user_id)
);

CREATE TABLE request_actions (
    action_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    details TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_request_action_request
        FOREIGN KEY (request_id)
        REFERENCES service_requests(request_id),

    CONSTRAINT fk_request_action_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

CREATE TABLE resolutions (
    resolution_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id INTEGER NOT NULL UNIQUE,
    resolved_by INTEGER NOT NULL,
    details TEXT NOT NULL,
    resolved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resolution_request
        FOREIGN KEY (request_id)
        REFERENCES service_requests(request_id),

    CONSTRAINT fk_resolution_user
        FOREIGN KEY (resolved_by)
        REFERENCES users(user_id)
);