ALTER TABLE public.locais_mapa
ADD COLUMN codigo_local text;

ALTER TABLE public.locais_mapa
ADD COLUMN local_vinculado_id bigint;

ALTER TABLE public.locais_mapa
ADD CONSTRAINT fk_locais_vinculado
FOREIGN KEY (local_vinculado_id)
REFERENCES public.locais_mapa(id);

ALTER TABLE public.locais_mapa
ADD CONSTRAINT uq_locais_mapa_codigo
UNIQUE (mapa_id, codigo_local);