BEGIN;

DROP POLICY IF EXISTS
"Usuário lê seus próprios governantes"
ON public.cidades;

CREATE POLICY
"Usuário lê cidades visíveis no mapa"
ON public.cidades
FOR SELECT
TO authenticated
USING (
    auth.uid() = user_id
    OR tipo_entidade IN ('reino', 'npc')
);

COMMIT;