CREATE TABLE IF NOT EXISTS residue (
    id SERIAL PRIMARY KEY,
    type SMALLINT NOT NULL, -- 0: PAPER, 1: PLASTIC, 2: GLASS, 3: METAL
    kg DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('PRODUTOR', 'COLETOR', 'COOPERATIVA', 'ADMIN')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE auth_tokens (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,             -- nunca armazenar token puro
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    street VARCHAR(150),
    number VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(50),
    zipcode VARCHAR(15),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

CREATE TABLE recyclable_materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,  -- plástico, papel, vidro, etc.
    description TEXT
);

CREATE TABLE pickup_requests (
    id SERIAL PRIMARY KEY,
    producer_id INT REFERENCES users(id),
    address_id INT REFERENCES addresses(id),
    scheduled_time TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('PENDENTE', 'ACEITA', 'COLETADA', 'ENTREGUE', 'CANCELADA')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE pickup_request_items (
    id SERIAL PRIMARY KEY,
    request_id INT REFERENCES pickup_requests(id) ON DELETE CASCADE,
    material_id INT REFERENCES recyclable_materials(id),
    weight_kg DECIMAL(10,2) DEFAULT 0,
    quantity INT DEFAULT 1
);

CREATE TABLE collections (
    id SERIAL PRIMARY KEY,
    request_id INT REFERENCES pickup_requests(id),
    collector_id INT REFERENCES users(id),
    collected_at TIMESTAMP,
    delivered_at TIMESTAMP,
    destination_cooperative_id INT REFERENCES users(id)  -- cooperativa
);

CREATE TABLE rewards (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),        -- pode ser produtor ou coletor
    collection_id INT REFERENCES collections(id),
    amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wallet (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    balance DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE wallet_transactions (
    id SERIAL PRIMARY KEY,
    wallet_id INT REFERENCES wallet(id),
    amount DECIMAL(10,2),
    type VARCHAR(20) CHECK (type IN ('CREDITO', 'DEBITO')),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    reviewer_id INT REFERENCES users(id),
    reviewed_user_id INT REFERENCES users(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
