-- Confirma que toda cidade possui uma governança ativa antes da remoção.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.cidades c
        WHERE NOT EXISTS (
            SELECT 1
            FROM public.cidade_governanca cg
            WHERE cg.cidade_id = c.id
              AND cg.ativo = true
        )
    ) THEN
        RAISE EXCEPTION
            'Existem cidades sem governança ativa. Migração cancelada.';
    END IF;
END
$$;


-- Remove os dados de governança duplicados.
ALTER TABLE public.cidades
    DROP COLUMN nome_governante,
    DROP COLUMN titulo_governante,
    DROP COLUMN nivel_governante;