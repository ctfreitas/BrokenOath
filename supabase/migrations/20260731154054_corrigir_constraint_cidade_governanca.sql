BEGIN;

ALTER TABLE public.cidade_governanca
DROP CONSTRAINT IF EXISTS cidade_governanca_governante_valido;

ALTER TABLE public.cidade_governanca
ADD CONSTRAINT cidade_governanca_governante_valido
CHECK (
    (
        tipo_governante = 'jogador'
        AND governante_user_id IS NOT NULL
        AND nome_governante IS NOT NULL
    )
    OR
    (
        tipo_governante = 'npc'
        AND governante_user_id IS NULL
        AND nome_governante IS NOT NULL
    )
);

COMMIT;