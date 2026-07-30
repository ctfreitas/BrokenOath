BEGIN;

ALTER TABLE public.locais_mapa
ADD COLUMN categoria varchar(30);

COMMIT;