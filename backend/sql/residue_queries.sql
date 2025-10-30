-- name: create_residue :one
INSERT INTO residue (
    type,
    kg
) VALUES (
    $1, 
    $2
) RETURNING 
    id, 
    type, 
    kg, 
    created_at;