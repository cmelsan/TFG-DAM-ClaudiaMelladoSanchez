-- Añade política UPDATE para que los admins puedan hacer upsert de imágenes
-- en el bucket dish-images (necesario cuando la imagen ya existe y upsert=true)

CREATE POLICY "Admin actualiza imágenes de platos"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'dish-images' AND (SELECT get_my_role()) = 'admin')
  WITH CHECK (bucket_id = 'dish-images' AND (SELECT get_my_role()) = 'admin');
