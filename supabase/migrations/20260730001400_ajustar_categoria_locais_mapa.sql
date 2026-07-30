BEGIN;

-- Atualiza o local do Reino existente
UPDATE public.locais_mapa
SET
    codigo_local = 'REINO_01',
    categoria = 'real'
WHERE mapa_id = 5;

-- Categoria obrigatória
ALTER TABLE public.locais_mapa
ALTER COLUMN categoria SET NOT NULL;

-- Restringe os valores permitidos
ALTER TABLE public.locais_mapa
ADD CONSTRAINT chk_local_categoria
CHECK (
    categoria IN (
        'real',
        'mercantil',
        'pacificadora',
        'conquistadora'
    )
);

COMMIT;