INSERT INTO assets (name, unit_value)
VALUES
    ('Bitcoin', 30000.0),
    ('Ethereum', 2000.0),
    ('Dólar', 1.0),
    ('Real', 0.20)
ON CONFLICT (name)
DO UPDATE SET unit_value = EXCLUDED.unit_value;
