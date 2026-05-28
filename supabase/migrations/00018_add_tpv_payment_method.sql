-- Add 'tpv' (Terminal Punto de Venta) as a valid payment method enum value
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'tpv';
