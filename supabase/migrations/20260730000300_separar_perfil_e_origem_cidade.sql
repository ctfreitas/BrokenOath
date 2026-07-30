-- ===========================================================
-- Separa perfil da cidade da origem da cidade
-- ===========================================================

-- 1. Ajusta possíveis dados antigos.
UPDATE public.cidades
SET perfil_cidade = 'real'
WHERE tipo_entidade = 'reino'
  AND perfil_cidade IS DISTINCT FROM 'real';


-- 2. Remove o DEFAULT incorreto.
ALTER TABLE public.cidades
    ALTER COLUMN perfil_cidade DROP DEFAULT;


-- 3. Remove o CHECK antigo.
ALTER TABLE public.cidades
    DROP CONSTRAINT IF EXISTS chk_tipo_cidade;


-- 4. Cria o novo CHECK.
ALTER TABLE public.cidades
    ADD CONSTRAINT chk_tipo_cidade
    CHECK (
        perfil_cidade IN (
            'mercantil',
            'conquistadora',
            'pacificadora',
            'real'
        )
    );


-- 5. Cria a origem da cidade.
ALTER TABLE public.cidades
    ADD COLUMN origem_cidade varchar(20);


-- 6. Preenche as cidades existentes.
UPDATE public.cidades
SET origem_cidade =
CASE
    WHEN tipo_entidade = 'reino' THEN 'reino'
    WHEN tipo_entidade = 'jogador' AND user_id IS NOT NULL THEN 'fundada'
    ELSE 'npc'
END;


-- 7. Torna obrigatório.
ALTER TABLE public.cidades
    ALTER COLUMN origem_cidade SET NOT NULL;


-- 8. Restringe os valores.
ALTER TABLE public.cidades
    ADD CONSTRAINT chk_origem_cidade
    CHECK (
        origem_cidade IN (
            'fundada',
            'npc',
            'reino'
        )
    );


-- 9. Remove o perfil duplicado do mapa.
ALTER TABLE public.locais_mapa
    DROP CONSTRAINT IF EXISTS chk_local_perfil_cidade;

ALTER TABLE public.locais_mapa
    DROP COLUMN IF EXISTS perfil_cidade;