-- ===========================================================
-- Ajusta a modelagem de suserania entre cidades
-- ===========================================================

-- 1. Adiciona a cidade suserana.
ALTER TABLE public.cidade_subordinacao
    ADD COLUMN suserano_cidade_id bigint;

-- 2. Cria a chave estrangeira.
ALTER TABLE public.cidade_subordinacao
    ADD CONSTRAINT fk_subordinacao_suserano_cidade
    FOREIGN KEY (suserano_cidade_id)
    REFERENCES public.cidades(id);

-- 3. A Cidade Real passa a apontar para si mesma.
UPDATE public.cidade_subordinacao cs
SET suserano_cidade_id = 1
WHERE tipo_suserano = 'reino';

-- 4. Garante que cidades subordinadas ao Reino sempre tenham
-- uma cidade suserana definida.
ALTER TABLE public.cidade_subordinacao
    ADD CONSTRAINT chk_reino_possui_cidade
    CHECK (
        tipo_suserano <> 'reino'
        OR suserano_cidade_id IS NOT NULL
    );