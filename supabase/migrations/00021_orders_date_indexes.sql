-- ============================================================
-- Migration 00021: Índices de rendimiento para consultas por fecha en pedidos
-- ============================================================
-- Mejora las queries de filtrado por fecha (Hoy / Semana / Histórico)
-- en las vistas de admin, cocina, reparto y mostrador.

-- Índice principal para consultas por fecha de creación (vista Hoy/Semana admin)
CREATE INDEX IF NOT EXISTS idx_orders_created_at
  ON public.orders(created_at DESC);

-- Índice para encargos con fecha programada
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_at
  ON public.orders(scheduled_at ASC NULLS LAST);

-- Índice compuesto type+status: usado por cocina, reparto y mostrador
CREATE INDEX IF NOT EXISTS idx_orders_type_status
  ON public.orders(order_type, status);

-- Índice solo status: usado en filtros de admin
CREATE INDEX IF NOT EXISTS idx_orders_status
  ON public.orders(status);

-- Índice compuesto para queries de "pedidos hoy por tipo"
-- Permite resolver created_at >= X AND order_type = Y eficientemente
CREATE INDEX IF NOT EXISTS idx_orders_type_created
  ON public.orders(order_type, created_at DESC);
