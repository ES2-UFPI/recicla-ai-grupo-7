-- name: CreateUser :one
INSERT INTO users (name, email, password_hash, phone, role)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, name, email, phone, role, created_at;

-- name: GetUserByEmail :one
SELECT id, name, email, password_hash, role, is_active
FROM users
WHERE email = $1;

-- name: GetUserByID :one
SELECT id, name, email, phone, role, created_at
FROM users
WHERE id = $1;

-- name: CreateAuthToken :one
INSERT INTO auth_tokens (user_id, token_hash, expires_at)
VALUES ($1, $2, $3)
RETURNING id, user_id, token_hash, expires_at, revoked;

-- name: GetValidAuthToken :one
SELECT id, user_id, token_hash, expires_at, revoked
FROM auth_tokens
WHERE token_hash = $1
AND revoked = FALSE
AND expires_at > NOW();

-- name: RevokeAuthToken :exec
UPDATE auth_tokens
SET revoked = TRUE
WHERE id = $1;

-- name: CreateMaterial :one
INSERT INTO recyclable_materials (name, description)
VALUES ($1, $2)
RETURNING id, name, description;

-- name: ListMaterials :many
SELECT id, name, description
FROM recyclable_materials;

-- name: CreatePickupRequest :one
INSERT INTO pickup_requests (producer_id, address_id, scheduled_time, status)
VALUES ($1, $2, $3, 'PENDENTE')
RETURNING id, producer_id, address_id, scheduled_time, status, created_at;

-- name: ListPickupRequestsByProducer :many
SELECT id, producer_id, address_id, scheduled_time, status, created_at
FROM pickup_requests
WHERE producer_id = $1
ORDER BY created_at DESC;

-- name: AddPickupRequestItem :exec
INSERT INTO pickup_request_items (request_id, material_id, weight_kg, quantity)
VALUES ($1, $2, $3, $4);

-- name: ListItemsByPickupRequest :many
SELECT pri.id, pri.material_id, rm.name AS material_name, pri.weight_kg, pri.quantity
FROM pickup_request_items pri
JOIN recyclable_materials rm ON rm.id = pri.material_id
WHERE pri.request_id = $1;

-- name: CreateCollection :one
INSERT INTO collections (request_id, collector_id, collected_at, destination_cooperative_id)
VALUES ($1, $2, NOW(), $3)
RETURNING id, request_id, collector_id, collected_at, destination_cooperative_id;

-- name: SetCollectionDelivered :exec
UPDATE collections
SET delivered_at = NOW()
WHERE id = $1;


-- name: CreateReward :exec
INSERT INTO rewards (user_id, collection_id, amount)
VALUES ($1, $2, $3);

-- name: ListRewardsByUser :many
SELECT id, user_id, collection_id, amount, created_at
FROM rewards
WHERE user_id = $1;

