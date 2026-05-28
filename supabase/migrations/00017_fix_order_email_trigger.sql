-- ============================================================
-- SABOR DE CASA — Corregir triggers de email para pedidos
-- ============================================================
-- Problema: el trigger on_new_order_email disparaba la Edge
-- Function ANTES de insertar los order_items, generando emails
-- con la lista de productos vacía.
--
-- Solución: eliminar el trigger INSERT (el email de confirmación
-- ya lo gestiona la llamada desde Flutter después de insertar
-- los items, evitando la race condition).
-- El trigger UPDATE se mantiene para notificar cambios de estado.
-- ============================================================

-- Eliminar trigger de nuevo pedido (lo gestiona el cliente Dart)
DROP TRIGGER IF EXISTS on_new_order_email ON public.orders;
