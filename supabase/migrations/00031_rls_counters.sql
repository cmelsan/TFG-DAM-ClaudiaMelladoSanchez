-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00031 · RLS en tablas de contadores internos
-- order_type_counters y catering_counters son tablas de uso interno
-- accedidas exclusivamente por funciones SECURITY DEFINER.
-- Se habilita RLS sin políticas de acceso directo para usuarios.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE order_type_counters ENABLE ROW LEVEL SECURITY;
ALTER TABLE catering_counters   ENABLE ROW LEVEL SECURITY;

-- Solo el admin puede consultar/gestionar los contadores directamente
CREATE POLICY "Admin ve contadores de pedido"
  ON order_type_counters FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin gestiona contadores de pedido"
  ON order_type_counters FOR ALL
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin ve contadores de catering"
  ON catering_counters FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin gestiona contadores de catering"
  ON catering_counters FOR ALL
  USING (get_my_role() = 'admin');
